import 'package:flutter/material.dart';
import 'package:you_can_cook/utils/color.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Màu nền trắng
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hiển thị GIF loading
            Image.asset(
              'assets/images/loading.gif', // Đường dẫn đến file GIF
              width: 500, // Kích thước của GIF
              height: 500,
            ),
          ],
        ),
      ),
    );
  }
}
