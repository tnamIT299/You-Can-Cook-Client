import 'dart:convert';
import 'package:flutter/foundation.dart';

class Post {
  final int? pid;
  final int uid;
  final String? pcontent;
  final List<String>? pimage;
  final List<String>? phashtag;
  final int? plike;
  final int? pcomment;
  final int? psave;
  final String? prange;
  final DateTime? createAt;
  final String? nickname; // Từ bảng users
  final String? name;
  final String? avatar; // Từ bảng users
  final bool? isWarning;

  Post({
    this.pid,
    required this.uid,
    this.pcontent,
    this.pimage,
    this.phashtag,
    this.plike,
    this.pcomment,
    this.psave,
    this.prange,
    this.createAt,
    this.nickname,
    this.name,
    this.avatar,
    this.isWarning,
  });

  Post copyWith({
    int? pid,
    int? uid,
    String? pcontent,
    List<String>? pimage,
    List<String>? phashtag,
    int? plike,
    int? pcomment,
    int? psave,
    String? prange,
    DateTime? createAt,
    String? nickname,
    String? name,
    String? avatar,
    bool? isWarning,
  }) {
    return Post(
      pid: pid ?? this.pid,
      uid: uid ?? this.uid,
      pcontent: pcontent ?? this.pcontent,
      pimage: pimage ?? this.pimage,
      phashtag: phashtag ?? this.phashtag,
      plike: plike ?? this.plike,
      pcomment: pcomment ?? this.pcomment,
      psave: psave ?? this.psave,
      prange: prange ?? this.prange,
      createAt: createAt ?? this.createAt,
      nickname: nickname ?? this.nickname,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      isWarning: isWarning ?? this.isWarning,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'pcontent': pcontent,
      'pimage': pimage,
      'phashtag': phashtag,
      'plike': plike,
      'pcomment': pcomment,
      'psave': psave,
      'prange': prange,
      'createAt': createAt?.toIso8601String(),
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      pid: map['pid'] != null ? map['pid'] as int : null,
      uid: map['uid'] as int,
      pcontent: map['pcontent']?.toString(),
      pimage:
          map['pimage'] != null
              ? (map['pimage'] is String
                  ? jsonDecode(
                    map['pimage'] as String,
                  ).map<String>((e) => e as String).toList()
                  : List<String>.from(map['pimage'] as List))
              : null,
      phashtag:
          map['phashtag'] != null
              ? (map['phashtag'] is String
                  ? jsonDecode(
                    map['phashtag'] as String,
                  ).map<String>((e) => e as String).toList()
                  : List<String>.from(map['phashtag'] as List))
              : null,
      plike: map['plike'] != null ? map['plike'] as int : null,
      pcomment: map['pcomment'] != null ? map['pcomment'] as int : null,
      psave: map['psave'] != null ? map['psave'] as int : null,
      prange: map['prange']?.toString(),
      createAt:
          map['createAt'] != null
              ? DateTime.parse(map['createAt'] as String)
              : null,
      nickname:
          map['users'] != null && map['users']['nickname'] != null
              ? map['users']['nickname'].toString()
              : null,
      name:
          map['users'] != null && map['users']['name'] != null
              ? map['users']['name'].toString()
              : null,
      avatar:
          map['users'] != null && map['users']['avatar'] != null
              ? map['users']['avatar'].toString()
              : null,
      isWarning: map['isWarning'] != null ? map['isWarning'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) =>
      Post.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<String> parseHashtags(String hashtagText) {
    return hashtagText
        .split(' ')
        .where((tag) => tag.isNotEmpty && tag.startsWith('#'))
        .toList();
  }

  @override
  String toString() {
    return 'Post(pid: $pid, uid: $uid, pcontent: $pcontent, pimage: $pimage, phashtag: $phashtag, plike: $plike, pcomment: $pcomment, psave: $psave, prange: $prange, createAt: $createAt, name: $name, nickname: $nickname, avatar: $avatar, isWarning: $isWarning)';
  }

  @override
  bool operator ==(covariant Post other) {
    if (identical(this, other)) return true;

    return other.pid == pid &&
        other.uid == uid &&
        other.pcontent == pcontent &&
        listEquals(other.pimage, pimage) &&
        listEquals(other.phashtag, phashtag) &&
        other.plike == plike &&
        other.pcomment == pcomment &&
        other.psave == psave &&
        other.prange == prange &&
        other.createAt == createAt &&
        other.nickname == nickname &&
        other.name == name &&
        other.avatar == avatar &&
        other.isWarning == isWarning;
  }

  @override
  int get hashCode {
    return pid.hashCode ^
        uid.hashCode ^
        pcontent.hashCode ^
        pimage.hashCode ^
        phashtag.hashCode ^
        plike.hashCode ^
        pcomment.hashCode ^
        psave.hashCode ^
        prange.hashCode ^
        createAt.hashCode ^
        nickname.hashCode ^
        name.hashCode ^
        avatar.hashCode ^
        isWarning.hashCode;
  }

  static List<String> _parseStringList(String value) {
    if (value.isEmpty) return [];
    try {
      final decoded = json.decode(value);
      if (decoded is List) {
        return List<String>.from(decoded);
      }
    } catch (_) {
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [value];
  }
}
