import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void kShowScaffoldSnackBar(
  BuildContext context,
  String message, {
  Color? color,
  int? seconds,
  bool tryOverlay = true,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: Duration(
        seconds: seconds ?? (message.length / 30).clamp(2, 5).round(),
      ),
      content: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: Row(
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.onPrimary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: color ?? Theme.of(context).colorScheme.error,
    ),
  );
}

Future<Result?> kShowConfirmationDialog<Result>({
  required BuildContext context,
  String? title,
  String? message,
  String? confirmText,
  String? cancelText,
  Result Function()? onConfirm,
  Result Function()? onCancel,
}) async {
  return await showDialog<Result>(
    context: context,
    barrierDismissible: true,
    builder: (context) => AlertDialog(
      title: title != null ? Text(title) : null,
      content: message != null ? Text(message) : null,
      actions: [
        TextButton(
          onPressed: () {
            final result = onCancel?.call();
            Navigator.of(context).pop(result);
          },
          child: Text(cancelText ?? 'Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final result = onConfirm?.call();
            Navigator.of(context).pop(result);
          },
          child: Text(confirmText ?? 'Confirmar'),
        ),
      ],
    ),
  );
}

void showErrorDialog(
  FlutterErrorDetails error, {
  String? title,
  String? message,
  String? customTitle,
  bool displayDefaultMessage = true,
}) {
  debugPrint('[ErrorDialog]>> ${error.exception}');
  debugPrint('[ErrorDialog]>> Stack: ${error.stack}');
}

Future<void> kShowLoadingDialog({
  required BuildContext context,
  Color? backgroundColor,
  EdgeInsets? insetPadding,
}) async {
  await showDialog<void>(
    context: context,
    barrierColor: const Color.fromARGB(129, 0, 0, 0),
    barrierDismissible: kDebugMode,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      backgroundColor:
          Theme.of(context).colorScheme.surface.withOpacity(0.92),
      insetPadding: insetPadding ?? const EdgeInsets.all(1),
      content: SizedBox(
        width: double.infinity,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    ),
  );
}
