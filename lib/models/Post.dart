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
      pcontent: map['pcontent'] != null ? map['pcontent'] as String : null,
      pimage:
          map['pimage'] != null
              ? (map['pimage'] is String
                  ? [map['pimage'] as String]
                  : List<String>.from(map['pimage'] as List))
              : null,
      phashtag:
          map['phashtag'] != null
              ? (map['phashtag'] is String
                  ? [map['phashtag'] as String]
                  : List<String>.from(map['phashtag'] as List))
              : null,
      plike: map['plike'] != null ? map['plike'] as int : null,
      pcomment: map['pcomment'] != null ? map['pcomment'] as int : null,
      psave: map['psave'] != null ? map['psave'] as int : null,
      prange: map['prange'] != null ? map['prange'] as String : null,
      createAt:
          map['createAt'] != null
              ? DateTime.parse(map['createAt'] as String)
              : null,
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
    return 'Post(pid: $pid, uid: $uid, pcontent: $pcontent, pimage: $pimage, phashtag: $phashtag, plike: $plike, pcomment: $pcomment, psave: $psave, prange: $prange, createAt: $createAt)';
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
        other.createAt == createAt;
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
        createAt.hashCode;
  }
}
