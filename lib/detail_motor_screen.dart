import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:ryokou/bahasa.dart';

import 'data/detail_motor.dart';
import 'informasi_denda_screen.dart';
import 'models/motor.dart';
import 'theme/app_assets.dart';
import 'theme/app_colors.dart';
import 'widgets/banner_cs.dart' show noCs;
import 'widgets/common_widgets.dart';
import 'widgets/navbar.dart';

/// Buka halaman detail sebuah motor (dari Katalog Produk / Beranda / Profil).
/// [status] opsional: memaksa tampilan status tertentu (dipakai Profil).
void bukaDetailMotor(BuildContext context, Motor motor, {StatusMotor? status}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => DetailMotorScreen(motor: motor, status: status),
    ),
  );
}

enum _Tab { produk, pemesanan, penyewaan, info }

/// Halaman detail motor dengan 3 tab:
///  - Tersedia  : Detail Produk | Pemesanan | Info Penting
///  - Disewa    : Detail Produk | Detail Penyewaan | Info Penting
///  - Perbaikan : Detail Produk | Info Penting
/// Status mengikuti field `status` pada data motor.
class DetailMotorScreen extends StatefulWidget {
  final Motor motor;
  final StatusMotor? status;
  const DetailMotorScreen({super.key, required this.motor, this.status});

  @override
  State<DetailMotorScreen> createState() => _DetailMotorScreenState();
}

class _DetailMotorScreenState extends State<DetailMotorScreen> {
  // ---------- Warna khusus halaman ----------
  static const _teksAbu = Color(0xFF6B7280);
  static const _teksTab = Color(0xFF8E98A8);
  static const _garis = Color(0xFFE5E7EB);
  static const _ubinBg = Color(0xFFF8FAFC);
  static const _ubinGaris = Color(0xFFE8ECEF);
  static const _kuning = Color(0xFFFFFBEB);
  static const _kuningGaris = Color(0xFFFDE68A);
  static const _biruMuda = Color(0xFFC2E9F4);

  final _scroll = ScrollController();

  late final StatusMotor _status = widget.status ?? widget.motor.status;
  _Tab _tab = _Tab.produk;
  int _foto = 0;

  // ---- form Pemesanan ----
  DateTime? _tanggalAmbil;
  int _durasi = 1;
  TimeOfDay _jam = const TimeOfDay(hour: 10, minute: 0);
  String _lokasi = lokasiPopuler.first.$2;
  bool _lokasiTerkonfirmasi = false;
  bool _setuju = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // ---------- Data turunan ----------

  Motor get _m => widget.motor;

  InfoSewaMotor get _info => infoUntuk(_m);

  List<_Tab> get _tabs => switch (_status) {
    StatusMotor.tersedia => [_Tab.produk, _Tab.pemesanan, _Tab.info],
    StatusMotor.disewa => [_Tab.produk, _Tab.penyewaan, _Tab.info],
    StatusMotor.perbaikan => [_Tab.produk, _Tab.info],
  };

  String _labelTab(_Tab t) => switch (t) {
    _Tab.produk => 'Detail Produk',
    _Tab.pemesanan => 'Pemesanan',
    _Tab.penyewaan => 'Detail Penyewaan',
    _Tab.info => 'Info Penting',
  };

  /// Warna aksen: tab aktif, tombol, dsb. (mengikuti status motor).
  Color get _aksen => switch (_status) {
    StatusMotor.tersedia => AppColors.primary,
    StatusMotor.disewa => AppColors.statusDisewa,
    StatusMotor.perbaikan => AppColors.statusPerbaikanTombol,
  };

  String get _namaLengkap => '${_m.merek.toUpperCase()} – ${_m.model}';

  List<FotoMotor> get _daftarFoto => _info.foto.isEmpty
      ? [FotoMotor('TAMPAK DEPAN', _m.image)]
      : _info.foto;

