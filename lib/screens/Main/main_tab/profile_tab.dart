import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:you_can_cook/redux/actions.dart';
import 'package:you_can_cook/redux/reducers.dart';
import 'package:you_can_cook/screens/Main/sub_screens/settting.dart';
import 'package:you_can_cook/screens/Main/sub_screens/profile/edit_profile.dart';
import 'package:you_can_cook/widgets/card_photo_profile.dart';
import 'package:you_can_cook/widgets/card_post_profile.dart';
import 'package:you_can_cook/widgets/card_badges_profile.dart';
import 'package:you_can_cook/widgets/loading_screen.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:you_can_cook/services/FollowerService.dart';
import 'package:you_can_cook/services/UserService.dart';
import 'package:you_can_cook/widgets/card_reel_profile.dart';

class ProfileTab extends StatefulWidget {
  final int userId;
  const ProfileTab({super.key, required this.userId});

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? currentUserUid;
  Future<int?>? _fetchCurrentUserUidFuture;

  @override
  void initState() {
    super.initState();
    print("UserId passed to ProfileTab: ${widget.userId}");
    _tabController = TabController(length: 4, vsync: this);

    _fetchCurrentUserUidFuture = _fetchCurrentUserUid();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final store = StoreProvider.of<AppState>(context, listen: false);
      await store.dispatch(FetchProfileUserInfo(widget.userId));

      final profileUserInfo = store.state.profileUserInfo;
      if (profileUserInfo != null && profileUserInfo.uid != null) {
        store.dispatch(FetchUserPostsAndPhotos(profileUserInfo.uid));
        final userService = UserService();
        try {
          final totalLikes = await userService.getTotalLikes(widget.userId);
          store.dispatch(FetchTotalLikes(totalLikes));
        } catch (e) {
          store.dispatch(SetError('Failed to fetch total likes: $e'));
        }
      } else {
        debugPrint(
          "Profile user info is null or UID is missing for userId: ${widget.userId}",
        );
      }
    });
  }

  Future<int?> _fetchCurrentUserUid() async {
    final userService = UserService();
    final uid = await userService.getCurrentUserUid();
    if (uid != null) {
      setState(() {
        currentUserUid = uid;
        print("Current user UID: $uid");
      });
      return uid;
    } else {
      debugPrint("Current user UID is null.");
      return null;
    }
  }

  Future<void> _refreshData() async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    final profileUserInfo = store.state.profileUserInfo;

    if (profileUserInfo != null && profileUserInfo.uid != null) {
      store.dispatch(FetchUserPostsAndPhotos(profileUserInfo.uid));
      store.dispatch(FetchProfileUserInfo(profileUserInfo.uid));
      final userService = UserService();
      try {
        final totalLikes = await userService.getTotalLikes(profileUserInfo.uid);
        store.dispatch(FetchTotalLikes(totalLikes));
      } catch (e) {
        store.dispatch(SetError('Failed to fetch total likes: $e'));
      }
    } else {
      debugPrint("Profile UID is null, cannot refresh data.");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            iconSize: 30,
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          SettingsScreen(userId: widget.userId.toString()),
                ),
              );
            },
          ),
        ],
      ),
      body: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingScreen();
          } else if (state.errorMessage != null) {
            return Center(child: Text(state.errorMessage!));
          } else if (state.profileUserInfo != null) {
            final userInfo = state.profileUserInfo;
            final isOwnProfile =
                currentUserUid != null && currentUserUid == widget.userId;

            return RefreshIndicator(
              onRefresh: _refreshData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 5.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    userInfo.avatar != null
                                        ? NetworkImage(userInfo.avatar)
                                        : const AssetImage(
                                              "assets/icons/logo.png",
                                            )
                                            as ImageProvider,
                              ),
                              const SizedBox(height: 8),
                              if (!isOwnProfile &&
                                  currentUser != null &&
                                  currentUserUid != null)
                                FutureBuilder<bool>(
                                  future: FollowerService()
                                      .checkFollowingStatus(
                                        currentUserUid!,
                                        widget.userId,
                                      ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return const Text(
                                        'Error loading follow status',
                                      );
                                    }
                                    final isFollowing = snapshot.data ?? false;
                                    return ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          await FollowerService().toggleFollow(
                                            currentUserUid!,
                                            widget.userId,
                                            isFollowing,
                                          );
                                          setState(() {});
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString()),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        minimumSize: const Size(100, 36),
                                      ),
                                      child: Text(
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        isFollowing
                                            ? "Hủy theo dõi"
                                            : "Theo dõi",
                                      ),
                                    );
                                  },
                                ),
                            ],
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
                                    if (isOwnProfile)
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
                                                  (context) =>
                                                      EditProfileScreen(
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
                                    userInfo.nickname,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildStatColumn(
                                      "Follower",
                                      userInfo.follower ?? 0,
                                    ),
                                    _buildStatColumn("Thích", state.totalLikes),
                                    _buildStatColumn(
                                      "Bài đăng",
                                      state.userPosts.length,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (userInfo.bio != null && userInfo.bio.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 16.0,
                        ),
                        child: Center(
                          child: Text(
                            userInfo.bio,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.black,
                      tabs: const [
                        Tab(text: "Bài đăng"),
                        Tab(text: "Ảnh"),
                        Tab(text: "Reel"),
                        Tab(text: "Huy hiệu"),
                      ],
                    ),
                  ),
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        state.userPosts.isEmpty
                            ? const Center(child: Text("Chưa có bài đăng nào"))
                            : GridView.builder(
                              padding: const EdgeInsets.all(8.0),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 8.0,
                                    mainAxisSpacing: 8.0,
                                    childAspectRatio: 0.8,
                                  ),
                              itemCount: state.userPosts.length,
                              itemBuilder: (context, index) {
                                return CardPostProfile(
                                  post: state.userPosts[index],
                                );
                              },
                            ),
                        state.userPhotos.isEmpty
                            ? const Center(child: Text("Chưa có ảnh nào"))
                            : CardPhotoProfile(
                              photos: state.userPhotos,
                              // Thêm tham số isOwnProfile dựa trên điều kiện kiểm tra
                              isOwnProfile:
                                  currentUserUid != null &&
                                  currentUserUid == widget.userId,
                              onDeletePhoto: (photoUrl) async {
                                try {
                                  // Kiểm tra lại một lần nữa trước khi thực hiện xóa
                                  if (currentUserUid != null &&
                                      currentUserUid == widget.userId) {
                                    // Hiển thị loading indicator
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder:
                                          (context) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                    );

                                    // Gọi service để xóa ảnh từ Supabase Storage
                                    final userService = UserService();
                                    await userService.deleteUserPhoto(photoUrl);

                                    // Cập nhật Redux store
                                    final store = StoreProvider.of<AppState>(
                                      context,
                                      listen: false,
                                    );
                                    store.dispatch(DeleteUserPhoto(photoUrl));
                                    // Đóng loading indicator
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Bạn không có quyền xóa ảnh này',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  throw Exception("Lỗi khi xóa ảnh: $e");
                                }
                              },
                            ),
                        FutureBuilder<int?>(
                          future: _fetchCurrentUserUidFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text("Lỗi khi lấy UID"),
                              );
                            }
                            return state.userVideos.isEmpty
                                ? const Center(child: Text("Chưa có video nào"))
                                : CardReelProfile(
                                  videos: state.userVideos,
                                  currentUserUid: currentUserUid?.toString(),
                                );
                          },
                        ),
                        userInfo.badges == null || userInfo.badges.isEmpty
                            ? const Center(child: Text("Chưa có huy hiệu nào"))
                            : CardBadgesTab(
                              badges:
                                  userInfo.badges
                                      .map(
                                        (badge) => {
                                          "image": "assets/icons/logo.png",
                                          "name": badge,
                                        },
                                      )
                                      .toList(),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text("Đang tải thông tin..."));
        },
      ),
    );
  }

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
