import 'package:flutter/material.dart';

void showLoadingPopup(BuildContext context, String message) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [CircularProgressIndicator(), Text('    $message...')],
        ),
      ),
    ),
  );
}
