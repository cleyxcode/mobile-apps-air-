class SensorData {
  final double soilMoisture;
  final double temperature;
  final double airHumidity;
  final String label;
  final double confidence;
  final bool needsWatering;
  final String description;
  final bool pumpStatus;
  final String mode;
  final String timestamp;

  const SensorData({
    required this.soilMoisture,
    required this.temperature,
    required this.airHumidity,
    required this.label,
    required this.confidence,
    required this.needsWatering,
    required this.description,
    required this.pumpStatus,
    required this.mode,
    required this.timestamp,
  });

  factory SensorData.fromStatusJson(Map<String, dynamic> json) {
    final latest = json['latest_data'] as Map<String, dynamic>? ?? {};
    return SensorData(
      soilMoisture  : (latest['soil_moisture'] as num?)?.toDouble() ?? 0,
      temperature   : (latest['temperature']   as num?)?.toDouble() ?? 0,
      airHumidity   : (latest['air_humidity']  as num?)?.toDouble() ?? 0,
      label         : latest['label']        as String? ?? '---',
      confidence    : (latest['confidence']   as num?)?.toDouble() ?? 0,
      needsWatering : latest['needs_watering'] as bool? ?? false,
      description   : latest['description']  as String? ?? '',
      pumpStatus    : json['pump_status']     as bool? ?? false,
      mode          : json['mode']            as String? ?? 'auto',
      timestamp     : latest['timestamp']     as String? ?? '',
    );
  }

  static SensorData empty() => const SensorData(
    soilMoisture  : 0,
    temperature   : 0,
    airHumidity   : 0,
    label         : '---',
    confidence    : 0,
    needsWatering : false,
    description   : '',
    pumpStatus    : false,
    mode          : 'auto',
    timestamp     : '',
  );

  String get labelDisplay {
    switch (label) {
      case 'Kering': return 'KERING';
      case 'Lembab': return 'OPTIMAL';
      case 'Basah':  return 'BASAH';
      default:       return label;
    }
  }

  String get labelEmoji {
    switch (label) {
      case 'Kering': return '🌵';
      case 'Lembab': return '😊';
      case 'Basah':  return '💧';
      default:       return '🌿';
    }
  }
}

class HistoryRecord {
  final String timestamp;
  final double soilMoisture;
  final double temperature;
  final double airHumidity;
  final String label;
  final bool pumpStatus;

  const HistoryRecord({
    required this.timestamp,
    required this.soilMoisture,
    required this.temperature,
    required this.airHumidity,
    required this.label,
    required this.pumpStatus,
  });

  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    return HistoryRecord(
      timestamp    : json['timestamp']     as String? ?? '',
      soilMoisture : (json['soil_moisture'] as num?)?.toDouble() ?? 0,
      temperature  : (json['temperature']   as num?)?.toDouble() ?? 0,
      airHumidity  : (json['air_humidity']  as num?)?.toDouble() ?? 0,
      label        : json['label']          as String? ?? '---',
      pumpStatus   : json['pump_status']    as bool? ?? false,
    );
  }
}

// ── Model Jadwal Penyiraman ───────────────────────────────────────────────────
class WateringSchedule {
  final String       id;
  final String       name;
  final String       time;             // "06:00"
  final int          durationMinutes;
  final List<String> days;
  final bool         enabled;
  final String?      lastTriggered;

  const WateringSchedule({
    required this.id,
    required this.name,
    required this.time,
    required this.durationMinutes,
    required this.days,
    required this.enabled,
    this.lastTriggered,
  });

  factory WateringSchedule.fromJson(Map<String, dynamic> json) {
    return WateringSchedule(
      id              : json['id']               as String? ?? '',
      name            : json['name']             as String? ?? '',
      time            : json['time']             as String? ?? '00:00',
      durationMinutes : (json['duration_minutes'] as num?)?.toInt() ?? 5,
      days            : List<String>.from(json['days'] as List? ?? []),
      enabled         : json['enabled']          as bool? ?? true,
      lastTriggered   : json['last_triggered']   as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name'            : name,
    'time'            : time,
    'duration_minutes': durationMinutes,
    'days'            : days,
    'enabled'         : enabled,
  };

  WateringSchedule copyWith({
    String? name,
    String? time,
    int?    durationMinutes,
    List<String>? days,
    bool?   enabled,
  }) => WateringSchedule(
    id              : id,
    name            : name            ?? this.name,
    time            : time            ?? this.time,
    durationMinutes : durationMinutes ?? this.durationMinutes,
    days            : days            ?? this.days,
    enabled         : enabled         ?? this.enabled,
    lastTriggered   : lastTriggered,
  );

  static const List<String> allDays = [
    'senin','selasa','rabu','kamis','jumat','sabtu','minggu'
  ];

  static const Map<String, String> dayLabel = {
    'senin'  : 'Sen', 'selasa' : 'Sel', 'rabu'   : 'Rab',
    'kamis'  : 'Kam', 'jumat'  : 'Jum', 'sabtu'  : 'Sab',
    'minggu' : 'Min',
  };

  bool get isEveryDay => days.length == 7;

  String get daysDisplay {
    if (isEveryDay) return 'Setiap hari';
    return days.map((d) => dayLabel[d] ?? d).join(', ');
  }
}
