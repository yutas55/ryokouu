import 'package:flutter/material.dart';

import '../models/motor.dart';
import '../theme/app_colors.dart';
import 'common_widgets.dart';

// ---------- KARTU HORIZONTAL (Beranda) ----------
class MotorListCard extends StatelessWidget {
  final Motor motor;
  const MotorListCard({super.key, required this.motor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, child: BadgeStatus(status: motor.status)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 28, 12, 12),
            child: Row(
              children: [
                AssetImg(motor.image, width: 96, height: 84),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        motor.nama,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SpecRow(motor: motor),
                      const Divider(height: 16, color: AppColors.border),
                      Text(
                        '${formatRupiah(motor.hargaSewaPerHari)} / hari',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SewaButton(enabled: motor.tersedia),
                      ),
                    ],
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

// ---------- KARTU GRID (Produk) ----------
class MotorGridCard extends StatelessWidget {
  final Motor motor;
  const MotorGridCard({super.key, required this.motor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, child: BadgeStatus(status: motor.status)),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 28, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar motor selebar kartu
                AssetImg(motor.image, width: double.infinity, height: 100),
                const SizedBox(height: 8),
                Text(
                  motor.nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                SpecRow(motor: motor),
                const Divider(height: 16, color: AppColors.border),
                const Text(
                  'Tarif Sewa',
                  style: TextStyle(fontSize: 10, color: AppColors.grey),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        formatRupiah(motor.hargaSewaPerHari),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        ' / hari',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: SewaButton(enabled: motor.tersedia),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}