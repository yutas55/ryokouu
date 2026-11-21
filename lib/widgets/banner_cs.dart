import 'package:flutter/material.dart' hide Text;
import 'package:ryokou/bahasa.dart';

import '../theme/app_colors.dart';

/// Nomor Customer Service RYOKOU (ubah di sini, berlaku di semua halaman).
const String noCs = '08123456789';

/// Kotak biru tua "Hubungi CS ...". Dipakai di Informasi Denda dan Bantuan.
class BannerCs extends StatelessWidget {
  const BannerCs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 14, height: 1.5, color: Colors.white),
                children: [
                  TextSpan(
                    text: 'Hubungi CS Jika Ada Hal Yang Ingin Ditanyakan ',
                  ),
                  TextSpan(
                    text: noCs,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Icon(Icons.support_agent_rounded, size: 34, color: AppColors.csIcon),
        ],
      ),
    );
  }
}