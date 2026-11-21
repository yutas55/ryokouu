import 'package:flutter/material.dart' hide Text;
import 'package:ryokou/bahasa.dart';

import 'models/motor.dart';
import 'theme/app_colors.dart';
import 'widgets/topbar.dart';

/// Halaman "Informasi Denda": syarat & ketentuan denda rental motor.
/// Dibuka dari baris "Informasi Denda" di halaman Profil.
class InformasiDendaScreen extends StatelessWidget {
  const InformasiDendaScreen({super.key});

  // ---------- Data (ubah di sini kalau tarif berubah) ----------

  // Denda keterlambatan per jam, sesuai model motor.
  static const _tarifTerlambat = [
    _Tarif('BEAT', 8000),
    _Tarif('SCOOPY', 10000),
    _Tarif('CRF', 21500),
    _Tarif('VARIO', 11000),
  ];

  static const _dendaKeluarWilayah = 300000;
  static const _noCs = '08123456789';

  // ---------- Warna khusus halaman ini ----------

  static const _teksKartu = Color(0xFF111827);
  static const _teksLabel = Color(0xFF4B5563);
  static const _garis = Color(0xFFEDEFF1);
  static const _borderKartu = Color(0xFFF3F4F6);
  static const _kuning = Color(0xFFFCD34D);
  static const _oranye = Color(0xFFD97706);
  static const _oranyeMuda = Color(0xFFFFFBEB);
  static const _merah = Color(0xFFDC2626);
  static const _merahMuda = Color(0xFFFEF2F2);
  static const _ungu = Color(0xFF9333EA);
  static const _unguMuda = Color(0xFFFAF5FF);
  static const _unguBorder = Color(0xFFF3E8FF);
  static const _unguTeks = Color(0xFF581C87);

  /// 8000 -> "8.000" (tanpa "Rp", memakai pemisah titik dari formatRupiah).
  static String _angka(int n) => formatRupiah(n).replaceFirst('Rp ', '');

  // ---------- Halaman ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: const RyokouTopBar(title: 'INFORMASI DENDA'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _tombolKembali(context),
              ),
              const SizedBox(height: 16),
              _hero(),
              const SizedBox(height: 16),
              _kartuKeterlambatan(),
              const SizedBox(height: 16),
              _kartuKerusakan(),
              const SizedBox(height: 16),
              _kartuWilayah(),
              const SizedBox(height: 24),
              _bannerCs(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Bagian atas ----------

  Widget _tombolKembali(BuildContext context) {
    return Material(
      color: _borderKartu,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.of(context).maybePop(),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.arrow_back_rounded, size: 24, color: _teksKartu),
        ),
      ),
    );
  }

  /// Kartu hijau tua "PANDUAN PENTING".
  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF104652), Color(0xFF0B3640)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 28,
              color: _kuning,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _kuning.withAlpha(50),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PANDUAN PENTING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: _kuning,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Syarat & Ketentuan Denda Rental Motor RYOKOU',
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Harap baca dengan seksama agar perjalanan Anda tetap '
                  'nyaman, aman, dan bebas dari kendala biaya tak terduga.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xE6FFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Kerangka kartu putih ----------

  Widget _kartu({
    required IconData icon,
    required Color warnaIcon,
    required Color warnaTile,
    required String judul,
    required String subjudul,
    required Widget isi,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderKartu),
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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: warnaTile,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: warnaIcon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subjudul,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.profilSubtext,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: _garis),
          isi,
        ],
      ),
    );
  }

  // ---------- 1. Keterlambatan ----------

  Widget _kartuKeterlambatan() {
    return _kartu(
      icon: Icons.schedule_rounded,
      warnaIcon: _oranye,
      warnaTile: _oranyeMuda,
      judul: 'Keterlambatan Pengembalian',
      subjudul: 'Tergantung Model Yang Digunakan',
      isi: Column(
        children: [
          for (var i = 0; i < _tarifTerlambat.length; i++) ...[
            _barisTarif(_tarifTerlambat[i]),
            if (i != _tarifTerlambat.length - 1)
              const Divider(height: 1, color: _garis),
          ],
        ],
      ),
    );
  }

  Widget _barisTarif(_Tarif tarif) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 14, color: _teksKartu),
                children: [
                  const TextSpan(text: 'Model '),
                  TextSpan(
                    text: tarif.model,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          Text(
            '${_angka(tarif.perJam)}/Jam',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _teksKartu,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- 2. Kerusakan ----------

  Widget _kartuKerusakan() {
    return _kartu(
      icon: Icons.warning_amber_rounded,
      warnaIcon: _merah,
      warnaTile: _merahMuda,
      judul: 'Kerusakan Fisik & Komponen',
      subjudul: 'Tergantung seberapa rusaknya, dan spare partnya',
      isi: Column(
        children: [
          _barisKerusakan(
            'Lecet / Goresan Ringan',
            _nilai('Rp 50.000 - 100.000'),
          ),
          const Divider(height: 1, color: _garis),
          _barisKerusakan(
            'Pecah Body / Rusak Sedang',
            _nilai('Part Resmi Honda + Pasang'),
          ),
          const Divider(height: 1, color: _garis),
          _barisKerusakan('Ban Bocor / Kena Paku', _chipDitanggung()),
        ],
      ),
    );
  }

  Widget _barisKerusakan(String label, Widget nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.35,
                color: _teksLabel,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nilai dibatasi lebarnya supaya yang panjang turun ke baris bawah
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 156),
            child: nilai,
          ),
        ],
      ),
    );
  }

  Widget _nilai(String teks) {
    return Text(
      teks,
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontSize: 13,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: _teksKartu,
      ),
    );
  }

  Widget _chipDitanggung() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _oranyeMuda,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Ditanggung Penyewa',
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: _oranye,
        ),
      ),
    );
  }

  // ---------- 3. Batas wilayah ----------

  Widget _kartuWilayah() {
    return _kartu(
      icon: Icons.location_on_outlined,
      warnaIcon: _ungu,
      warnaTile: _unguMuda,
      judul: 'Batas Area Operasional',
      subjudul: 'Out of Coverage Penalty',
      isi: Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: _teksLabel,
                ),
                children: [
                  TextSpan(text: 'Hanya diperbolehkan digunakan pada daerah '),
                  TextSpan(
                    text: 'KOTA Malang & KOTA Batu',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _teksKartu,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _unguMuda,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _unguBorder),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Ke Luar Batas Wilayah',
                      style: TextStyle(fontSize: 13, color: _unguTeks),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Denda ${formatRupiah(_dendaKeluarWilayah)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _unguTeks,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Bawah halaman ----------

  Widget _bannerCs() {
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
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                    text: 'Hubungi CS Jika Ada Hal Yang Ingin Ditanyakan ',
                  ),
                  TextSpan(
                    text: _noCs,
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

/// Satu baris tarif denda keterlambatan (model motor + denda per jam).
class _Tarif {
  final String model;
  final int perJam;
  const _Tarif(this.model, this.perJam);
}
