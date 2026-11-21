import 'package:flutter/material.dart' hide Text;
import 'package:flutter/widgets.dart' as w show Text;

// =====================================================================
//  BAHASA APLIKASI (Indonesia <-> English)
//
//  Cara kerja:
//  - Semua widget Text di aplikasi memakai Text milik file ini
//    (bukan Text bawaan Flutter). Saat bahasa = 'EN', teksnya
//    dicari di kamus `_en` di bawah lalu diganti ke bahasa Inggris.
//  - Teks yang belum ada di kamus tetap tampil apa adanya (Indonesia).
//  - Mau menambah teks baru? Tambah 1 baris di kamus `_en`:
//        'Teks Indonesia': 'English text',
// =====================================================================

/// Bahasa yang sedang aktif: 'ID' (Indonesia) atau 'EN' (English).
final ValueNotifier<String> bahasaAktif = ValueNotifier<String>('ID');

bool get _inggris => bahasaAktif.value == 'EN';

/// Terjemahkan teks. Dipakai otomatis oleh Text, dan bisa dipanggil
/// langsung untuk teks non-Text (hintText, tooltip, dll): tr('Teks').
String tr(String s) {
  if (!_inggris || s.isEmpty) return s;
  return _terjemah(s);
}

String _terjemah(String s) {
  // 1. Cocok persis dengan kamus.
  final langsung = _en[s];
  if (langsung != null) return langsung;

  // 2. Sama persis, kecuali spasi / baris baru di awal atau akhir.
  final t = s.trim();
  if (t.isEmpty) return s;
  if (t != s) {
    final i = s.indexOf(t);
    return s.substring(0, i) + _terjemah(t) + s.substring(i + t.length);
  }

  // 3. Kalimat berpola (ada angka / nama yang berubah-ubah).
  for (final p in _pola) {
    final m = p.re.firstMatch(s);
    if (m != null) return p.ubah(m);
  }

  // 4. Teks HURUF BESAR hasil toUpperCase() dari teks di kamus.
  if (s == s.toUpperCase()) {
    final v = _enHurufBesar[s];
    if (v != null) return v.toUpperCase();
  }

  // 5. Tanggal: "14 Okt 2024" -> "14 Oct 2024".
  return _bulan(s);
}

final RegExp _reTanggal = RegExp(
  r'\b(\d{1,2}) (Jan|Feb|Mar|Apr|Mei|Jun|Jul|Agu|Sep|Okt|Nov|Des) (\d{4})\b',
);
const Map<String, String> _bulanEn = {
  'Mei': 'May',
  'Agu': 'Aug',
  'Okt': 'Oct',
  'Des': 'Dec',
};

String _bulan(String s) => s.replaceAllMapped(
  _reTanggal,
  (m) => '${m[1]} ${_bulanEn[m[2]] ?? m[2]} ${m[3]}',
);

String _jml(String? n, String satu, String banyak) => n == '1' ? satu : banyak;

const Map<String, String> _satuan = {
  'Panduan': 'Guides',
  'Info': 'Info',
  'Prosedur': 'Procedures',
  'Solusi': 'Solutions',
};

class _Pola {
  final RegExp re;
  final String Function(RegExpMatch m) ubah;
  const _Pola(this.re, this.ubah);
}

