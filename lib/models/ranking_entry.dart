class RankingEntry {
  final String username;

  RankingEntry({
    required this.username,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      username: json['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
    };
  }
}


