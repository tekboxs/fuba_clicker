import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppLoadingDialog extends StatelessWidget {
  final String? message;

  const AppLoadingDialog({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  static Future<void> show(BuildContext context, {String? message}) async {
    return await showDialog<void>(
      context: context,
      barrierColor: const Color.fromARGB(129, 0, 0, 0),
      barrierDismissible: kDebugMode,
      builder: (_) => AppLoadingDialog(message: message),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