final List<_Pola> _pola = [
  _Pola(RegExp(r'^Topik: (.+)$'), (m) => 'Topic: ${_terjemah(m[1]!)}'),
  _Pola(RegExp(r'^(\d+) hasil$'), (m) => '${m[1]} results'),
  _Pola(RegExp(r'^(\d+) topik bantuan$'), (m) => '${m[1]} help topics'),
  _Pola(
    RegExp(r'^(\d+) (Panduan|Info|Prosedur|Solusi)$'),
    (m) => '${m[1]} ${_satuan[m[2]]}',
  ),
  _Pola(
    RegExp(r'^Memiliki (\d+) Denda$'),
    (m) => 'Has ${m[1]} ${_jml(m[1], 'Fine', 'Fines')}',
  ),
  _Pola(
    RegExp(r'^(\d+) Jenis$'),
    (m) => '${m[1]} ${_jml(m[1], 'Type', 'Types')}',
  ),
  _Pola(
    RegExp(r'^ANDA MEMILIKI (\d+) JENIS DENDA PADA PENYEWAAN MOTOR$'),
    (m) => 'YOU HAVE ${m[1]} TYPES OF FINES FOR YOUR MOTORCYCLE RENTAL',
  ),
  _Pola(
    RegExp(r'^Terlambat (\d+) Jam$'),
    (m) => 'Late by ${m[1]} ${_jml(m[1], 'hour', 'hours')}',
  ),
  _Pola(
    RegExp(r'^Terlambat (\d+) Menit$'),
    (m) => 'Late by ${m[1]} ${_jml(m[1], 'minute', 'minutes')}',
  ),
  _Pola(RegExp(r'^Status: (.+)$'), (m) => 'Status: ${_terjemah(m[1]!)}'),
  _Pola(RegExp(r'^Kembali: (.+)$'), (m) => 'Returned: ${_terjemah(m[1]!)}'),
  _Pola(RegExp(r'^Koordinat: (.+)$'), (m) => 'Coordinates: ${m[1]}'),
  _Pola(RegExp(r'^(.+)/Jam$'), (m) => '${m[1]}/Hour'),
  _Pola(RegExp(r'^Denda (Rp .+)$'), (m) => 'Fine ${m[1]}'),
  _Pola(RegExp(r'^Tahun (\d+)$'), (m) => 'Year ${m[1]}'),
  _Pola(
    RegExp(r'^RYOKOU Rental Motor v(.+)$'),
    (m) => 'RYOKOU Motorcycle Rental v${m[1]}',
  ),
  _Pola(RegExp(r'^v(.+) \(Terbaru\)$'), (m) => 'v${m[1]} (Latest)'),
    _Pola(
    RegExp(r'^Terakhir Kali Di Rental: (.+)$'),
    (m) => 'Last Rented: ${_terjemah(m[1]!)}',
  ),
  _Pola(
    RegExp(r'^(\d+) Hari lagi$'),
    (m) => '${m[1]} ${_jml(m[1], 'day', 'days')} left',
  ),
  _Pola(
    RegExp(r'^Lewat (\d+) Hari$'),
    (m) => 'Overdue by ${m[1]} ${_jml(m[1], 'day', 'days')}',
  ),
  _Pola(
    RegExp(r'^(\d+) Hari$'),
    (m) => '${m[1]} ${_jml(m[1], 'Day', 'Days')}',
  ),
];

/// Versi HURUF BESAR dari kamus (untuk judul hasil toUpperCase()).
final Map<String, String> _enHurufBesar = {
  for (final e in _en.entries) e.key.toUpperCase(): e.value,
};

// =====================================================================
//  Text pengganti Text bawaan Flutter (otomatis menerjemahkan)
// =====================================================================

