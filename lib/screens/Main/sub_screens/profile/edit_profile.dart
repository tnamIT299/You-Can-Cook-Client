import 'package:flutter/material.dart';
import 'package:you_can_cook/helper/pick_Image.dart';
import 'package:you_can_cook/models/User.dart' as userModel;
import 'package:you_can_cook/services/UserService.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:you_can_cook/redux/actions.dart';
import 'package:you_can_cook/redux/reducers.dart';

class EditProfileScreen extends StatefulWidget {
  final userModel.User userInfo;
  const EditProfileScreen({required this.userInfo, super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late String _avatar;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String _gender = 'Nam';

  @override
  void initState() {
    super.initState();
    _avatar = widget.userInfo.avatar ?? "assets/icons/logo.png";
    _nameController.text = widget.userInfo.name;
    _nicknameController.text = widget.userInfo.nickname ?? '';
    _bioController.text = widget.userInfo.bio ?? '';
    _gender = widget.userInfo.gender ?? 'Nam';
  }

  Future<void> _pickImage() async {
    final imagePath = await ImagePickerUtil.pickImage();
    if (imagePath != null) {
      setState(() {
        _avatar = imagePath;
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      String? avatarUrl;
      if (!_avatar.startsWith('assets') && _avatar != widget.userInfo.avatar) {
        avatarUrl = await UserService().uploadAvatar(
          _avatar,
          widget.userInfo.uid.toString(),
        );
      }

      final updates = {
        'name': _nameController.text,
        'nickname': _nicknameController.text,
        'gender': _gender,
        'bio': _bioController.text,
        if (avatarUrl != null) 'avatar': avatarUrl,
      };

      // ignore: use_build_context_synchronously
      StoreProvider.of<AppState>(
        context,
      ).dispatch(UpdateUserInfo(widget.userInfo.email, updates));
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      throw Exception('Failed to update user info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFEEA734)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Chỉnh sửa hồ sơ",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFFEEA734)),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _avatar.startsWith('assets')
                          ? AssetImage(_avatar)
                          : NetworkImage(_avatar) as ImageProvider,
                ),
                Container(
                  height: 30,
                  width: 35,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    iconSize: 20,
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _pickImage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Trường nhập liệu
            _buildTextField("Tên", _nameController),
            const SizedBox(height: 16),
            _buildTextField("Tên người dùng", _nicknameController),
            const SizedBox(height: 16),
            _buildDropdownField("Giới tính", _gender, ["Nam", "Nữ", "Khác"]),
            const SizedBox(height: 16),
            _buildTextField("Bio", _bioController),
          ],
        ),
      ),
    );
  }

  // Widget cho trường nhập liệu thông thường
  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  // Widget cho trường chọn dropdown (dành cho Gender)
  Widget _buildDropdownField(String label, String value, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _gender = newValue!;
            });
          },
        ),
      ],
    );
  }
}
