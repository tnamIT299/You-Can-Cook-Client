import 'package:flutter/material.dart';
class ChefsTabSearch extends StatelessWidget {
  const ChefsTabSearch({
    super.key,
    required this.chefs,
  });

  final List<Map<String, dynamic>> chefs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: chefs.length,
      itemBuilder: (context, index) {
        final chef = chefs[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(chef["image"]!),
          ),
          title: Text(chef["name"]!),
          subtitle: Row(
            children: [
              const Icon(Icons.star, color: Colors.yellow, size: 16),
              Text("${chef["rating"]}", style: const TextStyle(fontSize: 14)),
            ],
          ),
        );
      },
    );
  }
}