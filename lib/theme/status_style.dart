import 'package:flutter/material.dart';

import '../models/motor.dart';
import 'app_colors.dart';

extension StatusMotorStyle on StatusMotor {
  /// Warna badge di kartu motor.
  Color get badgeColor => switch (this) {
    StatusMotor.tersedia => AppColors.statusTersedia,
    StatusMotor.disewa => AppColors.statusDisewa,
    StatusMotor.perbaikan => AppColors.statusPerbaikan,
  };

  /// Warna tombol di kartu motor.
  Color get tombolColor => switch (this) {
    StatusMotor.tersedia => AppColors.statusTersedia,
    StatusMotor.disewa => AppColors.statusDisewa,
    StatusMotor.perbaikan => AppColors.tombolNonaktif,
  };

  /// Warna teks tombol di kartu motor.
  Color get tombolTextColor => switch (this) {
    StatusMotor.perbaikan => AppColors.tombolNonaktifText,
    _ => Colors.white,
  };

  /// Teks tombol di kartu motor.
  String get tombolLabel => switch (this) {
    StatusMotor.tersedia => 'SEWA SEKARANG',
    StatusMotor.disewa => 'LIHAT DETAIL SEWA',
    StatusMotor.perbaikan => 'SEDANG DIPERBAIKI',
  };

  /// Warna latar chip filter di bagian atas katalog.
  Color get chipColor => switch (this) {
    StatusMotor.tersedia => AppColors.chipTersedia,
    StatusMotor.disewa => AppColors.chipDisewa,
    StatusMotor.perbaikan => AppColors.statusPerbaikan,
  };

  /// Warna garis kotak angka di dalam chip.
  Color get chipCountBorder => switch (this) {
    StatusMotor.tersedia => AppColors.statusTersedia,
    StatusMotor.disewa => AppColors.statusDisewa,
    StatusMotor.perbaikan => AppColors.statusPerbaikanTombol,
  };

  /// Teks chip filter.
  String get chipLabel => switch (this) {
    StatusMotor.tersedia => 'Motor Yang Tersedia',
    StatusMotor.disewa => 'Motor Sedang Disewa',
    StatusMotor.perbaikan => 'Motor Sedang Diperbaiki',
  };

  /// Icon SVG chip filter (checklist, jam, topi konstruksi).
  String get iconAsset => switch (this) {
    StatusMotor.tersedia => 'assets/icons/centang.svg',
    StatusMotor.disewa => 'assets/icons/jam.svg',
    StatusMotor.perbaikan => 'assets/icons/topikonstruksi.svg',
  };
}