  DateTime get _estimasiSelesai =>
      _info.estimasiSelesai ?? hariIniDemo.add(const Duration(days: 2));

  DateTime get _siapLagi =>
      _info.siapDisewaLagi ?? _estimasiSelesai.add(const Duration(days: 1));

  DateTime _hanyaTgl(DateTime d) => DateTime(d.year, d.month, d.day);

  int get _sisaHari =>
      _hanyaTgl(_estimasiSelesai).difference(_hanyaTgl(hariIniDemo)).inDays;

  // ---------- Format ----------

  static const _bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String _dd(int n) => n.toString().padLeft(2, '0');

  /// "16 Okt 2024"
  String _tgl(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

  /// "16/10/2024" (atau "-" kalau kosong)
  String _tglAngka(DateTime? d) =>
      d == null ? '-' : '${_dd(d.day)}/${_dd(d.month)}/${d.year}';

  String get _jamTeks => '${_dd(_jam.hour)}:${_dd(_jam.minute)} WIB';

  // ---------- Aksi ----------

  void _pesan(String teks) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(teks)),
    );
  }

  void _pindahTab(_Tab t) {
    setState(() => _tab = t);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _gantiFoto(int arah) {
    final n = _daftarFoto.length;
    if (n < 2) return;
    setState(() => _foto = (_foto + arah + n) % n);
  }

  Future<void> _pilihTanggal() async {
    final sekarang = _hanyaTgl(DateTime.now());
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggalAmbil ?? sekarang,
      firstDate: sekarang,
      lastDate: sekarang.add(const Duration(days: 365)),
      helpText: tr('Pilih tanggal ambil'),
    );
    if (hasil != null && mounted) setState(() => _tanggalAmbil = hasil);
  }

  Future<void> _pilihJam() async {
    final hasil = await showTimePicker(context: context, initialTime: _jam);
    if (hasil != null && mounted) setState(() => _jam = hasil);
  }

  void _pilihLokasi(String lokasi) {
    setState(() {
      _lokasi = lokasi;
      _lokasiTerkonfirmasi = false;
    });
  }

  void _bukaDaftarLokasi() {
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
                'Pilih Lokasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              for (final l in lokasiPopuler)
                ListTile(
                  selected: _lokasi == l.$2,
                  selectedTileColor: AppColors.cardSoft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.place_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    l.$2,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.profilText,
                    ),
                  ),
                  trailing: _lokasi == l.$2
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () {
                    _pilihLokasi(l.$2);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _togglePengingat() {
    final id = _m.platNo;
    final aktif = pengingatKetersediaan.contains(id);
    setState(() {
      if (aktif) {
        pengingatKetersediaan.remove(id);
      } else {
        pengingatKetersediaan.add(id);
      }
    });
    _pesan(
      aktif
          ? 'Pengingat ketersediaan dimatikan'
          : 'Pengingat ketersediaan diaktifkan',
    );
  }

  Future<void> _salinNomorCs() async {
    await Clipboard.setData(const ClipboardData(text: noCs));
    if (!mounted) return;
    _pesan('Nomor CS disalin');
  }

  void _lanjutBayar() {
    if (_tanggalAmbil == null) {
      _pesan('Isi tanggal ambil terlebih dahulu');
      return;
    }
    if (!_lokasiTerkonfirmasi) {
      _pesan('Konfirmasi lokasi pertemuan terlebih dahulu');
      return;
    }
    if (!_setuju) {
      _pesan('Centang pernyataan terlebih dahulu');
      return;
    }
    _tampilRingkasan();
  }

  void _tampilRingkasan() {
    final total = _m.hargaSewaPerHari * _durasi;

    Widget baris(String label, String nilai) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13.5, color: _teksAbu),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              nilai,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.profilText,
              ),
            ),
          ),
        ],
      ),
    );

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
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
              const Text(
                'Ringkasan Pemesanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              baris('Motor', _m.nama),
              baris('Tanggal Ambil', _tgl(_tanggalAmbil!)),
              baris('Jam Pengambilan', _jamTeks),
              baris('Durasi Sewa', '$_durasi Hari'),
              baris('Lokasi Pertemuan', _lokasi),
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
                        'TOTAL SEWA',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 0.5,
                          color: Color(0xFF9CC9D6),
                        ),
                      ),
                    ),
                    Text(
                      formatRupiah(total),
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
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _pesan('Halaman pembayaran belum tersedia');
                  },
                  child: const Text(
                    'Lanjutkan Pembayaran',
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

  // ---------- Halaman ----------

  @override
  Widget build(BuildContext context) {
    final bawah = _barBawah();

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: _barAtas(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _tab == _Tab.produk
                        ? _headerProduk()
                        : _headerRingkas(),
                  ),
                  const SizedBox(height: 16),
                  _barTab(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: _konten(),
                  ),
                ],
              ),
            ),
          ),
          ?bawah,
        ],
      ),
    );
  }

  PreferredSizeWidget _barAtas() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      leadingWidth: 68,
      titleSpacing: 0,
      shape: const Border(
        bottom: BorderSide(color: AppColors.border, width: 0.5),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: Material(
            color: AppColors.tuneBg,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).maybePop(),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 22,
                  color: AppColors.profilText,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          const AssetImg(
            AppAssets.logo,
            width: 34,
            height: 34,
            fallbackIcon: Icons.circle,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _status == StatusMotor.disewa
                  ? 'DETAIL PENYEWAAN'
                  : 'DETAIL PRODUK',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => Navigator.of(
              context,
            ).pushReplacementNamed(NavTab.profil.route),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Header ----------

  /// Header besar (tab Detail Produk): galeri + nama + tarif.
  Widget _headerProduk() {
    final foto = _daftarFoto[_foto % _daftarFoto.length];
    final banyak = _daftarFoto.length > 1;
    final label = _info.label;

    Widget panah(IconData icon, int arah) => Opacity(
      opacity: banyak ? 1 : 0.4,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 3,
        shadowColor: Colors.black26,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: banyak ? () => _gantiFoto(arah) : null,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 24, color: AppColors.profilText),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- galeri ----
        Container(
          height: 330,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _garis),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Text(
                    foto.label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Center(child: AssetImg(foto.path, height: 250)),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(child: panah(Icons.chevron_left_rounded, -1)),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(child: panah(Icons.chevron_right_rounded, 1)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ---- nama + label ----
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                _namaLengkap,
                style: const TextStyle(
                  fontSize: 24,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textTitle,
                ),
              ),
            ),
            if (label != null) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _garis),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.schedule_rounded, size: 17, color: _teksTab),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Terakhir Kali Di Rental: ${_tglAngka(_info.terakhirDisewa)}',
                style: const TextStyle(fontSize: 14, color: _teksAbu),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ---- tarif ----
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _ubinBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _ubinGaris),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TARIF SEWA',
                style: TextStyle(
                  fontSize: 13,
                  letterSpacing: 0.8,
                  color: _teksAbu,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    formatRupiah(_m.hargaSewaPerHari),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '/ hari',
                    style: TextStyle(fontSize: 16, color: _teksAbu),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Header ringkas (tab lain): foto kecil + nama + tarif.
  Widget _headerRingkas() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ubinBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _ubinGaris),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 110,
            height: 110,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: AssetImg(_m.image, width: 94, height: 94),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _namaLengkap,
                  style: const TextStyle(
                    fontSize: 19,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textTitle,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Terakhir Kali Di Rental',
                  style: TextStyle(fontSize: 13.5, color: _teksTab),
                ),
                Text(
                  _tglAngka(_info.terakhirDisewa),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTitle,
                  ),
                ),
                const SizedBox(height: 10),
                const _GarisPutus(),
                const SizedBox(height: 10),
                const Text(
                  'Tarif Sewa',
                  style: TextStyle(fontSize: 13.5, color: _teksAbu),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formatRupiah(_m.hargaSewaPerHari),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '/hari',
                      style: TextStyle(fontSize: 14, color: _teksAbu),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Tab ----------

  Widget _barTab() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _garis)),
      ),
      child: Row(
        children: [
          for (final t in _tabs)
            Expanded(
              child: InkWell(
                onTap: () => _pindahTab(t),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _tab == t ? _aksen : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _labelTab(t),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _tab == t
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _tab == t ? _aksen : _teksTab,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _konten() => switch (_tab) {
    _Tab.produk => _kontenProduk(),
    _Tab.pemesanan => _kontenPemesanan(),
    _Tab.penyewaan => _kontenPenyewaan(),
    _Tab.info => _kontenInfo(),
  };

  // ---------- Komponen umum ----------

  Widget _kartuPutih({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    double radius = 24,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _garis),
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

  /// Judul bagian dengan garis tebal di kiri.
  Widget _judulBagian(String teks) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 24,
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
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: AppColors.profilText,
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Tab: Detail Produk ----------

  Widget _kontenProduk() {
    final (bgStatus, teksStatus, garisStatus) = switch (_status) {
      StatusMotor.tersedia => (
        const Color(0xFFE3F8EF),
        AppColors.statusTersedia,
        const Color(0xFFB7EBD0),
      ),
      StatusMotor.disewa => (
        const Color(0xFFFFE4E1),
        AppColors.statusDisewa,
        const Color(0xFFFFCBC6),
      ),
      StatusMotor.perbaikan => (
        const Color(0xFFFEF3DC),
        AppColors.statusPerbaikanTombol,
        const Color(0xFFFCE2A9),
      ),
    };

    final catatan = switch (_status) {
      StatusMotor.tersedia =>
        'Unit ini siap disewa. Lanjutkan ke Pemesanan untuk memilih '
            'tanggal, durasi, dan lokasi pertemuan.',
      StatusMotor.disewa =>
        'Unit ini sedang dalam masa sewa aktif oleh pelanggan lain. '
            'Anda dapat melihat berakhirnya masa sewa atau mendapatkan '
            'notifikasi saat motor sudah siap disewa kembali',
      StatusMotor.perbaikan =>
        'Unit ini sedang dalam perbaikan dan belum bisa disewa. '
            'Silakan pilih unit lain di katalog produk.',
    };

    Widget ubin(
      String label,
      String nilai, {
      Color bg = _ubinBg,
      Color garis = _ubinGaris,
      Color? warnaLabel,
      Color warnaNilai = AppColors.textTitle,
    }) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: garis),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 0.4,
                fontWeight: FontWeight.w500,
                color: warnaLabel ?? _teksTab,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              nilai,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: warnaNilai,
              ),
            ),
          ],
        ),
      );
    }

    Widget dua(Widget a, Widget b) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: a),
          const SizedBox(width: 12),
          Expanded(child: b),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _kartuPutih(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _judulBagian('SPESIFIKASI MOTOR'),
              dua(ubin('MEREK', _m.merek), ubin('MODEL', _m.model)),
              dua(
                ubin('TAHUN PEMBUATAN', '${_m.tahun}'),
                ubin('KAPASITAS MESIN', '${_m.cc} CC'),
              ),
              dua(
                ubin('WARNA UNIT', _m.warna),
                ubin(
                  'STATUS UNIT',
                  _status.label,
                  bg: bgStatus,
                  garis: garisStatus,
                  warnaLabel: teksStatus,
                  warnaNilai: teksStatus,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            catatan,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.6,
              color: AppColors.profilSubtext,
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Tab: Detail Penyewaan (status Disewa) ----------

  Widget _kontenPenyewaan() {
    final sisa = _sisaHari;
    final lewat = sisa < 0;
    final waktu = sisa > 0
        ? '$sisa Hari lagi'
        : (sisa == 0 ? 'Hari ini' : 'Lewat ${-sisa} Hari');
    final aktif = pengingatKetersediaan.contains(_m.platNo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- status periode ----
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardSoft,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'STATUS PERIODE',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 0.6,
                        color: AppColors.profilSubtext,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDAD6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.statusDisewa,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lewat ? 'Melewati Batas' : 'Sedang Berjalan',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.statusDisewa,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.profilText,
                  ),
                  children: [
                    const TextSpan(text: 'Penyewaan Selesai Pada: '),
                    TextSpan(
                      text: waktu,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.statusDisewa,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _judulBagian('DETAIL MASA SEWA'),
              const SizedBox(height: 10),
              const Divider(height: 1, color: _garis),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Estimasi Selesai',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.profilSubtext,
                      ),
                    ),
                  ),
                  Text(
                    _tgl(_estimasiSelesai),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.profilText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ---- perkiraan siap disewa lagi ----
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.event_available_outlined,
                size: 30,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Perkiraan Siap Disewa lagi',
                      style: TextStyle(fontSize: 13.5, color: _teksAbu),
                    ),
                    Text(
                      _tglAngka(_siapLagi),
                      style: const TextStyle(
                        fontSize: 18,
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
        const SizedBox(height: 14),

        // ---- prosedur kesiapan ----
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardSoft,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: _biruMuda,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cleaning_services_outlined,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prosedur Kesiapan Motor',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.profilText,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Unit diperkirakan siap disewa kembali setelah '
                      'pengecekan kondisi motor, oleh pihak RYOKOU, jika '
                      'kondisi motor mengalami kerusakan kemungkinan bisa '
                      'saja lebih lama',
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.6,
                        color: AppColors.profilSubtext,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ---- pengingat ketersediaan ----
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE2F1F8),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.notifications_active_rounded,
                    size: 24,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ingin Menggunakan Motor Ini?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: AppColors.profilSubtext,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Dapatkan notifikasi instan saat unit ',
                    ),
                    TextSpan(text: _m.nama),
                    const TextSpan(
                      text: ' ini telah selesai diservis dan siap disewa.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Material(
                color: aktif ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _togglePengingat,
                  child: SizedBox(
                    height: 52,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          aktif
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_none_rounded,
                          size: 22,
                          color: aktif ? Colors.white : AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          aktif
                              ? 'Pengingat Ketersediaan Aktif'
                              : 'Aktifkan Pengingat Ketersediaan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: aktif ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- Tab: Pemesanan (status Tersedia) ----------

  Widget _labelWajib(String teks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            teks,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.profilText,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE11D48),
            ),
          ),
        ],
      ),
    );
  }

  /// Kolom isian yang bisa ditekan (tanggal / jam).
  Widget _kolomIsi({
    required IconData icon,
    required String teks,
    required bool kosong,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _ubinBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _garis),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  teks,
                  style: TextStyle(
                    fontSize: 16,
                    color: kosong ? _teksTab : AppColors.profilText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tombolStepper(IconData icon, bool aktif, VoidCallback onTap) {
    return Material(
      color: aktif ? AppColors.primary : AppColors.tuneBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: aktif ? onTap : null,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 20,
            color: aktif ? Colors.white : AppColors.grey,
          ),
        ),
      ),
    );
  }

  Widget _kepalaKartu(IconData icon, String judul, {Widget? kanan}) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7F4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 24, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                judul,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.profilText,
                ),
              ),
            ),
            ?kanan,
          ],
        ),
        const SizedBox(height: 14),
        const Divider(height: 1, color: _garis),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _kontenPemesanan() {
    final tglTeks = _tanggalAmbil == null
        ? 'DD/MM/YYYY'
        : _tglAngka(_tanggalAmbil);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- jadwal sewa ----
        _kartuPutih(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _kepalaKartu(Icons.calendar_month_outlined, 'Jadwal Sewa'),
              _labelWajib('Tanggal Ambil'),
              _kolomIsi(
                icon: Icons.calendar_month_outlined,
                teks: tglTeks,
                kosong: _tanggalAmbil == null,
                onTap: _pilihTanggal,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _ubinBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _garis),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Durasi Sewa',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.profilText,
                            ),
                          ),
                          Text(
                            'Dihitung per 24 jam',
                            style: TextStyle(fontSize: 13.5, color: _teksAbu),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _garis),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _tombolStepper(
                            Icons.remove_rounded,
                            _durasi > 1,
                            () => setState(() => _durasi--),
                          ),
                          SizedBox(
                            width: 70,
                            child: Text(
                              '$_durasi Hari',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          _tombolStepper(
                            Icons.add_rounded,
                            _durasi < 30,
                            () => setState(() => _durasi++),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _labelWajib('Jam Pengambilan'),
              _kolomIsi(
                icon: Icons.schedule_rounded,
                teks: _jamTeks,
                kosong: false,
                onTap: _pilihJam,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ---- lokasi pertemuan ----
        _kartuPutih(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _kepalaKartu(
                Icons.place_outlined,
                'Lokasi Pertemuan',
                kanan: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Antar Gratis',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                decoration: BoxDecoration(
                  color: _ubinBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _garis),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      size: 22,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _lokasi,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.profilText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: const Color(0xFFD4F5EA),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: _bukaDaftarLokasi,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: Text(
                            'Pilih Lokasi Di Peta',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Pilihan Lokasi Populer:',
                style: TextStyle(fontSize: 14.5, color: _teksAbu),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final l in lokasiPopuler)
                    Material(
                      color: _lokasi == l.$2
                          ? AppColors.primary
                          : AppColors.tuneBg,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _pilihLokasi(l.$2),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Text(
                            l.$1,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: _lokasi == l.$2
                                  ? Colors.white
                                  : AppColors.profilSubtext,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Material(
                color: _lokasiTerkonfirmasi
                    ? AppColors.statusTersedia
                    : const Color(0xFFE8EDEC),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(
                    () => _lokasiTerkonfirmasi = !_lokasiTerkonfirmasi,
                  ),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _lokasiTerkonfirmasi
                            ? AppColors.statusTersedia
                            : _garis,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: _lokasiTerkonfirmasi
                              ? Colors.white
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _lokasiTerkonfirmasi
                              ? 'Lokasi Dikonfirmasi'
                              : 'Konfirmasi Lokasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _lokasiTerkonfirmasi
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ---- perhatian ----
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _kuningGaris),
          ),
          child: const Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF5B2E0A),
              ),
              children: [
                TextSpan(
                  text: 'PERHATIAN',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(
                  text: ' PASTIKAN MENGISI FORM PEMESANAN TERSEBUT SESUAI '
                      'DENGAN ',
                ),
                TextSpan(
                  text: 'TANGGAL AMBIL',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'LOKASI',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: ', DAN '),
                TextSpan(
                  text: 'JAM PENGAMBILAN',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: ' YANG ANDA BISA. JIKA '),
                TextSpan(
                  text: 'PENYEWA',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(
                  text: ' TIDAK HADIR PADA WAKTU DAN TITIK TEMU YANG '
                      'DISEPAKATI, TRANSAKSI AKAN OTOMATIS ',
                ),
                TextSpan(
                  text: 'TERTUNDA',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE11D48),
                  ),
                ),
                TextSpan(text: '.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // ---- checkbox ----
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Checkbox(
                value: _setuju,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _setuju = v ?? false),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'SAYA TELAH MEMBACA KETENTUAN DIATAS DENGAN SEKSAMA',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: AppColors.profilText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------- Tab: Info Penting ----------

  Widget _kontenInfo() {
    const gaya = TextStyle(
      fontSize: 16,
      height: 1.6,
      color: AppColors.profilText,
    );
    const tebal = TextStyle(fontWeight: FontWeight.w800);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- sistem denda ----
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _kuning,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kuningGaris),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text.rich(
                TextSpan(
                  style: gaya,
                  children: [
                    TextSpan(
                      text: 'RYOKOU',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    TextSpan(text: ' MEMILIKI SISTEM '),
                    TextSpan(
                      text: 'DENDA',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFD91A45),
                      ),
                    ),
                    TextSpan(text: ', DENDA DIBAGI MENJADI 3 JENIS YAITU '),
                    TextSpan(text: 'DENDA KETERLAMBATAN', style: tebal),
                    TextSpan(text: ', '),
                    TextSpan(text: 'DENDA KELUAR BATAS WILAYAH', style: tebal),
                    TextSpan(text: ', dan '),
                    TextSpan(text: 'DENDA KERUSAKAN', style: tebal),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const InformasiDendaScreen(),
                      ),
                    ),
                    child: const Text(
                      'Selengkapnya',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                      ),
                    ),
                  ),
                  const Text(':', style: gaya),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ---- kontak CS ----
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF5FAFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD6EAF8)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F0FB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  size: 26,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: AppColors.profilText,
                        ),
                        children: [
                          TextSpan(text: 'Jika terkena '),
                          TextSpan(text: 'KENDALA', style: tebal),
                          TextSpan(
                            text: ' dalam pembayaran, ataupun sebagainya '
                                'bisa hubungi CS pada nomor',
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: _salinNomorCs,
                      child: const Text(
                        noCs,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- Tombol bawah ----------

  Widget? _barBawah() {
    String teks = '';
    Color warna = AppColors.primary;
    Color warnaTeks = Colors.white;
    VoidCallback? aksi;
    var panah = true;

    if (_tab == _Tab.produk) {
      if (_status == StatusMotor.tersedia) {
        teks = 'LANJUT KE PEMESANAN';
        aksi = () => _pindahTab(_Tab.pemesanan);
      } else if (_status == StatusMotor.disewa) {
        teks = 'LIHAT DETAIL PENYEWAAN';
        warna = AppColors.statusDisewa;
        aksi = () => _pindahTab(_Tab.penyewaan);
      } else {
        teks = 'SEDANG DIPERBAIKI';
        warna = AppColors.tombolNonaktif;
        warnaTeks = AppColors.tombolNonaktifText;
        panah = false;
      }
    } else if (_tab == _Tab.pemesanan) {
      teks = 'LANJUT KE PEMBAYARAN';
      aksi = _lanjutBayar;
    } else if (_tab == _Tab.penyewaan) {
      teks = 'KEMBALI KE KATALOG PRODUK';
      warna = AppColors.statusTersedia;
      aksi = () => Navigator.of(context).pushNamedAndRemoveUntil(
        NavTab.produk.route,
        (route) => false,
      );
    } else {
      return null; // tab Info Penting: tanpa tombol
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _garis)),
      ),
      child: SafeArea(
        top: false,
        child: Material(
          color: warna,
          elevation: aksi == null ? 0 : 4,
          shadowColor: warna.withAlpha(90),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: aksi,
            child: SizedBox(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        teks,
                        style: TextStyle(
                          fontSize: 16,
                          letterSpacing: 0.4,
                          fontWeight: FontWeight.w700,
                          color: warnaTeks,
                        ),
                      ),
                    ),
                  ),
                  if (panah) ...[
                    const SizedBox(width: 10),
                    Icon(Icons.arrow_forward_rounded, size: 22, color: warnaTeks),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Garis putus-putus tipis (pemisah di header ringkas).
class _GarisPutus extends StatelessWidget {
  const _GarisPutus();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final n = (c.maxWidth / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            n,
            (_) => const SizedBox(
              width: 4,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFD1D5DB)),
              ),
            ),
          ),
        );
      },
    );
  }
}