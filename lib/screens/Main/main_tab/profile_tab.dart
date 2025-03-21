import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:you_can_cook/db/db.dart';
import 'package:you_can_cook/screens/Main/sub_screens/settting.dart';
import 'package:you_can_cook/widgets/card_photo_profile.dart';
import 'package:you_can_cook/widgets/card_post_profile.dart';
import 'package:you_can_cook/widgets/card_badges_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:you_can_cook/redux/actions.dart';
import 'package:you_can_cook/redux/reducers.dart';
import 'package:you_can_cook/screens/Main/sub_screens/profile/edit_profile.dart';
import 'package:you_can_cook/widgets/loading_screen.dart';
import 'package:supabase/supabase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:you_can_cook/utils/color.dart';

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
    _tabController = TabController(length: 3, vsync: this);

    // Dispatch actions ngay lập tức trong initState
    final store = StoreProvider.of<AppState>(context, listen: false);
    if (widget.email != null && store.state.userInfo == null) {
      store.dispatch(FetchUserInfo(widget.email!));
    }

    // Kiểm tra và dispatch FetchUserPostsAndPhotos nếu cần
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = store.state.userInfo?.uid;
      if (uid != null &&
          (store.state.userPosts.isEmpty || store.state.userPhotos.isEmpty)) {
        store.dispatch(FetchUserPostsAndPhotos(uid));
      }
    });
  }

  Future<void> _refreshData() async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    final uid = store.state.userInfo?.uid;
    if (uid != null) {
      store.dispatch(FetchUserPostsAndPhotos(uid));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          // Hiển thị màn hình loading nếu đang tải dữ liệu
          if (state.isLoading) {
            return const LoadingScreen();
          }
          // Hiển thị lỗi nếu có
          else if (state.errorMessage != null) {
            return Center(child: Text(state.errorMessage!));
          }
          // Hiển thị UI chính khi có userInfo
          else if (state.userInfo != null) {
            final userInfo = state.userInfo!;

            // Cập nhật dữ liệu khi uid thay đổi
            if (state.userPosts.isEmpty && userInfo.uid != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final store = StoreProvider.of<AppState>(
                  context,
                  listen: false,
                );
                store.dispatch(FetchUserPostsAndPhotos(userInfo.uid));
              });
            }

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
                                    _buildStatColumn("Thích", 0),
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
                  if (userInfo.bio != null && userInfo.bio!.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 16.0,
                        ),
                        child: Center(
                          child: Text(
                            userInfo.bio!,
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
                        Tab(text: "Huy hiệu"),
                      ],
                    ),
                  ),
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Posts Tab
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
                        // Photos Tab
                        state.userPhotos.isEmpty
                            ? const Center(child: Text("Chưa có ảnh nào"))
                            : CardPhotoProfile(photos: state.userPhotos),
                        // Badges Tab
                        userInfo.badges == null || userInfo.badges!.isEmpty
                            ? const Center(child: Text("Chưa có huy hiệu nào"))
                            : CardBadgesTab(
                              badges:
                                  userInfo.badges!
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
          // Trường hợp mặc định khi chưa có dữ liệu
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
