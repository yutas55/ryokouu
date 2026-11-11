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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          const Positioned(top: 0, left: 0, child: BadgeTersedia()),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 22, 12, 10),
            child: Row(
              children: [
                AssetImg(motor.image, width: 80, height: 70),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        motor.nama,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      SpecRow(motor: motor),
                      const Divider(height: 14, color: AppColors.border),
                      Text(
                        '${formatRupiah(motor.harga)} / hari',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: SewaButton(),
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          const Positioned(top: 0, left: 0, child: BadgeTersedia()),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 22, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: AssetImg(motor.image, width: 80, height: 65)),
                const SizedBox(height: 6),
                Text(
                  motor.nama,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                SpecRow(motor: motor),
                const Divider(height: 12, color: AppColors.border),
                const Text(
                  'Tarif Sewa',
                  style: TextStyle(fontSize: 8, color: AppColors.grey),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        formatRupiah(motor.harga),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        ' / hari',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const SizedBox(width: double.infinity, child: SewaButton()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
