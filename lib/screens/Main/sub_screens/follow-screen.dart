import 'package:flutter/material.dart';
import 'package:you_can_cook/services/FollowerService.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:you_can_cook/screens/Main/main_tab/profile_tab.dart';

class FollowScreen extends StatefulWidget {
  final int userId;

  const FollowScreen({required this.userId, super.key});

  @override
  _FollowScreenState createState() => _FollowScreenState();
}

class _FollowScreenState extends State<FollowScreen> {
  final FollowerService _followerService = FollowerService();
  List<Map<String, dynamic>> _followingList = [];
  List<Map<String, dynamic>> _followersList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() => _isLoading = true);
      final following = await _followerService.getFollowing(widget.userId);
      final followers = await _followerService.getFollowers(widget.userId);
      setState(() {
        _followingList = following;
        _followersList = followers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')));
    }
  }

  Future<void> _unfollow(int followingId) async {
    try {
      await _followerService.unfollow(widget.userId, followingId);
      setState(() {
        _followingList.removeWhere((user) => user['id'] == followingId);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã hủy theo dõi')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi hủy theo dõi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Đang theo dõi (${_followingList.length})'),
              Tab(text: 'Người theo dõi (${_followersList.length})'),
            ],
          ),
        ),
        body:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
                  children: [
                    // Danh sách ĐANG THEO DÕI
                    _followingList.isEmpty
                        ? Center(child: Text('Chưa theo dõi người dùng nào!'))
                        : ListView.builder(
                          itemCount: _followingList.length,
                          itemBuilder: (context, index) {
                            final user = _followingList[index];
                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            ProfileTab(userId: user['uid']),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    user['avatar'] != null
                                        ? NetworkImage(user['avatar'])
                                        : AssetImage('assets/icons/logo.png')
                                            as ImageProvider,
                              ),
                              title: Text(user['name'] ?? 'Không có tên'),
                              subtitle: Text(
                                '@${user['nickname'] ?? 'unknown'}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _unfollow(user['uid']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: Text(
                                  'Hủy theo dõi',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                        ),
                    // Danh sách NGƯỜI THEO DÕI
                    _followersList.isEmpty
                        ? Center(child: Text('Chưa có người theo dõi'))
                        : ListView.builder(
                          itemCount: _followersList.length,
                          itemBuilder: (context, index) {
                            final user = _followersList[index];
                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            ProfileTab(userId: user['uid']),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    user['avatar'] != null
                                        ? NetworkImage(user['avatar'])
                                        : AssetImage(
                                              'assets/images/default_avatar.png',
                                            )
                                            as ImageProvider,
                              ),
                              title: Text(user['name'] ?? 'Không có tên'),
                              subtitle: Text(
                                '@${user['nickname'] ?? 'unknown'}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          },
                        ),
                  ],
                ),
      ),
    );
  }
}
