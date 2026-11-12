import 'package:flutter/material.dart';

import 'models/motor.dart';
import 'theme/app_colors.dart';
import 'widgets/motor_cards.dart';

class BerandaScreen extends StatelessWidget {
  final VoidCallback onLihatSemua;
  const BerandaScreen({super.key, required this.onLihatSemua});

  @override
  Widget build(BuildContext context) {
    final rekomendasi = dataMotor.where((m) => m.tersedia).take(2).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Banner
        Container(
          width: double.infinity,
          height: 150,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sewa Motor Harian Hemat\ndan Cepat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Daerah Malang\ndan Batu',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Header rekomendasi
        Row(
          children: [
            Container(width: 3, height: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            const Text(
              'Rekomendasi Motor',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onLihatSemua,
              child: const Text(
                'Lihat Semua >',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...rekomendasi.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MotorListCard(motor: m),
          ),
        ),
      ],
    );
  }
}
