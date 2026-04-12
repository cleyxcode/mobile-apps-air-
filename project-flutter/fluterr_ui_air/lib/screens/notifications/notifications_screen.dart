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
  Timer? _refreshTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _buildNotifications();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _buildNotifications(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _buildNotifications() async {
    setState(() => _isLoading = true);
    try {
      final records = await ServiceLocator.sensorRepo.getHistory(limit: 50);
      final notifs = <_NotifItem>[];

      for (final r in records.reversed) {
        if (r.label == 'Kering') {
          notifs.add(_NotifItem(
            icon: Icons.warning_amber_rounded,
            color: AppColors.warning,
            title: 'Tanah Kering Terdeteksi',
            body:
                'Kelembaban ${r.soilMoisture.toStringAsFixed(1)}% — KNN merekomendasikan penyiraman',
            timestamp: r.timestamp,
            type: 'peringatan',
          ));
        } else if (r.pumpStatus) {
          notifs.add(_NotifItem(
            icon: Icons.water_drop_rounded,
            color: AppColors.info,
            title: 'Penyiraman Aktif',
            body:
                'Pompa dinyalakan. Kelembaban tanah: ${r.soilMoisture.toStringAsFixed(1)}%',
            timestamp: r.timestamp,
            type: 'info',
          ));
        } else if (r.label == 'Lembab') {
          notifs.add(_NotifItem(
            icon: Icons.check_circle_rounded,
            color: AppColors.primary,
            title: 'Kondisi Optimal',
            body:
                'Tanah dalam kondisi lembab optimal (${r.soilMoisture.toStringAsFixed(1)}%)',
            timestamp: r.timestamp,
            type: 'sukses',
          ));
        }
        if (notifs.length >= 20) break;
      }

      if (mounted) {
        setState(() {
          _notifications = notifs;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
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
              onRefresh: _buildNotifications,
              color: AppColors.primary,
              backgroundColor: AppColors.white,
              child: _isLoading
                  ? _buildShimmerLoading()
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
        ],
      ),
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
