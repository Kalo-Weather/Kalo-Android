class UVIndex {
  final double value;
  final String label;
  final String protectionTip;

  UVIndex({
    required this.value,
    required this.label,
    required this.protectionTip,
  });

  factory UVIndex.fromDouble(double value) {
    String label;
    String tip;
    if (value <= 2) {
      label = 'Low';
      tip = 'No protection needed';
    } else if (value <= 5) {
      label = 'Moderate';
      tip = 'Wear sunscreen if outside';
    } else if (value <= 7) {
      label = 'High';
      tip = 'Wear SPF 30+, seek shade at midday';
    } else if (value <= 10) {
      label = 'Very High';
      tip = 'SPF 50+, avoid midday sun';
    } else {
      label = 'Extreme';
      tip = 'Avoid going outside';
    }
    return UVIndex(value: value, label: label, protectionTip: tip);
  }

  double get progress => (value / 11).clamp(0.0, 1.0);
}
