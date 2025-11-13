class Profile {
  final String profilePicture;

  Profile({
    required this.profilePicture,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      profilePicture: json['profilePicture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profilePicture': profilePicture,
    };
  }

  Profile copyWith({
    String? profilePicture,
  }) {
    return Profile(
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}

