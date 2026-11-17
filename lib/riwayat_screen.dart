import 'package:flutter/material.dart';

import 'models/motor.dart';
import 'theme/app_colors.dart';
import 'widgets/common_widgets.dart';
import 'widgets/topbar.dart';

// =====================================================================
//  DATA RIWAYAT  (untuk testing, ubah / tambah data di bagian ini saja)
// =====================================================================

/// Tanggal acuan untuk filter "Bulan Ini".
/// Data contoh ada di Oktober 2024, jadi diset ke tanggal itu.
/// Kalau data sudah asli, ganti jadi: DateTime.now()
final DateTime _hariIni = DateTime(2024, 10, 20);

final List<_Transaksi> _dataRiwayat = [
  _Transaksi(
    jenis: _Jenis.denda,
    label: 'DENDA\nKERUSAKAN',
    judul: 'Pembayaran - Denda',
    tanggal: DateTime(2024, 10, 15),
    nama: 'Kerusakan Spare Part',
    nominal: 150000,
    keterangan: 'Klaim: spion kanan retak & baret pada body',
    status: 'Lunas (TRANSFER)',
    unit: 'Unit: Honda Beat Street',
    tombol: 'Lihat Detail Denda',
    info: [
      ('Status', 'Lunas'),
      ('Metode Pembayaran', 'Transfer'),
      ('Unit', 'Honda Beat Street'),
    ],
    rincian: [
      ('Spion Kanan Patah & Retak', 65000),
      ('Baret & Lecet Pada Body', 85000),
    ],
  ),
  _Transaksi(
    jenis: _Jenis.sewa,
    label: 'RENTAL\nMOTOR',
    judul: 'Penyewaan - Honda Beat Street',
    tanggal: DateTime(2024, 10, 12),
    nama: 'Honda Beat Street',
    nominal: 90000,
    keterangan: 'Plat N 4821 EC • Durasi: 1 Hari',
    status: 'Sewa Selesai',
    gambarModel: 'Beat Deluxe Street', // dicocokkan dengan model di dataMotor
    tombol: 'Lihat Detail Struk',
    info: [
      ('Status', 'Sewa Selesai'),
      ('Plat Nomor', 'N 4821 EC'),
      ('Durasi', '1 Hari'),
    ],
    rincian: [('Sewa Honda Beat Street (1 Hari)', 90000)],
  ),
];

// =====================================================================

enum _Jenis { sewa, denda }

enum _FilterJenis { semua, sewa, denda }

enum _FilterWaktu { bulanIni, semuaWaktu, rentang }

class _Transaksi {
  final _Jenis jenis;
  final String label; // tag kiri atas (pakai \n untuk 2 baris)
  final String judul; // judul header
  final DateTime tanggal;
  final String nama;
  final int nominal;
  final String keterangan;
  final String status; // teks chip status
  final String? unit; // teks abu di samping chip (khusus denda)
  final String? gambarModel; // model motor untuk gambar (khusus sewa)
  final String tombol; // teks tombol bawah kartu
  final List<(String, String)> info; // baris info di detail
  final List<(String, int)> rincian; // baris rincian biaya di detail

  _Transaksi({
    required this.jenis,
    required this.label,
    required this.judul,
    required this.tanggal,
    required this.nama,
    required this.nominal,
    required this.keterangan,
    required this.status,
    required this.tombol,
    required this.info,
    required this.rincian,
    this.unit,
    this.gambarModel,
  });

  int get total => rincian.fold(0, (a, e) => a + e.$2);
}

