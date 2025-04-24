import 'package:flutter/material.dart';
import 'package:you_can_cook/models/Post.dart';
import 'package:you_can_cook/services/PostService.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:you_can_cook/db/db.dart' as db;
import 'package:you_can_cook/screens/Main/sub_screens/post/detail_post.dart';

class RecipesTabSearch extends StatefulWidget {
  final String searchQuery;

  const RecipesTabSearch({super.key, required this.searchQuery});

  @override
  _RecipesTabSearchState createState() => _RecipesTabSearchState();
}

class _RecipesTabSearchState extends State<RecipesTabSearch> {
  final PostService _postService = PostService(db.supabaseClient);
  List<Post> topPosts = []; // 5 bài đăng có nhiều lượt thích nhất
  List<Post> allPosts = []; // Tất cả bài đăng
  List<Post> filteredPosts = []; // Danh sách hiển thị
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void didUpdateWidget(covariant RecipesTabSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _filterPosts();
    }
  }

  Future<void> _fetchInitialData() async {
    try {
      final topPostsResult = await _postService.get5PostMaxLike();

      final allPostsResult =
          await _postService.getAllPosts(); // Giả định có hàm này

      setState(() {
        topPosts = topPostsResult;
        allPosts = allPostsResult;
        filteredPosts = topPosts; // Mặc định hiển thị 5 bài đăng hàng đầu
        isLoading = false;
      });
      _filterPosts();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  void _filterPosts() {
    if (widget.searchQuery.isEmpty) {
      setState(() {
        filteredPosts =
            topPosts; // Hiển thị 5 bài đăng hàng đầu khi không có từ khóa
      });
      return;
    }

    final query = widget.searchQuery.toLowerCase();
    setState(() {
      filteredPosts =
          allPosts.where((post) {
            final content = (post.pcontent ?? '').toLowerCase();
            final hashtags = (post.phashtag ?? []).join(' ').toLowerCase();
            return content.contains(query) || hashtags.contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredPosts.isEmpty) {
      return const Center(child: Text("Không tìm thấy bài đăng nào phù hợp."));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredPosts.length,
      itemBuilder: (context, index) {
        final post = filteredPosts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => DetailPostScreen(
                      post: post,
                      currentUserUid: post.uid.toString(),
                    ),
              ),
            );
          },
          child: CardPostSearch(post: post),
        );
      },
    );
  }
}

class CardPostSearch extends StatelessWidget {
  const CardPostSearch({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              (post.pimage != null && post.pimage!.isNotEmpty)
                  ? post.pimage![0]
                  : "assets/icons/logo.png",
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/icons/logo.png",
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite_outlined,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text("${post.plike}", style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              post.pcontent ?? "Không có nội dung",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (post.phashtag != null && post.phashtag!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Wrap(
                children:
                    post.phashtag!.map<Widget>((tag) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          tag,
                          style: const TextStyle(color: Colors.blue),
                        ),
                      );
                    }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
