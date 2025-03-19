import 'package:flutter/material.dart';
import 'package:you_can_cook/services/AuthService.dart';
import 'package:you_can_cook/screens/Auth/login.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  // Dữ liệu giả cho các mục cài đặt
  final List<Map<String, dynamic>> settingsItems = [
    {
      "title": "Chỉnh sửa trang cá nhân",
      "icon": Icons.edit,
      "trailing": Icons.chevron_right,
    },
    {
      "title": "Ngôn ngữ",
      "icon": Icons.language,
      "trailing": Icons.chevron_right,
      "subItems": ["Tiếng Việt", "Tiếng Anh"],
    },
    {
      "title": "Đang theo dõi",
      "icon": Icons.groups,
      "trailing": Icons.chevron_right,
      "subItems": null,
    },
    {
      "title": "Người theo dõi",
      "icon": Icons.people,
      "trailing": Icons.chevron_right,
      "subItems": null,
    },
    {
      "title": "Thông báo",
      "icon": Icons.notifications,
      "trailing": false,
      "subItems": null,
    },
    {
      "title": "Tài khoản & Chính sách",
      "icon": Icons.security,
      "trailing": Icons.chevron_right,
      "subItems": null,
    },
    {
      "title": "Chủ đề",
      "icon": Icons.brightness_6,
      "trailing": Icons.chevron_right,
      "subItems": ["Tối", "Sáng", "Hệ thống"],
    },
    {
      "title": "Trợ giúp",
      "icon": Icons.help,
      "trailing": Icons.chevron_right,
      "subItems": null,
    },
    {
      "title": "Về chúng tôi",
      "icon": Icons.info,
      "trailing": Icons.chevron_right,
      "subItems": null,
    },
    {
      "title": "Đăng xuất",
      "icon": Icons.logout,
      "trailing": null,
      "subItems": null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFEEA734),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Cài đặt",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Container(
            height: 70,
            color: const Color(0xFFEEA734),
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Tìm kiếm",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const Icon(Icons.mic, color: Colors.black),
                ],
              ),
            ),
          ),
          // Danh sách các mục cài đặt
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: settingsItems.length,
              itemBuilder: (context, index) {
                final item = settingsItems[index];
                return ListTile(
                  leading: Icon(item["icon"], color: Colors.grey),
                  title: Text(
                    item["title"],
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing:
                      item["trailing"] is bool
                          ? Switch(
                            value: item["trailing"],
                            onChanged: (value) {},
                            activeColor: const Color(0xFFEEA734),
                          )
                          : item["trailing"] is String
                          ? Text(
                            item["trailing"],
                            style: const TextStyle(color: Color(0xFFEEA734)),
                          )
                          : Icon(item["trailing"], color: Colors.grey),
                  onTap: () {
                    if (item["title"] == "Chủ đề") {
                      _showSubMenu(context, item["title"], item["subItems"]);
                    }
                    if (item["title"] == "Đăng xuất") {
                      final authService = AuthService();
                      authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }
                    if (item["title"] == "Ngôn ngữ") {
                      _showSubMenu(context, item["title"], item["subItems"]);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Hàm hiển thị menu con (dành cho Theme)
  void _showSubMenu(
    BuildContext context,
    String title,
    List<String>? subItems,
  ) {
    if (subItems == null) return;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: subItems.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(subItems[index]),
              onTap: () {
                Navigator.pop(context);
                // Xử lý logic khi chọn theme
              },
            );
          },
        );
      },
    );
  }
}
