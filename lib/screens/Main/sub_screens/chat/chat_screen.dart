import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:you_can_cook/services/ConversationService.dart';
import 'package:you_can_cook/services/UserService.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:you_can_cook/redux/reducers.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:you_can_cook/redux/actions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final ScrollController _scrollController = ScrollController();
  int? _uid;
  bool _isLoading = true;
  bool _isBotLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUidAndUserInfo();
    _loadConversation();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
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
    setState(() {
      _isLoading = true;
    });
    final messages = await _conversationService.loadConversation(
      widget.conversationId,
    );
    setState(() {
      _messages = messages;
      _isLoading = false;
    });

    // Kiểm tra nếu chưa có phản hồi từ chatbot, gọi API
    if (_messages.isNotEmpty &&
        !_messages.any((msg) => msg['sender'] == 'bot')) {
      await _fetchInitialBotResponse();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _fetchInitialBotResponse() async {
    setState(() {
      _isBotLoading = true;
    });

    final userMessage = _messages.firstWhere(
      (msg) => msg['sender'] == 'user',
      orElse: () => <String, dynamic>{},
    );
    if (userMessage.isNotEmpty) {
      final botResponse = await _callChatbotApi(userMessage['content']['text']);
      await _conversationService.addMessage(widget.conversationId, 'bot', {
        'text': botResponse['response'],
        'recipes': botResponse['recipes'],
      }, DateTime.now());
      await _loadConversation();
    }

    setState(() {
      _isBotLoading = false;
    });
  }

  Future<Map<String, dynamic>> _callChatbotApi(String message) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.43.92:5000/api/chat'),
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

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final message = _controller.text;
    _controller.clear();

    await _conversationService.addMessage(widget.conversationId, 'user', {
      'text': message,
    }, DateTime.now());

    setState(() {
      _isBotLoading = true;
    });

    await _loadConversation();

    final botResponse = await _callChatbotApi(message);

    await _conversationService.addMessage(widget.conversationId, 'bot', {
      'text': botResponse['response'],
      'recipes': botResponse['recipes'],
    }, DateTime.now());

    await _loadConversation();
    setState(() {
      _isBotLoading = false;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildRecipeImage(String? imageUrl, {double? height, double? width}) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/icons/logo.png',
            height: height,
            width: width,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      return Image.asset(
        'assets/icons/logo.png',
        height: height,
        width: width,
        fit: BoxFit.cover,
      );
    }
  }

  void _showRecipeDialog(Map<String, dynamic> recipe) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(recipe["name"] ?? "Không có tiêu đề"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecipeImage(recipe["image"], height: 150),
                  SizedBox(height: 8),
                  Text("Thời gian nấu: ${recipe["time"] ?? 'Không xác định'}"),
                  Text("Độ khó: ${recipe["difficulty"] ?? 'Không xác định'}"),
                  SizedBox(height: 8),
                  Text(
                    "Nguyên liệu:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (recipe["ingredients"] != null &&
                      recipe["ingredients"].isNotEmpty)
                    ...recipe["ingredients"]
                        .map<Widget>((item) => Text("- ${item ?? ''}"))
                        .toList()
                  else
                    const Text("- Không có thông tin nguyên liệu"),
                  SizedBox(height: 8),
                  Text(
                    "Bước làm:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (recipe["steps"] != null && recipe["steps"].isNotEmpty)
                    ...recipe["steps"]
                        .map<Widget>((item) => Text("- ${item ?? ''}"))
                        .toList()
                  else
                    const Text("- Không có thông tin bước làm"),
                  if (recipe["nutrition"] != null &&
                      recipe["nutrition"].isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      "Thông tin dinh dưỡng:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...recipe["nutrition"]
                        .map<Widget>((item) => Text("- $item"))
                        .toList(),
                  ],
                  if (recipe["suggestions"] != null &&
                      recipe["suggestions"].isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      "Đề xuất giải pháp:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...recipe["suggestions"]
                        .map<Widget>((item) => Text("- $item"))
                        .toList(),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Đóng"),
              ),
            ],
          ),
    );
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
          body:
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _messages.length + (_isBotLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_isBotLoading && index == _messages.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.grey[300],
                                      child: Icon(
                                        Icons.android,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Image.asset(
                                        'assets/images/meme-typing.gif',
                                        height: 50,
                                        width: 50,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final message = _messages[index];
                            final isUser = message['sender'] == 'user';
                            final content = message['content'];
                            final recipes = content['recipes'] ?? [];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    isUser
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: [
                                  Row(
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                isUser
                                                    ? CrossAxisAlignment.end
                                                    : CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                content['text'],
                                                style: TextStyle(
                                                  color:
                                                      isUser
                                                          ? Colors.white
                                                          : Colors.black,
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
                                                  ? Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                  )
                                                  : null,
                                        ),
                                    ],
                                  ),
                                  if (recipes.isNotEmpty)
                                    Container(
                                      height: 150,
                                      margin: const EdgeInsets.only(top: 8),
                                      child: GridView.builder(
                                        scrollDirection: Axis.horizontal,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 1,
                                              mainAxisSpacing: 8,
                                              childAspectRatio: 1,
                                            ),
                                        itemCount: recipes.length,
                                        itemBuilder: (context, i) {
                                          var recipe = recipes[i];
                                          if (recipe["image"] == null ||
                                              recipe["image"]
                                                  .toString()
                                                  .isEmpty) {
                                            recipe["image"] = null;
                                          }
                                          return GestureDetector(
                                            onTap:
                                                () => _showRecipeDialog(recipe),
                                            child: Card(
                                              elevation: 2,
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    child:
                                                        recipe["image"] !=
                                                                    null &&
                                                                recipe["image"]
                                                                    .toString()
                                                                    .isNotEmpty
                                                            ? Image.network(
                                                              recipe["image"],
                                                              fit: BoxFit.cover,
                                                              width:
                                                                  double
                                                                      .infinity,
                                                              errorBuilder: (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Image.asset(
                                                                  'assets/icons/logo.png',
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                  width:
                                                                      double
                                                                          .infinity,
                                                                );
                                                              },
                                                            )
                                                            : Image.asset(
                                                              'assets/icons/logo.png',
                                                              fit: BoxFit.cover,
                                                              width:
                                                                  double
                                                                      .infinity,
                                                            ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(4),
                                                    child: Text(
                                                      recipe["name"] ?? "",
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
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
                                  icon: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
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
