import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../core/service_locator.dart';
import '../../widgets/bottom_navigation.dart';

class ManualControlScreen extends StatefulWidget {
  const ManualControlScreen({super.key});

  @override
  State<ManualControlScreen> createState() => _ManualControlScreenState();
}

class _ManualControlScreenState extends State<ManualControlScreen> {
  bool _pumpOn = false;
  bool _loading = false;
  bool _initialLoading = true;
  String _statusMsg = '';
  bool _isError = false;
  int selectedDuration = 2;
  bool autoThresholdEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPumpStatus();
  }

  Future<void> _loadPumpStatus() async {
    try {
      final data = await ServiceLocator.sensorRepo.getStatus();
      if (mounted) {
        setState(() {
          _pumpOn = data.pumpStatus;
          _initialLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _initialLoading = false);
    }
  }

  Future<void> _controlPump({required bool turnOn}) async {
    if (_loading) return;
    HapticFeedback.mediumImpact();

    final prev = _pumpOn;
    setState(() {
      _pumpOn = turnOn;
      _loading = true;
      _isError = false;
      _statusMsg = turnOn ? 'Menyalakan pompa...' : 'Mematikan pompa...';
    });

    try {
      final success = await ServiceLocator.sensorRepo
          .controlPump(on: turnOn, mode: 'manual');
      if (mounted) {
        setState(() {
          _loading = false;
          if (success) {
            _statusMsg = turnOn ? '✓ Pompa dinyalakan' : '✓ Pompa dimatikan';
            _isError = false;
          } else {
            _pumpOn = prev;
            _statusMsg = 'Gagal mengontrol pompa. Coba lagi.';
            _isError = true;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _pumpOn = prev;
          _statusMsg = 'Gagal terhubung ke server.';
          _isError = true;
        });
      }
    }
    _autoDismissStatus();
  }

  void _autoDismissStatus() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _statusMsg = '');
    });
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
                      // Mode Status
                      Container(
                        color: const Color(0xFFF1F5F9),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Text("👤", style: TextStyle(fontSize: 14)),
                                SizedBox(width: 9),
                                Text(
                                  "Mode Manual Aktif",
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
                                    color: const Color(0xFFE2E8F0),
                                  ),
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
                                  "Ganti ke Mode AI",
                                  style: TextStyle(
                                    color: Color(0xFF19E66F),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Pump Status
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: _initialLoading
                            ? const CircularProgressIndicator()
                            : AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(9999),
                                    color: AppColors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_pumpOn
                                                ? AppColors.primary
                                                : Colors.grey)
                                            .withValues(alpha: 0.15),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: _pumpOn
                                          ? AppColors.primary.withValues(
                                              alpha: 0.3)
                                          : const Color(0xFFE2E8F0),
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
                                        "STATUS POMPA",
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
                                          color: _pumpOn
                                              ? const Color(0xFF19E66F)
                                              : AppColors.error,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        child: Text(
                                            _pumpOn ? "MENYALA" : "MATI"),
                                      ),
                                      const SizedBox(height: 7),
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _pumpOn
                                              ? const Color(0xFF19E66F)
                                              : AppColors.error,
                                          boxShadow: [
                                            BoxShadow(
                                              color: (_pumpOn
                                                      ? const Color(0xFF19E66F)
                                                      : AppColors.error)
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),

                      // Control Panel
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
                                  Text("⚙️", style: TextStyle(fontSize: 18)),
                                  SizedBox(width: 9),
                                  Text(
                                    "Kontrol Manual",
                                    style: TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Pump Toggle
                              Row(
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "POMPA AIR",
                                          style: TextStyle(
                                            color: Color(0xFF1E293B),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          "Nyalakan atau matikan pompa secara manual",
                                          style: TextStyle(
                                            color: AppColors.textMedium,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 25),
                                  GestureDetector(
                                    onTap: _loading
                                        ? null
                                        : () => _controlPump(on: !_pumpOn),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 56,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(9999),
                                        color: _pumpOn
                                            ? const Color(0xFF19E66F)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                      padding: EdgeInsets.only(
                                        left: _pumpOn ? 28 : 4,
                                        right: _pumpOn ? 4 : 28,
                                      ),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.white,
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x1A000000),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Duration Control
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Durasi Penyiraman",
                                    style: TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "$selectedDuration menit",
                                    style: const TextStyle(
                                      color: Color(0xFF19E66F),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Duration Slider placeholder
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Duration Buttons
                              Row(
                                children: [
                                  _buildDurationButton("30 dtk", 0.5),
                                  const SizedBox(width: 12),
                                  _buildDurationButton("1 mnt", 1),
                                  const SizedBox(width: 12),
                                  _buildDurationButton("2 mnt", 2),
                                  const SizedBox(width: 12),
                                  _buildDurationButton("5 mnt", 5),
                                  const SizedBox(width: 12),
                                  _buildDurationButton("10 mnt", 10),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Auto Threshold toggle (UI only)
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFF1F5F9),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  color: AppColors.white,
                                ),
                                padding: const EdgeInsets.all(17),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Penyiraman Otomatis Threshold",
                                          style: TextStyle(
                                            color: Color(0xFF334155),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              autoThresholdEnabled =
                                                  !autoThresholdEnabled;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            width: 40,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(9999),
                                              color: autoThresholdEnabled
                                                  ? AppColors.primary
                                                  : const Color(0xFFE2E8F0),
                                            ),
                                            padding: EdgeInsets.only(
                                              left: autoThresholdEnabled
                                                  ? 18
                                                  : 2,
                                              right: autoThresholdEnabled
                                                  ? 2
                                                  : 18,
                                            ),
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.white,
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: AppColors.shadow,
                                                    blurRadius: 2,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            "Siram jika kelembaban < 40%",
                                            style: TextStyle(
                                              color: AppColors.textMedium,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 13),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            color: const Color(0xFFF1F5F9),
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          child: const Text(
                                            "40%",
                                            style: TextStyle(
                                              color: Color(0xFF334155),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
                                  : const Color(0xFF19E66F)
                                      .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _isError
                                    ? AppColors.error.withValues(alpha: 0.2)
                                    : const Color(0xFF19E66F)
                                        .withValues(alpha: 0.2),
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
                                      : const Color(0xFF19E66F),
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _statusMsg,
                                    style: TextStyle(
                                      color: _isError
                                          ? AppColors.error
                                          : const Color(0xFF19E66F),
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

                      // Action Buttons
                      Container(
                        color: const Color(0xCCFFFFFF),
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          children: [
                            // Stop / Hentikan Button
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: InkWell(
                                onTap: _loading
                                    ? null
                                    : () => _controlPump(on: false),
                                borderRadius: BorderRadius.circular(24),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: _pumpOn
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFFEF4444)
                                            .withValues(alpha: 0.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEF4444)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 17),
                                  child: _loading
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
                                            Icon(Icons.stop_circle_rounded,
                                                color: Colors.white, size: 20),
                                            SizedBox(width: 10),
                                            Text(
                                              "HENTIKAN PENYIRAMAN",
                                              style: TextStyle(
                                                color: AppColors.white,
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

                            // Siram Sekarang Button
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: InkWell(
                                onTap: _loading
                                    ? null
                                    : () => _controlPump(on: true),
                                borderRadius: BorderRadius.circular(24),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: !_pumpOn
                                        ? const Color(0xFF19E66F)
                                        : const Color(0xFF19E66F)
                                            .withValues(alpha: 0.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF19E66F)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 17),
                                  child: _loading
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
                                              "SIRAM SEKARANG",
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

  Widget _buildDurationButton(String label, double minutes) {
    final isSelected = selectedDuration == minutes.toInt();
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedDuration = minutes.toInt();
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: isSelected ? null : Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(16),
            color: isSelected ? const Color(0xFF19E66F) : AppColors.white,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.white : const Color(0xFF475569),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
