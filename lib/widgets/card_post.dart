import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:you_can_cook/models/Post.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago/src/messages/vi_messages.dart';
import 'package:you_can_cook/screens/Main/main_tab/profile_tab.dart';

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
  int _currentImageIndex = 0;
  @override
  void initState() {
    super.initState();
    // Đăng ký ngôn ngữ Tiếng Việt
    timeago.setLocaleMessages('vi', timeago.ViMessages());
  }

  // Hàm chuyển hướng đến ProfileTab
  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ProfileTab(
              userId: widget.post.uid,
            ), // Truyền UID của người đăng
      ),
    );
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
              onTap:
                  () => _navigateToProfile(
                    context,
                  ), // Chuyển hướng khi nhấn avatar
              child: CircleAvatar(
                backgroundImage:
                    widget.post.avatar != null
                        ? NetworkImage(widget.post.avatar!)
                        : const AssetImage("assets/icons/logo.png")
                            as ImageProvider,
              ),
            ),
            title: GestureDetector(
              onTap:
                  () => _navigateToProfile(
                    context,
                  ), // Chuyển hướng khi nhấn nickname
              child: Text(widget.post.nickname ?? 'Unknown User'),
            ),
            trailing:
                isPostOwner
                    ? IconButton(
                      icon: const Icon(Icons.more_horiz),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("More options for post owner"),
                          ),
                        );
                      },
                    )
                    : null,
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
          Padding(
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
                          const SnackBar(
                            content: Text("Like functionality here"),
                          ),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Comment functionality here"),
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
                          const SnackBar(
                            content: Text("Save functionality here"),
                          ),
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
            child: Text(
              widget.post.pcontent ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
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
