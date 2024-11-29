// lib/features/nfc/services/nfc_service.dart
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:typed_data';

class NFCService {
  static Future<bool> isNFCAvailable() async {
    return await NfcManager.instance.isAvailable();
  }

  static Future<bool> writeUrl(String url) async {
    try {
      bool success = false;
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          var ndef = Ndef.from(tag);
          if (ndef == null) {
            throw 'Tag is not NDEF compatible';
          }

          if (!ndef.isWritable) {
            throw 'Tag is not writable';
          }

          try {
            // Create URL Record
            var uriRecord = NdefRecord.createUri(Uri.parse(url));

            var message = NdefMessage([uriRecord]);
            await ndef.write(message);
            success = true;
            
            // Stop session after successful write
            await NfcManager.instance.stopSession();
          } catch (e) {
            success = false;
            await NfcManager.instance.stopSession(errorMessage: e.toString());
            rethrow;
          }
        },
        onError: (error) async {
          success = false;
          await NfcManager.instance.stopSession(errorMessage: error.message);
          throw error.message;
        },
      );
      return success;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> stopNFCSession() async {
    await NfcManager.instance.stopSession();
  }
}

