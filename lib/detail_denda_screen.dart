import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import 'data/status_pengguna.dart';
import 'informasi_denda_screen.dart';
import 'models/motor.dart';
import 'theme/app_colors.dart';
import 'widgets/common_widgets.dart';
import 'widgets/topbar.dart';

// =====================================================================
//  DATA BUKTI DENDA  (untuk testing, ubah nilai di bagian ini saja)
//
//  Yang menentukan jenis denda MUNCUL atau tidak adalah variabel
//  boolean di lib/data/status_pengguna.dart:
//    dendaKerusakan, dendaKeluarWilayah, dendaKeterlambatan
//  Isi detail (nominal, tanggal, lokasi, dll) diatur di bawah ini.
// =====================================================================

/// Motor terakhir yang dipakai (dicocokkan dengan `model` di dataMotor).
const String _modelMotorTerakhir = 'Beat Deluxe Street';

/// Tanggal motor dikembalikan.
final DateTime _tanggalKembali = DateTime(2024, 10, 14);

// ---- Kerusakan spare part ----
const List<_ItemKerusakan> _daftarKerusakan = [
  _ItemKerusakan('Spion Kanan Patah & Retak', 65000, Icons.broken_image_outlined),
  _ItemKerusakan('Baret & Lecet Pada Body', 85000, Icons.two_wheeler_rounded),
];

// ---- Keluar batas wilayah ----
final DateTime _waktuKeluarWilayah = DateTime(2024, 10, 13, 16, 42);
const double _latKeluarWilayah = -7.5641;
const double _lngKeluarWilayah = 112.7238;
const String _lokasiKeluarWilayah = 'Kec. Gempol, Pasuruan (Jawa Timur)';
const int _jarakKeluarWilayahKm = 38;
const int _dendaKeluarWilayah = 300000;

// ---- Keterlambatan pengembalian ----
final DateTime _jatuhTempo = DateTime(2024, 10, 14, 14, 0);
final DateTime _waktuKedatangan = DateTime(2024, 10, 14, 18, 30);
const int _dendaKeterlambatan = 20000;

// =====================================================================

class _ItemKerusakan {
  final String nama;
  final int harga;
  final IconData icon;
  const _ItemKerusakan(this.nama, this.harga, this.icon);
}

enum _JenisDenda { kerusakan, keluarWilayah, keterlambatan }

/// Halaman "Detail Denda". Jenis denda yang tampil mengikuti variabel
/// boolean di data/status_pengguna.dart. Tiap jenis bisa dibuka/tutup
/// untuk melihat bukti dendanya.
class DetailDendaScreen extends StatefulWidget {
  const DetailDendaScreen({super.key});

  @override
  State<DetailDendaScreen> createState() => _DetailDendaScreenState();
}

class _DetailDendaScreenState extends State<DetailDendaScreen> {
  // ---------- Warna khusus halaman ----------
  static const _merah = Color(0xFFBA1A1A);
  static const _merahBanner = Color(0xFFFFD9D6);
  static const _merahMuda = Color(0xFFFFEDEC);
  static const _tealGelap = Color(0xFF002F38);
  static const _teksAbu = Color(0xFF40484B);
  static const _abuKartu = Color(0xFFF3F4F4);
  static const _abuFoto = Color(0xFFEDEEEF);
  static const _garisKartu = Color(0xFFE5E7EB);
  static const _biruMuda = Color(0xFFC2E9F4);

  /// Jenis denda yang sedang dibuka.
  final Set<_JenisDenda> _terbuka = {};

  // ---------- Data turunan ----------

  /// Jenis denda yang aktif, urutannya sama dengan desain.
  List<_JenisDenda> get _aktif => [
    if (dendaKerusakan) _JenisDenda.kerusakan,
    if (dendaKeluarWilayah) _JenisDenda.keluarWilayah,
    if (dendaKeterlambatan) _JenisDenda.keterlambatan,
  ];

  int get _totalKerusakan => _daftarKerusakan.fold(0, (a, e) => a + e.harga);

  int _nominal(_JenisDenda j) => switch (j) {
    _JenisDenda.kerusakan => _totalKerusakan,
    _JenisDenda.keluarWilayah => _dendaKeluarWilayah,
    _JenisDenda.keterlambatan => _dendaKeterlambatan,
  };

  /// Total keseluruhan = jumlah denda yang aktif saja.
  int get _totalKeseluruhan => _aktif.fold(0, (a, j) => a + _nominal(j));

  Motor get _motor => dataMotor.firstWhere(
    (m) => m.model == _modelMotorTerakhir,
    orElse: () => dataMotor.first,
  );

  // ---------- Format ----------

