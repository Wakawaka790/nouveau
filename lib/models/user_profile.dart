class UserProfile {
  UserProfile({required this.name, required this.avatar, this.score = 0});

  final String name;
  final String avatar;
  int score;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'avatar': avatar,
        'score': score,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final rawScore = json['score'];
    final score = rawScore is num
        ? rawScore.toInt()
        : int.tryParse(rawScore?.toString() ?? '') ?? 0;

    return UserProfile(
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '🙂',
      score: score < 0 ? 0 : score,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile && name == other.name && avatar == other.avatar;

  @override
  int get hashCode => Object.hash(name, avatar);
}
