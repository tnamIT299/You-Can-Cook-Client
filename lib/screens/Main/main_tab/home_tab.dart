import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:you_can_cook/services/PostService.dart';
import 'package:you_can_cook/services/UserService.dart';
import 'package:you_can_cook/services/NotificationService.dart';
import 'package:you_can_cook/widgets/card_post.dart';
import 'package:you_can_cook/screens/Main/sub_screens/settting.dart';
import 'package:you_can_cook/screens/Main/sub_screens/post/create_post.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:you_can_cook/screens/drawerScreens/loyalPoint.dart';
import 'package:you_can_cook/db/db.dart' as db;
import 'package:you_can_cook/models/Post.dart';
import 'package:you_can_cook/models/User.dart' as userModel;
import 'package:you_can_cook/widgets/loading_screen.dart';
import 'package:you_can_cook/screens/drawerScreens/badgeScreen.dart';
import 'package:you_can_cook/screens/Main/sub_screens/notification/notification_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PostService _postService = PostService(db.supabaseClient);
  final UserService _userService = UserService();
  final NotificationService _notificationService = NotificationService(
    db.supabaseClient,
  );

  List<Post> _posts = [];
  userModel.User? _currentUser;
  bool _isLoading = true;
  int? _currentUserUid;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchPosts() async {
    if (_currentUserUid == null)
      return; // Đảm bảo có UID trước khi lấy bài post

    setState(() {
      _isLoading = true;
    });
    try {
      final posts = await _postService.fetchFilteredPosts(_currentUserUid!);
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi tải bài viết: $e")));
    }
  }

  Future<void> _fetchUserInfo() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final user = await _userService.getUserInfo(firebaseUser.email!);
        final uid = await _userService.getCurrentUserUid();
        setState(() {
          _currentUser = user;
          _currentUserUid = uid;
          _isLoading = false;
        });
        // Sau khi lấy được UID, gọi fetchPosts
        await _fetchPosts();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Cập nhật trạng thái like của một bài viết cụ thể
  void _updatePostLike(int postId, int newLikeCount) {
    setState(() {
      _posts =
          _posts.map((post) {
            if (post.pid == postId) {
              return Post(
                pid: post.pid,
                uid: post.uid,
                pcontent: post.pcontent,
                pimage: post.pimage,
                phashtag: post.phashtag,
                plike: newLikeCount,
                pcomment: post.pcomment,
                psave: post.psave,
                createAt: post.createAt,
                avatar: post.avatar,
                nickname: post.nickname,
                name: post.name,
              );
            }
            return post;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? email = user?.email;
    if (_isLoading) {
      return const LoadingScreen();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        _currentUser?.avatar != null
                            ? NetworkImage(_currentUser!.avatar!)
                            : const AssetImage("assets/icons/logo.png")
                                as ImageProvider,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    email ?? "Guest",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Điểm đóng góp'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => LoyaltyPointsScreen(
                          userId: _currentUserUid?.toString() ?? '',
                        ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Khám phá kho huy hiệu'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BadgeScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPosts,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: false,
              floating: false,
              expandedHeight: 200.0,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Builder(
                            builder: (context) {
                              return IconButton(
                                iconSize: 30,
                                icon: const Icon(
                                  Icons.menu,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Scaffold.of(context).openDrawer();
                                },
                              );
                            },
                          ),
                          Row(
                            children: [
                              IconButton(
                                iconSize: 30,
                                color: Colors.white,
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => CreateNewPostScreen(),
                                    ),
                                  ).then((_) => _fetchPosts());
                                },
                              ),
                              StreamBuilder<int>(
                                stream:
                                    _currentUserUid != null
                                        ? _notificationService
                                            .listenToUnreadNotifications(
                                              _currentUserUid!,
                                            )
                                        : Stream.value(0),
                                initialData: 0,
                                builder: (context, snapshot) {
                                  final unreadCount = snapshot.data ?? 0;
                                  return Stack(
                                    children: [
                                      IconButton(
                                        iconSize: 30,
                                        color: Colors.white,
                                        icon: const Icon(Icons.notifications),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      NotificationsScreen(
                                                        userId:
                                                            _currentUserUid ??
                                                            0,
                                                        supabaseClient:
                                                            db.supabaseClient,
                                                      ),
                                            ),
                                          );
                                        },
                                      ),
                                      if (unreadCount > 0)
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Text(
                        "Xin Chào",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Source Sans 3',
                        ),
                      ),
                      const Text(
                        "Hôm nay ăn gì? Để chúng tôi gợi ý!",
                        style: TextStyle(
                          color: Color(0xff141a46),
                          fontSize: 20,
                          fontFamily: 'Source Sans 3',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _posts.isEmpty
                      ? const Center(child: Text('Không có bài viết nào'))
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 8.0,
                            ),
                            child: CardPost(
                              post: post,
                              currentUserUid: _currentUserUid?.toString(),
                              onLikeToggled:
                                  (newLikeCount) =>
                                      _updatePostLike(post.pid!, newLikeCount),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
