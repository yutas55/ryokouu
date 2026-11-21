import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme/app_assets.dart';
import 'theme/app_colors.dart';
import 'widgets/common_widgets.dart';
import 'widgets/topbar.dart';

// =====================================================================
//  DATA BANTUAN  (ubah / tambah isi di bagian ini saja)
// =====================================================================

const String _noCs = '08123456789';

class _Artikel {
  final String judul;
  final String isi;
  final IconData icon;
  const _Artikel(
    this.judul,
    this.isi, {
    this.icon = Icons.help_outline_rounded,
  });
}

class _Topik {
  final String nama;
  final String deskripsi;
  final String satuan; // "Panduan", "Info", "Prosedur", "Solusi"
  final IconData icon;
  final Color bg;
  final Color warnaIcon;
  final bool pakaiLogo; // true -> tampilkan logo RYOKOU, bukan icon
  final List<_Artikel> artikel;

  const _Topik({
    required this.nama,
    required this.deskripsi,
    required this.satuan,
    required this.icon,
    required this.bg,
    required this.warnaIcon,
    required this.artikel,
    this.pakaiLogo = false,
  });
}

// Isi di bawah ini hanya contoh. Silakan diganti sesuai aturan RYOKOU.
const List<_Topik> _daftarTopik = [
  _Topik(
    nama: 'Penyewaan',
    deskripsi: 'Syarat KTP/SIM, durasi sewa & reservasi unit.',
    satuan: 'Panduan',
    icon: Icons.two_wheeler_rounded,
    bg: Color(0xFFC2E9F4),
    warnaIcon: AppColors.primary,
    artikel: [
      _Artikel(
        'Apa saja syarat menyewa motor?',
        'Kamu perlu KTP dan SIM C yang masih berlaku. Data diri juga harus '
            'dilengkapi di Form Data Diri sebelum memesan unit.',
        icon: Icons.badge_outlined,
      ),
      _Artikel(
        'Berapa durasi sewa minimal?',
        'Durasi sewa minimal adalah 1 hari. Perpanjangan bisa diajukan '
            'selama unit belum melewati batas waktu sewa.',
        icon: Icons.schedule_rounded,
      ),
      _Artikel(
        'Bagaimana cara memesan unit?',
        'Buka tab Produk, pilih motor yang berstatus Tersedia, lalu ikuti '
            'langkah pemesanan sampai pembayaran selesai.',
        icon: Icons.two_wheeler_rounded,
      ),
      _Artikel(
        'Apakah unit boleh dibawa keluar kota?',
        'Unit hanya boleh dipakai di dalam zona aman RYOKOU. Jika keluar '
            'dari batas wilayah, GPS akan mencatatnya dan kamu dikenakan '
            'denda keluar wilayah.',
        icon: Icons.satellite_alt_rounded,
      ),
      _Artikel(
        'Bisakah membatalkan pemesanan?',
        'Pemesanan bisa dibatalkan sebelum unit diambil. Hubungi Customer '
            'Service untuk proses pembatalannya.',
        icon: Icons.event_busy_outlined,
      ),
    ],
  ),
  _Topik(
    nama: 'Tentang RYOKOU',
    deskripsi: 'Profil pool garasi, legalitas & jam buka.',
    satuan: 'Info',
    icon: Icons.info_outline_rounded,
    bg: AppColors.primary,
    warnaIcon: Colors.white,
    pakaiLogo: true,
    artikel: [
      _Artikel(
        'Apa itu RYOKOU?',
        'RYOKOU adalah layanan rental motor yang memudahkan kamu memesan, '
            'memantau, dan mengembalikan unit lewat aplikasi.',
        icon: Icons.info_outline_rounded,
      ),
      _Artikel(
        'Di mana lokasi pool garasi?',
        'Alamat pool garasi dan titik pengambilan unit tertera pada struk '
            'pemesanan. Hubungi Customer Service jika butuh petunjuk arah.',
        icon: Icons.place_outlined,
      ),
      _Artikel(
        'Jam buka layanan',
        'Pengambilan dan pengembalian unit dilayani pada jam operasional '
            'pool. Jam lengkapnya bisa ditanyakan ke Customer Service.',
        icon: Icons.access_time_rounded,
      ),
    ],
  ),
  _Topik(
    nama: 'Pengembalian',
    deskripsi: 'Checklist bensin 3 bar, helm & jas hujan unit.',
    satuan: 'Prosedur',
    icon: Icons.task_alt_rounded,
    bg: Color(0xFFFBE8D6),
    warnaIcon: Color(0xFF5B3A1E),
    artikel: [
      _Artikel(
        'Apa yang dicek saat pengembalian?',
        'Tim RYOKOU memeriksa kondisi bodi dan spare part, bensin minimal '
            '3 bar, serta kelengkapan helm dan jas hujan.',
        icon: Icons.fact_check_outlined,
      ),
      _Artikel(
        'Apa itu denda keterlambatan?',
        'Jika unit tiba setelah waktu jatuh tempo, sistem mencatat denda '
            'keterlambatan sesuai lama keterlambatannya.',
        icon: Icons.timer_off_outlined,
      ),
      _Artikel(
        'Bagaimana jika ada kerusakan?',
        'Kerusakan yang ditemukan saat inspeksi dicatat sebagai denda '
            'kerusakan spare part, lengkap dengan foto bukti dari pegawai.',
        icon: Icons.build_outlined,
      ),
      _Artikel(
        'Di mana melihat dan membayar denda?',
        'Buka Profil lalu pilih Detail Denda. Di sana ada rincian dan bukti '
            'tiap denda, serta tombol Bayar Denda Sekarang.',
        icon: Icons.receipt_long_outlined,
      ),
    ],
  ),
  _Topik(
    nama: 'Pembayaran',
    deskripsi: 'QRIS, Transfer bank, & pengembalian uang.',
    satuan: 'Solusi',
    icon: Icons.account_balance_wallet_outlined,
    bg: Color(0xFFC2E9F4),
    warnaIcon: AppColors.primary,
    artikel: [
      _Artikel(
        'Pembayaran apa saja yang tersedia?',
        'Kamu bisa membayar lewat QRIS atau Transfer bank. Pilih metode '
            'yang kamu inginkan saat melakukan pembayaran.',
        icon: Icons.account_balance_wallet_outlined,
      ),
      _Artikel(
        'Bagaimana membayar dengan QRIS?',
        'Pilih QRIS, lalu pindai kode yang tampil memakai aplikasi '
            'pembayaran favoritmu dan selesaikan pembayaran.',
        icon: Icons.qr_code_2_rounded,
      ),
      _Artikel(
        'Kapan uang saya dikembalikan?',
        'Pengembalian uang diproses setelah pembatalan disetujui. Lama '
            'prosesnya tergantung metode pembayaran yang kamu pakai.',
        icon: Icons.currency_exchange_rounded,
      ),
      _Artikel(
        'Pembayaran saya gagal, apa yang harus dilakukan?',
        'Pastikan saldo dan koneksi internet cukup, lalu coba lagi. Jika '
            'saldo sudah terpotong, hubungi Customer Service.',
        icon: Icons.error_outline_rounded,
      ),
    ],
  ),
];

