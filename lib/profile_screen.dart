import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme/app_colors.dart';
import 'widgets/topbar.dart';

/// Halaman form data diri. Dibuka dari icon di halaman Setting.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _merah = Color(0xFFD32F2F);

  final _formKey = GlobalKey<FormState>();
  final _namaC = TextEditingController();
  final _emailC = TextEditingController();
  final _telpC = TextEditingController();
  final _sandiC = TextEditingController();

  bool _lihatSandi = false;
  bool _setuju = false;

  @override
  void dispose() {
    _namaC.dispose();
    _emailC.dispose();
    _telpC.dispose();
    _sandiC.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    if (!_setuju) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Centang pernyataan terlebih dahulu')),
      );
      return;
    }

    // TODO: kirim/simpan data ke server atau database di sini.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data diri berhasil disimpan')),
    );
    Navigator.of(context).maybePop();
  }

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
                  controller: _namaC,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  style: _teksInput,
                  decoration: _dekorasi(
                    hint: 'cth. Rian Pratama',
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                // Email
                _label('Alamat Email'),
                TextFormField(
                  controller: _emailC,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: _teksInput,
                  decoration: _dekorasi(
                    hint: 'cth. rian.pratama@email.com',
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
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

                // Nomor telepon
                _label('Nomor Telepon'),
                TextFormField(
                  controller: _telpC,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13),
                  ],
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
                  ),
                  validator: (v) {
                    final telp = v ?? '';
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
                  controller: _sandiC,
                  obscureText: !_lihatSandi,
                  textInputAction: TextInputAction.done,
                  style: _teksInput,
                  decoration: _dekorasi(
                    hint: 'Minimal 8 karakter',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _lihatSandi = !_lihatSandi),
                      icon: Icon(
                        _lihatSandi
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
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
