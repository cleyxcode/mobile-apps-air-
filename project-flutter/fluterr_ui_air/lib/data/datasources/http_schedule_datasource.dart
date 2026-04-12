import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/sensor_data.dart';
import '../../constants/app_config.dart';
import '../repositories/schedule_repository.dart';

/// Implementasi HTTP dari ScheduleRepository.
class HttpScheduleDatasource implements ScheduleRepository {
  static const String _baseUrl = AppConfig.apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 10);

  @override
  Future<List<WateringSchedule>> getSchedules() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/schedules'))
        .timeout(_timeout);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final list = json['schedules'] as List<dynamic>;
      return list
          .map((e) => WateringSchedule.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Gagal memuat jadwal');
  }

  @override
  Future<WateringSchedule> createSchedule(WateringSchedule s) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/schedules'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(s.toJson()),
        )
        .timeout(_timeout);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WateringSchedule.fromJson(json['schedule'] as Map<String, dynamic>);
    }
    throw Exception('Gagal membuat jadwal');
  }

  @override
  Future<bool> updateSchedule(String id, Map<String, dynamic> data) async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl/schedules/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        )
        .timeout(_timeout);
    return response.statusCode == 200;
  }

  @override
  Future<bool> deleteSchedule(String id) async {
    final response = await http
        .delete(Uri.parse('$_baseUrl/schedules/$id'))
        .timeout(_timeout);
    return response.statusCode == 200;
  }
}
