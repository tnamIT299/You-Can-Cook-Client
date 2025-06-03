import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:you_can_cook/services/ConversationService.dart';
import 'package:you_can_cook/services/UserService.dart';
import 'package:you_can_cook/screens/Main/sub_screens/chat/chat_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatAI_Tab extends StatefulWidget {
  const ChatAI_Tab({super.key});

  @override
  State<ChatAI_Tab> createState() => _ChatAI_TabState();
}

class _ChatAI_TabState extends State<ChatAI_Tab> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _chatHistory = [];
  final ConversationService _conversationService = ConversationService();
  final UserService _userService = UserService();
  int? _uid;
  bool _isLoadingUid = true;

  @override
  void initState() {
    super.initState();
    _fetchUidAndChatHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchUidAndChatHistory() async {
    setState(() {
      _isLoadingUid = true;
    });
    final uid = await _userService.getCurrentUserUid();
    setState(() {
      _uid = uid;
      _isLoadingUid = false;
    });
    if (uid != null) {
      final history = await _conversationService.fetchChatHistory(
        uid.toString(),
      );
      setState(() {
        _chatHistory = history;
      });
    }
  }

  Future<Map<String, dynamic>> _callChatbotApi(String message) async {
    try {
      final response = await http.post(
        Uri.parse(
          'http://192.168.43.92:5000/api/chat',
        ), // Thay bằng địa chỉ API của bạn
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"query": message}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"response": "Có lỗi xảy ra!", "recipes": []};
      }
    } catch (e) {
      return {"response": "Không kết nối được!", "recipes": []};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUid) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 80,
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lịch sử trò chuyện',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_square, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            ..._chatHistory.map((chat) {
              return ListTile(
                title: Text(
                  chat['question'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(chat['timestamp']),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        final TextEditingController titleController =
                            TextEditingController(text: chat['question']);
                        final newTitle = await showDialog<String>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text('Chỉnh sửa tiêu đề'),
                                content: TextField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập tiêu đề mới',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (titleController.text
                                          .trim()
                                          .isNotEmpty) {
                                        Navigator.pop(
                                          context,
                                          titleController.text.trim(),
                                        );
                                      }
                                    },
                                    child: Text(
                                      'Lưu',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (newTitle != null && newTitle.isNotEmpty) {
                          try {
                            await _conversationService.updateConversationTitle(
                              chat['id'],
                              newTitle,
                            );
                            await _fetchUidAndChatHistory();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đã cập nhật tiêu đề')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi khi cập nhật: $e')),
                            );
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmDelete = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text('Xóa cuộc hội thoại'),
                                content: Text(
                                  'Bạn có chắc chắn muốn xóa cuộc hội thoại này không?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: Text(
                                      'Xóa',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (confirmDelete == true) {
                          try {
                            await _conversationService.deleteConversation(
                              chat['id'],
                            );
                            await _fetchUidAndChatHistory();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đã xóa cuộc hội thoại')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi khi xóa: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChatScreen(
                            conversationId: chat['id'],
                            conversationTitle: chat['question'],
                          ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(300, 300),
                        painter: CirclePainter(),
                      ),
                      Positioned(
                        bottom: 15,
                        right: 90,
                        child: Image.asset(
                          'assets/images/ai.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 80,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            'Chào bạn, mình là AI CHEF. Bạn có thể hỏi mình về bất cứ điều gì liên quan đến nấu ăn nhé!',
                            style: TextStyle(fontSize: 14),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Chào mừng trở lại',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const Text(
                    'Mình có thể giúp gì cho bạn?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Icon(Icons.mic, color: Colors.grey[600]),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () async {
                          if (_controller.text.isNotEmpty) {
                            final question = _controller.text;
                            _controller.clear();
                            final conversationId = await _conversationService
                                .createNewConversation(
                                  _uid.toString(),
                                  question,
                                );
                            if (conversationId != null) {
                              // Chuyển hướng sang ChatScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatScreen(
                                        conversationId: conversationId,
                                        conversationTitle: question,
                                      ),
                                ),
                              );
                            }
                            _fetchUidAndChatHistory(); // Cập nhật lịch sử
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.primary.withOpacity(0.3)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
