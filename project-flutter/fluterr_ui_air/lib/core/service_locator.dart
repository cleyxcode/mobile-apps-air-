import '../data/repositories/sensor_repository.dart';
import '../data/repositories/schedule_repository.dart';
import '../data/datasources/http_sensor_datasource.dart';
import '../data/datasources/http_schedule_datasource.dart';

/// Dependency Injection sederhana — tidak perlu package tambahan.
///
/// Cara pakai di screens:
///   ServiceLocator.sensorRepo.getStatus()
///   ServiceLocator.scheduleRepo.getSchedules()
///
/// Cara ganti ke Supabase (masa depan):
///   1. Buat SupabaseSensorDatasource implements SensorRepository
///   2. Di setup(), ubah: sensorRepo = SupabaseSensorDatasource()
///   3. Tidak ada perubahan di screens sama sekali.
class ServiceLocator {
  static late SensorRepository sensorRepo;
  static late ScheduleRepository scheduleRepo;

  /// Dipanggil sekali di main() sebelum runApp().
  static void setup() {
    sensorRepo   = HttpSensorDatasource();
    scheduleRepo = HttpScheduleDatasource();
  }
}
