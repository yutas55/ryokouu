import '../theme/app_assets.dart';

class Motor {
  final String nama;
  final int tahun;
  final int cc;
  final int harga;
  final String image;
  final bool tersedia;

  const Motor({
    required this.nama,
    required this.tahun,
    required this.cc,
    required this.harga,
    required this.image,
    this.tersedia = true,
  });
}

const List<Motor> dataMotor = [
  Motor(nama: 'Vario ISS SP', tahun: 2022, cc: 125, harga: 110000, image: AppAssets.vario),
  Motor(nama: 'BEAT Deluxe', tahun: 2020, cc: 110, harga: 80000, image: AppAssets.beat),
  Motor(nama: 'Vario ISS SP', tahun: 2022, cc: 125, harga: 110000, image: AppAssets.vario),
  Motor(nama: 'Vario ISS SP', tahun: 2022, cc: 125, harga: 110000, image: AppAssets.vario),
  Motor(nama: 'Vario ISS SP', tahun: 2022, cc: 125, harga: 110000, image: AppAssets.vario),
  Motor(nama: 'Vario ISS SP', tahun: 2022, cc: 125, harga: 110000, image: AppAssets.vario),
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
