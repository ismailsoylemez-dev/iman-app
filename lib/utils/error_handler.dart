import 'package:flutter/material.dart';
import 'app_exception.dart';

class ErrorHandler {
  ErrorHandler._();

  static Future<void> showError(BuildContext context, Exception error) async {
    final message = error is AppException ? error.message : error.toString();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void logError(Exception error, StackTrace? stackTrace) {
    debugPrint('Hata: $error');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
