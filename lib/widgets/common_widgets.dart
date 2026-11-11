import 'package:flutter/material.dart';

import '../models/motor.dart';
import '../theme/app_assets.dart';
import '../theme/app_colors.dart';

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
        child: Icon(fallbackIcon, color: AppColors.border, size: (height ?? 48) * 0.6),
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
          AssetImg(AppAssets.logo, width: 24, height: 24, fallbackIcon: Icons.circle),
          SizedBox(width: 8),
          Text(
            'RYOKOU',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

// ---------- BADGE TERSEDIA ----------
class BadgeTersedia extends StatelessWidget {
  const BadgeTersedia({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: const BoxDecoration(
        color: AppColors.badgeBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: const Text(
        'Tersedia',
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: AppColors.badgeText,
        ),
      ),
    );
  }
}

class SpecRow extends StatelessWidget {
  final Motor motor;
  const SpecRow({super.key, required this.motor});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 9, color: AppColors.grey);
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 9, color: AppColors.grey),
          const SizedBox(width: 3),
          Text('Tahun ${motor.tahun}', style: style),
          const SizedBox(width: 6),
          const Icon(Icons.speed, size: 9, color: AppColors.grey),
          const SizedBox(width: 3),
          Text('${motor.cc} CC', style: style),
        ],
      ),
    );
  }
}

class SewaButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const SewaButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed ?? () {},
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            'Sewa Sekarang',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
