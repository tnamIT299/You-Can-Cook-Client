import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:you_can_cook/screens/Main/sub_screens/settting.dart';
import 'package:you_can_cook/widgets/card_photo_profile.dart';
import 'package:you_can_cook/widgets/card_post_profile.dart';
import 'package:you_can_cook/widgets/card_badges_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:you_can_cook/redux/actions.dart';
import 'package:you_can_cook/redux/reducers.dart';
import 'package:you_can_cook/screens/Main/sub_screens/profile/edit_profile.dart';

class ProfileTab extends StatefulWidget {
  ProfileTab({super.key});
  final email = FirebaseAuth.instance.currentUser!.email;

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    ); // Cập nhật length thành 3
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StoreProvider.of<AppState>(
        context,
      ).dispatch(FetchUserInfo(widget.email!));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Dữ liệu giả cho danh sách bạn bè
  final List<String> friends = [
    "assets/icons/logo.png",
    "assets/icons/logo.png",
    "assets/icons/logo.png",
    "assets/icons/logo.png",
  ];

  // Dữ liệu giả cho bài đăng
  final List<Map<String, dynamic>> posts = [
    {
      "image": "assets/icons/logo.png",
      "description": "Exploring the autumn vibes 🍂",
      "likes": 120,
    },
    {
      "image": "assets/icons/logo.png",
      "description": "Photography session in the woods 📸",
      "likes": 150,
    },
  ];

  // Dữ liệu giả cho kho ảnh
  final List<String> photos = [
    "assets/icons/logo.png",
    "assets/icons/logo.png",
    "assets/icons/logo.png",
    "assets/icons/logo.png",
  ];

  // Dữ liệu giả cho huy hiệu
  final List<Map<String, dynamic>> badges = [
    {"image": "assets/icons/logo.png", "name": "Huy hiệu 1"},
    {"image": "assets/icons/logo.png", "name": "Huy hiệu 2"},
    {"image": "assets/icons/logo.png", "name": "Huy hiệu 3"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            iconSize: 30,
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.errorMessage != null) {
            return Center(child: Text(state.errorMessage!));
          } else if (state.userInfo != null) {
            final userInfo = state.userInfo;

            return Column(
              children: [
                // Header với thông tin người dùng
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            userInfo.avatar != null
                                ? NetworkImage(userInfo.avatar!)
                                : const AssetImage("assets/icons/logo.png")
                                    as ImageProvider,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    userInfo.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => EditProfileScreen(
                                              userInfo: userInfo,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            if (userInfo.nickname != null) ...[
                              Text(
                                userInfo.nickname!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                overflow:
                                    TextOverflow
                                        .ellipsis, // Rút gọn tên nếu quá dài
                                maxLines: 1, // Giới hạn số dòng hiển thị
                              ),
                              const SizedBox(height: 16),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatColumn(
                                  "Follower",
                                  userInfo.follower ?? 0,
                                ),
                                _buildStatColumn("Thích", 0),
                                _buildStatColumn("Bài đăng", 0),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (userInfo.bio != null && userInfo.bio!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      userInfo.bio!,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                // TabBar
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  tabs: const [
                    Tab(text: "Bài đăng"),
                    Tab(text: "Ảnh"),
                    Tab(text: "Huy hiệu"), // Thêm tab mới
                  ],
                ),
                // TabBarView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Posts Tab
                      GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return CardPostProfile(post: post);
                        },
                      ),
                      // Photos Tab
                      CardPhotoProfile(photos: photos),
                      // Badges Tab
                      CardBadgesTab(badges: badges),
                    ],
                  ),
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }

  // Hàm xây dựng cột thống kê (Following, Followers, Post)
  Widget _buildStatColumn(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
