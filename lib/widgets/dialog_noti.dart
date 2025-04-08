import 'package:flutter/material.dart';
import 'package:you_can_cook/utils/color.dart';

void show_Dialog(
  BuildContext context,
  String title,
  String content,
  VoidCallback onOkPressed,
  VoidCallback onCancelPressed,
) {
  showDialog(
    context: context,
    barrierDismissible:
        false, // Không cho phép đóng dialog bằng cách nhấn ra ngoài
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng dialog
              onCancelPressed(); // Thực hiện hành động khi nhấn nút "OK"
            },
            child: Text('Huỷ', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng dialog
              onOkPressed(); // Thực hiện hành động khi nhấn nút "OK"
            },
            child: Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      );
    },
  );
}
