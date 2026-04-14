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

  /// Normalisasi `mode` dari API (hindari spasi / casing dari MySQL).
  static String normalizeMode(dynamic raw) {
    final s = (raw as String? ?? 'auto').trim().toLowerCase();
    if (s == 'auto' || s == 'manual' || s == 'schedule') return s;
    return 'auto';
  }

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
      mode          : normalizeMode(json['mode']),
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
  /// Dari API `needs_watering` (klasifikasi KNN).
  final bool needsWatering;
  final double confidence;
  final String mode;

  const HistoryRecord({
    required this.timestamp,
    required this.soilMoisture,
    required this.temperature,
    required this.airHumidity,
    required this.label,
    required this.pumpStatus,
    this.needsWatering = false,
    this.confidence = 0,
    this.mode = 'auto',
  });

  static String _timestampToString(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    return v.toString();
  }

  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    return HistoryRecord(
      timestamp    : _timestampToString(json['timestamp']),
      soilMoisture : (json['soil_moisture'] as num?)?.toDouble() ?? 0,
      temperature  : (json['temperature']   as num?)?.toDouble() ?? 0,
      airHumidity  : (json['air_humidity']  as num?)?.toDouble() ?? 0,
      label        : json['label']          as String? ?? '---',
      pumpStatus   : json['pump_status']    as bool? ?? false,
      needsWatering: json['needs_watering'] as bool? ?? false,
      confidence   : (json['confidence']   as num?)?.toDouble() ?? 0,
      mode         : json['mode']           as String? ?? 'auto',
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

  /// Samakan format API/MySQL (`08:00:00`, `8:05`) ke `HH:mm` untuk perbandingan jam lokal.
  static String normalizeTimeToHHmm(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '00:00';
    final parts = raw.trim().split(':');
    if (parts.isEmpty) return '00:00';
    final h = int.tryParse(parts[0].trim()) ?? 0;
    final mRaw = parts.length > 1 ? parts[1].trim() : '0';
    final mDigits = RegExp(r'^\d+').stringMatch(mRaw) ?? '0';
    final m = int.tryParse(mDigits) ?? 0;
    return '${h.clamp(0, 23).toString().padLeft(2, '0')}:${m.clamp(0, 59).toString().padLeft(2, '0')}';
  }

  static List<String> normalizeDays(Iterable<dynamic>? raw) {
    if (raw == null) return [];
    return raw
        .map((e) => e.toString().trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// `DateTime.weekday`: 1 = Senin … 7 = Minggu
  static String weekdayKey(int weekday) {
    const map = {
      1: 'senin',
      2: 'selasa',
      3: 'rabu',
      4: 'kamis',
      5: 'jumat',
      6: 'sabtu',
      7: 'minggu',
    };
    return map[weekday] ?? 'senin';
  }

  factory WateringSchedule.fromJson(Map<String, dynamic> json) {
    return WateringSchedule(
      id              : json['id']               as String? ?? '',
      name            : json['name']             as String? ?? '',
      time            : normalizeTimeToHHmm(json['time']?.toString()),
      durationMinutes : (json['duration_minutes'] as num?)?.toInt() ?? 5,
      days            : normalizeDays(json['days'] as List?),
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
