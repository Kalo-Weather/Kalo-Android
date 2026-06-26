class ProxyWeatherResponse {
  final ProxyMeta meta;
  final ProxyCoordinates coordinates;
  final ProxyCurrent current;
  final ProxyUV uv;
  final ProxyAQI aqi;
  final ProxyWind wind;
  final ProxyHumidity humidity;
  final ProxyForecast forecast;

  ProxyWeatherResponse({
    required this.meta,
    required this.coordinates,
    required this.current,
    required this.uv,
    required this.aqi,
    required this.wind,
    required this.humidity,
    required this.forecast,
  });

  factory ProxyWeatherResponse.fromJson(Map<String, dynamic> json) {
    return ProxyWeatherResponse(
      meta: ProxyMeta.fromJson(json['meta'] as Map<String, dynamic>),
      coordinates: ProxyCoordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
      current: ProxyCurrent.fromJson(json['current'] as Map<String, dynamic>),
      uv: ProxyUV.fromJson(json['uv'] as Map<String, dynamic>),
      aqi: ProxyAQI.fromJson(json['aqi'] as Map<String, dynamic>),
      wind: ProxyWind.fromJson(json['wind'] as Map<String, dynamic>),
      humidity: ProxyHumidity.fromJson(json['humidity'] as Map<String, dynamic>),
      forecast: ProxyForecast.fromJson(json['forecast'] as Map<String, dynamic>),
    );
  }
}

class ProxyMeta {
  final String serverVersion;
  final String clientCompatibilityMin;
  final String engine;

  ProxyMeta({
    required this.serverVersion,
    required this.clientCompatibilityMin,
    required this.engine,
  });

  factory ProxyMeta.fromJson(Map<String, dynamic> json) => ProxyMeta(
    serverVersion: json['server_version'] as String,
    clientCompatibilityMin: json['client_compatibility_min'] as String,
    engine: json['engine'] as String,
  );
}

class ProxyCoordinates {
  final double lat;
  final double lon;

  ProxyCoordinates({required this.lat, required this.lon});

  factory ProxyCoordinates.fromJson(Map<String, dynamic> json) => ProxyCoordinates(
    lat: (json['lat'] as num).toDouble(),
    lon: (json['lon'] as num).toDouble(),
  );
}

class ProxyCurrent {
  final double temp;
  final double feelsLike;
  final String condition;
  final String illustrationCode;
  final int timestamp;

  ProxyCurrent({
    required this.temp,
    required this.feelsLike,
    required this.condition,
    required this.illustrationCode,
    required this.timestamp,
  });

  factory ProxyCurrent.fromJson(Map<String, dynamic> json) => ProxyCurrent(
    temp: (json['temp'] as num).toDouble(),
    feelsLike: (json['feels_like'] as num).toDouble(),
    condition: json['condition'] as String,
    illustrationCode: json['illustration_code'] as String,
    timestamp: json['timestamp'] as int,
  );
}

class ProxyUV {
  final double index;
  final String level;
  final String msg;

  ProxyUV({required this.index, required this.level, required this.msg});

  factory ProxyUV.fromJson(Map<String, dynamic> json) => ProxyUV(
    index: (json['index'] as num).toDouble(),
    level: json['level'] as String,
    msg: json['msg'] as String,
  );
}

class ProxyAQI {
  final double value;
  final String level;
  final String msg;

  ProxyAQI({required this.value, required this.level, required this.msg});

  factory ProxyAQI.fromJson(Map<String, dynamic> json) => ProxyAQI(
    value: (json['value'] as num).toDouble(),
    level: json['level'] as String,
    msg: json['msg'] as String,
  );
}

class ProxyWind {
  final double speed;
  final double deg;
  final double? gust;

  ProxyWind({required this.speed, required this.deg, this.gust});

  factory ProxyWind.fromJson(Map<String, dynamic> json) => ProxyWind(
    speed: (json['speed'] as num).toDouble(),
    deg: (json['deg'] as num).toDouble(),
    gust: (json['gust'] as num?)?.toDouble(),
  );
}

class ProxyHumidity {
  final double value;
  final double? dewPoint;
  final String msg;

  ProxyHumidity({required this.value, this.dewPoint, required this.msg});

  factory ProxyHumidity.fromJson(Map<String, dynamic> json) => ProxyHumidity(
    value: (json['value'] as num).toDouble(),
    dewPoint: (json['dew_point'] as num?)?.toDouble(),
    msg: json['msg'] as String,
  );
}

class ProxyForecast {
  final List<ProxyHourly> hourly;
  final List<ProxyDaily> daily;

  ProxyForecast({required this.hourly, required this.daily});

  factory ProxyForecast.fromJson(Map<String, dynamic> json) => ProxyForecast(
    hourly: (json['hourly'] as List<dynamic>)
        .map((e) => ProxyHourly.fromJson(e as Map<String, dynamic>))
        .toList(),
    daily: (json['daily'] as List<dynamic>)
        .map((e) => ProxyDaily.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class ProxyHourly {
  final int time;
  final double temp;
  final String condition;

  ProxyHourly({required this.time, required this.temp, required this.condition});

  factory ProxyHourly.fromJson(Map<String, dynamic> json) => ProxyHourly(
    time: json['time'] as int,
    temp: (json['temp'] as num).toDouble(),
    condition: json['condition'] as String,
  );
}

class ProxyDaily {
  final int time;
  final double min;
  final double max;
  final String condition;

  ProxyDaily({required this.time, required this.min, required this.max, required this.condition});

  factory ProxyDaily.fromJson(Map<String, dynamic> json) => ProxyDaily(
    time: json['time'] as int,
    min: (json['min'] as num).toDouble(),
    max: (json['max'] as num).toDouble(),
    condition: json['condition'] as String,
  );
}
