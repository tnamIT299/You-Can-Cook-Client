import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:you_can_cook/models/Post.dart';
import 'package:you_can_cook/services/FollowerService.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:you_can_cook/screens/Main/main_tab/profile_tab.dart';
import 'package:you_can_cook/screens/Main/sub_screens/post/create_post.dart';
import 'package:you_can_cook/screens/Main/sub_screens/post/detail_post.dart';
import 'package:you_can_cook/widgets/dialog_noti.dart';
import 'package:you_can_cook/services/PostService.dart';
import 'package:you_can_cook/db/db.dart';
import 'package:you_can_cook/widgets/report-dialog.dart';

void registerTimeagoMessages() {
  timeago.setLocaleMessages('vi', timeago.ViMessages());
}

class CardPost extends StatefulWidget {
  const CardPost({super.key, required this.post, required this.currentUserUid});

  final Post post;
  final String? currentUserUid;

  @override
  _CardPostState createState() => _CardPostState();
}

class _CardPostState extends State<CardPost> {
  late final PostService _postService;
  late final FollowerService _followerService;
  int _currentImageIndex = 0;
  bool _isExpanded = false;
  @override
  void initState() {
    super.initState();
    _postService = PostService(supabaseClient);
    _followerService = FollowerService();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
  }

  // Hàm chuyển hướng đến ProfileTab
  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileTab(userId: widget.post.uid),
      ),
    );
  }

  Future<void> _showReportDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => ReportDialog(
            reporterUid: widget.currentUserUid!,
            reportedUid: widget.post.uid.toString(), // UID của người bị báo cáo
            pid: widget.post.pid.toString(), // ID của bài post (nếu có)
          ),
    );

    if (result == true) {
      // Xử lý thêm nếu cần sau khi báo cáo thành công
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPostOwner =
        widget.currentUserUid != null &&
        widget.currentUserUid == widget.post.uid.toString();

    final List<String>? images = widget.post.pimage;
    final String relativeTime = timeago.format(
      widget.post.createAt ?? DateTime.now(),
      locale: 'vi', // Sử dụng ngôn ngữ Tiếng Việt
    );
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: () => _navigateToProfile(context),
              child: CircleAvatar(
                backgroundImage:
                    widget.post.avatar != null
                        ? NetworkImage(widget.post.avatar!)
                        : const AssetImage("assets/icons/logo.png")
                            as ImageProvider,
              ),
            ),
            title: GestureDetector(
              onTap: () => _navigateToProfile(context),
              child: Text(
                widget.post.nickname ?? widget.post.name ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            trailing:
                isPostOwner
                    ? IconButton(
                      icon: const Icon(Icons.more_horiz),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (BuildContext context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.read_more,
                                    color: Colors.blue,
                                  ),
                                  title: const Text("Xem bài viết"),
                                  onTap: () {
                                    Navigator.pop(context); // Đóng modal
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => DetailPostScreen(
                                              post: widget.post,
                                              currentUserUid:
                                                  widget.currentUserUid,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  title: const Text("Chỉnh sửa bài viết"),
                                  onTap: () {
                                    Navigator.pop(context); // Đóng modal
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => CreateNewPostScreen(
                                              post: widget.post,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  title: const Text("Xóa bài viết"),
                                  onTap: () {
                                    show_Dialog(
                                      context,
                                      "Xóa bài viết",
                                      "Bạn có chắc chắn muốn xóa bài viết này không?",
                                      () async {
                                        _postService.deletePost(
                                          widget.post.pid!,
                                        );
                                        Navigator.pop(context); // Đóng modal
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Bài viết đã được xóa",
                                            ),
                                          ),
                                        );
                                      },
                                      () {
                                        Navigator.pop(context); // Đóng modal
                                      }, // Add the missing argument (e.g., an empty callback)
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    )
                    : IconButton(
                      icon: const Icon(Icons.more_horiz),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (BuildContext context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.read_more,
                                    color: Colors.blue,
                                  ),
                                  title: const Text("Xem bài viết"),
                                  onTap: () {
                                    Navigator.pop(context); // Đóng modal
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => DetailPostScreen(
                                              post: widget.post,
                                              currentUserUid:
                                                  widget.currentUserUid,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.block,
                                    color: Colors.red,
                                  ),
                                  title: Text(
                                    "Huỷ theo dõi ${widget.post.nickname!}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  onTap: () {
                                    show_Dialog(
                                      context,
                                      "Huỷ theo dõi",
                                      "Bạn có chắc chắn muốn huỷ theo dõi ${widget.post.nickname} không?",
                                      () async {
                                        _followerService.unfollow(
                                          int.parse(widget.currentUserUid!),
                                          widget.post.uid,
                                        );
                                        Navigator.pop(context); // Đóng modal
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Đã huỷ theo dõi"),
                                          ),
                                        );
                                      },
                                      () {
                                        Navigator.pop(context); // Đóng modal
                                      }, // Add the missing argument (e.g., an empty callback)
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.report,
                                    color: Colors.red,
                                  ),
                                  title: const Text("Báo cáo người dùng "),
                                  onTap: () {
                                    Navigator.pop(context); // Đóng modal
                                    _showReportDialog();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
          ),
          if (images != null && images.isNotEmpty)
            images.length > 1
                ? Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 300.0,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        enlargeCenterPage: true,
                        aspectRatio: 16 / 9,
                        viewportFraction: 1.0,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                      ),
                      items:
                          images.map((imageUrl) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text(
                                        'Error loading image',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          }).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          images.asMap().entries.map((entry) {
                            return GestureDetector(
                              onTap:
                                  () => setState(() {
                                    _currentImageIndex = entry.key;
                                  }),
                              child: Container(
                                width: 8.0,
                                height: 8.0,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      _currentImageIndex == entry.key
                                          ? AppColors.primary
                                          : Colors.grey,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                )
                : Image.network(
                  images[0],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300.0,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        'Error loading image',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  },
                ),
          FunctionButton(widget: widget),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              relativeTime,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.pcontent ?? '',
                  maxLines:
                      _isExpanded ? null : 1, // Hiển thị đầy đủ nếu mở rộng
                  overflow:
                      _isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                if ((widget.post.pcontent ?? '').length >
                    100) // Kiểm tra độ dài nội dung
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded; // Đổi trạng thái khi nhấn
                      });
                    },
                    child: Text(
                      _isExpanded ? "Thu gọn" : "Xem thêm",
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (widget.post.phashtag != null && widget.post.phashtag!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Wrap(
                children:
                    widget.post.phashtag!.map<Widget>((tag) {
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

class FunctionButton extends StatelessWidget {
  const FunctionButton({super.key, required this.widget});

  final CardPost widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.favorite_border,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Like functionality here")),
                  );
                },
              ),
              Text(
                "${widget.post.plike ?? 0}",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                color: AppColors.primary,
                icon: const Icon(Icons.comment),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DetailPostScreen(
                            post: widget.post,
                            currentUserUid: widget.currentUserUid,
                          ),
                    ),
                  );
                },
              ),
              Text(
                "${widget.post.pcomment ?? 0}",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                color: AppColors.primary,
                icon: const Icon(Icons.bookmark_border),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Save functionality here")),
                  );
                },
              ),
              Text(
                "${widget.post.psave ?? 0}",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
