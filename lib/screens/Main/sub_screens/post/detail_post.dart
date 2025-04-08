import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:you_can_cook/models/Post.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago/src/messages/vi_messages.dart';
import 'package:you_can_cook/screens/Main/main_tab/profile_tab.dart';
import 'package:you_can_cook/widgets/card_comment.dart';

void registerTimeagoMessages() {
  timeago.setLocaleMessages('vi', timeago.ViMessages());
}

class DetailPostScreen extends StatefulWidget {
  final Post post;
  final String? currentUserUid;

  const DetailPostScreen({super.key, required this.post, this.currentUserUid});

  @override
  _DetailPostScreenState createState() => _DetailPostScreenState();
}

class _DetailPostScreenState extends State<DetailPostScreen> {
  int _currentImageIndex = 0;
  final TextEditingController _commentController = TextEditingController();

  // Dữ liệu giả cho bình luận
  final List<Map<String, String>> _fakeComments = [
    {
      'avatar': "",
      'nickname': 'NguyenVanA',
      'content': 'Món ăn này trông ngon quá!',
      'time': '5 phút trước',
    },
    {
      'avatar': "",
      'nickname': 'TranThiB',
      'content': 'Cảm ơn bạn đã chia sẻ công thức.',
      'time': '10 phút trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
    {
      'avatar': "",
      'nickname': 'LeVanC',
      'content': 'Mình sẽ thử làm cuối tuần này.',
      'time': '1 giờ trước',
    },
  ];
  int _commentsToShow = 8;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileTab(userId: widget.post.uid),
      ),
    );
  }

  void _submitComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _fakeComments.insert(0, {
          'avatar': "", // Thay bằng avatar người dùng hiện tại
          'nickname': 'Bạn', // Thay bằng nickname người dùng hiện tại
          'content': _commentController.text,
          'time': 'Vừa xong',
        });
        _commentController.clear();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Bình luận đã được thêm")));
    }
  }

  void _loadMoreComments() {
    setState(() {
      _commentsToShow += 10; // Tăng số lượng bình luận hiển thị thêm 10
    });
  }

  @override
  Widget build(BuildContext context) {
    final String relativeTime = timeago.format(
      widget.post.createAt ?? DateTime.now(),
      locale: 'vi',
    );
    final List<String>? images = widget.post.pimage;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Chi tiết bài viết",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin người đăng và bài viết
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
                        widget.post.nickname ??
                            'you_can_cook ${DateTime.now().microsecondsSinceEpoch}',
                      ),
                    ),
                    subtitle: Text(relativeTime),
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
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return const Center(
                                              child: Text(
                                                'Error loading image',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
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
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.post.pcontent ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (widget.post.phashtag != null &&
                      widget.post.phashtag!.isNotEmpty)
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
                  // Nút Like, Comment, Save
                  FunctionButton(widget: widget),
                  const Divider(),
                  // Danh sách bình luận
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Bình luận",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._fakeComments
                            .take(
                              _commentsToShow,
                            ) // Hiển thị tối đa _commentsToShow bình luận
                            .map((comment) {
                              return CardComment(comment: comment);
                            }),
                        if (_commentsToShow < _fakeComments.length)
                          Center(
                            child: TextButton(
                              onPressed: _loadMoreComments,
                              child: const Text(
                                "Xem thêm",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // TextField để nhập bình luận
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      widget.post.avatar != null
                          ? NetworkImage(widget.post.avatar!)
                          : const AssetImage("assets/icons/logo.png")
                              as ImageProvider,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Viết bình luận...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FunctionButton extends StatelessWidget {
  const FunctionButton({super.key, required this.widget});

  final DetailPostScreen widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
              Text("${widget.post.plike ?? 0}"),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.comment, color: AppColors.primary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Comment functionality here")),
                  );
                },
              ),
              Text("${widget.post.pcomment ?? 0}"),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.bookmark_border,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Save functionality here")),
                  );
                },
              ),
              Text("${widget.post.psave ?? 0}"),
            ],
          ),
        ],
      ),
    );
  }
}
