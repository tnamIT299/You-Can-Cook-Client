import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:you_can_cook/models/User.dart' as userModel;
import 'package:you_can_cook/models/Reel.dart';
import 'package:you_can_cook/services/ReelService.dart';
import 'package:you_can_cook/services/UserService.dart';
import 'package:you_can_cook/widgets/loading_screen.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:you_can_cook/db/db.dart';

class CreateReel extends StatefulWidget {
  const CreateReel({super.key});

  @override
  State<CreateReel> createState() => _CreateReelState();
}

class _CreateReelState extends State<CreateReel> {
  File? selectedVideo;
  String visibility = "Công khai";
  final TextEditingController contentController = TextEditingController();
  final TextEditingController hashtagController = TextEditingController();
  bool _isLoading = false; // Biến trạng thái loading

  late final ReelService _reelService;
  late final UserService _userService;
  userModel.User? _currentUserInfo;

  @override
  void initState() {
    super.initState();
    _reelService = ReelService();
    _userService = UserService();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchCurrentUserInfo();
    });
  }

  Future<void> _fetchCurrentUserInfo() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userInfo = await _userService.getUserByEmail(currentUser.email!);
      setState(() {
        _currentUserInfo = userInfo;
      });
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedVideo = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveReel(userModel.User userInfo) async {
    if (contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng thêm nội dung reel")),
      );
      return;
    }

    if (selectedVideo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vui lòng chọn một video")));
      return;
    }

    setState(() {
      _isLoading = true; // Bật trạng thái loading
    });

    try {
      final hashtags =
          hashtagController.text.split(' ').map((tag) => tag.trim()).toList();
      final newReel = Reel(
        uid: userInfo.uid,
        reelContent: contentController.text,
        reelUrl: '', // Will be updated after upload
        reelHashtag: hashtags,
        reelLike: 0,
        reelComment: 0,
        reelSave: 0,
        reelRange: visibility,
        createAt: DateTime.now(),
        isWarning: false,
      );

      // Upload the reel video to Supabase
      await _reelService.uploadReel(newReel, selectedVideo!.path);
      final currentPoint = await _userService.getUserPoints(userInfo.uid);
      await _userService.updateUserPoints(userInfo.uid, currentPoint + 10);

      setState(() {
        _isLoading = false; // Tắt trạng thái loading
      });

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reel đã được tạo thành công")),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false; // Tắt trạng thái loading nếu có lỗi
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi tạo reel: $e")));
    }
  }

  // Function to shorten the video name if it's too long
  String _shortenVideoName(String fileName, {int maxLength = 20}) {
    if (fileName.length <= maxLength) return fileName;
    final extension = fileName.split('.').last;
    final nameWithoutExtension = fileName.substring(
      0,
      fileName.length - extension.length - 1,
    );
    final shortenedName = nameWithoutExtension.substring(
      0,
      maxLength - extension.length - 3,
    );
    return '$shortenedName...$extension';
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserInfo == null) {
      return const LoadingScreen();
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed:
                  _isLoading
                      ? null
                      : () => Navigator.pop(
                        context,
                      ), // Vô hiệu hóa nút back khi đang loading
            ),
            title: const Text(
              "Tạo Reel",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed:
                    _isLoading
                        ? null
                        : () => _saveReel(
                          _currentUserInfo!,
                        ), // Vô hiệu hóa nút "Đăng" khi đang loading
                child: const Text(
                  "Đăng",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          _currentUserInfo!.avatar != null
                              ? NetworkImage(_currentUserInfo!.avatar!)
                              : const AssetImage("assets/icons/logo.png")
                                  as ImageProvider,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _currentUserInfo!.nickname ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        value: visibility,
                        items:
                            ["Công khai", "Người theo dõi"].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged:
                            _isLoading
                                ? null // Vô hiệu hóa dropdown khi đang loading
                                : (String? newValue) {
                                  setState(() {
                                    visibility = newValue!;
                                  });
                                },
                        selectedItemBuilder: (BuildContext context) {
                          return ["Công khai", "Người theo dõi"].map((
                            String value,
                          ) {
                            return Center(
                              child: Text(
                                value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList();
                        },
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        underline: Container(),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (selectedVideo != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _shortenVideoName(
                              selectedVideo!.path.split('/').last,
                              maxLength: 25,
                            ),
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed:
                              _isLoading
                                  ? null // Vô hiệu hóa nút xóa khi đang loading
                                  : () {
                                    setState(() {
                                      selectedVideo = null;
                                    });
                                  },
                        ),
                      ],
                    ),
                  ),
                TextButton.icon(
                  onPressed:
                      _isLoading
                          ? null
                          : _pickVideo, // Vô hiệu hóa nút "Thêm video" khi đang loading
                  icon: const Icon(
                    Icons.video_library,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    "Thêm video",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  enabled:
                      !_isLoading, // Vô hiệu hóa TextField khi đang loading
                  decoration: InputDecoration(
                    hintText: "Mô tả về video của bạn",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: hashtagController,
                  enabled:
                      !_isLoading, // Vô hiệu hóa TextField khi đang loading
                  decoration: InputDecoration(
                    hintText: "Thêm hashtags (#dance #fun,...)",
                    prefixStyle: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black54, // Nền mờ khi loading
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }
}
