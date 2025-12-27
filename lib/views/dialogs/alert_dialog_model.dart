import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

@immutable
class AlertDialogModel<T> {
  final String title;
  final String message;
  final Map<String, T> buttons;
  final Map<String, TextStyle>? buttonTextStyles; // optional styles per button label

  const AlertDialogModel({
    required this.title,
    required this.message,
    required this.buttons,
    this.buttonTextStyles,
  });
}

extension Present<T> on AlertDialogModel<T> {
  Future<T?> present(BuildContext context) {
    return showDialog<T?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: buttons.entries.map(
                (entry) {
              final textStyle = buttonTextStyles == null ? null : buttonTextStyles![entry.key];
              return TextButton(
                child: Text(
                  entry.key,
                  style: textStyle,
                ),
                onPressed: () {
                  context.pop(entry.value);
                },
              );
            },
          ).toList(),
        );
      },
    );
  }
}