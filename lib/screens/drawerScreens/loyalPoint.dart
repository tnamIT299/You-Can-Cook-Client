import 'package:flutter/material.dart';
import 'package:you_can_cook/screens/Main/main_tab/ranked_tab.dart';

class LoyaltyPointsScreen extends StatelessWidget {
  LoyaltyPointsScreen({super.key});

  // Dữ liệu giả cho người dùng
  final Map<String, dynamic> user = {"name": "Sanita Queen", "points": 509};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5), // Màu nền hồng nhạt giống hình
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Điểm Đóng Góp",
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Biểu tượng huy hiệu
            Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.workspace_premium,
                  size: 200,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tên người dùng
            Text(
              user["name"],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            // Số điểm
            Text(
              "${user["points"]} Points",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            // Thông tin chuyển đổi điểm
            // const Text(
            //   "Convert Points to Purchase Voucher Code..",
            //   style: TextStyle(fontSize: 16, color: Colors.grey),
            // ),
            const SizedBox(height: 8),
            // const Text(
            //   "You need to 1000 points to get 1000 OFF your order to get more points.",
            //   textAlign: TextAlign.center,
            //   style: TextStyle(fontSize: 14, color: Colors.grey),
            // ),
            const SizedBox(height: 24),
            // Nút Convert
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Ranked_Tab()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Đến kho huy hiệu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
