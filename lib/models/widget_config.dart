enum WidgetSize { small, medium, large }

enum WidgetBlockType {
  temperature,
  feelsLike,
  conditionIcon,
  locationName,
  time,
  humidity,
  wind,
  uvIndex,
  aqi,
}

extension WidgetBlockTypeX on WidgetBlockType {
  String get label {
    switch (this) {
      case WidgetBlockType.temperature:
        return 'Temperature';
      case WidgetBlockType.feelsLike:
        return 'Feels Like';
      case WidgetBlockType.conditionIcon:
        return 'Condition Icon';
      case WidgetBlockType.locationName:
        return 'Location Name';
      case WidgetBlockType.time:
        return 'Time';
      case WidgetBlockType.humidity:
        return 'Humidity';
      case WidgetBlockType.wind:
        return 'Wind';
      case WidgetBlockType.uvIndex:
        return 'UV Index';
      case WidgetBlockType.aqi:
        return 'Air Quality';
    }
  }

  WidgetSize get minSize {
    switch (this) {
      case WidgetBlockType.conditionIcon:
      case WidgetBlockType.locationName:
      case WidgetBlockType.temperature:
        return WidgetSize.small;
      case WidgetBlockType.feelsLike:
      case WidgetBlockType.time:
        return WidgetSize.medium;
      case WidgetBlockType.humidity:
      case WidgetBlockType.wind:
      case WidgetBlockType.uvIndex:
      case WidgetBlockType.aqi:
        return WidgetSize.large;
    }
  }
}

final defaultSmallBlocks = [
  WidgetBlockType.locationName,
  WidgetBlockType.temperature,
  WidgetBlockType.conditionIcon,
];

final defaultMediumBlocks = [
  WidgetBlockType.locationName,
  WidgetBlockType.temperature,
  WidgetBlockType.conditionIcon,
  WidgetBlockType.feelsLike,
];

final defaultLargeBlocks = [
  WidgetBlockType.locationName,
  WidgetBlockType.temperature,
  WidgetBlockType.conditionIcon,
  WidgetBlockType.feelsLike,
  WidgetBlockType.humidity,
  WidgetBlockType.wind,
  WidgetBlockType.uvIndex,
  WidgetBlockType.aqi,
];

class WidgetSizeConfig {
  final WidgetSize size;
  final List<WidgetBlockType> blocks;

  const WidgetSizeConfig({required this.size, required this.blocks});

  Map<String, dynamic> toJson() => {
    'size': size.name,
    'blocks': blocks.map((b) => b.name).toList(),
  };

  factory WidgetSizeConfig.fromJson(Map<String, dynamic> json) => WidgetSizeConfig(
    size: WidgetSize.values.byName(json['size'] as String),
    blocks: (json['blocks'] as List).map((b) => WidgetBlockType.values.byName(b as String)).toList(),
  );

  static WidgetSizeConfig smallDefault() => WidgetSizeConfig(size: WidgetSize.small, blocks: List.from(defaultSmallBlocks));
  static WidgetSizeConfig mediumDefault() => WidgetSizeConfig(size: WidgetSize.medium, blocks: List.from(defaultMediumBlocks));
  static WidgetSizeConfig largeDefault() => WidgetSizeConfig(size: WidgetSize.large, blocks: List.from(defaultLargeBlocks));
}

class WidgetConfig {
  final Map<WidgetSize, WidgetSizeConfig> sizes;

  const WidgetConfig({required this.sizes});

  WidgetSizeConfig forSize(WidgetSize size) => sizes[size] ?? WidgetSizeConfig.smallDefault();

  WidgetConfig withUpdated(WidgetSize size, WidgetSizeConfig config) {
    final updated = Map<WidgetSize, WidgetSizeConfig>.from(sizes);
    updated[size] = config;
    return WidgetConfig(sizes: updated);
  }

  List<WidgetBlockType> allBlockTypesFor(WidgetSize size) {
    return WidgetBlockType.values.where((b) => b.minSize.index <= size.index).toList();
  }

  Map<String, dynamic> toJson() => {
    'sizes': sizes.map((key, value) => MapEntry(key.name, value.toJson())),
  };

  factory WidgetConfig.fromJson(Map<String, dynamic> json) {
    final sizesMap = <WidgetSize, WidgetSizeConfig>{};
    if (json['sizes'] is Map) {
      for (final entry in (json['sizes'] as Map).entries) {
        final size = WidgetSize.values.byName(entry.key as String);
        sizesMap[size] = WidgetSizeConfig.fromJson(entry.value as Map<String, dynamic>);
      }
    }
    return WidgetConfig(sizes: sizesMap);
  }

  factory WidgetConfig.defaults() => WidgetConfig(sizes: {
    WidgetSize.small: WidgetSizeConfig.smallDefault(),
    WidgetSize.medium: WidgetSizeConfig.mediumDefault(),
    WidgetSize.large: WidgetSizeConfig.largeDefault(),
  });
}
