import 'package:flutter/material.dart' hide Text;
import 'package:ryokou/bahasa.dart';

import '../detail_motor_screen.dart';
import '../models/motor.dart';
import '../theme/app_colors.dart';
import 'common_widgets.dart';

BoxDecoration _dekorasiKartu() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AppColors.cardBorder),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );
}

/// "Rp 90.000" tebal + "/hari" abu-abu kecil.
class _Harga extends StatelessWidget {
  final int harga;
  final double ukuran;
  const _Harga({required this.harga, required this.ukuran});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            formatRupiah(harga),
            style: TextStyle(
              fontSize: ukuran,
              fontWeight: FontWeight.w700,
              color: AppColors.textTitle,
            ),
          ),
          Text(
            '/hari',
            style: TextStyle(
              fontSize: ukuran * 0.72,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- KARTU HORIZONTAL (Beranda) ----------
class MotorListCard extends StatelessWidget {
  final Motor motor;
  const MotorListCard({super.key, required this.motor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => bukaDetailMotor(context, motor),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _dekorasiKartu(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 104,
              height: 96,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AssetImg(motor.image, width: 104, height: 96),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: BadgeStatus(status: motor.status),
                  ),
                ],
              ),
            ),
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
                      color: AppColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SpecRow(motor: motor),
                  const SizedBox(height: 8),
                  _Harga(harga: motor.hargaSewaPerHari, ukuran: 16),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: MotorButton(
                      status: motor.status,
                      onPressed: () => bukaDetailMotor(context, motor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- KARTU GRID (Katalog Produk) ----------
class MotorGridCard extends StatelessWidget {
  final Motor motor;
  const MotorGridCard({super.key, required this.motor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => bukaDetailMotor(context, motor),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _dekorasiKartu(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar motor + badge status di pojok kiri atas
            Stack(
              children: [
                AssetImg(motor.image, width: double.infinity, height: 110),
                Positioned(
                  top: 0,
                  left: 0,
                  child: BadgeStatus(status: motor.status),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              motor.nama,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textTitle,
              ),
            ),
            const SizedBox(height: 4),
            SpecRow(motor: motor),
            const SizedBox(height: 10),
            const Text(
              'Tarif Sewa',
              style: TextStyle(fontSize: 11, color: AppColors.textFaint),
            ),
            const SizedBox(height: 2),
            _Harga(harga: motor.hargaSewaPerHari, ukuran: 18),
            const SizedBox(height: 8),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: MotorButton(
                status: motor.status,
                onPressed: () => bukaDetailMotor(context, motor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}