// =====================================================================
//  DAFTAR FAQ
//  kalo mau nambah cukup tambah satu blok _Artikel(...) di
//  dalam daftar di bawah. Kotak, ikon, panah, dan jawabannya otomatis.
// =====================================================================

/// Jumlah pertanyaan yang tampil di halaman utama Bantuan.
/// Sisanya muncul saat menekan tulisan "FAQ RYOKOU".
const int _jumlahFaqDiBeranda = 4;

const List<_Artikel> _daftarFaq = [
  _Artikel(
    'Pembayaran apa saja yang tersedia?',
    'Kamu bisa membayar lewat QRIS atau Transfer bank. Pilih metode '
        'yang kamu inginkan saat melakukan pembayaran.',
    icon: Icons.account_balance_wallet_outlined,
  ),
  _Artikel(
    'Apa saja syarat menyewa motor?',
    'Kamu perlu KTP dan SIM C yang masih berlaku. Data diri juga harus '
        'dilengkapi di Form Data Diri sebelum memesan unit.',
    icon: Icons.badge_outlined,
  ),
  _Artikel(
    'Apa itu denda keterlambatan?',
    'Jika unit tiba setelah waktu jatuh tempo, sistem mencatat denda '
        'keterlambatan sesuai lama keterlambatannya.',
    icon: Icons.timer_off_outlined,
  ),
  _Artikel(
    'Di mana melihat dan membayar denda?',
    'Buka Profil lalu pilih Detail Denda. Di sana ada rincian dan bukti '
        'tiap denda, serta tombol Bayar Denda Sekarang.',
    icon: Icons.receipt_long_outlined,
  ),
  _Artikel(
    'Bisakah saya memperpanjang masa sewa?',
    'Perpanjangan bisa diajukan selama unit belum melewati batas waktu '
        'sewa. Hubungi Customer Service untuk prosesnya.',
    icon: Icons.update_rounded,
  ),
];

