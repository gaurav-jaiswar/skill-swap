import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' as ftoast;

class Toast {
  static void showToast({required String message, bool? isError}) {
    ftoast.Fluttertoast.showToast(
        msg: message,
        toastLength: isError != null && isError
            ? ftoast.Toast.LENGTH_LONG
            : ftoast.Toast.LENGTH_SHORT,
        gravity: ftoast.ToastGravity.BOTTOM,
        backgroundColor: isError != null
            ? isError
                ? Colors.red
                : Colors.green
            : Colors.blueGrey[100],
        textColor: isError != null && isError ? null : Colors.black,
        fontSize: 16.0);
  }
}
