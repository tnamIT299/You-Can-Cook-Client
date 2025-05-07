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
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(overflow: TextOverflow.ellipsis),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onCancelPressed();
            },
            child: Text('Huỷ', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onOkPressed();
            },
            child: Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      );
    },
  );
}
