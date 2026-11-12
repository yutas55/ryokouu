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

// NOTE: plat nomor, warna, status, dan denda di bawah ini data contoh.
// Ganti sesuai data asli.
const List<Motor> dataMotor = [
  Motor(
    platNo: 'N 1234 AB',
    merek: 'Honda',
    model: 'Vario 125',
    tahun: 2022,
    cc: 125,
    warna: 'Hitam',
    status: StatusMotor.tersedia,
    hargaSewaPerHari: 110000,
    dendaPerJam: 10000,
    image: AppAssets.vario125,
  ),
  Motor(
    platNo: 'N 2345 BC',
    merek: 'Honda',
    model: 'Beat Deluxe',
    tahun: 2020,
    cc: 110,
    warna: 'Putih',
    status: StatusMotor.tersedia,
    hargaSewaPerHari: 80000,
    dendaPerJam: 8000,
    image: AppAssets.beatDeluxe,
  ),
  Motor(
    platNo: 'N 3456 CD',
    merek: 'Honda',
    model: 'Vario 125 Street',
    tahun: 2022,
    cc: 125,
    warna: 'Merah',
    status: StatusMotor.disewa,
    hargaSewaPerHari: 110000,
    dendaPerJam: 10000,
    image: AppAssets.vario125Street,
  ),
  Motor(
    platNo: 'N 4567 DE',
    merek: 'Honda',
    model: 'Beat Deluxe Street',
    tahun: 2020,
    cc: 110,
    warna: 'Biru',
    status: StatusMotor.tersedia,
    hargaSewaPerHari: 80000,
    dendaPerJam: 8000,
    image: AppAssets.beatDeluxeStreet,
  ),
  Motor(
    platNo: 'N 5678 EF',
    merek: 'Honda',
    model: 'Scoopy Prestige',
    tahun: 2022,
    cc: 110,
    warna: 'Cokelat',
    status: StatusMotor.tersedia,
    hargaSewaPerHari: 90000,
    dendaPerJam: 9000,
    image: AppAssets.scoopyPrestige,
  ),
  Motor(
    platNo: 'N 6789 FG',
    merek: 'Honda',
    model: 'CRF150L',
    tahun: 2022,
    cc: 150,
    warna: 'Merah',
    status: StatusMotor.perbaikan,
    hargaSewaPerHari: 150000,
    dendaPerJam: 15000,
    image: AppAssets.crf,
  ),
];

String formatRupiah(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}
