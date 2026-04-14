import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/sensor_data.dart';
import '../../constants/app_config.dart';
import '../repositories/sensor_repository.dart';

/// Implementasi HTTP dari SensorRepository.
/// Untuk ganti ke Supabase: buat SupabaseSensorDatasource implements SensorRepository,
/// lalu ubah satu baris di ServiceLocator.setup() — screens tidak perlu diubah.
class HttpSensorDatasource implements SensorRepository {
  static const String _baseUrl = AppConfig.apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 10);
  /// Ubah mode / pompa butuh waktu di jaringan lemah — hindari timeout palsu.
  static const Duration _controlTimeout = Duration(seconds: 18);

  @override
  Future<SensorData> getStatus() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/status'))
        .timeout(_timeout);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return SensorData.fromStatusJson(json);
    }
    if (response.statusCode >= 500) {
      throw Exception(
        'Server mengembalikan error ${response.statusCode} pada /status. '
        'Periksa log backend (sering: koneksi database / env DB_HOST).',
      );
    }
    throw Exception('Gagal memuat status: ${response.statusCode}');
  }

  @override
  Future<List<HistoryRecord>> getHistory({int limit = 50}) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/history?limit=$limit'))
        .timeout(_timeout);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final records = json['records'] as List<dynamic>;
      return records
          .map((e) => HistoryRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Gagal memuat riwayat: ${response.statusCode}');
  }

  @override
  Future<bool> controlPump({required bool on, String mode = 'manual'}) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/control'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'action': on ? 'on' : 'off', 'mode': mode}),
        )
        .timeout(_controlTimeout);
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<Map<String, dynamic>> getModelInfo() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/model-info'))
        .timeout(_timeout);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Gagal memuat info model: ${response.statusCode}');
  }

  @override
  Future<bool> isOnline() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/'))
          .timeout(const Duration(seconds: 15));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