/// Halaman "Riwayat": daftar transaksi penyewaan & pembayaran denda,
/// lengkap dengan filter jenis dan filter tanggal.
class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  // ---------- Warna ----------
  static const _teksAbu = Color(0xFF40484B);
  static const _teksTanggal = Color(0xFF9CA3AF);
  static const _chipAbu = Color(0xFFE9E9EA);
  static const _chipBiru = Color(0xFFEEF2F6);
  static const _biruMuda = Color(0xFFC2E9F4);
  static const _merah = Color(0xFFD91A45);
  static const _garis = Color(0xFFEFEFEF);

  // ---------- State filter ----------
  _FilterJenis _jenis = _FilterJenis.semua;
  _FilterWaktu _waktu = _FilterWaktu.bulanIni; // sama dengan desain
  DateTimeRange? _rentang;

  // ---------- Data terfilter ----------

  DateTime _hanyaTanggal(DateTime d) => DateTime(d.year, d.month, d.day);

  List<_Transaksi> get _hasil {
    final list = _dataRiwayat.where((t) {
      final cocokJenis = switch (_jenis) {
        _FilterJenis.semua => true,
        _FilterJenis.sewa => t.jenis == _Jenis.sewa,
        _FilterJenis.denda => t.jenis == _Jenis.denda,
      };
      if (!cocokJenis) return false;

      return switch (_waktu) {
        _FilterWaktu.semuaWaktu => true,
        _FilterWaktu.bulanIni =>
          t.tanggal.year == _hariIni.year && t.tanggal.month == _hariIni.month,
        _FilterWaktu.rentang =>
          _rentang == null ||
              (!_hanyaTanggal(t.tanggal).isBefore(_hanyaTanggal(_rentang!.start)) &&
                  !_hanyaTanggal(t.tanggal).isAfter(_hanyaTanggal(_rentang!.end))),
      };
    }).toList();

    // Terbaru di atas
    list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return list;
  }

  // ---------- Format ----------

  String _dd(int n) => n.toString().padLeft(2, '0');

  String _tgl(DateTime d) => '${_dd(d.day)}/${_dd(d.month)}/${d.year}';

  String _tglPendek(DateTime d) => '${_dd(d.day)}/${_dd(d.month)}';

  // ---------- Aksi ----------

  Future<void> _pilihTanggal() async {
    final hasil = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _rentang,
      helpText: 'Pilih rentang tanggal',
      saveText: 'Terapkan',
    );
    if (hasil != null && mounted) {
      setState(() {
        _rentang = hasil;
        _waktu = _FilterWaktu.rentang;
      });
    }
  }

  void _bukaDetail(_Transaksi t) {
    final denda = t.jenis == _Jenis.denda;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                denda ? 'Detail Denda' : 'Detail Struk',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                t.judul,
                style: const TextStyle(fontSize: 13, color: _teksAbu),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: _garis),
              _barisInfo('Tanggal', _tgl(t.tanggal)),
              for (final i in t.info) _barisInfo(i.$1, i.$2),
              const Divider(height: 24, color: _garis),
              Text(
                denda ? 'Rincian Denda' : 'Rincian Biaya',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.profilText,
                ),
              ),
              const SizedBox(height: 8),
              for (final r in t.rincian)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          r.$1,
                          style: const TextStyle(fontSize: 13.5, color: _teksAbu),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatRupiah(r.$2),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.profilText,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'TOTAL',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 0.5,
                          color: Color(0xFF9CC9D6),
                        ),
                      ),
                    ),
                    Text(
                      formatRupiah(t.total),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.tuneBg,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barisInfo(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: _teksAbu),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            nilai,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.profilText,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Halaman ----------

  @override
  Widget build(BuildContext context) {
    final hasil = _hasil;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: const RyokouTopBar(title: 'RIWAYAT'),
      body: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _tombolKembali(),
            ),
          ),
          const SizedBox(height: 12),
          _barisFilterJenis(),
          const SizedBox(height: 12),
          _barisFilterWaktu(),
          const SizedBox(height: 20),
          if (hasil.isEmpty)
            _kosong()
          else
            for (final t in hasil)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _kartuTransaksi(t),
              ),
        ],
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

  // ---------- Filter ----------

  /// Satu chip (dipakai di kedua baris filter).
  Widget _chip({
    required String label,
    required bool aktif,
    required VoidCallback onTap,
    required Color warnaAktif,
    required Color teksAktif,
    required Color warnaNonaktif,
    IconData? icon,
  }) {
    final warnaTeks = aktif ? teksAktif : _teksAbu;
    return Material(
      color: aktif ? warnaAktif : warnaNonaktif,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: warnaTeks),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: aktif ? FontWeight.w600 : FontWeight.w500,
                    color: warnaTeks,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Baris 1: Semua Transaksi | Penyewaan Motor | Pembayaran Denda
  Widget _barisFilterJenis() {
    Widget item(String label, _FilterJenis j) => _chip(
      label: label,
      aktif: _jenis == j,
      onTap: () => setState(() => _jenis = j),
      warnaAktif: AppColors.primary,
      teksAktif: Colors.white,
      warnaNonaktif: _chipBiru,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          item('Semua Transaksi', _FilterJenis.semua),
          const SizedBox(width: 8),
          item('Penyewaan Motor', _FilterJenis.sewa),
          const SizedBox(width: 8),
          item('Pembayaran Denda', _FilterJenis.denda),
        ],
      ),
    );
  }

  /// Baris 2: Bulan Ini | Semua Waktu | ........ Filter Tanggal
  Widget _barisFilterWaktu() {
    final rentangAktif = _waktu == _FilterWaktu.rentang && _rentang != null;
    final labelTanggal = rentangAktif
        ? '${_tglPendek(_rentang!.start)} - ${_tglPendek(_rentang!.end)}'
        : 'Filter Tanggal';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _chip(
            label: 'Bulan Ini',
            icon: Icons.calendar_month_outlined,
            aktif: _waktu == _FilterWaktu.bulanIni,
            onTap: () => setState(() => _waktu = _FilterWaktu.bulanIni),
            warnaAktif: _biruMuda,
            teksAktif: AppColors.primary,
            warnaNonaktif: _chipAbu,
          ),
          const SizedBox(width: 8),
          _chip(
            label: 'Semua Waktu',
            aktif: _waktu == _FilterWaktu.semuaWaktu,
            onTap: () => setState(() => _waktu = _FilterWaktu.semuaWaktu),
            warnaAktif: _biruMuda,
            teksAktif: AppColors.primary,
            warnaNonaktif: _chipAbu,
          ),
          const Spacer(),
          Flexible(
            child: _chip(
              label: labelTanggal,
              icon: Icons.tune_rounded,
              aktif: rentangAktif,
              onTap: _pilihTanggal,
              warnaAktif: _biruMuda,
              teksAktif: AppColors.primary,
              warnaNonaktif: _chipAbu,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Kartu transaksi ----------

  Widget _kartuTransaksi(_Transaksi t) {
    final denda = t.jenis == _Jenis.denda;

    final warnaTag = denda ? _merah : const Color(0xFF0F766E);
    final bgTag = denda ? const Color(0xFFFFF0F0) : const Color(0xFFF0FDFA);
    final borderTag = denda ? const Color(0xFFFFD6D6) : const Color(0xFFA7F0DD);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: denda ? const Color(0xFFFFE4E6) : const Color(0xFFF1F1F1),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- Header: tag, judul, tanggal ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: bgTag,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderTag),
                ),
                child: Text(
                  t.label,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.3,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w700,
                    color: warnaTag,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t.judul,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                    color: AppColors.profilText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _tgl(t.tanggal),
                style: const TextStyle(fontSize: 12.5, color: _teksTanggal),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: _garis),
          const SizedBox(height: 14),

          // ---- Isi: gambar/ikon + nama + nominal ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              denda ? _tileIconDenda() : _tileMotor(t),
              const SizedBox(width: 12),
              Expanded(child: _isiKartu(t, denda)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: _garis),

          // ---- Tombol detail ----
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _bukaDetail(t),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.tombol,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _isiKartu(_Transaksi t, bool denda) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                t.nama,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.profilText,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatRupiah(t.nominal),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: denda ? _merah : AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          t.keterangan,
          style: const TextStyle(
            fontSize: 13,
            height: 1.35,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _chipStatus(t.status, denda),
            if (t.unit != null)
              Text(
                t.unit!,
                style: const TextStyle(fontSize: 12, color: _teksTanggal),
              ),
          ],
        ),
      ],
    );
  }

  Widget _chipStatus(String teks, bool denda) {
    // Denda: hijau "Lunas". Sewa: hijau toska dengan titik.
    final warna = denda ? const Color(0xFF047857) : const Color(0xFF0F766E);
    final bg = denda ? const Color(0xFFE8FBF1) : const Color(0xFFECFDF8);
    final border = denda ? const Color(0xFFB7EBD0) : const Color(0xFF99F0DC);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!denda) ...[
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF14B8A6),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            teks,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: warna,
            ),
          ),
        ],
      ),
    );
  }

  /// Kotak kuning berisi ikon kunci (transaksi denda).
  Widget _tileIconDenda() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Icon(
        Icons.build_rounded,
        size: 24,
        color: Color(0xFFB45309),
      ),
    );
  }

  /// Kotak abu berisi gambar motor (transaksi sewa).
  Widget _tileMotor(_Transaksi t) {
    final motor = dataMotor.firstWhere(
      (m) => m.model == t.gambarModel,
      orElse: () => dataMotor.first,
    );
    return Container(
      width: 80,
      height: 64,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.pageBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: AssetImg(motor.image, width: 64, height: 48),
    );
  }

  Widget _kosong() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.border),
          SizedBox(height: 12),
          Text(
            'Belum ada transaksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Coba ubah filter jenis atau tanggal.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _teksAbu),
          ),
        ],
      ),
    );
  }
}