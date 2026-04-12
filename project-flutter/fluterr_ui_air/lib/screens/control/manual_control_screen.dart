import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/bottom_navigation.dart';

class ManualControlScreen extends StatefulWidget {
  const ManualControlScreen({super.key});

  @override
  State<ManualControlScreen> createState() => _ManualControlScreenState();
}

class _ManualControlScreenState extends State<ManualControlScreen> {
  bool isPumpOn = true;
  int selectedDuration = 2; // in minutes
  bool autoThresholdEnabled = false;

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
                      // Warning Banner
                      Container(
                        color: const Color(0xFFFEF9C3),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 12,
                              height: 11,
                              child: Image.network(
                                "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/jKLzvv3N3H/4gx7k3py_expires_30_days.png",
                                fit: BoxFit.fill,
                              ),
                            ),
                            const SizedBox(width: 9),
                            const Expanded(
                              child: Text(
                                "TANAH TERLALU BASAH. Penyiraman tidak disarankan. Kelembaban\nsaat ini 75%",
                                style: TextStyle(
                                  color: Color(0xFF854D0E),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

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
                              onTap: () {
                                Navigator.pop(context);
                              },
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
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/jKLzvv3N3H/es2oce1k_expires_30_days.png",
                              ),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9999),
                              color: AppColors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 29,
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
                                const Text(
                                  "MENYALA",
                                  style: TextStyle(
                                    color: Color(0xFF19E66F),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                SizedBox(
                                  width: 20,
                                  height: 24,
                                  child: Image.network(
                                    "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/jKLzvv3N3H/bdj5ozxu_expires_30_days.png",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                const Text(
                                  "2m 34s",
                                  style: TextStyle(
                                    color: AppColors.textMedium,
                                    fontSize: 12,
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
                                    onTap: () {
                                      setState(() {
                                        isPumpOn = !isPumpOn;
                                      });
                                    },
                                    child: Container(
                                      width: 56,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          9999,
                                        ),
                                        color: isPumpOn
                                            ? const Color(0xFF19E66F)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                      padding: EdgeInsets.only(
                                        left: isPumpOn ? 28 : 4,
                                        right: isPumpOn ? 4 : 28,
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

                              // Duration Slider
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

                              // Auto Threshold
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
                                          child: Container(
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
                                        InkWell(
                                          onTap: () {
                                            debugPrint('Edit threshold');
                                          },
                                          child: Container(
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

                      // Action Buttons
                      Container(
                        color: const Color(0xCCFFFFFF),
                        padding: const EdgeInsets.only(top: 13),
                        child: Column(
                          children: [
                            // Stop Button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: InkWell(
                                onTap: () {
                                  debugPrint('Stop watering');
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: const Color(0xFFEF4444),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColors.shadow,
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 17,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          child: Image.network(
                                            "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/jKLzvv3N3H/jzkyeakh_expires_30_days.png",
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
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

                            // Water Now Button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: InkWell(
                                onTap: () {
                                  debugPrint('Water now');
                                },
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
                                    vertical: 17,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 12,
                                        height: 14,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          child: Image.network(
                                            "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/jKLzvv3N3H/d32agqc2_expires_30_days.png",
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
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
                            const SizedBox(height: 8),

                            // Schedule Button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: InkWell(
                                onTap: () {
                                  debugPrint('Schedule watering');
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFCBD5E1),
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 13,
                                        height: 14,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          child: Image.network(
                                            "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/jKLzvv3N3H/gc43ob0w_expires_30_days.png",
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Jadwalkan Penyiraman",
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
                              currentIndex: 1, // Mode tab
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
    final isSelected = selectedDuration == minutes;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedDuration = minutes.toInt();
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: isSelected
                ? null
                : Border.all(color: const Color(0xFFE2E8F0)),
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
