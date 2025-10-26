class UserData {
  final int id;
  final String email;
  final String username;
  final String fuba;
  final List<int>? generators;
  final Map<String, int>? inventory;
  final List<String>? equipped;
  final Map<String, dynamic>? rebirthData;
  final List<String>? achievements;
  final Map<String, double>? achievementStats;
  final Map<String, int>? upgrades;

  UserData({
    required this.id,
    required this.email,
    required this.username,
    required this.fuba,
    this.generators,
    this.inventory,
    this.equipped,
    this.rebirthData,
    this.achievements,
    this.achievementStats,
    this.upgrades,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      fuba: json['fuba'] ?? '0',
      generators: json['generators'] != null 
          ? List<int>.from(json['generators']) 
          : null,
      inventory: json['inventory'] != null 
          ? Map<String, int>.from(json['inventory']) 
          : null,
      equipped: json['equipped'] != null 
          ? List<String>.from(json['equipped']) 
          : null,
      rebirthData: json['rebirthData'] != null 
          ? Map<String, dynamic>.from(json['rebirthData']) 
          : null,
      achievements: json['achievements'] != null 
          ? List<String>.from(json['achievements']) 
          : null,
      achievementStats: json['achievementStats'] != null 
          ? Map<String, double>.from(json['achievementStats']) 
          : null,
      upgrades: json['upgrades'] != null 
          ? Map<String, int>.from(json['upgrades']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'fuba': fuba,
      'generators': generators,
      'inventory': inventory,
      'equipped': equipped,
      'rebirthData': rebirthData,
      'achievements': achievements,
      'achievementStats': achievementStats,
      'upgrades': upgrades,
    };
  }
}


