import 'package:flutter/material.dart';
import 'package:you_can_cook/services/LikeService.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:you_can_cook/widgets/loading_screen.dart';
import 'package:you_can_cook/screens/Main/main_tab/profile_tab.dart';

class LikersScreen extends StatefulWidget {
  final int postId;
  final int? currentUserId;
  final LikeService likeService;

  const LikersScreen({
    super.key,
    required this.postId,
    required this.currentUserId,
    required this.likeService,
  });

  @override
  _LikersScreenState createState() => _LikersScreenState();
}

class _LikersScreenState extends State<LikersScreen> {
  List<Map<String, dynamic>> likers = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchLikers();
  }

  Future<void> _fetchLikers() async {
    try {
      final fetchedLikers = await widget.likeService.getPostLikers(
        widget.postId,
        currentUserId: widget.currentUserId,
      );
      if (mounted) {
        setState(() {
          likers = fetchedLikers;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Lỗi khi tải danh sách người thích: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Người thích bài viết",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: LoadingScreen())
              : error != null
              ? Center(child: Text(error!))
              : likers.isEmpty
              ? const Center(child: Text("Chưa có ai thích bài viết này."))
              : ListView.builder(
                itemCount: likers.length,
                itemBuilder: (context, index) {
                  final liker = likers[index];
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ProfileTab(userId: liker['like'].uid),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundImage:
                          liker['avatar'] != null
                              ? NetworkImage(liker['avatar'])
                              : const AssetImage("assets/icons/logo.png")
                                  as ImageProvider,
                    ),
                    title: Text(
                      liker['nickname'],
                      style: TextStyle(
                        fontWeight:
                            liker['isCurrentUser']
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(liker['name']),
                  );
                },
              ),
    );
  }
}
