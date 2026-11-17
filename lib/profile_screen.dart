import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/status_pengguna.dart';
import 'theme/app_colors.dart';
import 'widgets/topbar.dart';

// ---------- Format nomor telepon ----------

/// "8123456789" -> "812-3456-789" (pola 3-4-sisanya)
String _formatTelp(String digit) {
  final b = StringBuffer();
  for (var i = 0; i < digit.length; i++) {
    if (i == 3 || i == 7) b.write('-');
    b.write(digit[i]);
  }
  return b.toString();
}

/// Ambil bagian nomor setelah +62 / 62 / 0 dari data akun, lalu format.
/// "+62812-3456-7890" -> "812-3456-7890"
String _telpDariAkun(String nomor) {
  var d = nomor.replaceAll(RegExp(r'\D'), '');
  if (d.startsWith('62')) {
    d = d.substring(2);
  } else if (d.startsWith('0')) {
    d = d.substring(1);
  }
  if (d.length > 12) d = d.substring(0, 12);
  return _formatTelp(d);
}

/// Otomatis menambah tanda "-" saat mengetik nomor telepon.
class _FormatTelepon extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue lama,
    TextEditingValue baru,
  ) {
    var d = baru.text.replaceAll(RegExp(r'\D'), '');
    if (d.length > 12) d = d.substring(0, 12);
    final teks = _formatTelp(d);

    // Jaga posisi kursor: hitung jumlah digit sebelum kursor.
    final akhir = baru.selection.end < 0
        ? baru.text.length
        : math.min(baru.selection.end, baru.text.length);
    final digitSebelumKursor = math.min(
      baru.text.substring(0, akhir).replaceAll(RegExp(r'\D'), '').length,
      d.length,
    );

    var pos = 0;
    var hitung = 0;
    while (pos < teks.length && hitung < digitSebelumKursor) {
      if (teks[pos] != '-') hitung++;
      pos++;
    }

    return TextEditingValue(
      text: teks,
      selection: TextSelection.collapsed(offset: pos),
    );
  }
}

