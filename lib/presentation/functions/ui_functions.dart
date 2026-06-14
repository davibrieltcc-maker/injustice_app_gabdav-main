import 'package:flutter/material.dart';

import '../../core/failure/failure.dart';
import '../../core/messages/app_messages.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validators/base_validator.dart';
import '../../core/validators/text_field_validator.dart';

/// validacoes de campos de texto
String? validateField(String? value, List<BaseValidator> validators) {
  try {
    final isValid = TextFieldValidator(
      validators: validators,
    ).validations(value);

    if (!isValid) {
      return AppMessages.error.defaultError;
    }

    return null;
  } on Failure catch (e) {
    return e.msg;
  } catch (e) {
    return e.toString();
  }
}

/// Exibe um SnackBar com a mensagem fornecida e a cor de fundo especificada.
void showSnackBar(
  BuildContext context,
  String message, {
  required Color backgroundColor,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onError,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

/// SnackBar padronizado para fluxos de autenticação.
void showAuthSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  showSnackBar(
    context,
    message,
    backgroundColor: isError
        ? colorScheme.error
        : LightModeColors.lightPrimaryContainer,
  );
}

/// Exibe um diálogo de confirmação com título, mensagem
/// e opções de confirmação/cancelamento.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'CONFIRMAR',
  String cancelText = 'CANCELAR',
  IconData icon = Icons.warning_amber_rounded,
  Color? confirmColor,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final theme = Theme.of(context);

      return AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: confirmColor ?? theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
