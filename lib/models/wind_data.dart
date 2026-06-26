class WindData {
  final double speed;
  final double direction;
  final double? gust;

  WindData({
    required this.speed,
    required this.direction,
    this.gust,
  });

  String get directionLabel {
    final dirs = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
                  'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    final index = ((direction / 22.5) + 0.5).floor() % 16;
    return dirs[index];
  }
}
