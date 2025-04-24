import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:you_can_cook/models/Post.dart';
import 'package:you_can_cook/services/FollowerService.dart';
import 'package:you_can_cook/services/LikeService.dart';
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
  const CardPost({
    super.key,
    required this.post,
    required this.currentUserUid,
    this.onLikeToggled,
  });

  final Post post;
  final String? currentUserUid;
  final void Function(int newLikeCount)? onLikeToggled;

  @override
  _CardPostState createState() => _CardPostState();
}

class _CardPostState extends State<CardPost> {
  late final PostService _postService;
  late final FollowerService _followerService;
  late final LikeService _likeService;
  int _currentImageIndex = 0;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _postService = PostService(supabaseClient);
    _followerService = FollowerService();
    _likeService = LikeService();
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
            reportedUid: widget.post.uid.toString(),
            pid: widget.post.pid.toString(),
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
      locale: 'vi',
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
                                    Navigator.pop(context);
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
                                    ).then((result) {
                                      if (result != null &&
                                          result is Map<String, dynamic>) {
                                        widget.onLikeToggled?.call(
                                          result['likeCount'],
                                        );
                                      }
                                    });
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  title: const Text("Chỉnh sửa bài viết"),
                                  onTap: () {
                                    Navigator.pop(context);
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
                                        await _postService.deletePost(
                                          widget.post.pid!,
                                        );
                                        Navigator.pop(context);
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
                                        Navigator.pop(context);
                                      },
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
                                    Navigator.pop(context);
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
                                    ).then((result) {
                                      if (result != null &&
                                          result is Map<String, dynamic>) {
                                        widget.onLikeToggled?.call(
                                          result['likeCount'],
                                        );
                                      }
                                    });
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
                                        await _followerService.unfollow(
                                          int.parse(widget.currentUserUid!),
                                          widget.post.uid,
                                        );
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Đã huỷ theo dõi"),
                                          ),
                                        );
                                      },
                                      () {
                                        Navigator.pop(context);
                                      },
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
                                    Navigator.pop(context);
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
          FunctionButton(
            widget: widget,
            likeService: _likeService,
            onLikeToggled: widget.onLikeToggled,
          ),
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
                  maxLines: _isExpanded ? null : 1,
                  overflow:
                      _isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                if ((widget.post.pcontent ?? '').length > 100)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
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

class FunctionButton extends StatefulWidget {
  const FunctionButton({
    super.key,
    required this.widget,
    required this.likeService,
    this.onLikeToggled,
  });

  final CardPost widget;
  final LikeService likeService;
  final void Function(int newLikeCount)? onLikeToggled;

  @override
  _FunctionButtonState createState() => _FunctionButtonState();
}

class _FunctionButtonState extends State<FunctionButton> {
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.widget.post.plike ?? 0;
    if (widget.widget.currentUserUid != null) {
      _checkLikeStatus();
    }
  }

  Future<void> _checkLikeStatus() async {
    final isLiked = await widget.likeService.hasLiked(
      int.parse(widget.widget.currentUserUid!),
      widget.widget.post.pid!,
    );
    if (mounted) {
      setState(() {
        _isLiked = isLiked;
      });
    }
  }

  Future<void> _toggleLike() async {
    if (widget.widget.currentUserUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để thích bài viết')),
      );
      return;
    }

    try {
      await widget.likeService.toggleLike(
        int.parse(widget.widget.currentUserUid!),
        widget.widget.post.pid!,
        widget.widget.post.uid,
        _isLiked,
      );
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
          _likeCount += _isLiked ? 1 : -1;
        });
        widget.onLikeToggled?.call(_likeCount);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi thích bài viết: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream:
          widget.widget.currentUserUid != null
              ? widget.likeService.listenToLikeStatus(
                int.parse(widget.widget.currentUserUid!),
                widget.widget.post.pid!,
              )
              : null,
      initialData: _isLiked ? 1 : 0,
      builder: (context, likeStatusSnapshot) {
        final isLiked = likeStatusSnapshot.data == 1;
        return StreamBuilder<int>(
          stream: widget.likeService.listenToLikeCount(widget.widget.post.pid!),
          initialData: _likeCount,
          builder: (context, snapshot) {
            final likeCount = snapshot.data ?? _likeCount;
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 2.0,
                vertical: 4.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : AppColors.primary,
                        ),
                        onPressed: _toggleLike,
                      ),
                      likeCount >= 1000
                          ? Text(
                            '${(likeCount / 1000).toStringAsFixed(1)}k',
                            style: const TextStyle(fontSize: 14),
                          )
                          : likeCount >= 0
                          ? Text(
                            likeCount.toString(),
                            style: const TextStyle(fontSize: 14),
                          )
                          : const SizedBox.shrink(),
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
                                    post: widget.widget.post,
                                    currentUserUid:
                                        widget.widget.currentUserUid,
                                  ),
                            ),
                          ).then((result) {
                            if (result != null &&
                                result is Map<String, dynamic>) {
                              widget.onLikeToggled?.call(result['likeCount']);
                            }
                          });
                        },
                      ),
                      Text(
                        "${widget.widget.post.pcomment ?? 0}",
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
                            const SnackBar(
                              content: Text("Save functionality here"),
                            ),
                          );
                        },
                      ),
                      Text(
                        "${widget.widget.post.psave ?? 0}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
