import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/app_colors.dart';
import '../../core/service_locator.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with AutomaticKeepAliveClientMixin {
  List<_NotifItem> _notifications = [];
  bool _isLoading = true;
  String? _errorMsg;
  Timer? _refreshTimer;

  /// Sama sumber data dengan Riwayat: `GET /history`, polling agar mendekati real-time.
  static const Duration _pollInterval = Duration(seconds: 15);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadNotifications(silent: false);
    _refreshTimer = Timer.periodic(_pollInterval, (_) {
      _loadNotifications(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Bangun daftar notifikasi dari rekaman sensor terbaru (sama seperti backend `/history`).
  Future<void> _loadNotifications({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMsg = null;
      });
    }
    try {
      final records = await ServiceLocator.sensorRepo.getHistory(limit: 80);
      final notifs = <_NotifItem>[];

      for (final r in records.reversed) {
        final confSuffix = r.confidence > 0
            ? ' Keyakinan KNN: ${r.confidence.toStringAsFixed(0)}%.'
            : '';

        if (r.needsWatering || r.label == 'Kering') {
          notifs.add(_NotifItem(
            icon: Icons.warning_amber_rounded,
            color: AppColors.warning,
            title: 'Tanah Kering Terdeteksi',
            body:
                'Kelembaban ${r.soilMoisture.toStringAsFixed(1)}% — sistem merekomendasikan penyiraman.$confSuffix',
            timestamp: r.timestamp,
            type: 'peringatan',
          ));
        } else if (r.pumpStatus) {
          notifs.add(_NotifItem(
            icon: Icons.water_drop_rounded,
            color: AppColors.info,
            title: 'Penyiraman Aktif',
            body:
                'Pompa menyala. Kelembaban tanah: ${r.soilMoisture.toStringAsFixed(1)}%. Mode: ${r.mode}.$confSuffix',
            timestamp: r.timestamp,
            type: 'info',
          ));
        } else if (r.label == 'Lembab') {
          notifs.add(_NotifItem(
            icon: Icons.check_circle_rounded,
            color: AppColors.primary,
            title: 'Kondisi Optimal',
            body:
                'Tanah lembab optimal (${r.soilMoisture.toStringAsFixed(1)}%).$confSuffix',
            timestamp: r.timestamp,
            type: 'sukses',
          ));
        } else if (r.label == 'Basah') {
          notifs.add(_NotifItem(
            icon: Icons.opacity_rounded,
            color: AppColors.info,
            title: 'Tanah Basah',
            body:
                'Kelembaban tinggi (${r.soilMoisture.toStringAsFixed(1)}%).$confSuffix',
            timestamp: r.timestamp,
            type: 'info',
          ));
        }
        if (notifs.length >= 40) break;
      }

      if (!mounted) return;
      setState(() {
        _notifications = notifs;
        _isLoading = false;
        _errorMsg = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (_notifications.isEmpty || !silent) {
          _errorMsg = 'Tidak dapat memuat notifikasi dari server';
        }
      });
    }
  }

  String _formatTime(String ts) {
    try {
      final dt = DateTime.parse(ts).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      return DateFormat('dd MMM, HH:mm').format(dt);
    } catch (_) {
      return ts;
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
              onRefresh: () => _loadNotifications(silent: true),
              color: AppColors.primary,
              backgroundColor: AppColors.white,
              child: _isLoading
                  ? _buildShimmerLoading()
                  : _errorMsg != null && _notifications.isEmpty
                      ? _buildError()
                      : _notifications.isEmpty
                          ? _buildEmpty()
                          : _buildList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Shimmer.fromColors(
          baseColor: AppColors.border,
          highlightColor: AppColors.white,
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
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
                  'Notifikasi',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Aktivitas terkini sistem AI',
                  style:
                      TextStyle(color: AppColors.textMedium, fontSize: 13),
                ),
              ],
            ),
          ),
          if (_notifications.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_notifications.length}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
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
              onPressed: () =>
                  _loadNotifications(silent: _notifications.isNotEmpty),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
        ),
        Center(
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
              Text(
                _errorMsg ?? 'Terjadi kesalahan',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textMedium, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _loadNotifications(silent: false),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.notifications_none_rounded,
                      color: AppColors.textLight, size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada notifikasi',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Notifikasi muncul saat ada aktivitas sensor',
                  style: TextStyle(
                      color: AppColors.textLight, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: _notifications.length,
      itemBuilder: (_, i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (i * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildNotifCard(_notifications[i]),
          ),
        );
      },
    );
  }

  Widget _buildNotifCard(_NotifItem n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: n.color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: n.color.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: n.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(n.icon, color: n.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        n.title,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      _formatTime(n.timestamp),
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  n.body,
                  style: const TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 13,
                    height: 1.5,
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

class _NotifItem {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String timestamp;
  final String type;

  const _NotifItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
  });
}