  static const _bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String _tgl(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

  String _jam(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')} WIB';

  String get _teksTerlambat {
    final selisih = _waktuKedatangan.difference(_jatuhTempo);
    if (selisih.inHours >= 1) return 'Terlambat ${selisih.inHours} Jam';
    return 'Terlambat ${selisih.inMinutes} Menit';
  }

  // ---------- Aksi ----------

  void _toggle(_JenisDenda j) {
    setState(() {
      if (!_terbuka.remove(j)) _terbuka.add(j);
    });
  }

  void _bukaInformasiDenda() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const InformasiDendaScreen()),
    );
  }

  void _bayar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pembayaran denda belum tersedia')),
    );
  }

  // ---------- Halaman ----------

  @override
  Widget build(BuildContext context) {
    final adaDenda = punyaDenda;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: const RyokouTopBar(title: 'INFORMASI DENDA'),
      bottomNavigationBar: adaDenda ? _tombolBayar() : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(alignment: Alignment.centerLeft, child: _tombolKembali()),
            const SizedBox(height: 16),
            if (adaDenda) ...[
              _bannerPeringatan(),
              const SizedBox(height: 16),
              _kartuMotor(),
              const SizedBox(height: 16),
              _kartuDetailDenda(),
              const SizedBox(height: 16),
            ] else ...[
              _kosong(),
              const SizedBox(height: 16),
            ],
            _kartuImbauan(),
          ],
        ),
      ),
    );
  }

  Widget _tombolKembali() {
    return Material(
      color: AppColors.tuneBg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.of(context).maybePop(),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 24,
            color: AppColors.profilText,
          ),
        ),
      ),
    );
  }

  // ---------- Banner merah ----------

  String get _judulBanner {
    final aktif = _aktif;
    if (aktif.length == 1) {
      return switch (aktif.first) {
        _JenisDenda.kerusakan =>
          'ANDA MEMILIKI DENDA KARENA TELAH MERUSAKAN SPARE PART MOTOR',
        _JenisDenda.keluarWilayah =>
          'ANDA MEMILIKI DENDA KARENA KELUAR BATAS WILAYAH SEWA',
        _JenisDenda.keterlambatan =>
          'ANDA MEMILIKI DENDA KARENA TERLAMBAT MENGEMBALIKAN MOTOR',
      };
    }
    return 'ANDA MEMILIKI $jumlahDenda JENIS DENDA PADA PENYEWAAN MOTOR';
  }

  String get _subjudulBanner => _aktif.contains(_JenisDenda.kerusakan)
      ? 'Kompensasi tercatat otomatis saat inspeksi tim operasional pada '
            'pengembalian unit sewa.'
      : 'Denda tercatat otomatis oleh sistem RYOKOU pada saat penyewaan '
            'dan pengembalian unit.';

  Widget _bannerPeringatan() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        color: _merahBanner,
        child: Stack(
          children: [
            Positioned(
              right: -24,
              bottom: -24,
              child: Icon(
                Icons.build_circle_outlined,
                size: 110,
                color: _merah.withAlpha(30),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _merah,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'PERLU TINDAKAN SEGERA',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Status: Belum Lunas',
                      style: TextStyle(fontSize: 11.5, color: _merah),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _judulBanner,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    color: _merah,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(right: 56),
                  child: Text(
                    _subjudulBanner,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: _merah,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Kartu motor ----------

  Widget _kartuPutih({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _kartuMotor() {
    final motor = _motor;
    return _kartuPutih(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MOTOR RENTAL',
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 0.4,
              fontWeight: FontWeight.w500,
              color: _teksAbu,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _abuKartu,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AssetImg(motor.image, width: 60, height: 60),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MOTOR TERAKHIR DIGUNAKAN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.chevron,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        motor.nama,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 15,
                            color: _teksAbu,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Kembali: ${_tgl(_tanggalKembali)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: _teksAbu,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Kartu "Detail Denda" ----------

  Widget _kartuDetailDenda() {
    final aktif = _aktif;
    return _kartuPutih(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: _merah,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Detail Denda',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tuneBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$jumlahDenda Jenis',
                  style: const TextStyle(fontSize: 12, color: _teksAbu),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final j in aktif) ...[
            _itemDenda(j),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 2),
          _kotakTotal(
            label: 'TOTAL KESELURUHAN',
            nominal: _totalKeseluruhan,
            besar: true,
          ),
        ],
      ),
    );
  }

  String _judulJenis(_JenisDenda j) => switch (j) {
    _JenisDenda.kerusakan => 'Kerusakan Spare Part',
    _JenisDenda.keluarWilayah => 'Keluar Batas Wilayah',
    _JenisDenda.keterlambatan => 'Keterlambatan Pengembalian',
  };

  IconData _iconJenis(_JenisDenda j) => switch (j) {
    _JenisDenda.kerusakan => Icons.broken_image_outlined,
    _JenisDenda.keluarWilayah => Icons.satellite_alt_rounded,
    _JenisDenda.keterlambatan => Icons.receipt_long_outlined,
  };

  Widget _isiJenis(_JenisDenda j) => switch (j) {
    _JenisDenda.kerusakan => _isiKerusakan(),
    _JenisDenda.keluarWilayah => _isiKeluarWilayah(),
    _JenisDenda.keterlambatan => _isiKeterlambatan(),
  };

  /// Satu jenis denda: baris abu-abu + panah, dan isi bukti di bawahnya
  /// yang membuka/menutup saat baris ditekan.
  Widget _itemDenda(_JenisDenda j) {
    final buka = _terbuka.contains(j);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: _abuKartu,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _toggle(j),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  Icon(_iconJenis(j), size: 22, color: _merah),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _judulJenis(j),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.profilText,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: buka ? 0.25 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 26,
                      color: _tealGelap,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: buka
              ? Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _garisKartu),
                  ),
                  child: _isiJenis(j),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  /// Kotak hijau tua berisi total.
  Widget _kotakTotal({
    required String label,
    required int nominal,
    bool besar = false,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, besar ? 16 : 14, 16, besar ? 16 : 14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(besar ? 14 : 12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    letterSpacing: 0.5,
                    color: Color(0xFF9CC9D6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(nominal),
                  style: TextStyle(
                    fontSize: besar ? 30 : 26,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 22,
              color: _biruMuda,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Isi: Kerusakan spare part ----------

  Widget _isiKerusakan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: _merah,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Detail Kerusakan Spare Part',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in _daftarKerusakan) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: _abuKartu,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(item.icon, size: 20, color: _merah),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.nama,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.profilText,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatRupiah(item.harga),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Text(
                'Bukti Pengecekan Fisik',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Icon(
              Icons.verified_outlined,
              size: 16,
              color: AppColors.profilSubtext,
            ),
            const SizedBox(width: 4),
            const Text(
              'Terverifikasi Pegawai',
              style: TextStyle(fontSize: 11.5, color: AppColors.profilSubtext),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Dokumentasi berupa foto saat tim Ryokou melakukan pengecekan '
          'pengembalian unit.',
          style: TextStyle(fontSize: 12.5, height: 1.4, color: _teksAbu),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _abuFoto,
            borderRadius: BorderRadius.circular(12),
          ),
          child: AssetImg(_motor.image, height: 176),
        ),
        const SizedBox(height: 12),
        _kotakTotal(
          label: 'TOTAL DENDA KERUSAKAN SPARE PART',
          nominal: _totalKerusakan,
        ),
      ],
    );
  }

  // ---------- Isi: Keluar batas wilayah ----------

  Widget _isiKeluarWilayah() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Icon(Icons.satellite_alt_rounded, size: 22, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Detail Keluar Wilayah',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Log pergerakan titik koordinat GPS yang tercatat keluar dari '
          'geofence zona legal RYOKOU.',
          style: TextStyle(fontSize: 12.5, height: 1.4, color: _teksAbu),
        ),
        const SizedBox(height: 12),
        _petaGeofence(),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _abuKartu,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.wrong_location_outlined, size: 22, color: _merah),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lokasi Terdeteksi Melanggar',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _merah,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _lokasiKeluarWilayah,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: _teksAbu,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _merahBanner,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '+$_jarakKeluarWilayahKm km',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _merah,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'dari batas aman',
                    style: TextStyle(fontSize: 11.5, color: _teksAbu),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _kotakTotal(
          label: 'TOTAL DENDA KELUAR WILAYAH',
          nominal: _dendaKeluarWilayah,
        ),
      ],
    );
  }

  /// Ilustrasi peta: zona aman (lingkaran putus-putus), garis pelanggaran,
  /// dan kotak penanda titik pelanggaran.
  Widget _petaGeofence() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 230,
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final h = c.maxHeight;
            final pusat = Offset(w * 0.32, h * 0.58);
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _PetaPainter(pusat: pusat)),
                ),
                // Label zona aman
                Positioned(
                  left: pusat.dx - 62,
                  top: pusat.dy - 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(235),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Zona Aman RYOKOU',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                // Kotak "Batas Wilayah Terlewati"
                Positioned(
                  top: 12,
                  right: 10,
                  width: w * 0.58,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.notifications_active_outlined,
                          size: 18,
                          color: _merah,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Batas Wilayah Terlewati',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _merah,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_tgl(_waktuKeluarWilayah)}, '
                                '${_jam(_waktuKeluarWilayah)}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: _teksAbu,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Koordinat: $_latKeluarWilayah, '
                                '$_lngKeluarWilayah',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.profilText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------- Isi: Keterlambatan ----------

  Widget _isiKeterlambatan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Icon(Icons.receipt_long_outlined, size: 22, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Detail Keterlambatan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Jatuh tempo
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _abuKartu,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: _biruMuda,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_busy_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WAKTU JATUH TEMPO',
                      style: TextStyle(fontSize: 11.5, color: _teksAbu),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_tgl(_jatuhTempo)}, ${_jam(_jatuhTempo)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.profilText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Kedatangan aktual
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _merahMuda,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: _merah,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_off_outlined,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WAKTU KEDATANGAN AKTUAL',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _merah,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_tgl(_waktuKedatangan)}, ${_jam(_waktuKedatangan)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.profilText,
                      ),
                    ),
                    Text(
                      'Status: $_teksTerlambat',
                      style: const TextStyle(fontSize: 12.5, color: _merah),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _kotakTotal(
          label: 'TOTAL DENDA KETERLAMBATAN PENGEMBALIAN',
          nominal: _dendaKeterlambatan,
        ),
      ],
    );
  }

  // ---------- Bawah halaman ----------

  Widget _kosong() {
    return _kartuPutih(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      child: const Column(
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 52, color: AppColors.statusTersedia),
          SizedBox(height: 12),
          Text(
            'Kamu tidak memiliki denda',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Semua penyewaan kamu aman. Terima kasih!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _teksAbu),
          ),
        ],
      ),
    );
  }

  /// Kotak abu-abu imbauan + tombol "Pelajari tentang denda pada Ryokou".
  Widget _kartuImbauan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 24, color: AppColors.primary),
              SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'KAMI MEMINTA KEPADA ANDA AGAR CEPAT MELUNASI '
                            'DENDA UNTUK KEPENTINGAN BERSAMA\n',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      TextSpan(
                        text: 'Tidak membayar DENDA dapat menonaktifkan akun '
                            'sewa sementara serta membatasi hak pemesanan '
                            'unit RYOKOU di kemudian hari, ataupun '
                            'penahanterhadap jaminan yang diberikan.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: _teksAbu,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _bukaInformasiDenda,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.menu_book_outlined, size: 22, color: AppColors.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'PELAJARI TENTANG DENDA PADA RYOKOU',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.grey),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tombolBayar() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Material(
            color: _merah,
            elevation: 3,
            shadowColor: _merah.withAlpha(90),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _bayar,
              child: const SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payments_outlined, size: 24, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'BAYAR DENDA SEKARANG',
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Menggambar latar peta sederhana + zona aman + garis pelanggaran.
class _PetaPainter extends CustomPainter {
  final Offset pusat;
  const _PetaPainter({required this.pusat});

  @override
  void paint(Canvas canvas, Size size) {
    // Latar peta
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE6EDE3),
    );

    // Blok kota / jalan (hiasan)
    final blok = Paint()..color = const Color(0xFFD7E3D2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.08, size.width * 0.2, size.height * 0.18),
        const Radius.circular(8),
      ),
      blok,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.62, size.height * 0.68, size.width * 0.3, size.height * 0.22),
        const Radius.circular(8),
      ),
      blok,
    );
    final jalan = Paint()
      ..color = Colors.white.withAlpha(200)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, size.height * 0.82),
      Offset(size.width, size.height * 0.46),
      jalan,
    );
    canvas.drawLine(
      Offset(size.width * 0.55, 0),
      Offset(size.width * 0.7, size.height),
      jalan,
    );

    // Zona aman
    final r = size.width * 0.27;
    canvas.drawCircle(pusat, r, Paint()..color = const Color(0x40BFE6F5));
    _garisPutus(
      canvas,
      Path()..addOval(Rect.fromCircle(center: pusat, radius: r)),
      Paint()
        ..color = const Color(0xFF9FD8EC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
      dash: 7,
      gap: 5,
    );

    // Garis pelanggaran (merah putus-putus) ke kotak penanda
    final ujung = Offset(size.width * 0.44, size.height * 0.5);
    _garisPutus(
      canvas,
      Path()
        ..moveTo(pusat.dx, pusat.dy)
        ..lineTo(ujung.dx, ujung.dy),
      Paint()
        ..color = const Color(0xFFBA1A1A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
      dash: 8,
      gap: 5,
    );
    canvas.drawCircle(ujung, 5, Paint()..color = const Color(0xFFBA1A1A));
    canvas.drawCircle(ujung, 2, Paint()..color = Colors.white);
  }

  void _garisPutus(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dash,
    required double gap,
  }) {
    for (final PathMetric m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        final end = math.min(d + dash, m.length);
        canvas.drawPath(m.extractPath(d, end), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PetaPainter old) => old.pusat != pusat;
}