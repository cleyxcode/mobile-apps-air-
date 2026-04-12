import '../../models/sensor_data.dart';

/// Kontrak data layer untuk manajemen jadwal penyiraman.
/// Pisah dari SensorRepository karena domain berbeda
/// (sensor = realtime IoT, schedule = CRUD persistensi).
abstract class ScheduleRepository {
  Future<List<WateringSchedule>> getSchedules();
  Future<WateringSchedule> createSchedule(WateringSchedule s);
  Future<bool> updateSchedule(String id, Map<String, dynamic> data);
  Future<bool> deleteSchedule(String id);
}
