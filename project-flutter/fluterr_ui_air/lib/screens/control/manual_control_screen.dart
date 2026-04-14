import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../core/schedule_foreground_service.dart';
import '../../core/service_locator.dart';
import '../../models/sensor_data.dart';
import '../../widgets/bottom_navigation.dart';

// ─────────────────────────────────────────────────────────────────────────────
class ManualControlScreen extends StatefulWidget {
  const ManualControlScreen({super.key});

  @override
  State<ManualControlScreen> createState() => _ManualControlScreenState();
}

class _ManualControlScreenState extends State<ManualControlScreen>
{
  // ── Kontrol tab state ─────────────────────────────────────────────────────
  bool _pumpOn = false;
  bool _loading = false;
  bool _initialLoading = true;
  String _statusMsg = '';
  bool _isError = false;
  int selectedDuration = 2;
  bool autoThresholdEnabled = false;

  // ── Schedule tab state ───────────────────────────────────────────────────
  List<WateringSchedule> _schedules = [];
  bool _scheduleLoading = false;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadPumpStatus();
    _loadSchedules();
  }

  // ─────────────────────────────────────────────────────────────────────────

  // ── Pump status ───────────────────────────────────────────────────────────
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

  Future<void> _controlPump({required bool turnOn, String source = 'manual'}) async {
    if (_loading) {
      if (source != 'schedule') return;
      // Jadwal tidak boleh hilang karena tombol manual masih memproses.
      for (var i = 0; i < 60 && _loading && mounted; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
      if (!mounted || _loading) return;
    }
    HapticFeedback.mediumImpact();

    final prev = _pumpOn;
    setState(() {
      _pumpOn = turnOn;
      _loading = true;
      _isError = false;
      _statusMsg = turnOn ? 'Menyalakan pompa...' : 'Mematikan pompa...';
    });

    try {
      final apiMode = source == 'schedule' ? 'schedule' : 'manual';
      final success = await ServiceLocator.sensorRepo
          .controlPump(on: turnOn, mode: apiMode);
      if (mounted) {
        setState(() {
          _loading = false;
          if (success) {
            _statusMsg = turnOn
                ? (source == 'schedule'
                    ? '✓ Pompa ON (jadwal otomatis)'
                    : '✓ Pompa dinyalakan')
                : (source == 'schedule'
                    ? '✓ Pompa OFF (jadwal selesai)'
                    : '✓ Pompa dimatikan');
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
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _statusMsg = '');
    });
  }

  // ── Schedule CRUD ─────────────────────────────────────────────────────────
  Future<void> _loadSchedules() async {
    setState(() => _scheduleLoading = true);
    try {
      final list = await ServiceLocator.scheduleRepo.getSchedules();
      if (mounted) setState(() => _schedules = list);
    } catch (_) {
      // silent — empty state shown
    } finally {
      if (mounted) setState(() => _scheduleLoading = false);
    }
  }

  Future<void> _toggleSchedule(String id, bool enabled) async {
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index < 0) return;

    final previous = _schedules[index];
    setState(() {
      _schedules[index] = previous.copyWith(enabled: enabled);
    });

    bool success = false;
    try {
      success = await ServiceLocator.scheduleRepo.updateSchedule(
        id,
        {'enabled': enabled},
      );
    } catch (_) {
      success = false;
    }

    if (!mounted) return;
    if (!success) {
      final rollbackIndex = _schedules.indexWhere((s) => s.id == id);
      if (rollbackIndex < 0) return;
      setState(() {
        _schedules[rollbackIndex] = previous;
      });
    }
  }

  Future<void> _deleteSchedule(String id) async {
    final scheduleIndex = _schedules.indexWhere((s) => s.id == id);
    if (scheduleIndex < 0) return;
    final schedule = _schedules[scheduleIndex];

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Jadwal?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Jadwal "${schedule.name}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;

    ScheduleForegroundService.instance.invalidateSchedule(id);

    final previous = List<WateringSchedule>.from(_schedules);
    setState(() {
      _schedules.removeWhere((s) => s.id == id);
    });

    bool success = false;
    try {
      success = await ServiceLocator.scheduleRepo.deleteSchedule(id);
    } catch (_) {
      success = false;
    }
    if (!mounted) return;
    if (!success) {
      setState(() => _schedules = previous);
    }
  }

  /// Mengembalikan `true` jika jadwal berhasil dibuat di server.
  Future<bool> _createSchedule(WateringSchedule s) async {
    try {
      final created = await ServiceLocator.scheduleRepo.createSchedule(s);
      if (!mounted) return false;
      setState(() {
        _schedules = [created, ..._schedules];
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ───────────────────────────────────────────────────
            Container(
              color: const Color(0xFFF1F5F9),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text('👤', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 9),
                      Text(
                        'Mode Manual Aktif',
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
                        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                          horizontal: 12, vertical: 10),
                      child: const Text(
                        'Ganti ke Mode AI',
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

            // ── Main Content ──────────────────────────────────────────────
            Expanded(
              child: _buildKontrolTab(),
            ),

            // ── Bottom Navigation (always visible) ───────────────────────
            CustomBottomNavigation(
              currentIndex: 1,
              onTap: (index) => debugPrint('Navigation tapped: $index'),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 1 – KONTROL
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildKontrolTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          // Pump Status
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: _initialLoading
                ? const CircularProgressIndicator()
                : Container(
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
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : const Color(0xFFE2E8F0),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 44, vertical: 28),
                    child: Column(
                      children: [
                        const Text(
                          'STATUS POMPA',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 7),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            color: _pumpOn
                                ? const Color(0xFF19E66F)
                                : AppColors.error,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          child: Text(_pumpOn ? 'MENYALA' : 'MATI'),
                        ),
                        const SizedBox(height: 7),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 14,
                          height: 14,
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

          // Control Panel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFFF8FAFC),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('⚙️', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 9),
                      Text(
                        'Kontrol Manual',
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'POMPA AIR',
                              style: TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Nyalakan atau matikan pompa secara manual',
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
                            : () => _controlPump(turnOn: !_pumpOn),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 56,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9999),
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

                  // Duration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Durasi Penyiraman',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$selectedDuration menit',
                        style: const TextStyle(
                          color: Color(0xFF19E66F),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildDurationButton('30 dtk', 0.5),
                      const SizedBox(width: 8),
                      _buildDurationButton('1 mnt', 1),
                      const SizedBox(width: 8),
                      _buildDurationButton('2 mnt', 2),
                      const SizedBox(width: 8),
                      _buildDurationButton('5 mnt', 5),
                      const SizedBox(width: 8),
                      _buildDurationButton('10 mnt', 10),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Auto Threshold
                  Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.white,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Penyiraman Otomatis Threshold',
                              style: TextStyle(
                                color: Color(0xFF334155),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() =>
                                  autoThresholdEnabled =
                                      !autoThresholdEnabled),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
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
                                  left: autoThresholdEnabled ? 18 : 2,
                                  right: autoThresholdEnabled ? 2 : 18,
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
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Siram jika kelembaban < 40%',
                                style: TextStyle(
                                  color: AppColors.textMedium,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: const Color(0xFFF1F5F9),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: const Text(
                                '40%',
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
                      : const Color(0xFF19E66F).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isError
                        ? AppColors.error.withValues(alpha: 0.2)
                        : const Color(0xFF19E66F).withValues(alpha: 0.2),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Hentikan
                InkWell(
                  onTap: _loading
                      ? null
                      : () => _controlPump(turnOn: false),
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
                    padding:
                        const EdgeInsets.symmetric(vertical: 17),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.stop_circle_rounded,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'HENTIKAN PENYIRAMAN',
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
                const SizedBox(height: 8),

                // Siram / Matikan — selalu sinkron dengan status pompa (bukan selalu ON).
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _loading
                        ? null
                        : () => _controlPump(turnOn: !_pumpOn),
                    borderRadius: BorderRadius.circular(24),
                    splashColor: Colors.black12,
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: _pumpOn
                              ? [
                                  const Color(0xFFEF4444),
                                  const Color(0xFFDC2626),
                                ]
                              : [
                                  const Color(0xFF19E66F),
                                  const Color(0xFF16C95C),
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_pumpOn
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF19E66F))
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 17),
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
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _pumpOn
                                      ? Icons.stop_circle_rounded
                                      : Icons.water_drop_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _pumpOn
                                      ? 'MATIKAN POMPA'
                                      : 'SIRAM SEKARANG',
                                  style: const TextStyle(
                                    color: Colors.white,
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
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSchedulingSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PENJADWALAN
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSchedulingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFFF8FAFC),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text('🗓️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Penjadwalan',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: FilledButton(
                    onPressed: _showAddScheduleDialog,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: const Color(0xFF19E66F),
                      foregroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Icon(Icons.add_rounded, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_scheduleLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(
                  color: Color(0xFF19E66F),
                ),
              )
            else if (_schedules.isEmpty)
              _buildEmptyJadwal()
            else
              Column(
                children: _schedules
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildScheduleCard(s),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyJadwal() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      child: Column(
        children: [
          const Text(
            'Belum ada jadwal penyiraman',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tekan tombol + untuk menambahkan jadwal.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMedium,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(WateringSchedule s) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: s.enabled
              ? const Color(0xFF19E66F).withValues(alpha: 0.35)
              : const Color(0xFFE2E8F0),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.name,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildMetaPill(Icons.access_time_rounded, s.time),
                    _buildMetaPill(
                        Icons.hourglass_bottom_rounded, '${s.durationMinutes} mnt'),
                    _buildMetaPill(Icons.calendar_month_rounded, s.daysDisplay),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: s.enabled
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    s.enabled ? 'Aktif' : 'Nonaktif',
                    style: TextStyle(
                      color: s.enabled
                          ? const Color(0xFF15803D)
                          : const Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _toggleSchedule(s.id, !s.enabled),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 46,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9999),
                    color: s.enabled
                        ? const Color(0xFF19E66F)
                        : const Color(0xFFE2E8F0),
                  ),
                  padding: EdgeInsets.only(
                    left: s.enabled ? 22 : 2,
                    right: s.enabled ? 2 : 22,
                  ),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _deleteSchedule(s.id),
                borderRadius: BorderRadius.circular(9999),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFB91C1C),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaPill(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(9999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BOTTOM SHEET – Tambah Jadwal
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _showAddScheduleDialog() async {
    final nameCtrl = TextEditingController(text: 'Jadwal Pagi');
    TimeOfDay selectedTime = const TimeOfDay(hour: 6, minute: 0);
    int duration = 5;
    final selected = <String>{'senin', 'selasa', 'rabu', 'kamis', 'jumat'};
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Tambah Jadwal Baru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nama jadwal
                    const Text('Nama Jadwal',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        hintText: 'cth. Siram Pagi',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFF19E66F), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Pilih jam
                    const Text('Jam Penyiraman',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569))),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: ctx,
                          initialTime: selectedTime,
                          builder: (ctx, child) => MediaQuery(
                            data: MediaQuery.of(ctx).copyWith(
                                alwaysUse24HourFormat: true),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setSheet(() => selectedTime = picked);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(
                              color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                color: Color(0xFF19E66F), size: 20),
                            const SizedBox(width: 12),
                            Text(
                              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const Spacer(),
                            const Text('Ketuk untuk ubah',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textLight)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Durasi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Durasi (menit)',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569))),
                        Text(
                          '$duration mnt',
                          style: const TextStyle(
                            color: Color(0xFF19E66F),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: duration.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      activeColor: const Color(0xFF19E66F),
                      inactiveColor: const Color(0xFFE2E8F0),
                      label: '$duration mnt',
                      onChanged: (v) => setSheet(() => duration = v.round()),
                    ),
                    const SizedBox(height: 12),

                    // Hari
                    const Text('Hari Aktif',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569))),
                    const SizedBox(height: 8),
                    Row(
                      children: WateringSchedule.allDays.map((day) {
                        final isOn = selected.contains(day);
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setSheet(() {
                                if (isOn) {
                                  selected.remove(day);
                                } else {
                                  selected.add(day);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isOn
                                    ? const Color(0xFF19E66F)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                WateringSchedule.dayLabel[day] ?? day,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isOn
                                      ? Colors.white
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: saving || selected.isEmpty
                            ? null
                            : () async {
                                setSheet(() => saving = true);
                                final schedule = WateringSchedule(
                                  id: '',
                                  name: nameCtrl.text.trim().isEmpty
                                      ? 'Jadwal'
                                      : nameCtrl.text.trim(),
                                  time: WateringSchedule.normalizeTimeToHHmm(
                                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                  ),
                                  durationMinutes: duration,
                                  days: WateringSchedule.normalizeDays(
                                      selected.toList()),
                                  enabled: true,
                                );
                                final ok = await _createSchedule(schedule);
                                if (!ctx.mounted) return;
                                if (ok) {
                                  Navigator.pop(ctx);
                                } else {
                                  setSheet(() => saving = false);
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Gagal menyimpan jadwal. Periksa koneksi dan coba lagi.',
                                      ),
                                    ),
                                  );
                                }
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF19E66F),
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF0F172A),
                                ),
                              )
                            : const Text(
                                'SIMPAN JADWAL',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDurationButton(String label, double minutes) {
    final isSelected = selectedDuration == minutes.toInt() ||
        (minutes == 0.5 && selectedDuration == 0);
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedDuration =
                minutes < 1 ? 0 : minutes.toInt();
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: isSelected
                ? null
                : Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(14),
            color: isSelected
                ? const Color(0xFF19E66F)
                : AppColors.white,
          ),
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? AppColors.white
                  : const Color(0xFF475569),
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