class Text extends StatelessWidget {
  const Text(
    String this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : textSpan = null;

  const Text.rich(
    InlineSpan this.textSpan, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : data = null;

  final String? data;
  final InlineSpan? textSpan;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      return w.Text(
        tr(data!),
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }
    return w.Text.rich(
      _terjemahSpan(textSpan!),
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}

InlineSpan _terjemahSpan(InlineSpan span) {
  if (span is TextSpan) {
    return TextSpan(
      text: span.text == null ? null : tr(span.text!),
      children: span.children?.map(_terjemahSpan).toList(),
      style: span.style,
      recognizer: span.recognizer,
      semanticsLabel: span.semanticsLabel,
    );
  }
  return span;
}

/// Memaksa seluruh layar membangun ulang, supaya semua teks langsung
/// memakai bahasa yang baru dipilih (dipanggil dari main.dart).
void bangunUlangSemua(BuildContext context) {
  void ulang(Element el) {
    el.markNeedsBuild();
    el.visitChildren(ulang);
  }

  (context as Element).visitChildren(ulang);
}

// =====================================================================
//  KAMUS  Indonesia -> English
//  Menambah terjemahan baru: tambah 1 baris  'Indonesia': 'English',
// =====================================================================

const Map<String, String> _en = {
  'KATALOG PRODUK': 'PRODUCT CATALOG',
  'Belum ada motor dengan status ini': 'No motorcycles with this status',
  'BERANDA': 'HOME',
  'Sewa Motor Harian Hemat\ndan Cepat': 'Affordable & Fast\nDaily Motorcycle Rental',
  'Daerah Malang\ndan Batu': 'Malang and\nBatu Area',
  'Rekomendasi Motor': 'Recommended Motorcycles',
  'Lihat Semua >': 'See All >',
  'SEWA SEKARANG': 'RENT NOW',
  'LIHAT DETAIL SEWA': 'VIEW RENTAL DETAILS',
  'SEDANG DIPERBAIKI': 'UNDER MAINTENANCE',
  'Motor Yang Tersedia': 'Available Motorcycles',
  'Motor Sedang Disewa': 'Motorcycles Being Rented',
  'Motor Sedang Diperbaiki': 'Motorcycles Under Maintenance',
  'Tersedia': 'Available',
  'Disewa': 'Rented',
  'Perbaikan': 'Maintenance',
  'Hitam': 'Black',
  'Putih': 'White',
  'Merah': 'Red',
  'Biru': 'Blue',
  'Cokelat': 'Brown',
  'Beranda': 'Home',
  'Produk': 'Products',
  'Profil': 'Profile',
  'Tarif Sewa': 'Rental Rate',
  'Denda Keterlambatan': 'Late Return Fine',
  'Denda Kerusakan': 'Damage Fine',
  'Denda Keluar Wilayah': 'Out-of-Area Fine',
  'FORM DATA DIRI': 'PERSONAL DATA FORM',
  'Form Data Diri': 'Personal Data Form',
  'Lengkapi data diri Anda untuk mempercepat proses sewa motor di RYOKOU.': 'Complete your personal details to speed up the motorcycle rental process at RYOKOU.',
  'Nama Lengkap': 'Full Name',
  'wajib diisi': 'required',
  'cth. Rian Pratama': 'e.g. Rian Pratama',
  'Ubah nama': 'Edit name',
  'Nama wajib diisi': 'Name is required',
  'Alamat Email': 'Email Address',
  'cth. rian.pratama@email.com': 'e.g. rian.pratama@email.com',
  'Ubah email': 'Edit email',
  'Email wajib diisi': 'Email is required',
  'Format email tidak valid': 'Invalid email format',
  'Nomor Telepon': 'Phone Number',
  'Ubah nomor telepon': 'Edit phone number',
  'Nomor telepon wajib diisi': 'Phone number is required',
  'Tulis tanpa angka 0 di depan': 'Write it without a leading 0',
  'Nomor telepon tidak valid': 'Invalid phone number',
  'Kata Sandi': 'Password',
  'Minimal 8 karakter': 'At least 8 characters',
  'Ubah kata sandi': 'Edit password',
  'Simpan & Lanjutkan': 'Save & Continue',
  'Aman & Terenkripsi': 'Secure & Encrypted',
  'Saya menyatakan bahwa data yang diisi sudah benar dan menyetujui ': 'I declare that the data provided is correct and agree to the ',
  'Syarat & Ketentuan': 'Terms & Conditions',
  ' serta Kebijakan Privasi RYOKOU.': ' and the RYOKOU Privacy Policy.',
  'Selesai': 'Done',
  'Centang pernyataan terlebih dahulu': 'Please tick the statement first',
  'Data diri berhasil disimpan': 'Personal data saved successfully',
  'DENDA\nKERUSAKAN': 'FINE FOR\nDAMAGE',
  'Pembayaran - Denda': 'Payment - Fine',
  'Kerusakan Spare Part': 'Spare Part Damage',
  'Klaim: spion kanan retak & baret pada body': 'Claim: cracked right mirror & scratches on the body',
  'Lunas (TRANSFER)': 'Paid (TRANSFER)',
  'Lihat Detail Denda': 'View Fine Details',
  'Lunas': 'Paid',
  'Metode Pembayaran': 'Payment Method',
  'Spion Kanan Patah & Retak': 'Broken & Cracked Right Mirror',
  'Baret & Lecet Pada Body': 'Scratches & Scuffs on the Body',
  'RENTAL\nMOTOR': 'MOTORCYCLE\nRENTAL',
  'Penyewaan - Honda Beat Street': 'Rental - Honda Beat Street',
  'Plat N 4821 EC • Durasi: 1 Hari': 'Plate N 4821 EC • Duration: 1 Day',
  'Sewa Selesai': 'Rental Completed',
  'Lihat Detail Struk': 'View Receipt Details',
  'Plat Nomor': 'Plate Number',
  'Durasi': 'Duration',
  '1 Hari': '1 Day',
  'Sewa Honda Beat Street (1 Hari)': 'Honda Beat Street Rental (1 Day)',
  'Pilih rentang tanggal': 'Select date range',
  'Terapkan': 'Apply',
  'Detail Denda': 'Fine Details',
  'Detail Struk': 'Receipt Details',
  'Tanggal': 'Date',
  'Rincian Denda': 'Fine Breakdown',
  'Rincian Biaya': 'Cost Breakdown',
  'Tutup': 'Close',
  'RIWAYAT': 'HISTORY',
  'Semua Transaksi': 'All Transactions',
  'Penyewaan Motor': 'Motorcycle Rentals',
  'Pembayaran Denda': 'Fine Payments',
  'Filter Tanggal': 'Date Filter',
  'Bulan Ini': 'This Month',
  'Semua Waktu': 'All Time',
  'Belum ada transaksi': 'No transactions yet',
  'Coba ubah filter jenis atau tanggal.': 'Try changing the type or date filter.',
  'Riwayat Pemesanan, dll': 'Booking history, etc.',
  'Riwayat': 'History',
  'Penyewaan': 'Rental',
  'Syarat KTP/SIM, durasi sewa & reservasi unit.': 'ID/driving licence requirements, rental duration & unit reservation.',
  'Apa saja syarat menyewa motor?': 'What are the requirements to rent a motorcycle?',
  'Kamu perlu KTP dan SIM C yang masih berlaku. Data diri juga harus dilengkapi di Form Data Diri sebelum memesan unit.': 'You need a valid ID card (KTP) and a valid Class C driving licence (SIM C). Your personal details must also be completed in the Personal Data Form before booking a unit.',
  'Berapa durasi sewa minimal?': 'What is the minimum rental duration?',
  'Durasi sewa minimal adalah 1 hari. Perpanjangan bisa diajukan selama unit belum melewati batas waktu sewa.': 'The minimum rental duration is 1 day. Extensions can be requested as long as the unit has not passed its rental deadline.',
  'Bagaimana cara memesan unit?': 'How do I book a unit?',
  'Buka tab Produk, pilih motor yang berstatus Tersedia, lalu ikuti langkah pemesanan sampai pembayaran selesai.': 'Open the Products tab, choose a motorcycle with the Available status, then follow the booking steps until the payment is complete.',
  'Apakah unit boleh dibawa keluar kota?': 'Can the unit be taken out of town?',
  'Unit hanya boleh dipakai di dalam zona aman RYOKOU. Jika keluar dari batas wilayah, GPS akan mencatatnya dan kamu dikenakan denda keluar wilayah.': 'The unit may only be used within the RYOKOU safe zone. If you leave the area limit, the GPS will record it and you will be charged an out-of-area fine.',
  'Bisakah membatalkan pemesanan?': 'Can I cancel my booking?',
  'Pemesanan bisa dibatalkan sebelum unit diambil. Hubungi Customer Service untuk proses pembatalannya.': 'Bookings can be cancelled before the unit is picked up. Contact Customer Service for the cancellation process.',
  'Tentang RYOKOU': 'About RYOKOU',
  'Profil pool garasi, legalitas & jam buka.': 'Garage pool profile, legality & opening hours.',
  'Apa itu RYOKOU?': 'What is RYOKOU?',
  'RYOKOU adalah layanan rental motor yang memudahkan kamu memesan, memantau, dan mengembalikan unit lewat aplikasi.': 'RYOKOU is a motorcycle rental service that makes it easy for you to book, monitor, and return units through the app.',
  'Di mana lokasi pool garasi?': 'Where is the garage pool located?',
  'Alamat pool garasi dan titik pengambilan unit tertera pada struk pemesanan. Hubungi Customer Service jika butuh petunjuk arah.': 'The garage pool address and unit pick-up point are printed on your booking receipt. Contact Customer Service if you need directions.',
  'Jam buka layanan': 'Service opening hours',
  'Pengambilan dan pengembalian unit dilayani pada jam operasional pool. Jam lengkapnya bisa ditanyakan ke Customer Service.': 'Unit pick-up and return are served during the pool\'s operating hours. Ask Customer Service for the full schedule.',
  'Pengembalian': 'Return',
  'Checklist bensin 3 bar, helm & jas hujan unit.': 'Checklist: 3 bars of fuel, helmet & raincoat.',
  'Apa yang dicek saat pengembalian?': 'What is checked during return?',
  'Tim RYOKOU memeriksa kondisi bodi dan spare part, bensin minimal 3 bar, serta kelengkapan helm dan jas hujan.': 'The RYOKOU team checks the condition of the body and spare parts, at least 3 bars of fuel, and the completeness of the helmet and raincoat.',
  'Apa itu denda keterlambatan?': 'What is a late return fine?',
  'Jika unit tiba setelah waktu jatuh tempo, sistem mencatat denda keterlambatan sesuai lama keterlambatannya.': 'If the unit arrives after the due time, the system records a late return fine based on how late it is.',
  'Bagaimana jika ada kerusakan?': 'What if there is damage?',
  'Kerusakan yang ditemukan saat inspeksi dicatat sebagai denda kerusakan spare part, lengkap dengan foto bukti dari pegawai.': 'Damage found during inspection is recorded as a spare part damage fine, complete with photo evidence from staff.',
  'Di mana melihat dan membayar denda?': 'Where can I view and pay fines?',
  'Buka Profil lalu pilih Detail Denda. Di sana ada rincian dan bukti tiap denda, serta tombol Bayar Denda Sekarang.': 'Open Profile and choose Fine Details. There you will find the breakdown and evidence of each fine, as well as the Pay Fine Now button.',
  'Pembayaran': 'Payment',
  'QRIS, Transfer bank, & pengembalian uang.': 'QRIS, bank transfer, & refunds.',
  'Pembayaran apa saja yang tersedia?': 'What payment methods are available?',
  'Kamu bisa membayar lewat QRIS atau Transfer bank. Pilih metode yang kamu inginkan saat melakukan pembayaran.': 'You can pay via QRIS or bank transfer. Choose the method you prefer when making the payment.',
  'Bagaimana membayar dengan QRIS?': 'How do I pay with QRIS?',
  'Pilih QRIS, lalu pindai kode yang tampil memakai aplikasi pembayaran favoritmu dan selesaikan pembayaran.': 'Choose QRIS, then scan the code shown using your favourite payment app and complete the payment.',
  'Kapan uang saya dikembalikan?': 'When will my money be refunded?',
  'Pengembalian uang diproses setelah pembatalan disetujui. Lama prosesnya tergantung metode pembayaran yang kamu pakai.': 'Refunds are processed after the cancellation is approved. How long it takes depends on the payment method you used.',
  'Pembayaran saya gagal, apa yang harus dilakukan?': 'My payment failed, what should I do?',
  'Pastikan saldo dan koneksi internet cukup, lalu coba lagi. Jika saldo sudah terpotong, hubungi Customer Service.': 'Make sure your balance and internet connection are sufficient, then try again. If your balance has already been deducted, contact Customer Service.',
  'Filter Topik': 'Filter Topics',
  'Semua': 'All',
  'Nomor Customer Service disalin': 'Customer Service number copied',
  'BANTUAN': 'HELP',
  'Cari topik bantuan, denda, klaim...': 'Search help topics, fines, claims...',
  'Hapus': 'Clear',
  'Filter topik': 'Filter topics',
  'TOPIK BANTUAN': 'HELP TOPICS',
  'PERTANYAAN POPULER': 'POPULAR QUESTIONS',
  'HASIL PENCARIAN': 'SEARCH RESULTS',
  'Topik tidak ditemukan': 'Topic not found',
  'Coba kata kunci lain atau hubungi Customer Service.': 'Try another keyword or contact Customer Service.',
  'Masih butuh bantuan?': 'Still need help?',
  'Jika mempunyai kendala, hubungi Customer Service pada ': 'If you have a problem, contact Customer Service at ',
  'Salin Nomor': 'Copy Number',
  'PROFIL': 'PROFILE',
  'Setting & Bantuan': 'Settings & Help',
  'Setting': 'Settings',
  'Setting Tema Aplikasi, dll': 'App theme settings, etc.',
  'Bantuan': 'Help',
  'Beri laporan, atau lainnya': 'Send a report, or others',
  'Riwayat & Denda': 'History & Fines',
  'Terverifikasi': 'Verified',
  'STATUS SEWA': 'RENTAL STATUS',
  'Sedang Menyewa\n': 'Currently Renting\n',
  'Belum Menyewa\nMotor': 'Not Renting\na Motorcycle',
  'Anda Memiliki\nDenda': 'You Have\na Fine',
  'Lihat Detail\nPenyewaan': 'View Rental\nDetails',
  'Halaman detail penyewaan belum tersedia': 'Rental details page is not available yet',
  'Sewa\nSekarang!': 'Rent\nNow!',
  'Informasi Denda': 'Fine Information',
  'Pelajari tentang denda pada Rental RYOKOU': 'Learn about fines at RYOKOU Rental',
  'Tidak Memiliki': 'None',
  'Keluar Akun': 'Log Out',
  'Keluar akun?': 'Log out?',
  'Kamu akan keluar dari akun ini.': 'You will be logged out of this account.',
  'Batal': 'Cancel',
  'Keluar': 'Log Out',
  'Kec. Gempol, Pasuruan (Jawa Timur)': 'Gempol District, Pasuruan (East Java)',
  'Pembayaran denda belum tersedia': 'Fine payment is not available yet',
  'INFORMASI DENDA': 'FINE INFORMATION',
  'ANDA MEMILIKI DENDA KARENA TELAH MERUSAKAN SPARE PART MOTOR': 'YOU HAVE A FINE FOR DAMAGING MOTORCYCLE SPARE PARTS',
  'ANDA MEMILIKI DENDA KARENA KELUAR BATAS WILAYAH SEWA': 'YOU HAVE A FINE FOR LEAVING THE RENTAL AREA',
  'ANDA MEMILIKI DENDA KARENA TERLAMBAT MENGEMBALIKAN MOTOR': 'YOU HAVE A FINE FOR RETURNING THE MOTORCYCLE LATE',
  'Kompensasi tercatat otomatis saat inspeksi tim operasional pada pengembalian unit sewa.': 'Compensation is recorded automatically during the operations team inspection when the rental unit is returned.',
  'Denda tercatat otomatis oleh sistem RYOKOU pada saat penyewaan dan pengembalian unit.': 'Fines are recorded automatically by the RYOKOU system during rental and unit return.',
  'PERLU TINDAKAN SEGERA': 'ACTION REQUIRED',
  'Status: Belum Lunas': 'Status: Unpaid',
  'MOTOR RENTAL': 'RENTAL MOTORCYCLE',
  'MOTOR TERAKHIR DIGUNAKAN': 'LAST USED MOTORCYCLE',
  'TOTAL KESELURUHAN': 'GRAND TOTAL',
  'Keluar Batas Wilayah': 'Out of Area Limit',
  'Keterlambatan Pengembalian': 'Late Return',
  'Detail Kerusakan Spare Part': 'Spare Part Damage Details',
  'Bukti Pengecekan Fisik': 'Physical Inspection Evidence',
  'Terverifikasi Pegawai': 'Verified by Staff',
  'Dokumentasi berupa foto saat tim Ryokou melakukan pengecekan pengembalian unit.': 'Documentation in the form of photos taken when the Ryokou team inspected the returned unit.',
  'TOTAL DENDA KERUSAKAN SPARE PART': 'TOTAL SPARE PART DAMAGE FINE',
  'Detail Keluar Wilayah': 'Out-of-Area Details',
  'Log pergerakan titik koordinat GPS yang tercatat keluar dari geofence zona legal RYOKOU.': 'GPS coordinate movement log recorded leaving the RYOKOU legal zone geofence.',
  'Lokasi Terdeteksi Melanggar': 'Violating Location Detected',
  'dari batas aman': 'from the safe limit',
  'TOTAL DENDA KELUAR WILAYAH': 'TOTAL OUT-OF-AREA FINE',
  'Zona Aman RYOKOU': 'RYOKOU Safe Zone',
  'Batas Wilayah Terlewati': 'Area Limit Exceeded',
  'Detail Keterlambatan': 'Late Return Details',
  'WAKTU JATUH TEMPO': 'DUE TIME',
  'WAKTU KEDATANGAN AKTUAL': 'ACTUAL ARRIVAL TIME',
  'TOTAL DENDA KETERLAMBATAN PENGEMBALIAN': 'TOTAL LATE RETURN FINE',
  'Kamu tidak memiliki denda': 'You don\'t have any fines',
  'Semua penyewaan kamu aman. Terima kasih!': 'All your rentals are in good standing. Thank you!',
  'KAMI MEMINTA KEPADA ANDA AGAR CEPAT MELUNASI DENDA UNTUK KEPENTINGAN BERSAMA': 'WE ASK YOU TO SETTLE YOUR FINES PROMPTLY FOR OUR MUTUAL BENEFIT',
  'KAMI MEMINTA ANDA UNTUK TIDAK MELANGGAR BEBERAPA ATURAN SAAT SEDANG MENYEWA MOTOR DARI RYOKOU AGAR TIDAK MENDAPATKAN DENDA': 'WE ASK YOU NOT TO BREAK ANY RULES WHILE RENTING A MOTORCYCLE FROM RYOKOU SO THAT YOU DO NOT GET FINED',
  'Tidak membayar DENDA dapat menonaktifkan akun sewa sementara serta membatasi hak pemesanan unit RYOKOU di kemudian hari, ataupun penahanan terhadap jaminan yang diberikan.': 'Not paying FINES may temporarily deactivate your rental account, restrict your right to book RYOKOU units in the future, or result in the withholding of the deposit you provided.',
  'jika anda terkena DENDA maka akan ada pembatasan hak pemesanan unit RYOKOU di kemudian hari, ataupun penahanan terhadap jaminan yang diberikan.': 'If you are fined, your right to book RYOKOU units may be restricted in the future, or the deposit you provided may be withheld.',
  'PELAJARI TENTANG DENDA PADA RYOKOU': 'LEARN ABOUT FINES AT RYOKOU',
  'BAYAR DENDA SEKARANG': 'PAY FINE NOW',
  'PANDUAN PENTING': 'IMPORTANT GUIDE',
  'Syarat & Ketentuan Denda Rental Motor RYOKOU': 'RYOKOU Motorcycle Rental Fine Terms & Conditions',
  'Harap baca dengan seksama agar perjalanan Anda tetap nyaman, aman, dan bebas dari kendala biaya tak terduga.': 'Please read carefully so your trip stays comfortable, safe, and free from unexpected costs.',
  'Tergantung Model Yang Digunakan': 'Depends on the Model Used',
  'Kerusakan Fisik & Komponen': 'Physical Damage & Components',
  'Tergantung seberapa rusaknya, dan spare partnya': 'Depends on how severe the damage is, and on the spare part',
  'Lecet / Goresan Ringan': 'Minor Scuffs / Scratches',
  'Pecah Body / Rusak Sedang': 'Cracked Body / Moderate Damage',
  'Part Resmi Honda + Pasang': 'Official Honda Part + Installation',
  'Ban Bocor / Kena Paku': 'Flat Tire / Nail Puncture',
  'Ditanggung Penyewa': 'Borne by the Renter',
  'Batas Area Operasional': 'Operational Area Limit',
  'Hanya diperbolehkan digunakan pada daerah ': 'Only allowed to be used in the area of ',
  'KOTA Malang & KOTA Batu': 'Malang CITY & Batu CITY',
  'Ke Luar Batas Wilayah': 'Leaving the Area Limit',
  'Hubungi CS Jika Ada Hal Yang Ingin Ditanyakan ': 'Contact CS if you have anything you would like to ask ',
  'Bahasa Indonesia (Default)': 'Indonesian (Default)',
  'Bahasa Aplikasi': 'App Language',
  'Matikan pengingat?': 'Turn off the reminder?',
  'Tanpa pengingat, kamu bisa lupa mengembalikan unit tepat waktu dan terkena denda keterlambatan.': 'Without the reminder, you may forget to return the unit on time and get a late return fine.',
  'Matikan': 'Turn Off',
  'Pengingat pengembalian diaktifkan': 'Return reminder turned on',
  'Pengingat pengembalian dimatikan': 'Return reminder turned off',
  'SETTING': 'SETTINGS',
  'TAMPILAN & BAHASA': 'APPEARANCE & LANGUAGE',
  'Mode Gelap (Dark Mode)': 'Dark Mode',
  'Mengubah tema tampilan menjadi gelap hemat daya': 'Switches the display theme to dark to save power',
  'NOTIFIKASI & PENGINGAT SEWA': 'NOTIFICATIONS & RENTAL REMINDERS',
  'Pengingat Pengembalian Unit': 'Unit Return Reminder',
  'PENTING': 'IMPORTANT',
  'Notifikasi alarm 2 jam & 30 menit sebelum batas sewa habis': 'Alarm notification 2 hours & 30 minutes before the rental time ends',
  'SISTEM': 'SYSTEM',
  'Versi Aplikasi': 'App Version',
  'Bisakah saya memperpanjang masa sewa?': 'Can I extend my rental period?',
  'Perpanjangan bisa diajukan selama unit belum melewati batas waktu sewa. Hubungi Customer Service untuk prosesnya.': 'Extensions can be requested as long as the unit has not passed its rental deadline. Contact Customer Service for the process.',
  'Bagaimana jika motor mogok di jalan?': 'What if the motorcycle breaks down on the road?',
  'Segera hubungi Customer Service dan kirim lokasimu. Jangan memperbaiki motor sendiri agar tidak menimbulkan kerusakan baru.': 'Contact Customer Service immediately and send your location. Do not repair the motorcycle yourself to avoid causing new damage.',
    'Detail Produk': 'Product Details',
  'Pemesanan': 'Booking',
  'Detail Penyewaan': 'Rental Details',
  'Info Penting': 'Important Info',
  'TAMPAK DEPAN': 'FRONT VIEW',
  'Terakhir Kali Di Rental': 'Last Rented',
  '/ hari': '/ day',
  '/hari': '/day',
  'SPESIFIKASI MOTOR': 'MOTORCYCLE SPECIFICATIONS',
  'MEREK': 'BRAND',
  'TAHUN PEMBUATAN': 'YEAR OF MANUFACTURE',
  'KAPASITAS MESIN': 'ENGINE CAPACITY',
  'WARNA UNIT': 'UNIT COLOUR',
  'STATUS UNIT': 'UNIT STATUS',
  'Unit ini siap disewa. Lanjutkan ke Pemesanan untuk memilih tanggal, durasi, dan lokasi pertemuan.': 'This unit is ready to rent. Continue to Booking to choose the date, duration, and meeting location.',
  'Unit ini sedang dalam masa sewa aktif oleh pelanggan lain. Anda dapat melihat berakhirnya masa sewa atau mendapatkan notifikasi saat motor sudah siap disewa kembali': 'This unit is currently being actively rented by another customer. You can see when the rental period ends or get notified when the motorcycle is ready to be rented again',
  'Unit ini sedang dalam perbaikan dan belum bisa disewa. Silakan pilih unit lain di katalog produk.': 'This unit is under maintenance and cannot be rented yet. Please choose another unit in the product catalog.',
  'LANJUT KE PEMESANAN': 'CONTINUE TO BOOKING',
  'LIHAT DETAIL PENYEWAAN': 'VIEW RENTAL DETAILS',
  'LANJUT KE PEMBAYARAN': 'CONTINUE TO PAYMENT',
  'KEMBALI KE KATALOG PRODUK': 'BACK TO PRODUCT CATALOG',
  'STATUS PERIODE': 'PERIOD STATUS',
  'Sedang Berjalan': 'In Progress',
  'Melewati Batas': 'Past Deadline',
  'Penyewaan Selesai Pada:': 'Rental Ends:',
  'Hari ini': 'Today',
  'DETAIL MASA SEWA': 'RENTAL PERIOD DETAILS',
  'Estimasi Selesai': 'Estimated End',
  'Perkiraan Siap Disewa lagi': 'Estimated Ready to Rent Again',
  'Prosedur Kesiapan Motor': 'Motorcycle Readiness Procedure',
  'Unit diperkirakan siap disewa kembali setelah pengecekan kondisi motor, oleh pihak RYOKOU, jika kondisi motor mengalami kerusakan kemungkinan bisa saja lebih lama': 'The unit is expected to be ready to rent again after RYOKOU checks the motorcycle\'s condition. If the motorcycle is damaged, it may take longer.',
  'Ingin Menggunakan Motor Ini?': 'Want to Use This Motorcycle?',
  'Dapatkan notifikasi instan saat unit': 'Get an instant notification when the',
  'ini telah selesai diservis dan siap disewa.': 'unit has been serviced and is ready to rent.',
  'Aktifkan Pengingat Ketersediaan': 'Enable Availability Reminder',
  'Pengingat Ketersediaan Aktif': 'Availability Reminder On',
  'Pengingat ketersediaan diaktifkan': 'Availability reminder turned on',
  'Pengingat ketersediaan dimatikan': 'Availability reminder turned off',
  'Jadwal Sewa': 'Rental Schedule',
  'Tanggal Ambil': 'Pick-up Date',
  'Durasi Sewa': 'Rental Duration',
  'Dihitung per 24 jam': 'Counted per 24 hours',
  'Jam Pengambilan': 'Pick-up Time',
  'Lokasi Pertemuan': 'Meeting Location',
  'Lokasi': 'Location',
  'Antar Gratis': 'Free Delivery',
  'Pilih Lokasi Di Peta': 'Pick Location on Map',
  'Pilihan Lokasi Populer:': 'Popular Locations:',
  'Rental RYOKOU Malang (Pusat)': 'Rental RYOKOU Malang (Main Branch)',
  'Stasiun Malang Kota': 'Malang Kota Station',
  'Bandara Abdulrachman Saleh': 'Abdulrachman Saleh Airport',
  'Bandara Abd. Saleh': 'Abd. Saleh Airport',
  'Konfirmasi Lokasi': 'Confirm Location',
  'Lokasi Dikonfirmasi': 'Location Confirmed',
  'Pilih Lokasi': 'Choose Location',
  'Pilih tanggal ambil': 'Select pick-up date',
  'PERHATIAN': 'ATTENTION',
  'PASTIKAN MENGISI FORM PEMESANAN TERSEBUT SESUAI DENGAN': 'MAKE SURE TO FILL IN THE BOOKING FORM ACCORDING TO THE',
  'TANGGAL AMBIL': 'PICK-UP DATE',
  ', DAN': ', AND',
  'YANG ANDA BISA. JIKA': 'THAT WORK FOR YOU. IF THE',
  'PENYEWA': 'RENTER',
  'TIDAK HADIR PADA WAKTU DAN TITIK TEMU YANG DISEPAKATI, TRANSAKSI AKAN OTOMATIS': 'DOES NOT SHOW UP AT THE AGREED TIME AND MEETING POINT, THE TRANSACTION WILL AUTOMATICALLY BE',
  'TERTUNDA': 'POSTPONED',
  'SAYA TELAH MEMBACA KETENTUAN DIATAS DENGAN SEKSAMA': 'I HAVE CAREFULLY READ THE TERMS ABOVE',
  'MEMILIKI SISTEM': 'HAS A SYSTEM OF',
  'DENDA': 'FINES',
  ', DENDA DIBAGI MENJADI 3 JENIS YAITU': ', FINES ARE DIVIDED INTO 3 TYPES, NAMELY',
  'DENDA KELUAR BATAS WILAYAH': 'OUT-OF-AREA FINE',
  ', dan': ', and',
  'Selengkapnya': 'Read more',
  'Jika terkena': 'If you have a',
  'KENDALA': 'PROBLEM',
  'dalam pembayaran, ataupun sebagainya bisa hubungi CS pada nomor': 'with payment or anything else, you can contact CS at',
  'Nomor CS disalin': 'CS number copied',
  'Ringkasan Pemesanan': 'Booking Summary',
  'Motor': 'Motorcycle',
  'Total Sewa': 'Total Rental',
  'Lanjutkan Pembayaran': 'Proceed to Payment',
  'Halaman pembayaran belum tersedia': 'Payment page is not available yet',
  'Isi tanggal ambil terlebih dahulu': 'Please fill in the pick-up date first',
  'Konfirmasi lokasi pertemuan terlebih dahulu': 'Please confirm the meeting location first',
};