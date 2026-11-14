import 'package:flutter/material.dart';

import '../models/motor.dart';
import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/status_style.dart';

// ---------- WIDGET GAMBAR DENGAN FALLBACK ----------
class AssetImg extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final IconData fallbackIcon;

  const AssetImg(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fallbackIcon = Icons.two_wheeler,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SizedBox(
        width: width,
        height: height,
        child: Icon(
          fallbackIcon,
          color: AppColors.border,
          size: (height ?? 48) * 0.6,
        ),
      ),
    );
  }
}

// ---------- APP BAR (logo + teks RYOKOU) ----------
class RyokouAppBar extends StatelessWidget {
  const RyokouAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: const Row(
        children: [
          AssetImg(
            AppAssets.logo,
            width: 24,
            height: 24,
            fallbackIcon: Icons.circle,
          ),
          SizedBox(width: 8),
          Text(
            'RYOKOU',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- BADGE STATUS (Tersedia / Disewa / Perbaikan) ----------
class BadgeStatus extends StatelessWidget {
  final StatusMotor status;
  const BadgeStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ---------- BARIS SPESIFIKASI: "Tahun 2023 • 110 CC" ----------
class SpecRow extends StatelessWidget {
  final Motor motor;
  const SpecRow({super.key, required this.motor});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 11.5, color: AppColors.textMuted);
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 12,
            color: AppColors.textFaint,
          ),
          const SizedBox(width: 4),
          Text('Tahun ${motor.tahun}', style: style),
          const SizedBox(width: 6),
          const Text(
            '•',
            style: TextStyle(fontSize: 11, color: AppColors.textFaint),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.speed, size: 12, color: AppColors.textFaint),
          const SizedBox(width: 4),
          Text('${motor.cc} CC', style: style),
        ],
      ),
    );
  }
}

// ---------- TOMBOL KARTU MOTOR (warna & teks mengikuti status) ----------
class MotorButton extends StatelessWidget {
  final StatusMotor status;
  final VoidCallback? onPressed;
  const MotorButton({super.key, required this.status, this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Motor yang sedang diperbaiki: tombol hanya penanda, tidak bisa ditekan.
    final bisaDitekan = status != StatusMotor.perbaikan;

    return Material(
      color: status.tombolColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: bisaDitekan ? (onPressed ?? () {}) : null,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              status.tombolLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
