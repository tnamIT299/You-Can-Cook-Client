import 'package:flutter/material.dart';
import 'package:you_can_cook/services/PostService.dart';
import 'package:you_can_cook/db/db.dart' as db;
import 'package:you_can_cook/models/Post.dart';
import 'package:you_can_cook/widgets/card_post.dart';

class TagTabSearch extends StatefulWidget {
  const TagTabSearch({super.key});

  @override
  _TagTabSearchState createState() => _TagTabSearchState();
}

class _TagTabSearchState extends State<TagTabSearch> {
  final PostService _postService = PostService(db.supabaseClient);
  List<String> hashtags = [];
  List<Post> postsByHashtag = [];
  bool isLoading = true;
  bool isShowingPosts = false;
  String? selectedHashtag;

  @override
  void initState() {
    super.initState();
    _fetchHashtags();
  }

  Future<void> _fetchHashtags() async {
    try {
      final tags = await _postService.get10Hashtag();
      setState(() {
        hashtags = tags;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  Future<void> _fetchPostsByHashtag(String hashtag) async {
    setState(() {
      isLoading = true;
      selectedHashtag = hashtag;
      isShowingPosts = true;
    });

    try {
      final posts = await _postService.fetchPostsByHashtag(hashtag);
      setState(() {
        postsByHashtag = posts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  void _goBackToHashtags() {
    setState(() {
      isShowingPosts = false;
      selectedHashtag = null;
      postsByHashtag = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isShowingPosts) {
      // Hiển thị danh sách bài post có chứa hashtag
      return Column(
        children: [
          // Thanh tiêu đề với nút quay lại
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _goBackToHashtags,
                ),
                Text(
                  'Bài viết với $selectedHashtag',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Danh sách bài post
          Expanded(
            child:
                postsByHashtag.isEmpty
                    ? const Center(
                      child: Text("Không có bài viết nào với hashtag này."),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: postsByHashtag.length,
                      itemBuilder: (context, index) {
                        final post = postsByHashtag[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: CardPost(
                            post: post,
                            currentUserUid:
                                post.uid
                                    .toString(), // Cần lấy UID người dùng hiện tại
                          ),
                        );
                      },
                    ),
          ),
        ],
      );
    }

    // Hiển thị danh sách hashtag
    if (hashtags.isEmpty) {
      return const Center(child: Text("Không có hashtag nào."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: hashtags.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: const Icon(Icons.tag, color: Colors.blue),
            title: Text(
              hashtags[index],
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _fetchPostsByHashtag(hashtags[index]);
            },
          ),
        );
      },
    );
  }
}
