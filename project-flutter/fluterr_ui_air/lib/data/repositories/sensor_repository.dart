import '../../models/sensor_data.dart';

/// Kontrak data layer untuk sensor & kontrol pompa.
/// Implementasi bisa berupa HTTP (saat ini) atau Supabase (masa depan).
/// Screens hanya bergantung pada interface ini — zero perubahan saat ganti backend.
abstract class SensorRepository {
  Future<SensorData> getStatus();
  Future<List<HistoryRecord>> getHistory({int limit = 50});
  Future<bool> controlPump({required bool on, String mode = 'manual'});
  Future<Map<String, dynamic>> getModelInfo();
  Future<bool> isOnline();
}
