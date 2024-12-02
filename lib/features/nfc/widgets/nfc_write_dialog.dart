import 'package:flutter/material.dart';
import '../services/nfc_service.dart';

class NFCWriteDialog extends StatefulWidget {
  final String url;
  final VoidCallback? onWriteComplete;

  const NFCWriteDialog({
    Key? key,
    required this.url,
    this.onWriteComplete,
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
    if (!_success) {
      NFCService.stopNFCSession();
    }
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
      await NFCService.writeUrl(
        widget.url,
        onSuccessWrite: () {
          if (mounted) {
            setState(() {
              _success = true;
              _isWriting = false;
            });
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isWriting = false;
      });
    }
  }

  void _handleClose() {
    if (_success) {
      NFCService.stopNFCSession(); // Stop NFC session to allow system to handle tag
      widget.onWriteComplete?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully wrote to NFC tag. You can now tap the tag to open the URL.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      NFCService.stopNFCSession();
    }
    
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleClose();
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
              ] else if (_success) ...[
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Successfully wrote to NFC tag!',
                  style: TextStyle(color: Colors.green),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Click OK to enable reading the tag',
                  style: TextStyle(fontSize: 12),
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
          if (_isWriting)
            TextButton(
              onPressed: () {
                NFCService.stopNFCSession();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            )
          else if (_success)
            TextButton(
              onPressed: _handleClose,
              child: const Text('OK'),
            )
          else ...[
            TextButton(
              onPressed: () {
                NFCService.stopNFCSession();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            if (_errorMessage != null)
              ElevatedButton(
                onPressed: _startNFCWrite,
                child: const Text('Try Again'),
              ),
          ],
        ],
      ),
    );
  }
}