// =====================================================================
//  HALAMAN BANTUAN
// =====================================================================

class BantuanScreen extends StatefulWidget {
  const BantuanScreen({super.key});

  @override
  State<BantuanScreen> createState() => _BantuanScreenState();
}

class _BantuanScreenState extends State<BantuanScreen> {
  final _cari = TextEditingController();
  int? _filterTopik; // index topik yang dipilih lewat icon filter

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  String get _q => _cari.text.trim().toLowerCase();

  /// Artikel yang cocok dengan kata kunci + filter topik.
  /// Artikel yang cocok dengan kata kunci + filter topik.
  List<_Artikel> get _hasil {
    final q = _q;

    bool cocok(_Artikel a, [String namaTopik = '']) =>
        q.isEmpty ||
        a.judul.toLowerCase().contains(q) ||
        a.isi.toLowerCase().contains(q) ||
        namaTopik.toLowerCase().contains(q);

    final sumber = _filterTopik == null
        ? _daftarTopik
        : [_daftarTopik[_filterTopik!]];

    final hasil = <_Artikel>[
      for (final t in sumber)
        for (final a in t.artikel)
          if (cocok(a, t.nama)) a,
    ];

    // FAQ ikut dicari (hanya kalau tidak sedang memfilter satu topik).
    if (_filterTopik == null) {
      for (final a in _daftarFaq) {
        if (cocok(a) && !hasil.any((h) => h.judul == a.judul)) hasil.add(a);
      }
    }
    return hasil;
  }

