import 'package:flutter/material.dart';

import 'profile_screen.dart';
import 'theme/app_colors.dart';
import 'widgets/navbar.dart';
import 'widgets/topbar.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _FaqData {
  final String pertanyaan;
  final String jawaban;
  const _FaqData(this.pertanyaan, this.jawaban);
}

class _SettingScreenState extends State<SettingScreen> {
  // ---- Data contoh: ganti dengan data asli ----
  static const _nama = 'Sigma';
  static const _noHp = '+62812-3456-7890';
  static const _noCs = '08123456789';
  static const _versiApp = '2.4.1';
  static const _merah = Color(0xFFD32F2F);

  static const _faq = [
    _FaqData(
      'Bagaimana cara merental motor?',
      'Pilih motor di halaman Produk, tekan "Sewa Sekarang", tentukan '
          'tanggal sewa, lalu lakukan pembayaran. Motor siap diambil sesuai '
          'jadwal yang kamu pilih.',
    ),
    _FaqData(
      'Apa saja syarat dokumen yang diperlukan?',
      'Siapkan KTP dan SIM C yang masih berlaku. Dokumen asli ditunjukkan '
          'saat pengambilan motor.',
    ),
    _FaqData(
      'Bagaimana sistem pembayaran deposit?',
      'Deposit dibayarkan saat pengambilan motor dan dikembalikan saat '
          'motor dikembalikan tepat waktu dan dalam kondisi baik. '
          'Keterlambatan dikenakan denda per jam.',
    ),
  ];

  bool _modeGelap = false;

  void _snack(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  // Buka halaman ubah profil (bisa kembali dengan tombol back)
  void _bukaProfil() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const ProfileScreen()));
  }

  Future<void> _konfirmasiKeluar() async {
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
            child: const Text('Keluar', style: TextStyle(color: _merah)),
          ),
        ],
      ),
    );
    if (keluar == true && mounted) {
      // Kembali ke splash (route '/')
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const RyokouTopBar(title: 'SETTING'),
      bottomNavigationBar: const RyokouNavBar(current: NavTab.setting),
      body: ColoredBox(
        color: AppColors.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfil(),
              const SizedBox(height: 22),
              _judul('Aplikasi Setting'),
              _buildPengaturan(),
              const SizedBox(height: 22),
              _judul('FAQ'),
              _buildFaq(),
              const SizedBox(height: 14),
              _buildKontak(),
              const SizedBox(height: 22),
              _buildFooter(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Komponen umum ----------

  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _judul(String teks) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        teks,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _iconBulat(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: Colors.white),
    );
  }

  // ---------- Kartu profil ----------

  Widget _buildProfil() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.avatarBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      _nama,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      _noHp,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _badgeTerverifikasi(),
                  ],
                ),
              ),
              // Tombol ubah profil (icon) -> buka ProfileScreen
              Material(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _bukaProfil,
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 76,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _tileStatusSewa()),
                const SizedBox(width: 12),
                Expanded(child: _tileSewaSekarang()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeTerverifikasi() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 12,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            'Terverifikasi',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tileStatusSewa() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'STATUS SEWA',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Belum Menyewa\nMotor',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tileSewaSekarang() {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        // Ke halaman Produk
        onTap: () =>
            Navigator.of(context).pushReplacementNamed(NavTab.produk.route),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Sewa\nSekarang!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 28, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Aplikasi setting ----------

  Widget _buildPengaturan() {
    return _card(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _tilePengaturan(
            icon: Icons.language_rounded,
            judul: 'Bahasa Aplikasi',
            subjudul: 'Indonesia (Default)',
            onTap: () => _snack('Bahasa lain belum tersedia'),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ID',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
          _tilePengaturan(
            icon: Icons.dark_mode_rounded,
            judul: 'Mode Gelap',
            subjudul: 'Mengubah tema aplikasi',
            onTap: () => setState(() => _modeGelap = !_modeGelap),
            trailing: Switch(
              value: _modeGelap,
              onChanged: (v) => setState(() => _modeGelap = v),
              thumbColor: const WidgetStatePropertyAll(Colors.white),
              trackColor: WidgetStateProperty.resolveWith<Color>(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.primary
                    : AppColors.border,
              ),
              trackOutlineColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tilePengaturan({
    required IconData icon,
    required String judul,
    required String subjudul,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _iconBulat(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subjudul,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  // ---------- FAQ ----------

  Widget _buildFaq() {
    return _card(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _faq.length; i++) ...[
            _FaqItem(pertanyaan: _faq[i].pertanyaan, jawaban: _faq[i].jawaban),
            if (i != _faq.length - 1)
              const Divider(height: 1, color: AppColors.divider),
          ],
        ],
      ),
    );
  }

  // ---------- Kontak + footer ----------

  Widget _buildKontak() {
    return _card(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Belum menemukan solusi?\nhubungi kami pada nomor $_noCs',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 12),
          Icon(Icons.support_agent_rounded, size: 28, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'RYOKOU Rental Motor v$_versiApp',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: _konfirmasiKeluar,
          child: const Text(
            'Keluar Akun',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _merah,
            ),
          ),
        ),
      ],
    );
  }
}

// Satu pertanyaan FAQ yang bisa dibuka-tutup.
class _FaqItem extends StatefulWidget {
  final String pertanyaan;
  final String jawaban;
  const _FaqItem({required this.pertanyaan, required this.jawaban});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _terbuka = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _terbuka = !_terbuka),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.pertanyaan,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Arrow berputar ke bawah saat terbuka
                AnimatedRotation(
                  turns: _terbuka ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            // Jawaban membuka/menutup dengan animasi tinggi
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: _terbuka
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10, right: 24),
                      child: Text(
                        widget.jawaban,
                        style: const TextStyle(
                          fontSize: 11,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
