import 'dart:convert' show utf8;
import 'dart:typed_data' show Uint8List;
import 'dart:math' show min;
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart' show NfcA;

class NFCService {
  static Future<bool> isNFCAvailable() async {
    return await NfcManager.instance.isAvailable();
  }

  static Future<bool> writeUrl(String url, {Function? onSuccessWrite}) async {
    try {
      bool success = false;
      
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            // First try NDEF format
            var ndef = Ndef.from(tag);
            if (ndef != null) {
              success = await _writeNDEF(ndef, url);
            } 
            // Try Mifare Classic if NDEF fails
            else {
              // Get NfcA instance
              final nfcA = NfcA.from(tag);
              if (nfcA != null) {
                success = await _writeMifareClassic(nfcA, url);
              } else {
                throw 'Unsupported card type';
              }
            }

            if (success) {
              onSuccessWrite?.call();  // Call the success callback
            }
          } catch (e) {
            await NfcManager.instance.stopSession(errorMessage: e.toString());
            rethrow;
          }
        },
      );
      
      return success;
    } catch (e) {
      rethrow;
    }
  }

  // Write to NDEF compatible cards (like NTAG213)
  static Future<bool> _writeNDEF(Ndef ndef, String url) async {
    if (!ndef.isWritable) {
      throw 'Tag is not writable';
    }

    try {
      var uriRecord = NdefRecord.createUri(Uri.parse(url));
      var message = NdefMessage([uriRecord]);
      await ndef.write(message);
      return true;
    } catch (e) {
      throw 'Failed to write NDEF: ${e.toString()}';
    }
  }

  // Write to Mifare Classic 1K cards
  static Future<bool> _writeMifareClassic(NfcA nfcA, String url) async {
    try {
      final urlBytes = utf8.encode(url);
      
      // Authenticate sector 1
      await nfcA.transceive(
        data: Uint8List.fromList([
          0x60, // AUTH A
          0x01, // Sector 1
          0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF // Default key
        ]),
      );

      // Write data in 16-byte blocks
      int offset = 0;
      while (offset < urlBytes.length) {
        final blockData = Uint8List(16);
        final remaining = urlBytes.length - offset;
        final length = min(16, remaining);
        
        blockData.setAll(0, urlBytes.sublist(offset, offset + length));
        
        // Write command
        await nfcA.transceive(
          data: Uint8List.fromList([
            0xA0, // WRITE
            0x04 + (offset ~/ 16), // Block number (starting from block 4)
            ...blockData,
          ]),
        );
        
        offset += 16;
        if (offset >= 32) break; // Only use up to 2 blocks
      }
      
      return true;
    } catch (e) {
      throw 'Failed to write Mifare Classic: ${e.toString()}';
    }
  }

  static Future<void> stopNFCSession() async {
    await NfcManager.instance.stopSession();
  }
}