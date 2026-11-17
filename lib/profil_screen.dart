import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'riwayat_screen.dart';
import 'detail_denda_screen.dart';
import 'informasi_denda_screen.dart';
import 'data/status_pengguna.dart';
import 'profile_screen.dart';
import 'theme/app_colors.dart';
import 'widgets/navbar.dart';
import 'widgets/topbar.dart';

/// Halaman tab Profil. Isinya berubah otomatis mengikuti variabel di
/// lib/data/status_pengguna.dart (sewaMotor, dendaKeterlambatan, dll).
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  static const _versiApp = '2.4.1';

  // ---------- Aksi ----------

  void _belumTersedia(BuildContext context, String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  // Icon ubah profil -> halaman form data diri (ProfileScreen)
  void _bukaEditProfil(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
    );
  }

  // Buka halaman Detail Denda (rincian + bukti tiap jenis denda)
  void _bukaDetailDenda(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DetailDendaScreen()),
    );
  }

  Future<void> _konfirmasiKeluar(BuildContext context) async {
    final keluar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar akun?'),
        content: const Text('Kamu akan keluar dari akun ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppColors.logout),
            ),
          ),
        ],
      ),
    );
    if (keluar == true && context.mounted) {
      // Kembali ke splash (route '/')
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  // ---------- Halaman ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: const RyokouTopBar(title: 'PROFIL'),
      bottomNavigationBar: const RyokouNavBar(current: NavTab.profil),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _kartuProfil(context),
            const SizedBox(height: 32),

            // ---- Setting & Bantuan ----
            _judul('Setting & Bantuan'),
            _kartu(
              child: Column(
                children: [
                  _baris(
                    icon: Icons.settings_outlined,
                    judul: 'Setting',
                    subjudul: 'Setting Tema Aplikasi, dll',
                    onTap: () => _belumTersedia(
                      context,
                      'Halaman Setting belum tersedia',
                    ),
                  ),
                  _baris(
                    icon: Icons.contact_support_outlined,
                    judul: 'Bantuan',
                    subjudul: 'Beri laporan, atau lainnya',
                    onTap: () => _belumTersedia(
                      context,
                      'Halaman Bantuan belum tersedia',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ---- Riwayat & Denda ----
            _judul('Riwayat & Denda'),
            _kartuDenda(context),
            const SizedBox(height: 6),
                        _kartu(
              child: _baris(
                icon: Icons.schedule_outlined,
                judul: 'Riwayat',
                subjudul: 'Riwayat Pemesanan, dll',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RiwayatScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            _footer(context),
          ],
        ),
      ),
    );
  }

  // ---------- Komponen umum ----------

  Widget _judul(String teks) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        teks,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.profilText,
        ),
      ),
    );
  }

  /// Kartu abu-abu muda. Memakai Material supaya efek sentuh (ripple)
  /// pada baris di dalamnya tetap terlihat.
  Widget _kartu({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
  }) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: AppColors.cardSoft,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }

  /// Satu baris menu: bulatan icon + judul + keterangan + panah.
  /// [iconWidget] opsional, dipakai kalau icon-nya perlu dibuat khusus.
  Widget _baris({
    IconData? icon,
    Widget? iconWidget,
    required String judul,
    required String subjudul,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child:
                  iconWidget ??
                  Icon(icon, size: 22, color: AppColors.iconOnPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.profilText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subjudul,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.profilSubtext,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: AppColors.chevron,
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Kartu profil ----------

  Widget _kartuProfil(BuildContext context) {
    return _kartu(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _avatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaPengguna,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.profilText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      noHpPengguna,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.profilSubtext,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _badgeTerverifikasi(),
                  ],
                ),
              ),
              // Icon ubah profil
              Material(
                color: AppColors.tuneBg,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _bukaEditProfil(context),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 22,
                      color: AppColors.profilSubtext,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 84,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _tileStatusSewa()),
                const SizedBox(width: 12),
                Expanded(child: _tileAksi(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.avatarGrey, width: 3),
      ),
      child: const ClipOval(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Icon(
            Icons.person_rounded,
            size: 48,
            color: AppColors.avatarGrey,
          ),
        ),
      ),
    );
  }

  Widget _badgeTerverifikasi() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.chipTersedia,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_outlined, size: 13, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'Terverifikasi',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Kotak kiri: abu-abu "Belum Menyewa Motor" atau hijau "Sedang Menyewa ..."
  /// (mengikuti variabel sewaMotor).
  Widget _tileStatusSewa() {
    final menyewa = sewaMotor;
    final warnaTeks = menyewa ? Colors.white : AppColors.profilText;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: menyewa ? AppColors.statusTersedia : AppColors.tileGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'STATUS SEWA',
            style: TextStyle(
              fontSize: 9,
              height: 1.25,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w500,
              color: menyewa ? Colors.white : AppColors.profilSubtext,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: menyewa
                ? Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        color: warnaTeks,
                      ),
                      children: [
                        const TextSpan(text: 'Sedang Menyewa\n'),
                        TextSpan(
                          text: motorYangDisewa,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    'Belum Menyewa\nMotor',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: warnaTeks,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Kotak kanan (berubah otomatis):
  ///  - ada denda      -> merah  "Anda Memiliki Denda"
  ///  - sedang menyewa -> hijau tua "Lihat Detail Penyewaan"
  ///  - lainnya        -> hijau tua "Sewa Sekarang!"
  Widget _tileAksi(BuildContext context) {
    final String teks;
    final Color warna;
    final VoidCallback onTap;

    if (punyaDenda) {
      teks = 'Anda Memiliki\nDenda';
      warna = AppColors.statusDisewa;
      onTap = () => _bukaDetailDenda(context);
    } else if (sewaMotor) {
      teks = 'Lihat Detail\nPenyewaan';
      warna = AppColors.primary;
      onTap = () => _belumTersedia(
        context,
        'Halaman detail penyewaan belum tersedia',
      );
    } else {
      teks = 'Sewa\nSekarang!';
      warna = AppColors.primary;
      onTap = () =>
          Navigator.of(context).pushReplacementNamed(NavTab.produk.route);
    }

    return Material(
      color: warna,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    teks,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 26,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Denda ----------

  /// Icon uang dengan tanda seru kecil di pojok kanan bawah (Detail Denda).
  Widget _iconDetailDenda() {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(
          Icons.payments_outlined,
          size: 22,
          color: AppColors.iconOnPrimary,
        ),
        Positioned(
          right: 7,
          bottom: 8,
          child: Container(
            width: 10,
            height: 10,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Text(
              '!',
              style: TextStyle(
                fontSize: 8,
                height: 1,
                fontWeight: FontWeight.w900,
                color: AppColors.iconOnPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _kartuDenda(BuildContext context) {
    final kartu = _kartu(
      child: Column(
        children: [
          _baris(
            icon: Icons.contact_support_outlined,
            judul: 'Informasi Denda',
            subjudul: 'Pelajari tentang denda pada Rental RYOKOU',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const InformasiDendaScreen(),
              ),
            ),
          ),
          _baris(
            iconWidget: _iconDetailDenda(),
            judul: 'Detail Denda',
            subjudul: punyaDenda
                ? 'Memiliki $jumlahDenda Denda'
                : 'Tidak Memiliki',
            onTap: () => _bukaDetailDenda(context),
          ),
        ],
      ),
    );

    if (!punyaDenda) return kartu;

    // Tanda seru merah di pojok kanan atas kartu Denda (hanya kalau ada denda)
    return Stack(
      clipBehavior: Clip.none,
      children: [
        kartu,
        Positioned(
          top: -8,
          right: 10,
          child: SvgPicture.asset(
            'assets/icons/tanda_seru.svg',
            width: 22,
            height: 22,
          ),
        ),
      ],
    );
  }

  // ---------- Bawah halaman ----------

  Widget _footer(BuildContext context) {
    return Column(
      children: [
        const Text(
          'RYOKOU Rental Motor v$_versiApp',
          style: TextStyle(fontSize: 12, color: AppColors.profilSubtext),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () => _konfirmasiKeluar(context),
          child: const Text(
            'Keluar Akun',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.logout,
            ),
          ),
        ),
      ],
    );
  }
}