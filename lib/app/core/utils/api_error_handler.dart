import 'package:flutter/material.dart';
import '../../global_widgets/default_dialogs.dart';

class ApiErrorHandler {
  static void handleApiError({
    required String route,
    required dynamic error,
    required BuildContext context,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    String errorMessage = _extractErrorMessage(error);
    String routeDescription = _getRouteDescription(route);
    
    String finalMessage = customMessage ?? 'Erro ao $routeDescription. Erro: $errorMessage';
    
    debugPrint('[ApiErrorHandler]>> Rota: $route');
    debugPrint('[ApiErrorHandler]>> Erro: $error');
    debugPrint('[ApiErrorHandler]>> Mensagem: $finalMessage');
    
    _showErrorToUser(
      context: context,
      message: finalMessage,
      onRetry: onRetry,
    );
  }

  static String _extractErrorMessage(dynamic error) {
    if (error is Map<String, dynamic>) {
      return error['message'] ?? error['debugMessage'] ?? error.toString();
    }
    
    if (error is String) {
      return error;
    }
    
    return error.toString();
  }

  static String _getRouteDescription(String route) {
    final routeMap = {
      '/auth/login': 'autenticar usuário',
      '/auth/register': 'registrar usuário',
      '/user/': 'buscar dados do usuário',
      '/ranking/': 'buscar ranking',
    };

    for (final entry in routeMap.entries) {
      if (route.contains(entry.key)) {
        return entry.value;
      }
    }

    return 'executar operação na API';
  }

  static void _showErrorToUser({
    required BuildContext context,
    required String message,
    VoidCallback? onRetry,
  }) {
    kShowScaffoldSnackBar(
      context,
      message,
      color: Colors.redAccent,
      seconds: 5,
    );
  }

  static void handleApiErrorWithDialog({
    required String route,
    required dynamic error,
    required BuildContext context,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    String errorMessage = _extractErrorMessage(error);
    String routeDescription = _getRouteDescription(route);
    
    String finalMessage = customMessage ?? 'Erro ao $routeDescription. Erro: $errorMessage';
    
    debugPrint('[ApiErrorHandler]>> Rota: $route');
    debugPrint('[ApiErrorHandler]>> Erro: $error');
    debugPrint('[ApiErrorHandler]>> Mensagem: $finalMessage');
    
    showErrorDialog(
      FlutterErrorDetails(exception: finalMessage),
      title: 'Erro na API',
      displayDefaultMessage: false,
      message: finalMessage,
    );
  }
}
