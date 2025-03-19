import 'package:flutter/material.dart';

void show_Dialog(BuildContext context, String title, String content, VoidCallback onOkPressed) {
  showDialog(
    context: context,
    barrierDismissible: false, // Không cho phép đóng dialog bằng cách nhấn ra ngoài
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng dialog
              onOkPressed(); // Thực hiện hành động khi nhấn nút "OK"
            },
            child: Text(
              'OK',
              style: TextStyle(color: Color(0xFFEEA734)),
            ),
          ),
        ],
      );
    },
  );
}