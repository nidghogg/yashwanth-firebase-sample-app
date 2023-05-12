import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String? msg, String? body) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: ListTile(
            title: Text(msg ?? ""),
                subtitle: Text(body ?? ""),
        ),
        backgroundColor: Colors.blue.withOpacity(.8),
        behavior: SnackBarBehavior.floating));
  }
}