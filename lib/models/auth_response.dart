class AuthResponse {
  final String jwt;
  final String raw;
  final String? rt;

  AuthResponse({
    required this.jwt,
    required this.raw,
    this.rt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      jwt: json['jwt'] ?? '',
      raw: json['raw'] ?? '',
      rt: json['rt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jwt': jwt,
      'raw': raw,
      'rt': rt,
    };
  }
}


