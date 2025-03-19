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
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CreateNewPostScreen extends StatefulWidget {
  const CreateNewPostScreen({super.key});

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

  late final SupabaseClient _client;
  late final PostService _postService;

  @override
  void initState() {
    super.initState();
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_KEY'];

    if (supabaseUrl == null || supabaseKey == null) {
      throw Exception('Supabase URL and Key must be provided');
    }

    _client = SupabaseClient(supabaseUrl, supabaseKey);
    _postService = PostService(_client);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = StoreProvider.of<AppState>(context);
      if (store.state.userInfo == null) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          store.dispatch(FetchUserInfo(currentUser.email!));
        }
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePickerUtil.pickImage();
    if (pickedFile != null) {
      setState(() {
        selectedImages.add(File(pickedFile));
      });
    }
  }

  Future<void> _createPost(userModel.User userInfo) async {
    if (selectedImages.isEmpty || contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng thêm hình ảnh và nội dung bài đăng"),
        ),
      );
      return;
    }

    try {
      // Upload tất cả hình ảnh
      List<String> imageUrls = [];
      for (int i = 0; i < selectedImages.length; i++) {
        final imageUrl = await _postService.uploadImage(
          selectedImages[i],
          'post/${userInfo.uid}/${DateTime.now().millisecondsSinceEpoch}_$i',
        );
        imageUrls.add(imageUrl);
      }

      final post = Post(
        uid: userInfo.uid,
        pcontent: contentController.text,
        pimage: imageUrls,
        phashtag: Post.parseHashtags(hashtagController.text),
        plike: 0,
        pcomment: 0,
        psave: 0,
        prange: visibility,
        createAt: DateTime.now(),
      );

      await _postService.createPost(post);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bài đăng đã được tạo thành công")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi tạo bài đăng: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, userModel.User?>(
      converter: (store) => store.state.userInfo,
      builder: (context, userInfo) {
        if (userInfo == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFFEEA734),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Tạo bài đăng",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () => _createPost(userInfo),
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
                          userInfo.avatar != null
                              ? NetworkImage(userInfo.avatar!)
                              : const AssetImage("assets/icons/logo.png")
                                  as ImageProvider,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      userInfo.nickname ?? "",
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
                        color: const Color(0xFFEEA734),
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
                                    color: Color(0xFFEEA734),
                                  ),
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
                if (selectedImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.file(
                                selectedImages[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedImages.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_a_photo, color: Color(0xFFEEA734)),
                  label: const Text(
                    "Thêm ảnh",
                    style: TextStyle(color: Color(0xFFEEA734)),
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
      },
    );
  }
}
