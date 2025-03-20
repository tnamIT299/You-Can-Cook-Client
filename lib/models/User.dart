// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

// lib/models/user.dart
class User {
  final int uid;
  final String name;
  final String? nickname;
  final String email;
  final String? gender;
  final String? avatar;
  final String? bio;
  final bool? onlineStatus;
  final int? follower;
  final int? following;
  final int? totalPoint;
  final List<String>? badges;
  User({
    required this.uid,
    required this.name,
    this.nickname,
    required this.email,
    this.gender,
    this.avatar,
    this.bio,
    this.onlineStatus,
    this.follower,
    this.following,
    this.totalPoint,
    this.badges,
  });

  User copyWith({
    int? uid,
    String? name,
    String? nickname,
    String? email,
    String? gender,
    String? avatar,
    String? bio,
    bool? onlineStatus,
    int? follower,
    int? following,
    int? totalPoint,
    List<String>? badges,
  }) {
    return User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      onlineStatus: onlineStatus ?? this.onlineStatus,
      follower: follower ?? this.follower,
      following: following ?? this.following,
      totalPoint: totalPoint ?? this.totalPoint,
      badges: badges ?? this.badges,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'nickname': nickname,
      'email': email,
      'gender': gender,
      'avatar': avatar,
      'bio': bio,
      'onlineStatus': onlineStatus,
      'follower': follower,
      'following': following,
      'totalPoint': totalPoint,
      'badges': badges,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] as int,
      name: map['name'] as String,
      nickname: map['nickname'] != null ? map['nickname'] as String : null,
      email: map['email'] as String,
      gender: map['gender'] != null ? map['gender'] as String : null,
      avatar: map['avatar'] != null ? map['avatar'] as String : null,
      bio: map['bio'] != null ? map['bio'] as String : null,
      onlineStatus:
          map['onlineStatus'] != null ? map['onlineStatus'] as bool : null,
      follower: map['follower'] != null ? map['follower'] as int : null,
      following: map['following'] != null ? map['following'] as int : null,
      totalPoint: map['totalPoint'] != null ? map['totalPoint'] as int : null,
      badges:
          map['badges'] != null
              ? (map['badges'] is String
                  ? jsonDecode(
                    map['badges'] as String,
                  ).map<String>((e) => e as String).toList()
                  : List<String>.from(map['badges'] as List))
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(uid: $uid, name: $name, nickname: $nickname, email: $email, gender: $gender, avatar: $avatar, bio: $bio, onlineStatus: $onlineStatus, follower: $follower, following: $following, totalPoint: $totalPoint, badges: $badges)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.name == name &&
        other.nickname == nickname &&
        other.email == email &&
        other.gender == gender &&
        other.avatar == avatar &&
        other.bio == bio &&
        other.onlineStatus == onlineStatus &&
        other.follower == follower &&
        other.following == following &&
        other.totalPoint == totalPoint &&
        listEquals(other.badges, badges);
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        nickname.hashCode ^
        email.hashCode ^
        gender.hashCode ^
        avatar.hashCode ^
        bio.hashCode ^
        onlineStatus.hashCode ^
        follower.hashCode ^
        following.hashCode ^
        totalPoint.hashCode ^
        badges.hashCode;
  }
}
