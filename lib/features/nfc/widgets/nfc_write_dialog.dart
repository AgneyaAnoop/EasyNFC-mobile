// lib/features/nfc/widgets/nfc_write_dialog.dart
import 'package:flutter/material.dart';
import '../services/nfc_service.dart';

class NFCWriteDialog extends StatefulWidget {
  final String url;

  const NFCWriteDialog({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<NFCWriteDialog> createState() => _NFCWriteDialogState();
}

class _NFCWriteDialogState extends State<NFCWriteDialog> {
  bool _isWriting = false;
  String? _errorMessage;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _startNFCWrite();
  }

  @override
  void dispose() {
    NFCService.stopNFCSession();
    super.dispose();
  }

  Future<void> _startNFCWrite() async {
    if (_isWriting) return;

    setState(() {
      _isWriting = true;
      _errorMessage = null;
      _success = false;
    });

    try {
      final success = await NFCService.writeUrl(widget.url);
      
      if (!mounted) return;
      setState(() {
        _success = success;
        _isWriting = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully wrote to NFC tag'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isWriting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isWriting) {
          NFCService.stopNFCSession();
        }
        return true;
      },
      child: AlertDialog(
        title: Text(_success ? 'Success!' : 'Write to NFC Tag'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isWriting) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Hold your phone near the NFC tag',
                  textAlign: TextAlign.center,
                ),
              ] else if (_errorMessage != null) ...[
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: $_errorMessage',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'URL to write: ${widget.url}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              NFCService.stopNFCSession();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          if (!_isWriting && _errorMessage != null)
            ElevatedButton(
              onPressed: _startNFCWrite,
              child: const Text('Try Again'),
            ),
        ],
      ),
    );
  }
}