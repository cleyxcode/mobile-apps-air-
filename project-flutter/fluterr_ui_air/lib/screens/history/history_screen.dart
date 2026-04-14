import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/app_colors.dart';
import '../../core/service_locator.dart';
import '../../models/sensor_data.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with AutomaticKeepAliveClientMixin {
  List<HistoryRecord> _records = [];
  bool _isLoading = true;
  String? _errorMsg;
  Timer? _refreshTimer;

  /// Interval polling ke `GET /history` (data terbaru dari server).
  static const Duration _pollInterval = Duration(seconds: 15);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadHistory(silent: false);
    _refreshTimer = Timer.periodic(_pollInterval, (_) {
      _loadHistory(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// [silent]: true = pembaruan latar (tanpa shimmer penuh), mis. timer polling.
  Future<void> _loadHistory({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMsg = null;
      });
    }
    try {
      final records = await ServiceLocator.sensorRepo.getHistory(limit: 100);
      if (!mounted) return;
      setState(() {
        // API mengembalikan urutan kronologis naik; tampilkan terbaru di atas.
        _records = records.reversed.toList();
        _isLoading = false;
        _errorMsg = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (_records.isEmpty || !silent) {
          _errorMsg = 'Tidak dapat memuat riwayat';
        }
      });
    }
  }

  int get _totalWatering => _records.where((r) => r.pumpStatus).length;
  int get _kering => _records.where((r) => r.label == 'Kering').length;
  int get _lembab => _records.where((r) => r.label == 'Lembab').length;
  int get _basah => _records.where((r) => r.label == 'Basah').length;

  String _formatTime(String ts) {
    try {
      final dt = DateTime.parse(ts).toLocal();
      return DateFormat('dd MMM, HH:mm').format(dt);
    } catch (_) {
      return ts;
    }
  }

  Color _labelColor(String label) {
    switch (label) {
      case 'Kering':
        return AppColors.warning;
      case 'Lembab':
        return AppColors.primary;
      case 'Basah':
        return AppColors.info;
      default:
        return AppColors.textLight;
    }
  }

  Color _labelBg(String label) {
    switch (label) {
      case 'Kering':
        return const Color(0xFFFFFBEB);
      case 'Lembab':
        return AppColors.primarySurface;
      case 'Basah':
        return const Color(0xFFEFF6FF);
      default:
        return AppColors.surfaceVariant;
    }
  }

  String _labelEmoji(String label) {
    switch (label) {
      case 'Kering':
        return '🌵';
      case 'Lembab':
        return '🌿';
      case 'Basah':
        return '💧';
      default:
        return '🌱';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadHistory(silent: true),
              color: AppColors.primary,
              backgroundColor: AppColors.white,
              child: _isLoading
                  ? _buildShimmerLoading()
                  : _errorMsg != null
                      ? _buildError()
                      : _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Shimmer.fromColors(
        baseColor: AppColors.border,
        highlightColor: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stat cards
            Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: i == 0 ? 0 : 5,
                      right: i == 2 ? 0 : 5,
                    ),
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Distribution card
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),
            // Record list
            ...List.generate(
              5,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Riwayat Penyiraman',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Monitoring aktivitas AI KNN',
                  style: TextStyle(color: AppColors.textMedium, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.primary, size: 22),
              onPressed: () => _loadHistory(silent: _records.isNotEmpty),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: AppColors.error, size: 32),
            ),
            const SizedBox(height: 16),
            Text(_errorMsg!,
                style: const TextStyle(
                    color: AppColors.textMedium, fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadHistory(silent: false),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(),
          const SizedBox(height: 20),
          _buildDistribusiLabel(),
          const SizedBox(height: 24),
          _buildRecordList(),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        _StatCard(
          title: 'Total Data',
          value: '${_records.length}',
          unit: 'rekaman',
          icon: Icons.storage_rounded,
          color: AppColors.primary,
          bgColor: AppColors.primarySurface,
        ),
        const SizedBox(width: 10),
        _StatCard(
          title: 'Penyiraman',
          value: '$_totalWatering',
          unit: 'aktivasi',
          icon: Icons.water_drop_rounded,
          color: AppColors.info,
          bgColor: const Color(0xFFEFF6FF),
        ),
        const SizedBox(width: 10),
        _StatCard(
          title: 'Kering',
          value: '$_kering',
          unit: 'deteksi',
          icon: Icons.warning_amber_rounded,
          color: AppColors.warning,
          bgColor: const Color(0xFFFFFBEB),
        ),
      ],
    );
  }

  Widget _buildDistribusiLabel() {
    if (_records.isEmpty) return const SizedBox();
    final total = _records.length;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 6),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.purpleSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.pie_chart_rounded,
                    color: AppColors.purple, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Distribusi Kondisi Tanah',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _DistributionBar(
            label: 'Kering',
            count: _kering,
            total: total,
            color: AppColors.warning,
          ),
          const SizedBox(height: 12),
          _DistributionBar(
            label: 'Lembab',
            count: _lembab,
            total: total,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _DistributionBar(
            label: 'Basah',
            count: _basah,
            total: total,
            color: AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordList() {
    if (_records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.history_rounded,
                    color: AppColors.textLight, size: 28),
              ),
              const SizedBox(height: 12),
              const Text(
                'Belum ada data riwayat',
                style: TextStyle(color: AppColors.textMedium, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Log Sensor',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_records.length} data',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _buildRecordCard(_records[i]),
        ),
      ],
    );
  }

  Widget _buildRecordCard(HistoryRecord r) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 4),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _labelBg(r.label),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(_labelEmoji(r.label),
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _labelBg(r.label),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        r.label,
                        style: TextStyle(
                          color: _labelColor(r.label),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatTime(r.timestamp),
                      style: const TextStyle(
                          color: AppColors.textLight, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _SensorChip(
                      icon: Icons.water_drop_outlined,
                      value: '${r.soilMoisture.toStringAsFixed(0)}%',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    _SensorChip(
                      icon: Icons.thermostat_rounded,
                      value: '${r.temperature.toStringAsFixed(1)}°C',
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 10),
                    _SensorChip(
                      icon: Icons.air_rounded,
                      value: '${r.airHumidity.toStringAsFixed(0)}%',
                      color: AppColors.info,
                    ),
                    const Spacer(),
                    if (r.pumpStatus)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.water_rounded,
                                color: AppColors.primary, size: 12),
                            SizedBox(width: 3),
                            Text(
                              'Disiram',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 4),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              unit,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textMedium,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DistributionBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _DistributionBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: color.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 10,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 36,
          child: Text(
            '${(pct * 100).toInt()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textMedium,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SensorChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _SensorChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
