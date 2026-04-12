import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../core/service_locator.dart';
import 'schedule_screen.dart';

class ModeScreen extends StatefulWidget {
  const ModeScreen({super.key});

  @override
  State<ModeScreen> createState() => _ModeScreenState();
}

class _ModeScreenState extends State<ModeScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isAuto = true;
  bool _pumpOn = false;
  bool _loading = false;
  String _statusMsg = '';
  bool _isError = false;
  Timer? _refreshTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadCurrentStatus();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _loadCurrentStatus(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentStatus() async {
    try {
      final data = await ServiceLocator.sensorRepo.getStatus();
      if (mounted) {
        setState(() {
          _isAuto = data.mode == 'auto';
          _pumpOn = data.pumpStatus;
        });
      }
    } catch (_) {}
  }

  Future<void> _setMode(bool auto) async {
    if (_loading || _isAuto == auto) return;
    HapticFeedback.mediumImpact();
    final prevAuto = _isAuto;
    setState(() {
      _isAuto = auto;
      _loading = true;
      _isError = false;
      _statusMsg = auto ? 'Mode otomatis aktif' : 'Mode manual aktif';
    });

    try {
      final success = await ServiceLocator.sensorRepo.controlPump(
        on: _pumpOn,
        mode: auto ? 'auto' : 'manual',
      );
      if (mounted) {
        setState(() {
          _loading = false;
          if (!success) {
            _isAuto = prevAuto;
            _statusMsg = 'Gagal mengubah mode';
            _isError = true;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _isAuto = prevAuto;
          _statusMsg = 'Gagal mengubah mode';
          _isError = true;
        });
      }
    }

    _autoDismissStatus();
  }

  Future<void> _togglePump() async {
    if (_isAuto || _loading) return;
    HapticFeedback.mediumImpact();
    final prevPump = _pumpOn;
    setState(() {
      _pumpOn = !_pumpOn;
      _loading = true;
      _isError = false;
      _statusMsg = _pumpOn ? 'Pompa dinyalakan' : 'Pompa dimatikan';
    });

    try {
      final success = await ServiceLocator.sensorRepo.controlPump(
        on: _pumpOn,
        mode: 'manual',
      );
      if (mounted) {
        setState(() {
          _loading = false;
          if (!success) {
            _pumpOn = prevPump;
            _statusMsg = 'Gagal mengontrol pompa';
            _isError = true;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _pumpOn = prevPump;
          _statusMsg = 'Gagal mengontrol pompa';
          _isError = true;
        });
      }
    }

    _autoDismissStatus();
  }

  void _autoDismissStatus() {
    if (mounted && _statusMsg.isNotEmpty) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _statusMsg = '';
            _isError = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadCurrentStatus,
        color: AppColors.primary,
        backgroundColor: AppColors.white,
        displacement: 40,
        edgeOffset: 0,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildHeader()),
            // Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Mode toggle cards
                  _buildModeToggle(),
                  const SizedBox(height: 20),
                  // Pump status
                  _buildPumpStatus(),
                  const SizedBox(height: 20),
                  // Manual controls
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: !_isAuto
                        ? Column(
                            children: [
                              _buildManualButton(),
                              const SizedBox(height: 12),
                              _buildScheduleButton(),
                              const SizedBox(height: 4),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  // Status message
                  _buildStatusMessage(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Mode Kontrol',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pilih cara sistem mengontrol penyiraman',
                  style: TextStyle(color: AppColors.textMedium, fontSize: 13),
                ),
              ],
            ),
          ),
          // Current mode indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isAuto ? AppColors.purpleSurface : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isAuto ? Icons.auto_awesome_rounded : Icons.touch_app_rounded,
                  color: _isAuto ? AppColors.purple : AppColors.warning,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _isAuto ? 'AI' : 'Manual',
                  style: TextStyle(
                    color: _isAuto ? AppColors.purple : AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Column(
      children: [
        // AI Mode Card
        _ModeCard(
          isSelected: _isAuto,
          icon: Icons.psychology_rounded,
          accentColor: AppColors.purple,
          gradientColors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          surfaceColor: AppColors.purpleSurface,
          title: 'Mode Otomatis (AI)',
          badge: 'Direkomendasikan',
          description: 'KNN mengklasifikasi kondisi tanah secara real-time dan mengontrol pompa otomatis.',
          features: const ['Klasifikasi otomatis', 'Hemat air', 'Monitoring 24/7'],
          loading: _loading,
          onTap: () => _setMode(true),
        ),
        const SizedBox(height: 14),
        // Manual Mode Card
        _ModeCard(
          isSelected: !_isAuto,
          icon: Icons.tune_rounded,
          accentColor: AppColors.warning,
          gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
          surfaceColor: const Color(0xFFFFFBEB),
          title: 'Mode Manual',
          badge: null,
          description: 'Anda mengontrol pompa secara langsung menggunakan tombol atau jadwal.',
          features: const ['Kontrol penuh', 'Jadwal kustom', 'Override AI'],
          loading: _loading,
          onTap: () => _setMode(false),
        ),
      ],
    );
  }

  Widget _buildPumpStatus() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _pumpOn
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: _pumpOn
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Animated pump icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: _pumpOn
                  ? AppColors.primaryGradient
                  : null,
              color: _pumpOn ? null : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _pumpOn
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              _pumpOn ? Icons.water_drop_rounded : Icons.water_drop_outlined,
              color: _pumpOn ? Colors.white : AppColors.textLight,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Pompa',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    color: _pumpOn ? AppColors.primary : AppColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  child: Text(
                    _pumpOn
                        ? 'AKTIF - Sedang Menyiram'
                        : 'MATI - Tidak Menyiram',
                  ),
                ),
              ],
            ),
          ),
          // Animated indicator dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _pumpOn ? AppColors.primary : AppColors.error,
              boxShadow: [
                BoxShadow(
                  color: (_pumpOn ? AppColors.primary : AppColors.error)
                      .withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualButton() {
    return GestureDetector(
      onTap: _loading ? null : _togglePump,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _pumpOn
                ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                : [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: (_pumpOn ? AppColors.error : AppColors.primary)
                  .withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: _loading
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
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
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _pumpOn ? 'MATIKAN POMPA' : 'SIRAM SEKARANG',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildScheduleButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ScheduleScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 10),
            Text(
              'Kelola Jadwal Penyiraman',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: _statusMsg.isNotEmpty
          ? Container(
              key: ValueKey(_statusMsg),
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: _isError
                    ? AppColors.error.withValues(alpha: 0.08)
                    : AppColors.primarySurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isError
                      ? AppColors.error.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (_isError ? AppColors.error : AppColors.primary)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _isError
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_rounded,
                      color: _isError ? AppColors.error : AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _statusMsg,
                    style: TextStyle(
                      color: _isError ? AppColors.error : AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('empty')),
    );
  }
}

// ── Mode Card Widget ─────────────────────────────────────────────────────────

class _ModeCard extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradientColors;
  final Color surfaceColor;
  final String title;
  final String? badge;
  final String description;
  final List<String> features;
  final bool loading;
  final VoidCallback onTap;

  const _ModeCard({
    required this.isSelected,
    required this.icon,
    required this.accentColor,
    required this.gradientColors,
    required this.surfaceColor,
    required this.title,
    required this.badge,
    required this.description,
    required this.features,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                  ),
                ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: icon + radio
                  Row(
                    children: [
                      // Icon box
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(colors: gradientColors)
                              : null,
                          color: isSelected ? null : surfaceColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: accentColor.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? Colors.white : accentColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Title + badge column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.textDark
                                    : AppColors.textMedium,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (badge != null) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  badge!,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Radio button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? accentColor : AppColors.border,
                            width: 2,
                          ),
                          color: isSelected ? accentColor : Colors.transparent,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: accentColor.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textMedium
                          : AppColors.textLight,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            // Feature chips - only show when selected
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isSelected
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: features.map((f) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_rounded,
                                    color: accentColor, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  f,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
