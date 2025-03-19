
import 'package:flutter/material.dart';
class TagTabSearch extends StatelessWidget {
  const TagTabSearch({
    super.key,
    required this.tags,
  });

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            tags[index],
            style: const TextStyle(color: Colors.blue, fontSize: 16),
          ),
        );
      },
    );
  }
}