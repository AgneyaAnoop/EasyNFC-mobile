
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final Color backgroundColor;
  final Color spinnerColor;
  final String? message;

  const LoadingOverlay({
    Key? key,
    this.backgroundColor = Colors.black54,
    this.spinnerColor = Colors.white,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: TextStyle(
                  color: spinnerColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}