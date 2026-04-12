import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/bottom_navigation.dart';

class AIControlScreen extends StatefulWidget {
  const AIControlScreen({super.key});

  @override
  State<AIControlScreen> createState() => _AIControlScreenState();
}

class _AIControlScreenState extends State<AIControlScreen> {
  bool isAIActive = true;
  String currentMoisture = "75%";
  String aiDecision = "TIDAK MENYIRAM";
  String recommendation = "TANAH TERLALU BASAH";

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

                      // AI Decision Status
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
                                  "KEPUTUSAN AI",
                                  style: TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  aiDecision,
                                  style: const TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                SizedBox(
                                  width: 20,
                                  height: 24,
                                  child: Image.network(
                                    "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/jKLzvv3N3H/jzkyeakh_expires_30_days.png",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  recommendation,
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

                              // AI Toggle
                              Row(
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "MODE AI",
                                          style: TextStyle(
                                            color: Color(0xFF1E293B),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          "AI akan mengambil keputusan penyiraman otomatis",
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
                                        isAIActive = !isAIActive;
                                      });
                                    },
                                    child: Container(
                                      width: 56,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          9999,
                                        ),
                                        color: isAIActive
                                            ? AppColors.primary
                                            : const Color(0xFFE2E8F0),
                                      ),
                                      padding: EdgeInsets.only(
                                        left: isAIActive ? 28 : 4,
                                        right: isAIActive ? 4 : 28,
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

                              // Current Data
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
                                        Text(
                                          currentMoisture,
                                          style: const TextStyle(
                                            color: Color(0xFF19E66F),
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Progress Bar
                                    Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: 0.75,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            color: const Color(0xFF19E66F),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // AI Stats
                                    const Divider(
                                      color: Color(0xFFF1F5F9),
                                      height: 1,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildStatRow(
                                      "Algoritma",
                                      "K-NN",
                                      Icons.analytics_outlined,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildStatRow(
                                      "Data Latih",
                                      "3.226 dataset",
                                      Icons.data_usage,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildStatRow(
                                      "Akurasi",
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

                      // Action Section
                      Container(
                        color: const Color(0xCCFFFFFF),
                        padding: const EdgeInsets.only(top: 13),
                        child: Column(
                          children: [
                            // Override Button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: InkWell(
                                onTap: () {
                                  debugPrint('Override AI decision');
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

                            // View History Button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: InkWell(
                                onTap: () {
                                  debugPrint('View AI history');
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
                                            "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/jKLzvv3N3H/lx8yadqv_expires_30_days.png",
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Lihat Riwayat Keputusan AI",
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

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9333EA)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textMedium, fontSize: 11),
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

  Widget _buildFeatureCard(String emoji, String title, String description) {
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
