import '../theme/app_assets.dart';

enum StatusMotor {
  tersedia('Tersedia'),
  disewa('Disewa'),
  perbaikan('Perbaikan');

  final String label;
  const StatusMotor(this.label);
}

class Motor {
  final String platNo;
  final String merek;
  final String model;
  final int tahun;
  final int cc;
  final String warna;
  final StatusMotor status;
  final int hargaSewaPerHari;
  final int dendaPerJam; 
  final String image; 

  const Motor({
    required this.platNo,
    required this.merek,
    required this.model,
    required this.tahun,
    required this.cc,
    required this.warna,
    required this.status,
    required this.hargaSewaPerHari,
    required this.dendaPerJam,
    required this.image,
  });

  String get nama => '$merek $model';
  bool get tersedia => status == StatusMotor.tersedia;
}

String formatRupiah(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}