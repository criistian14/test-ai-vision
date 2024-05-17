import 'package:flutter/material.dart';

class MessagesUtils {
  static void showSnackbar(
    BuildContext context, {
    required String message,
  }) {
    final colors = Theme.of(context).colorScheme;

    final snackBar = SnackBar(
      duration: const Duration(seconds: 20),
      backgroundColor: colors.primary,
      content: Text(message),
      action: SnackBarAction(
        label: 'close',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
