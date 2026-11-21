import 'package:flutter/material.dart';

import 'theme/app_colors.dart';
import 'widgets/topbar.dart';

// Pengaturan tersimpan selama aplikasi berjalan (top-level, jadi tidak
// hilang saat halaman Setting ditutup lalu dibuka lagi).
String _kodeBahasa = 'ID';
bool _modeGelap = false;
bool _pengingatKembali = true;

const String _versiApp = '2.4.1';
const String _buildApp = '2404.1';

const List<(String, String)> _opsiBahasa = [
  ('ID', 'Bahasa Indonesia (Default)'),
  ('EN', 'English'),
];

/// Halaman Setting: tampilan & bahasa, pengingat sewa, dan info sistem.
class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String get _namaBahasa =>
      _opsiBahasa.firstWhere((o) => o.$1 == _kodeBahasa).$2;

  // ---------- Aksi ----------

  void _pilihBahasa() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
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
              const Text(
                'Bahasa Aplikasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              for (final o in _opsiBahasa)
                ListTile(
                  selected: o.$1 == _kodeBahasa,
                  selectedTileColor: AppColors.cardSoft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    o.$2,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.profilText,
                    ),
                  ),
                  trailing: o.$1 == _kodeBahasa
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () {
                    setState(() => _kodeBahasa = o.$1);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _ubahPengingat(bool nilai) async {
    if (!nilai) {
      // Mematikan pengingat bisa bikin telat balik -> konfirmasi dulu.
      final yakin = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Matikan pengingat?'),
          content: const Text(
            'Tanpa pengingat, kamu bisa lupa mengembalikan unit tepat waktu '
            'dan terkena denda keterlambatan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Matikan',
                style: TextStyle(color: AppColors.logout),
              ),
            ),
          ],
        ),
      );
      if (yakin != true || !mounted) return;
    }

    setState(() => _pengingatKembali = nilai);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nilai
              ? 'Pengingat pengembalian diaktifkan'
              : 'Pengingat pengembalian dimatikan',
        ),
      ),
    );
  }

  // ---------- Halaman ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: const RyokouTopBar(title: 'SETTING'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Align(alignment: Alignment.centerLeft, child: _tombolKembali()),
          const SizedBox(height: 20),

          _seksi(
            icon: Icons.palette_outlined,
            judul: 'TAMPILAN & BAHASA',
            children: [
              _baris(
                icon: Icons.translate_rounded,
                judul: 'Bahasa Aplikasi',
                subjudul: _namaBahasa,
                trailing: _chip(_kodeBahasa, chevron: true),
                onTap: _pilihBahasa,
              ),
              _baris(
                icon: Icons.dark_mode_outlined,
                judul: 'Mode Gelap (Dark Mode)',
                subjudul: 'Mengubah tema tampilan menjadi gelap hemat daya',
                trailing: _saklar(
                  _modeGelap,
                  (v) => setState(() => _modeGelap = v),
                ),
                onTap: () => setState(() => _modeGelap = !_modeGelap),
              ),
            ],
          ),
          const SizedBox(height: 28),

          _seksi(
            icon: Icons.notifications_active_outlined,
            judul: 'NOTIFIKASI & PENGINGAT SEWA',
            children: [
              _baris(
                icon: Icons.alarm_rounded,
                judul: 'Pengingat Pengembalian Unit',
                badge: 'PENTING',
                subjudul:
                    'Notifikasi alarm 2 jam & 30 menit sebelum batas sewa habis',
                trailing: _saklar(_pengingatKembali, _ubahPengingat),
                onTap: () => _ubahPengingat(!_pengingatKembali),
              ),
            ],
          ),
          const SizedBox(height: 28),

          _seksi(
            icon: Icons.info_outline_rounded,
            judul: 'SISTEM',
            children: [
              _baris(
                icon: Icons.code_rounded,
                judul: 'Versi Aplikasi',
                subjudul: 'RYOKOU Build $_buildApp',
                trailing: _chip(
                  'v$_versiApp (Terbaru)',
                  icon: Icons.check_circle_outline_rounded,
                  warna: AppColors.avatarBg,
                ),
              ),
            ],
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

  // ---------- Komponen ----------

  /// Satu bagian: judul kecil + kartu putih berisi baris-baris pengaturan.
  Widget _seksi({
    required IconData icon,
    required String judul,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Icon(icon, size: 17, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                judul,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.profilSubtext,
                ),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: 72,
                      endIndent: 16,
                      color: AppColors.divider,
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Satu baris pengaturan: kotak icon + judul + keterangan + widget kanan.
  Widget _baris({
    required IconData icon,
    required String judul,
    required String subjudul,
    required Widget trailing,
    String? badge,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 22, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          judul,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.profilText,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC2E9F4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subjudul,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.profilSubtext,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            trailing,
          ],
        ),
      ),
    );
  }

  /// Chip kecil di kanan baris ("ID >" atau "v2.4.1 (Terbaru)").
  Widget _chip(
    String teks, {
    IconData? icon,
    bool chevron = false,
    Color warna = AppColors.tuneBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: warna,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
          ],
          Text(
            teks,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          if (chevron)
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }

  Widget _saklar(bool nilai, ValueChanged<bool> onChanged) {
    return Switch(
      value: nilai,
      onChanged: onChanged,
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.tombolNonaktif,
      ),
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }
}