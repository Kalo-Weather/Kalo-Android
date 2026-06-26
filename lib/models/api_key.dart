class ApiKey {
  final int? id;
  final String provider;
  final String encryptedValue;

  ApiKey({
    this.id,
    required this.provider,
    required this.encryptedValue,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'provider': provider,
        'encryptedValue': encryptedValue,
      };

  factory ApiKey.fromJson(Map<String, dynamic> json) => ApiKey(
        id: json['id'] as int?,
        provider: json['provider'] as String,
        encryptedValue: json['encryptedValue'] as String,
      );
}