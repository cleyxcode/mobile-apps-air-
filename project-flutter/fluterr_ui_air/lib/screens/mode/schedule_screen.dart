import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../core/schedule_foreground_service.dart';
import '../../core/service_locator.dart';
import '../../models/sensor_data.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<WateringSchedule> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final list = await ServiceLocator.scheduleRepo.getSchedules();
      if (mounted) {
        setState(() {
          _schedules = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleEnabled(WateringSchedule s) async {
    await ServiceLocator.scheduleRepo
        .updateSchedule(s.id, {'enabled': !s.enabled});
    _load();
  }

  Future<void> _delete(WateringSchedule s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Jadwal',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Hapus jadwal "${s.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textMedium)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ServiceLocator.scheduleRepo.deleteSchedule(s.id);
      ScheduleForegroundService.instance.invalidateSchedule(s.id);
      _load();
    }
  }

  void _openForm({WateringSchedule? existing}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScheduleForm(existing: existing),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Jadwal Penyiraman',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add_rounded,
                  color: AppColors.primary, size: 20),
              label: const Text(
                'Tambah',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 3),
            )
          : _schedules.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  backgroundColor: AppColors.white,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.all(20),
                    itemCount: _schedules.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (_, i) => _buildCard(_schedules[i]),
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.schedule_rounded,
                color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum ada jadwal',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambah jadwal penyiraman otomatis\nsesuai waktu yang Anda inginkan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMedium,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah Jadwal',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(WateringSchedule s) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: s.enabled
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: s.enabled
                ? AppColors.primary.withValues(alpha: 0.05)
                : AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
            child: Row(
              children: [
                // Time box
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: s.enabled
                        ? AppColors.primarySurface
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: s.enabled
                            ? AppColors.primary
                            : AppColors.textLight,
                        size: 18,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.time,
                        style: TextStyle(
                          color: s.enabled
                              ? AppColors.primary
                              : AppColors.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: TextStyle(
                          color: s.enabled
                              ? AppColors.textDark
                              : AppColors.textMedium,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop_outlined,
                            size: 13,
                            color: s.enabled
                                ? AppColors.primary
                                : AppColors.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${s.durationMinutes} menit',
                            style: TextStyle(
                              color: s.enabled
                                  ? AppColors.textMedium
                                  : AppColors.textLight,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: s.enabled
                                ? AppColors.primary
                                : AppColors.textLight,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              s.daysDisplay,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: s.enabled
                                    ? AppColors.textMedium
                                    : AppColors.textLight,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (s.lastTriggered != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Terakhir: ${_formatDate(s.lastTriggered!)}',
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Switch(
                  value: s.enabled,
                  onChanged: (_) => _toggleEnabled(s),
                ),
              ],
            ),
          ),
          // Action buttons
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _openForm(existing: s),
                    icon: const Icon(Icons.edit_outlined,
                        size: 16, color: AppColors.textMedium),
                    label: const Text(
                      'Edit',
                      style: TextStyle(
                        color: AppColors.textMedium,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 24, color: AppColors.border),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _delete(s),
                    icon: const Icon(Icons.delete_outline,
                        size: 16, color: AppColors.error),
                    label: const Text(
                      'Hapus',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String ts) {
    try {
      final dt = DateTime.parse(ts).toLocal();
      return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return ts;
    }
  }
}

// ── Schedule Form ────────────────────────────────────────────────────────────

class _ScheduleForm extends StatefulWidget {
  final WateringSchedule? existing;
  const _ScheduleForm({this.existing});

  @override
  State<_ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<_ScheduleForm> {
  final _nameCtrl = TextEditingController();
  TimeOfDay _time = const TimeOfDay(hour: 6, minute: 0);
  int _duration = 5;
  List<String> _selectedDays = List.from(WateringSchedule.allDays);
  bool _enabled = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameCtrl.text = e.name;
      final parts = e.time.split(':');
      _time = TimeOfDay(
          hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      _duration = e.durationMinutes;
      _selectedDays = List.from(e.days);
      _enabled = e.enabled;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  String get _timeStr =>
      '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nama jadwal tidak boleh kosong'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih minimal 1 hari'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final s = WateringSchedule(
        id: widget.existing?.id ?? '',
        name: _nameCtrl.text.trim(),
        time: WateringSchedule.normalizeTimeToHHmm(_timeStr),
        durationMinutes: _duration,
        days: WateringSchedule.normalizeDays(_selectedDays),
        enabled: _enabled,
      );

      if (widget.existing == null) {
        await ServiceLocator.scheduleRepo.createSchedule(s);
      } else {
        await ServiceLocator.scheduleRepo.updateSchedule(
          widget.existing!.id,
          s.toJson()..['enabled'] = _enabled,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal menyimpan jadwal'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isEdit ? 'Edit Jadwal' : 'Jadwal Baru',
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),

            // Name input
            const Text(
              'Nama Jadwal',
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: 'mis: Pagi, Sore, Sebelum Tidur',
                hintStyle: const TextStyle(color: AppColors.textLight),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
                prefixIcon: const Icon(Icons.label_outline_rounded,
                    color: AppColors.textLight),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 22),

            // Time picker
            const Text(
              'Waktu Penyiraman',
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.access_time_rounded,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      _timeStr,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Ketuk untuk ganti',
                      style: TextStyle(
                          color: AppColors.textLight, fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textLight, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Duration slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Durasi Siram',
                  style: TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_duration menit',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.primaryLight,
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.1),
                trackHeight: 6,
              ),
              child: Slider(
                value: _duration.toDouble(),
                min: 1,
                max: 60,
                divisions: 59,
                label: '$_duration menit',
                onChanged: (v) => setState(() => _duration = v.toInt()),
              ),
            ),
            const SizedBox(height: 12),

            // Day selection
            const Text(
              'Hari Aktif',
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WateringSchedule.allDays.map((day) {
                final active = _selectedDays.contains(day);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (active) {
                      _selectedDays.remove(day);
                    } else {
                      _selectedDays.add(day);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          active ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: active ? AppColors.primary : AppColors.border,
                      ),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      WateringSchedule.dayLabel[day] ?? day,
                      style: TextStyle(
                        color:
                            active ? Colors.white : AppColors.textMedium,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Enable toggle
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.power_settings_new_rounded,
                      color: AppColors.textMedium, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Aktifkan jadwal ini',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Switch(
                    value: _enabled,
                    onChanged: (v) => setState(() => _enabled = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        isEdit ? 'Simpan Perubahan' : 'Tambah Jadwal',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
