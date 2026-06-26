class WeatherLocation {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final int order;

  WeatherLocation({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.order,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'order': order,
      };

  factory WeatherLocation.fromJson(Map<String, dynamic> json) =>
      WeatherLocation(
        id: json['id'] as int?,
        name: json['name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        order: json['order'] as int,
      );
}