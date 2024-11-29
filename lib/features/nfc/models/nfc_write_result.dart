class NFCWriteResult {
  final bool success;
  final String? errorMessage;

  NFCWriteResult({
    required this.success,
    this.errorMessage,
  });
}