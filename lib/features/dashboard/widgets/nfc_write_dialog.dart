import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCWriteDialog extends StatefulWidget {
  final String url;

  const NFCWriteDialog({Key? key, required this.url}) : super(key: key);

  @override
  State<NFCWriteDialog> createState() => _NFCWriteDialogState();
}

class _NFCWriteDialogState extends State<NFCWriteDialog> {
  bool _isWriting = false;

  Future<void> _writeNfc() async {
    setState(() => _isWriting = true);

    try {
      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        var ndef = Ndef.from(tag);
        if (ndef == null) {
          throw 'Tag is not NDEF compatible';
        }

        if (!ndef.isWritable) {
          throw 'Tag is not writable';
        }

        NdefMessage message = NdefMessage([
          NdefRecord.createUri(Uri.parse(widget.url)),
        ]);

        try {
          await ndef.write(message);
          if (!mounted) return;
          Navigator.pop(context, true);
        } catch (e) {
          if (!mounted) return;
          throw 'Failed to write to tag: $e';
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isWriting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Write to NFC Tag'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isWriting)
            const CircularProgressIndicator()
          else
            const Text('Hold your phone near the NFC tag'),
          const SizedBox(height: 16),
          Text('URL to write: ${widget.url}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isWriting ? null : _writeNfc,
          child: const Text('Write'),
        ),
      ],
    );
  }
}