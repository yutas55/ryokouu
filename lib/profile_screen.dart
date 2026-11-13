import 'package:flutter/material.dart';

import 'theme/app_colors.dart';

/// Halaman ubah profil. Dibuka dari icon di halaman Setting.
/// TODO: isi form ubah data user di sini.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary, // warna tombol back
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
        title: const Text(
          'UBAH PROFIL',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: AppColors.primary,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Isi form ubah profil di sini',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
