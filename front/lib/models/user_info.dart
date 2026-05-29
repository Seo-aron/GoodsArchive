class UserInfo {
  final int id;
  final String nickname;
  final String? profileImageUrl;

  const UserInfo({
    required this.id,
    required this.nickname,
    this.profileImageUrl,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int,
      nickname: json['nickname'] as String? ?? '이름 없음',
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }
}
