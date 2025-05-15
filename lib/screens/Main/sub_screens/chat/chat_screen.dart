import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:you_can_cook/services/ConversationService.dart';
import 'package:you_can_cook/services/UserService.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:you_can_cook/redux/reducers.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:you_can_cook/redux/actions.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String conversationTitle;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.conversationTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ConversationService _conversationService = ConversationService();
  final UserService _userService = UserService();
  List<Map<String, dynamic>> _messages = [];
  int? _uid;

  @override
  void initState() {
    super.initState();
    _fetchUidAndUserInfo();
    _loadConversation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchUidAndUserInfo() async {
    final uid = await _userService.getCurrentUserUid();
    if (uid != null) {
      setState(() {
        _uid = uid;
      });
      final store = StoreProvider.of<AppState>(context, listen: false);
      await store.dispatch(FetchProfileUserInfo(uid));
    }
  }

  Future<void> _loadConversation() async {
    final messages = await _conversationService.loadConversation(
      widget.conversationId,
    );
    setState(() {
      _messages = messages;
    });
  }

  Future<String> getBotResponse(String question) async {
    await Future.delayed(Duration(seconds: 1)); // Giả lập độ trễ của API
    return "Đây là phản hồi cho: $question";
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final message = _controller.text;
      _controller.clear();

      // Thêm tin nhắn của user
      await _conversationService.addMessage(widget.conversationId, 'user', {
        'text': message,
      }, DateTime.now());

      // Lấy phản hồi từ bot
      final botResponse = await getBotResponse(message);
      await _conversationService.addMessage(widget.conversationId, 'bot', {
        'text': botResponse,
      }, DateTime.now());

      // Tải lại danh sách tin nhắn
      _loadConversation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, String?>(
      converter: (store) => store.state.profileUserInfo?.avatar,
      builder: (context, avatarUrl) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.conversationTitle,
              style: TextStyle(overflow: TextOverflow.ellipsis),
              maxLines: 1,
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUser = message['sender'] == 'user';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment:
                            isUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                        children: [
                          if (!isUser)
                            CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              child: Icon(
                                Icons.android,
                                color: Colors.grey[700],
                              ),
                            ),
                          if (!isUser) const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color:
                                    isUser
                                        ? AppColors.primary
                                        : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    isUser
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['content']['text'],
                                    style: TextStyle(
                                      color:
                                          isUser ? Colors.white : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat(
                                      'HH:mm, dd/MM/yyyy',
                                    ).format(message['timestamp']),
                                    style: TextStyle(
                                      color:
                                          isUser
                                              ? Colors.white70
                                              : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isUser) const SizedBox(width: 8),
                          if (isUser)
                            CircleAvatar(
                              backgroundColor: AppColors.primary,
                              backgroundImage:
                                  avatarUrl != null
                                      ? NetworkImage(avatarUrl)
                                      : null,
                              child:
                                  avatarUrl == null
                                      ? Icon(Icons.person, color: Colors.white)
                                      : null,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
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
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Nhập tin nhắn...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
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
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
