import 'package:flutter/material.dart';
import 'package:you_can_cook/models/Reel.dart';
import 'package:you_can_cook/services/ReelService.dart';
import 'package:you_can_cook/utils/color.dart';

class EditReelPrivacyScreen extends StatefulWidget {
  final Reel reel;

  const EditReelPrivacyScreen({super.key, required this.reel});

  @override
  State<EditReelPrivacyScreen> createState() => _EditReelPrivacyScreenState();
}

class _EditReelPrivacyScreenState extends State<EditReelPrivacyScreen> {
  String _selectedPrivacy = "Công khai"; // Giá trị mặc định
  final ReelService _reelService = ReelService();

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị radio button dựa trên reelRange hiện tại
    _selectedPrivacy = widget.reel.reelRange ?? "Công khai";
  }

  Future<void> _updatePrivacy() async {
    try {
      // Cập nhật reelRange trong Supabase
      await _reelService.updateReelPrivacy(
        widget.reel.reel_id!,
        _selectedPrivacy,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật quyền riêng tư thành công")),
      );
      Navigator.pop(context); // Quay lại màn hình trước
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi cập nhật quyền riêng tư: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primary,
        title: const Text(
          "Cài đặt quyền riêng tư",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _updatePrivacy,
            child: const Text(
              "Lưu",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chọn quyền riêng tư cho video:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            RadioListTile<String>(
              title: const Text("Công khai"),
              value: "Công khai",
              groupValue: _selectedPrivacy,
              onChanged: (value) {
                setState(() {
                  _selectedPrivacy = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text("Người theo dõi"),
              value: "Người theo dõi",
              groupValue: _selectedPrivacy,
              onChanged: (value) {
                setState(() {
                  _selectedPrivacy = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
