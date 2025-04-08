import 'package:flutter/material.dart';

class CardComment extends StatelessWidget {
  final Map<String, String> comment;

  const CardComment({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            comment['avatar']!.isNotEmpty
                ? NetworkImage(comment['avatar']!)
                : const AssetImage("assets/icons/logo.png") as ImageProvider,
      ),
      title: Text(comment['nickname']!),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment['content']!),
          Text(
            comment['time']!,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
