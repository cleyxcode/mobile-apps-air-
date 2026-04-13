import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../core/service_locator.dart';
import '../../models/sensor_data.dart';
import '../../widgets/bottom_navigation.dart';

class AIControlScreen extends StatefulWidget {
  const AIControlScreen({super.key});

  @override
  State<AIControlScreen> createState() => _AIControlScreenState();
}

/// Catatan arsitektur:
/// Logika auto-watering SEPENUHNYA ditangani oleh backend (FastAPI).
/// Saat ESP32 POST /sensor → backend jalankan KNN → jika Kering & mode=auto
/// → backend langsung update pump_status di database (tanpa perlu perintah dari app).
/// App hanya polling /status untuk menampilkan kondisi terkini.
class _AIControlScreenState extends State<AIControlScreen> {
  SensorData? _sensorData;
  bool _initialLoading = true;
  bool _actionLoading = false;
  String _statusMsg = '';
  bool _isError = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    // Poll setiap 30 detik — hanya untuk update tampilan
    // Auto-watering ditangani sepenuhnya oleh backend saat ESP32 kirim data
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchStatus());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  /// Ambil status terkini dari backend untuk ditampilkan di UI
  Future<void> _fetchStatus() async {
    try {
      final data = await ServiceLocator.sensorRepo.getStatus();
      if (!mounted) return;
      setState(() {
        _sensorData = data;
        _initialLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _initialLoading = false);
    }
  }

  /// Manual force-water button: override AI, pump on with mode='manual'
  Future<void> _forceWater() async {
    if (_actionLoading) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _actionLoading = true;
      _statusMsg = 'Mengirim perintah siram...';
      _isError = false;
    });

    try {
      final success = await ServiceLocator.sensorRepo
          .controlPump(on: true, mode: 'manual');
      if (mounted) {
        setState(() {
          _actionLoading = false;
          _statusMsg = success
              ? '✓ Pompa dinyalakan (Override Manual)'
              : 'Gagal menyalakan pompa. Coba lagi.';
          _isError = !success;
          if (success && _sensorData != null) {
            _sensorData = SensorData(
              soilMoisture: _sensorData!.soilMoisture,
              temperature: _sensorData!.temperature,
              airHumidity: _sensorData!.airHumidity,
              label: _sensorData!.label,
              confidence: _sensorData!.confidence,
              needsWatering: _sensorData!.needsWatering,
              description: _sensorData!.description,
              pumpStatus: true,
              mode: _sensorData!.mode,
              timestamp: _sensorData!.timestamp,
            );
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _actionLoading = false;
          _statusMsg = 'Gagal terhubung ke server.';
          _isError = true;
        });
      }
    }
    _autoDismissStatus();
  }

  void _autoDismissStatus() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _statusMsg = '');
    });
  }

  String get _aiDecisionText {
    if (_sensorData == null) return '---';
    if (_sensorData!.needsWatering) return 'MENYIRAM';
    return 'TIDAK MENYIRAM';
  }

  Color get _aiDecisionColor {
    if (_sensorData == null) return AppColors.textLight;
    return _sensorData!.needsWatering
        ? AppColors.primary
        : const Color(0xFFEF4444);
  }

  String get _soilLabel {
    if (_sensorData == null) return '---';
    switch (_sensorData!.label) {
      case 'Kering':
        return 'TANAH KERING — Perlu disiram';
      case 'Basah':
        return 'TANAH BASAH — Penyiraman tidak disarankan';
      case 'Lembab':
        return 'TANAH OPTIMAL — Kondisi baik';
      default:
        return _sensorData!.description;
    }
  }

  Color get _soilLabelColor {
    if (_sensorData == null) return AppColors.textMedium;
    switch (_sensorData!.label) {
      case 'Kering':
        return const Color(0xFFEF4444);
      case 'Basah':
        return const Color(0xFF3B82F6);
      case 'Lembab':
        return const Color(0xFF19E66F);
      default:
        return AppColors.textMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 50,
                offset: Offset(0, 25),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Soil condition banner (dynamic from sensor)
                      if (_sensorData != null)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          color: _sensorData!.label == 'Kering'
                              ? const Color(0xFFFEF9C3)
                              : _sensorData!.label == 'Basah'
                                  ? const Color(0xFFDBEAFE)
                                  : const Color(0xFFDCFCE7),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                _sensorData!.label == 'Kering'
                                    ? Icons.warning_amber_rounded
                                    : _sensorData!.label == 'Basah'
                                        ? Icons.water_rounded
                                        : Icons.check_circle_rounded,
                                color: _soilLabelColor,
                                size: 16,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  _soilLabel,
                                  style: TextStyle(
                                    color: _soilLabelColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Mode Status Bar
                      Container(
                        color: const Color(0xFFF1F5F9),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Text("🤖", style: TextStyle(fontSize: 14)),
                                SizedBox(width: 9),
                                Text(
                                  "Mode AI Aktif",
                                  style: TextStyle(
                                    color: Color(0xFF334155),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(9999),
                                  color: AppColors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppColors.shadow,
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: const Text(
                                  "Ganti ke Mode Manual",
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // AI Decision Status Card
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: _initialLoading
                            ? const CircularProgressIndicator()
                            : AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(9999),
                                    color: AppColors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _aiDecisionColor
                                            .withValues(alpha: 0.15),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: _aiDecisionColor
                                          .withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 30,
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "KEPUTUSAN AI",
                                        style: TextStyle(
                                          color: AppColors.textLight,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      AnimatedDefaultTextStyle(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        style: TextStyle(
                                          color: _aiDecisionColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        child: Text(_aiDecisionText),
                                      ),
                                      const SizedBox(height: 7),
                                      Icon(
                                        _sensorData?.needsWatering == true
                                            ? Icons.water_drop_rounded
                                            : Icons.stop_circle_rounded,
                                        color: _aiDecisionColor,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        _sensorData?.mode == 'auto'
                                            ? 'Mode Otomatis — AI Aktif'
                                            : 'Mode Manual',
                                        style: const TextStyle(
                                          color: AppColors.textMedium,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),

                      // AI Information Panel
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(24),
                            color: const Color(0xFFF8FAFC),
                          ),
                          padding: const EdgeInsets.all(21),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              const Row(
                                children: [
                                  Text("🤖", style: TextStyle(fontSize: 18)),
                                  SizedBox(width: 9),
                                  Text(
                                    "Kontrol AI",
                                    style: TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Live Sensor Data
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(16),
                                  color: AppColors.white,
                                ),
                                padding: const EdgeInsets.all(17),
                                child: Column(
                                  children: [
                                    // Moisture Level
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Kelembaban Tanah",
                                          style: TextStyle(
                                            color: Color(0xFF334155),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        _initialLoading
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2))
                                            : Text(
                                                _sensorData != null
                                                    ? "${_sensorData!.soilMoisture.toStringAsFixed(0)}%"
                                                    : "---",
                                                style: TextStyle(
                                                  color: _sensorData?.label ==
                                                          'Kering'
                                                      ? const Color(0xFFEF4444)
                                                      : const Color(
                                                          0xFF19E66F),
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Progress Bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        height: 8,
                                        color: const Color(0xFFE2E8F0),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor:
                                              (_sensorData?.soilMoisture ?? 0)
                                                      .clamp(0, 100) /
                                                  100,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              color: _sensorData?.label ==
                                                      'Kering'
                                                  ? const Color(0xFFEF4444)
                                                  : const Color(0xFF19E66F),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    const Divider(
                                        color: Color(0xFFF1F5F9), height: 1),
                                    const SizedBox(height: 16),
                                    _buildStatRow(
                                      "Algoritma",
                                      "K-NN",
                                      Icons.analytics_outlined,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildStatRow(
                                      "Status Pompa",
                                      _sensorData == null
                                          ? "---"
                                          : _sensorData!.pumpStatus
                                              ? "AKTIF"
                                              : "MATI",
                                      Icons.water_drop_outlined,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildStatRow(
                                      "Kondisi Tanah",
                                      _sensorData?.label ?? "---",
                                      Icons.grass_outlined,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildStatRow(
                                      "Akurasi Model",
                                      "92%",
                                      Icons.verified_outlined,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // AI Features
                              _buildFeatureCard(
                                "🎯",
                                "Keputusan Cerdas",
                                "AI menganalisis kondisi tanah secara real-time",
                              ),
                              const SizedBox(height: 12),
                              _buildFeatureCard(
                                "💧",
                                "Hemat Air",
                                "Efisiensi penggunaan air hingga 40%",
                              ),
                              const SizedBox(height: 12),
                              _buildFeatureCard(
                                "⚡",
                                "Otomatis",
                                "Tidak perlu kontrol manual setiap hari",
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Status Message
                      if (_statusMsg.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _isError
                                  ? AppColors.error.withValues(alpha: 0.08)
                                  : AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _isError
                                    ? AppColors.error.withValues(alpha: 0.2)
                                    : AppColors.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Icon(
                                  _isError
                                      ? Icons.error_outline_rounded
                                      : Icons.check_circle_outline_rounded,
                                  color: _isError
                                      ? AppColors.error
                                      : AppColors.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _statusMsg,
                                    style: TextStyle(
                                      color: _isError
                                          ? AppColors.error
                                          : AppColors.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Action Section
                      Container(
                        color: const Color(0xCCFFFFFF),
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          children: [
                            // Force Water Override Button
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: InkWell(
                                onTap: _actionLoading ? null : _forceWater,
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: const Color(0xFF19E66F),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColors.shadow,
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 17),
                                  child: _actionLoading
                                      ? const Center(
                                          child: SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.water_drop_rounded,
                                                color: Color(0xFF0F172A),
                                                size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              "PAKSA SIRAM SEKARANG",
                                              style: TextStyle(
                                                color: Color(0xFF0F172A),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Refresh / Reload data button
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: InkWell(
                                onTap: () {
                                  setState(() => _initialLoading = true);
                                  _fetchAndAutoWater();
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFFCBD5E1)),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.refresh_rounded,
                                          color: Color(0xFF475569), size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        "Refresh Status Sensor",
                                        style: TextStyle(
                                          color: Color(0xFF475569),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Bottom Navigation
                            CustomBottomNavigation(
                              currentIndex: 1,
                              onTap: (index) {
                                debugPrint('Navigation tapped: $index');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9333EA)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style:
                const TextStyle(color: AppColors.textMedium, fontSize: 11),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF334155),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
      String emoji, String title, String description) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(16),
        color: AppColors.white,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
