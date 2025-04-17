// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Badge {
  final int id;
  final String name;
  final String imagePath;
  final String milestone;
  Badge({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.milestone,
  });

  Badge copyWith({
    int? id,
    String? name,
    String? imagePath,
    String? milestone,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      milestone: milestone ?? this.milestone,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'milestone': milestone,
    };
  }

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      id: map['id'] as int,
      name: map['name'] as String,
      imagePath: map['imagePath'] as String,
      milestone: map['milestone'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Badge.fromJson(String source) =>
      Badge.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Badge(id: $id, name: $name, imagePath: $imagePath, milestone: $milestone)';
  }

  @override
  bool operator ==(covariant Badge other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.imagePath == imagePath &&
        other.milestone == milestone;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        imagePath.hashCode ^
        milestone.hashCode;
  }
}
