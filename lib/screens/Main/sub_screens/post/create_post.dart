import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:you_can_cook/helper/pick_Image.dart';
import 'dart:io';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:you_can_cook/redux/reducers.dart';
import 'package:you_can_cook/models/User.dart' as userModel;
import 'package:you_can_cook/redux/actions.dart';
import 'package:you_can_cook/models/Post.dart';
import 'package:you_can_cook/services/PostService.dart';
import 'package:supabase/supabase.dart';
import 'package:you_can_cook/services/UserService.dart';
import 'package:you_can_cook/widgets/loading_screen.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:you_can_cook/db/db.dart';

class CreateNewPostScreen extends StatefulWidget {
  final Post? post;

  const CreateNewPostScreen({super.key, this.post});

  @override
  _CreateNewPostScreenState createState() => _CreateNewPostScreenState();
}

class _CreateNewPostScreenState extends State<CreateNewPostScreen> {
  List<File> selectedImages = [];
  String visibility = "Công khai";
  bool shareOnFacebook = false;
  bool shareOnTwitter = false;
  final TextEditingController contentController = TextEditingController();
  final TextEditingController hashtagController = TextEditingController();

  late final PostService _postService;
  late final UserService _userService;
  userModel.User? _currentUserInfo;
  bool _isEditMode = false; // Biến để xác định chế độ chỉnh sửa

  @override
  void initState() {
    super.initState();
    _postService = PostService(supabaseClient);
    _userService = UserService();

    _isEditMode = widget.post != null;

    // Nếu ở chế độ chỉnh sửa, khởi tạo dữ liệu từ bài viết
    if (_isEditMode) {
      contentController.text = widget.post!.pcontent ?? '';
      hashtagController.text = widget.post!.phashtag?.join(' ') ?? '';
      visibility = widget.post!.prange ?? "Công khai";
      if (widget.post!.pimage != null) {
        // Giả sử bạn chỉ lưu URL trong pimage, không thể tải File trực tiếp từ URL
        // Ở đây chỉ hiển thị URL dưới dạng văn bản hoặc cần logic tải ảnh từ URL
      }
    }

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

  Future<void> _pickImage() async {
    final pickedFile = await ImagePickerUtil.pickImage();
    if (pickedFile != null) {
      setState(() {
        selectedImages.add(File(pickedFile));
      });
    }
  }

  Future<void> _savePost(userModel.User userInfo) async {
    if (contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng thêm nội dung bài đăng")),
      );
      return;
    }

    try {
      List<String> imageUrls = widget.post?.pimage ?? [];
      if (selectedImages.isNotEmpty) {
        // Upload ảnh mới nếu có
        for (int i = 0; i < selectedImages.length; i++) {
          final imageUrl = await _postService.uploadImage(
            selectedImages[i],
            'post/${userInfo.uid}/${DateTime.now().millisecondsSinceEpoch}_$i',
          );
          imageUrls.add(imageUrl);
        }
      }

      final updatedPost = Post(
        pid: widget.post?.pid, // Giữ nguyên pid khi chỉnh sửa
        uid: userInfo.uid,
        pcontent: contentController.text,
        pimage: imageUrls,
        phashtag: Post.parseHashtags(hashtagController.text),
        plike: widget.post?.plike ?? 0,
        pcomment: widget.post?.pcomment ?? 0,
        psave: widget.post?.psave ?? 0,
        prange: visibility,
        createAt: widget.post?.createAt ?? DateTime.now(),
      );

      if (_isEditMode) {
        // Cập nhật bài viết
        await _postService.updatePost(updatedPost);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bài đăng đã được cập nhật thành công")),
        );
      } else {
        // Tạo bài viết mới
        await _postService.createPost(updatedPost);
        final currentPoint = await _userService.getUserPoints(userInfo.uid);
        await _userService.updateUserPoints(userInfo.uid, currentPoint + 5);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bài đăng đã được tạo thành công")),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi lưu bài đăng: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserInfo == null) {
      return const LoadingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? "Chỉnh sửa bài đăng" : "Tạo bài đăng",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _savePost(_currentUserInfo!),
            child: Text(
              _isEditMode ? "Cập nhật" : "Đăng",
              style: const TextStyle(color: Colors.white, fontSize: 16),
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
                              style: const TextStyle(color: AppColors.primary),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
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
                    style: const TextStyle(color: Colors.white, fontSize: 13),
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
            if (selectedImages.isNotEmpty ||
                (widget.post?.pimage?.isNotEmpty ?? false))
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      (widget.post?.pimage?.length ?? 0) +
                      selectedImages.length,
                  itemBuilder: (context, index) {
                    if (index < (widget.post?.pimage?.length ?? 0)) {
                      // Hiển thị ảnh cũ từ URL
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.network(
                              widget.post!.pimage![index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  widget.post!.pimage!.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Hiển thị ảnh mới chọn từ thiết bị
                      final newIndex =
                          index - (widget.post?.pimage?.length ?? 0);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.file(
                              selectedImages[newIndex],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  selectedImages.removeAt(newIndex);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_a_photo, color: AppColors.primary),
              label: const Text(
                "Thêm ảnh",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Mô tả về thực đơn của bạn",
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
              decoration: InputDecoration(
                hintText: "Thêm hashtags (#food #delicious,...)",
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
    );
  }
}
