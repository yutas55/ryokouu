import '../models/motor.dart';
//  STATUS motor (tersedia / disewa / perbaikan) diubah di
//  lib/models/motor.dart, pada field `status:` tiap motor di dataMotor.
//  Katalog Produk, Beranda, dan halaman detail otomatis mengikutinya.
//
//  File ini hanya berisi data tambahan untuk testing (tanggal, label,
//  foto, lokasi). Kunci tiap data = plat nomor motor (platNo).
// =====================================================================

/// Tanggal "hari ini" untuk testing (dipakai menghitung "2 Hari lagi").
/// Kalau datanya sudah asli, ganti menjadi: DateTime.now()
DateTime hariIniDemo = DateTime(2024, 10, 14);

/// Satu foto di galeri (tombol panah kiri/kanan).
class FotoMotor {
  final String label; // contoh: 'TAMPAK DEPAN'
  final String path; // contoh: AppAssets.beatDeluxeStreet
  const FotoMotor(this.label, this.path);
}

/// Data tambahan satu motor. Semua isian boleh dikosongkan.
class InfoSewaMotor {
  /// "Terakhir Kali Di Rental".
  final DateTime? terakhirDisewa;

  /// Khusus status Disewa: kapan masa sewa berakhir.
  final DateTime? estimasiSelesai;

  /// Khusus status Disewa: perkiraan siap disewa lagi.
  /// Kalau kosong -> sehari setelah estimasiSelesai.
  final DateTime? siapDisewaLagi;

  /// Chip kecil di samping nama (contoh: 'Best Value').
  final String? label;

  /// Foto tambahan. Kalau kosong -> hanya foto utama motor.
  /// Kalau diisi 2 foto atau lebih, tombol panah galeri aktif.
  final List<FotoMotor> foto;

  InfoSewaMotor({
    this.terakhirDisewa,
    this.estimasiSelesai,
    this.siapDisewaLagi,
    this.label,
    this.foto = const [],
  });
}

final Map<String, InfoSewaMotor> infoSewaMotor = {
  'N 1234 AB': InfoSewaMotor(terakhirDisewa: DateTime(2024, 10, 5)),
  'N 2345 BC': InfoSewaMotor(terakhirDisewa: DateTime(2024, 10, 2)),
  'N 3456 CD': InfoSewaMotor(
    terakhirDisewa: DateTime(2024, 10, 12),
    estimasiSelesai: DateTime(2024, 10, 16),
    siapDisewaLagi: DateTime(2024, 10, 17),
  ),
  'N 4567 DE': InfoSewaMotor(
    terakhirDisewa: DateTime(2024, 10, 12),
    label: 'Best Value',
    // Dipakai kalau status motor ini diubah jadi Disewa untuk testing:
    estimasiSelesai: DateTime(2024, 10, 16),
    siapDisewaLagi: DateTime(2024, 10, 17),
  ),
  'N 5678 EF': InfoSewaMotor(terakhirDisewa: DateTime(2024, 9, 28)),
  'N 6789 FG': InfoSewaMotor(terakhirDisewa: DateTime(2024, 9, 20)),
};

/// Ambil data tambahan sebuah motor (kosong kalau belum diisi).
InfoSewaMotor infoUntuk(Motor m) => infoSewaMotor[m.platNo] ?? InfoSewaMotor();

/// Pilihan lokasi di form Pemesanan: (nama chip, alamat lengkap).
const List<(String, String)> lokasiPopuler = [
  ('Rental RYOKOU', 'Rental RYOKOU Malang (Pusat)')
];

/// Plat nomor motor yang pengingat ketersediaannya sedang aktif.
final Set<String> pengingatKetersediaan = <String>{};