/// Halaman form data diri. Dibuka dari icon di halaman Profil.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _merah = Color(0xFFD32F2F);

  final _formKey = GlobalKey<FormState>();
  final _namaKey = GlobalKey<FormFieldState<String>>();
  final _emailKey = GlobalKey<FormFieldState<String>>();
  final _telpKey = GlobalKey<FormFieldState<String>>();
  final _sandiKey = GlobalKey<FormFieldState<String>>();

  final _namaC = TextEditingController();
  final _emailC = TextEditingController();
  final _telpC = TextEditingController();
  final _sandiC = TextEditingController();

  final _namaF = FocusNode();
  final _emailF = FocusNode();
  final _telpF = FocusNode();
  final _sandiF = FocusNode();

  // Kalau datanya sudah ada di akun, field langsung terisi dan terkunci.
  // Icon pensil dipakai untuk membuka kuncinya (mengubah).
  late final bool _namaAdaData = namaPengguna.trim().isNotEmpty;
  late final bool _emailAdaData = emailPengguna.trim().isNotEmpty;
  late final bool _telpAdaData = _telpDariAkun(noHpPengguna).isNotEmpty;
  late final bool _sandiAdaData = kataSandiPengguna.isNotEmpty;

  bool _namaEdit = false;
  bool _emailEdit = false;
  bool _telpEdit = false;
  bool _sandiEdit = false;

  bool _lihatSandi = false;
  bool _setuju = false;

  @override
  void initState() {
    super.initState();
    _namaC.text = namaPengguna;
    _emailC.text = emailPengguna;
    _telpC.text = _telpDariAkun(noHpPengguna);
    _sandiC.text = kataSandiPengguna;
  }

  @override
  void dispose() {
    _namaC.dispose();
    _emailC.dispose();
    _telpC.dispose();
    _sandiC.dispose();
    _namaF.dispose();
    _emailF.dispose();
    _telpF.dispose();
    _sandiF.dispose();
    super.dispose();
  }

  // ---------- Aksi ----------

  /// Pensil: pertama kali = buka kunci field, kedua kali (centang) = kunci
  /// lagi (hanya kalau isinya valid).
  void _toggleEdit({
    required bool sedangEdit,
    required GlobalKey<FormFieldState<String>> kunci,
    required FocusNode fokus,
    required TextEditingController c,
    required void Function(bool) setEdit,
  }) {
    if (sedangEdit) {
      if (kunci.currentState?.validate() ?? false) {
        setState(() => setEdit(false));
        FocusScope.of(context).unfocus();
      }
      return;
    }
    setState(() => setEdit(true));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      fokus.requestFocus();
      c.selection = TextSelection.collapsed(offset: c.text.length);
    });
  }

  void _ubahNama() => _toggleEdit(
    sedangEdit: _namaEdit,
    kunci: _namaKey,
    fokus: _namaF,
    c: _namaC,
    setEdit: (v) => _namaEdit = v,
  );

  void _ubahEmail() => _toggleEdit(
    sedangEdit: _emailEdit,
    kunci: _emailKey,
    fokus: _emailF,
    c: _emailC,
    setEdit: (v) => _emailEdit = v,
  );

  void _ubahTelp() => _toggleEdit(
    sedangEdit: _telpEdit,
    kunci: _telpKey,
    fokus: _telpF,
    c: _telpC,
    setEdit: (v) => _telpEdit = v,
  );

  void _ubahSandi() => _toggleEdit(
    sedangEdit: _sandiEdit,
    kunci: _sandiKey,
    fokus: _sandiF,
    c: _sandiC,
    setEdit: (v) => _sandiEdit = v,
  );

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    if (!_setuju) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Centang pernyataan terlebih dahulu')),
      );
      return;
    }

    // Perbarui data akun, supaya halaman Profil ikut menampilkan data baru.
    namaPengguna = _namaC.text.trim();
    emailPengguna = _emailC.text.trim();
    noHpPengguna = '+62${_telpC.text.trim()}';
    kataSandiPengguna = _sandiC.text;

    // TODO: kirim/simpan data ke server atau database di sini.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data diri berhasil disimpan')),
    );
    Navigator.of(context).maybePop();
  }

  // ---------- Halaman ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const RyokouTopBar(title: 'FORM DATA DIRI'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                const Text(
                  'Form Data Diri',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Lengkapi data diri Anda untuk mempercepat proses sewa '
                  'motor di RYOKOU.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 22),

                // Nama lengkap
                _label('Nama Lengkap', aksi: 'wajib diisi'),
                TextFormField(
                  key: _namaKey,
                  controller: _namaC,
                  focusNode: _namaF,
                  readOnly: _namaAdaData && !_namaEdit,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  style: _teksInput,
                  decoration: _dekorasi(
                    hint: 'cth. Rian Pratama',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    suffixIcon: _namaAdaData
                        ? _ikonPensil(
                            editing: _namaEdit,
                            tooltip: 'Ubah nama',
                            onTap: _ubahNama,
                          )
                        : null,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                // Email
                _label('Alamat Email'),
                TextFormField(
                  key: _emailKey,
                  controller: _emailC,
                  focusNode: _emailF,
                  readOnly: _emailAdaData && !_emailEdit,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: _teksInput,
                  decoration: _dekorasi(
                    hint: 'cth. rian.pratama@email.com',
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                    suffixIcon: _emailAdaData
                        ? _ikonPensil(
                            editing: _emailEdit,
                            tooltip: 'Ubah email',
                            onTap: _ubahEmail,
                          )
                        : null,
                  ),
                  validator: (v) {
                    final email = v?.trim() ?? '';
                    if (email.isEmpty) return 'Email wajib diisi';
                    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    return valid.hasMatch(email)
                        ? null
                        : 'Format email tidak valid';
                  },
                ),
                const SizedBox(height: 16),

                // Nomor telepon (format otomatis xxx-xxxx-xxxx)
                _label('Nomor Telepon'),
                TextFormField(
                  key: _telpKey,
                  controller: _telpC,
                  focusNode: _telpF,
                  readOnly: _telpAdaData && !_telpEdit,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [_FormatTelepon()],
                  style: _teksInput,
                  decoration: _dekorasi(
                    hint: '812-3456-7890',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 16, right: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.smartphone_rounded),
                          SizedBox(width: 8),
                          Text(
                            '+62',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    kecilkanPrefix: true,
                    suffixIcon: _telpAdaData
                        ? _ikonPensil(
                            editing: _telpEdit,
                            tooltip: 'Ubah nomor telepon',
                            onTap: _ubahTelp,
                          )
                        : null,
                  ),
                  validator: (v) {
                    final telp = (v ?? '').replaceAll(RegExp(r'\D'), '');
                    if (telp.isEmpty) return 'Nomor telepon wajib diisi';
                    if (telp.startsWith('0')) {
                      return 'Tulis tanpa angka 0 di depan';
                    }
                    if (telp.length < 8) return 'Nomor telepon tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Kata sandi
                _label('Kata Sandi'),
                TextFormField(
                  key: _sandiKey,
                  controller: _sandiC,
                  focusNode: _sandiF,
                  readOnly: _sandiAdaData && !_sandiEdit,
                  obscureText: !_lihatSandi,
                  textInputAction: TextInputAction.done,
                  style: _teksInput,
                  decoration: _dekorasi(
                    hint: 'Minimal 8 karakter',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () =>
                              setState(() => _lihatSandi = !_lihatSandi),
                          icon: Icon(
                            _lihatSandi
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        if (_sandiAdaData)
                          _ikonPensil(
                            editing: _sandiEdit,
                            tooltip: 'Ubah kata sandi',
                            onTap: _ubahSandi,
                          ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 8) ? 'Minimal 8 karakter' : null,
                ),
                const SizedBox(height: 24),

                // Pernyataan
                _buildPernyataan(),
                const SizedBox(height: 28),

                // Tombol simpan
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _simpan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppColors.primary.withAlpha(90),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Simpan & Lanjutkan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Bagian-bagian halaman ----------

  Widget _buildHeader() {
    return Row(
      children: [
        // Tombol kembali
        Material(
          color: AppColors.background,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).maybePop(),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 22,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const Spacer(),
        // Badge keamanan
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.avatarBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_outlined, size: 12, color: AppColors.primary),
              SizedBox(width: 4),
              Text(
                'Aman & Terenkripsi',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPernyataan() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _setuju,
            onChanged: (v) => setState(() => _setuju = v ?? false),
            activeColor: AppColors.primary,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text:
                      'Saya menyatakan bahwa data yang diisi sudah benar '
                      'dan menyetujui ',
                ),
                TextSpan(
                  text: 'Syarat & Ketentuan',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: ' serta Kebijakan Privasi RYOKOU.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Komponen form ----------

  static const _teksInput = TextStyle(
    fontSize: 13,
    color: AppColors.textPrimary,
  );

  /// Icon di kanan field: pensil (ubah) -> centang (selesai) saat mengubah.
  Widget _ikonPensil({
    required bool editing,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return IconButton(
      tooltip: editing ? 'Selesai' : tooltip,
      onPressed: onTap,
      icon: Icon(
        editing ? Icons.check_rounded : Icons.edit_outlined,
        size: 20,
        color: editing ? AppColors.primary : AppColors.textPrimary,
      ),
    );
  }

  Widget _label(String teks, {String? aksi}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              teks,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (aksi != null)
            Text(
              aksi,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  OutlineInputBorder _border([Color? warna]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: warna == null
          ? BorderSide.none
          : BorderSide(color: warna, width: 1.2),
    );
  }

  InputDecoration _dekorasi({
    required String hint,
    required Widget prefixIcon,
    Widget? suffixIcon,
    bool kecilkanPrefix = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.hint),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      prefixIcon: prefixIcon,
      prefixIconColor: AppColors.textPrimary,
      prefixIconConstraints: kecilkanPrefix
          ? const BoxConstraints(minWidth: 0, minHeight: 0)
          : null,
      suffixIcon: suffixIcon,
      suffixIconColor: AppColors.textPrimary,
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(AppColors.primary),
      errorBorder: _border(_merah),
      focusedErrorBorder: _border(_merah),
    );
  }
}