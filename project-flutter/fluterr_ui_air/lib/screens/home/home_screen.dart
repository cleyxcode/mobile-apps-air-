import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/app_colors.dart';
import '../../core/service_locator.dart';
import '../../core/notification_service.dart';
import '../../models/sensor_data.dart';
import 'widgets/header_section.dart';
import 'widgets/sensor_cards.dart';
import 'widgets/soil_condition_card.dart';
import 'widgets/ai_prediction_card.dart';
import 'widgets/humidity_chart_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  SensorData? _sensorData;
  double? _modelAccuracy;
  List<HistoryRecord> _history = [];
  bool _isLoading = true;
  bool _isOnline = false;
  String? _errorMsg;
  Timer? _refreshTimer;
  DateTime? _lastUpdated;

  // Track previous pump state for notification
  bool? _prevPumpStatus;

  late AnimationController _staggerController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _loadAll();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _loadAll(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadData(), _loadHistory(), _loadModelInfo()]);
    if (mounted && !_isLoading) {
      _staggerController.forward(from: 0.0);
    }
  }

  Future<void> _loadData() async {
    try {
      final data = await ServiceLocator.sensorRepo.getStatus();
      if (mounted) {
        // Trigger notifications based on sensor data
        _handleNotifications(data);

        setState(() {
          _sensorData = data;
          _isLoading = false;
          _isOnline = true;
          _errorMsg = null;
          _lastUpdated = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isOnline = false;
          _errorMsg = e.toString();
        });
        NotificationService.instance.notifyOffline();
      }
    }
  }

  void _handleNotifications(SensorData data) {
    final notif = NotificationService.instance;

    // Dry soil alert
    if (data.label == 'Kering') {
      notif.notifyDrySoil(data.soilMoisture);
    }

    // Pump status changed
    if (_prevPumpStatus != null && _prevPumpStatus != data.pumpStatus) {
      if (data.pumpStatus) {
        notif.notifyPumpOn();
      } else {
        notif.notifyPumpOff();
      }
    }

    // Optimal condition (less frequent)
    if (data.label == 'Lembab' && _prevPumpStatus == true && !data.pumpStatus) {
      notif.notifyOptimalSoil(data.soilMoisture);
    }

    _prevPumpStatus = data.pumpStatus;
  }

  Future<void> _loadHistory() async {
    try {
      final records = await ServiceLocator.sensorRepo.getHistory(limit: 30);
      if (mounted) setState(() => _history = records);
    } catch (_) {}
  }

  Future<void> _loadModelInfo() async {
    try {
      final info = await ServiceLocator.sensorRepo.getModelInfo();
      if (mounted) {
        setState(() =>
            _modelAccuracy = (info['accuracy'] as num?)?.toDouble());
      }
    } catch (_) {}
  }

  Future<void> _togglePump() async {
    final currentlyOn = _sensorData?.pumpStatus ?? false;
    final success = await ServiceLocator.sensorRepo.controlPump(
      on: !currentlyOn,
      mode: 'manual',
    );
    if (success) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Column(
        children: [
          HeaderSection(isOnline: _isOnline, lastUpdated: _lastUpdated),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAll,
              color: AppColors.primary,
              backgroundColor: AppColors.white,
              displacement: 20,
              child: _isLoading ? _buildShimmerLoading() : _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Shimmer.fromColors(
        baseColor: AppColors.border,
        highlightColor: AppColors.white,
        child: Column(
          children: [
            // Sensor cards shimmer
            Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: i == 0 ? 0 : 5,
                      right: i == 2 ? 0 : 5,
                    ),
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Soil condition shimmer
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 16),
            // AI card shimmer
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 16),
            // Action button shimmer
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            const SizedBox(height: 16),
            // Chart shimmer
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          if (_errorMsg != null) _buildErrorBanner(),
          _StaggeredItem(
            animation: _staggerController,
            begin: 0.0,
            end: 0.2,
            child: SensorCards(data: _sensorData),
          ),
          const SizedBox(height: 16),
          _StaggeredItem(
            animation: _staggerController,
            begin: 0.1,
            end: 0.3,
            child: SoilConditionCard(data: _sensorData),
          ),
          const SizedBox(height: 16),
          _StaggeredItem(
            animation: _staggerController,
            begin: 0.2,
            end: 0.5,
            child: AIPredictionCard(
              data: _sensorData,
              modelAccuracy: _modelAccuracy,
              onWaterNow: _togglePump,
            ),
          ),
          const SizedBox(height: 16),
          _StaggeredItem(
            animation: _staggerController,
            begin: 0.35,
            end: 0.65,
            child: HumidityChartCard(history: _history),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: AppColors.error, size: 16),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Tidak dapat terhubung ke server',
                style: TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ),
            GestureDetector(
              onTap: _loadData,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Coba lagi',
                  style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaggeredItem extends StatelessWidget {
  final Animation<double> animation;
  final double begin;
  final double end;
  final Widget child;

  const _StaggeredItem({
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    ));

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(begin, end, curve: Curves.easeOut),
      ),
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }
}