  void _bukaTopik(_Topik t) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ArtikelScreen(judul: t.nama, artikel: t.artikel),
      ),
    );
  }

  void _bukaSemuaFaq() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            _ArtikelScreen(judul: 'FAQ RYOKOU', artikel: _daftarFaq),
      ),
    );
  }

  void _pilihFilter() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        Widget chip(String label, int? nilai) {
          final aktif = _filterTopik == nilai;
          return Material(
            color: aktif ? AppColors.primary : AppColors.tuneBg,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                setState(() => _filterTopik = nilai);
                Navigator.pop(ctx);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: aktif ? Colors.white : AppColors.profilSubtext,
                  ),
                ),
              ),
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Filter Topik',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    chip('Semua', null),
                    for (var i = 0; i < _daftarTopik.length; i++)
                      chip(_daftarTopik[i].nama, i),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _salinNomorCs() async {
    await Clipboard.setData(const ClipboardData(text: _noCs));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nomor Customer Service disalin')),
    );
  }

  // ---------- Halaman ----------

  @override
  Widget build(BuildContext context) {
    final mencari = _q.isNotEmpty || _filterTopik != null;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: const RyokouTopBar(title: 'BANTUAN'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          const Align(alignment: Alignment.centerLeft, child: _TombolKembali()),
          const SizedBox(height: 16),
          _kotakCari(),
          if (_filterTopik != null) ...[
            const SizedBox(height: 12),
            _chipFilterAktif(),
          ],
          const SizedBox(height: 28),
          if (mencari) ..._bagianHasil() else ..._bagianUtama(),
          const SizedBox(height: 12),
          _kartuCs(),
        ],
      ),
    );
  }

  // ---------- Pencarian ----------

  Widget _kotakCari() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 6),
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
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 24, color: AppColors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _cari,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                fontSize: 14.5,
                color: AppColors.profilText,
              ),
              decoration: const InputDecoration(
                hintText: 'Cari topik bantuan, denda, klaim...',
                hintStyle: TextStyle(fontSize: 14.5, color: AppColors.hint),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
          if (_cari.text.isNotEmpty)
            IconButton(
              tooltip: 'Hapus',
              onPressed: () => setState(_cari.clear),
              icon: const Icon(
                Icons.close_rounded,
                size: 20,
                color: AppColors.grey,
              ),
            ),
          IconButton(
            tooltip: 'Filter topik',
            onPressed: _pilihFilter,
            icon: Icon(
              Icons.tune_rounded,
              size: 22,
              color: _filterTopik == null
                  ? AppColors.profilSubtext
                  : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipFilterAktif() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: const Color(0xFFC2E9F4),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _filterTopik = null),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Topik: ${_daftarTopik[_filterTopik!].nama}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Isi halaman ----------

  Widget _judulBagian(String teks, {Widget? kanan}) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            teks,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: AppColors.profilText,
            ),
          ),
        ),
        ?kanan,
      ],
    );
  }

  /// Tampilan awal: topik + pertanyaan populer.
  List<Widget> _bagianUtama() {
    return [
      _judulBagian('TOPIK BANTUAN'),
      const SizedBox(height: 16),
      for (var i = 0; i < _daftarTopik.length; i += 2) ...[
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _kartuTopik(_daftarTopik[i])),
              const SizedBox(width: 14),
              Expanded(
                child: i + 1 < _daftarTopik.length
                    ? _kartuTopik(_daftarTopik[i + 1])
                    : const SizedBox(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
      const SizedBox(height: 14),
      _judulBagian(
        'PERTANYAAN POPULER',
        kanan: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _bukaSemuaFaq,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Text(
              'FAQ RYOKOU',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.profilSubtext,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 14),
      for (final a in _daftarFaq.take(_jumlahFaqDiBeranda))
        _KartuTanya(key: ValueKey(a.judul), artikel: a),
    ];
  }

  /// Tampilan saat mencari atau memakai filter topik.
  List<Widget> _bagianHasil() {
    final hasil = _hasil;
    final judul = _q.isEmpty && _filterTopik != null
        ? _daftarTopik[_filterTopik!].nama.toUpperCase()
        : 'HASIL PENCARIAN';

    return [
      _judulBagian(
        judul,
        kanan: Text(
          '${hasil.length} hasil',
          style: const TextStyle(fontSize: 12.5, color: AppColors.grey),
        ),
      ),
      const SizedBox(height: 14),
      if (hasil.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 36),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 52, color: AppColors.border),
              SizedBox(height: 10),
              Text(
                'Topik tidak ditemukan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Coba kata kunci lain atau hubungi Customer Service.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.profilSubtext),
              ),
            ],
          ),
        )
      else
        for (final a in hasil) _KartuTanya(key: ValueKey(a.judul), artikel: a),
    ];
  }

  Widget _kartuTopik(_Topik t) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _bukaTopik(t),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: t.bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: t.pakaiLogo
                      ? const AssetImg(
                          AppAssets.logo,
                          width: 30,
                          height: 30,
                          fallbackIcon: Icons.info_outline_rounded,
                        )
                      : Icon(t.icon, size: 26, color: t.warnaIcon),
                ),
                const SizedBox(height: 14),
                Text(
                  t.nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.profilText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.deskripsi,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: AppColors.profilSubtext,
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${t.artikel.length} ${t.satuan}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kartuCs() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.support_agent_rounded,
                size: 30,
                color: AppColors.csIcon,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Masih butuh bantuan?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 13, height: 1.4, color: Colors.white),
              children: [
                TextSpan(
                  text:
                      'Jika mempunyai kendala, hubungi Customer Service pada ',
                ),
                TextSpan(
                  text: _noCs,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _salinNomorCs,
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Salin Nomor'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
//  HALAMAN DAFTAR ARTIKEL (dari kartu topik / "FAQ RYOKOU")
// =====================================================================

class _ArtikelScreen extends StatelessWidget {
  final String judul;
  final List<_Artikel> artikel;
  const _ArtikelScreen({required this.judul, required this.artikel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: RyokouTopBar(title: judul.toUpperCase()),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          const Align(alignment: Alignment.centerLeft, child: _TombolKembali()),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 14),
            child: Text(
              '${artikel.length} topik bantuan',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.profilSubtext,
              ),
            ),
          ),
          for (final a in artikel)
            _KartuTanya(key: ValueKey(a.judul), artikel: a),
        ],
      ),
    );
  }
}

// =====================================================================
//  KOMPONEN BERSAMA
// =====================================================================

class _TombolKembali extends StatelessWidget {
  const _TombolKembali();

  @override
  Widget build(BuildContext context) {
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
}

/// Kartu pertanyaan yang bisa dibuka/tutup untuk melihat jawabannya.
class _KartuTanya extends StatefulWidget {
  final _Artikel artikel;
  const _KartuTanya({super.key, required this.artikel});

  @override
  State<_KartuTanya> createState() => _KartuTanyaState();
}

class _KartuTanyaState extends State<_KartuTanya> {
  bool _buka = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.artikel;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
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
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _buka = !_buka),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(a.icon, size: 26, color: AppColors.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          a.judul,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: AppColors.profilText,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _buka ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 26,
                          color: AppColors.profilSubtext,
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: _buka
                        ? Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                              left: 42,
                              right: 8,
                            ),
                            child: Text(
                              a.isi,
                              style: const TextStyle(
                                fontSize: 13.5,
                                height: 1.5,
                                color: AppColors.profilSubtext,
                              ),
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
