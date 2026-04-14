import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/sensor_data.dart';
import 'service_locator.dart';

/// Menjalankan jadwal penyiraman lewat API saat aplikasi terbuka,
/// **tanpa** harus membuka layar Mode Manual.
///
/// Catatan: backend Anda juga punya `_schedule_checker`; jika pompa fisik
/// hanya mengikuti DB/ESP, pastikan server + perangkat keras sinkron.
class ScheduleForegroundService {
  ScheduleForegroundService._();
  static final ScheduleForegroundService instance = ScheduleForegroundService._();

  Timer? _poll;
  final Map<String, Timer> _stopTimers = {};
  final Set<String> _firedToday = {};
  int _lastCalendarDay = -1;

  static const Duration _interval = Duration(seconds: 15);

  void start() {
    _poll?.cancel();
    _poll = Timer.periodic(_interval, (_) => unawaited(_evaluate()));
    unawaited(_evaluate());
  }

  void stop() {
    _poll?.cancel();
    _poll = null;
    for (final t in _stopTimers.values) {
      t.cancel();
    }
    _stopTimers.clear();
  }

  /// Panggil saat jadwal dihapus agar timer matikan tidak mengganggu.
  void invalidateSchedule(String scheduleId) {
    _stopTimers[scheduleId]?.cancel();
    _stopTimers.remove(scheduleId);
    _firedToday.remove(scheduleId);
  }

  Future<void> _evaluate() async {
    List<WateringSchedule> schedules;
    try {
      schedules = await ServiceLocator.scheduleRepo.getSchedules();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ScheduleForeground] getSchedules gagal: $e');
      }
      return;
    }

    final now = DateTime.now();
    if (_lastCalendarDay != now.day) {
      _firedToday.clear();
      _lastCalendarDay = now.day;
    }

    final todayKey = WateringSchedule.weekdayKey(now.weekday);
    final nowTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    for (final s in schedules) {
      if (!s.enabled) continue;
      if (!s.days.contains(todayKey)) continue;
      if (WateringSchedule.normalizeTimeToHHmm(s.time) != nowTime) continue;
      if (_firedToday.contains(s.id)) continue;

      _firedToday.add(s.id);
      await _pumpOnForSchedule(s.id);
      _stopTimers[s.id]?.cancel();
      _stopTimers[s.id] = Timer(
        Duration(minutes: s.durationMinutes.clamp(1, 120)),
        () {
          unawaited(_pumpOffForSchedule(s.id));
          _stopTimers.remove(s.id);
        },
      );
    }
  }

  Future<void> _pumpOnForSchedule(String id) async {
    try {
      final ok = await ServiceLocator.sensorRepo.controlPump(
        on: true,
        mode: 'schedule',
      );
      if (kDebugMode) {
        debugPrint('[ScheduleForeground] ON jadwal $id → ${ok ? 'ok' : 'gagal'}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ScheduleForeground] ON error: $e');
      }
    }
  }

  Future<void> _pumpOffForSchedule(String id) async {
    try {
      final ok = await ServiceLocator.sensorRepo.controlPump(
        on: false,
        mode: 'schedule',
      );
      if (kDebugMode) {
        debugPrint('[ScheduleForeground] OFF jadwal $id → ${ok ? 'ok' : 'gagal'}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ScheduleForeground] OFF error: $e');
      }
    }
  }
}
