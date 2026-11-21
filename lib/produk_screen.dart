import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:ryokou/bahasa.dart';

import 'models/motor.dart';
import 'theme/app_colors.dart';
import 'widgets/motor_cards.dart';
import 'widgets/navbar.dart';
import 'widgets/status_filter_chip.dart';
import 'widgets/topbar.dart';

class ProdukScreen extends StatefulWidget {
  const ProdukScreen({super.key});

  @override
  State<ProdukScreen> createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  // null = tampilkan semua motor
  StatusMotor? _filter;

  int _hitung(StatusMotor status) =>
      dataMotor.where((m) => m.status == status).length;

  // Klik chip = tampilkan motor dengan status itu saja.
  // Klik chip yang sama lagi = kembali menampilkan semua.
  void _pilih(StatusMotor status) {
    HapticFeedback.selectionClick();
    setState(() => _filter = _filter == status ? null : status);
  }

  @override
  Widget build(BuildContext context) {
    final daftar = _filter == null
        ? dataMotor
        : dataMotor.where((m) => m.status == _filter).toList();

    return Scaffold(
      appBar: const RyokouTopBar(title: 'KATALOG PRODUK'),
      bottomNavigationBar: const RyokouNavBar(current: NavTab.produk),
      body: Column(
        children: [
          // Chip filter (bisa digeser ke samping kalau layarnya sempit)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                for (final status in StatusMotor.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: StatusFilterChip(
                      status: status,
                      count: _hitung(status),
                      selected: _filter == status,
                      onTap: () => _pilih(status),
                    ),
                  ),
              ],
            ),
          ),

          // Daftar motor (berganti dengan efek fade saat filter berubah)
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: daftar.isEmpty
                  ? const _KosongState(key: ValueKey('kosong'))
                  : GridView.builder(
                      key: ValueKey(_filter),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      itemCount: daftar.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 306, // tinggi tiap kartu
                          ),
                      itemBuilder: (_, i) => MotorGridCard(motor: daftar[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KosongState extends StatelessWidget {
  const _KosongState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.two_wheeler, size: 48, color: AppColors.border),
          SizedBox(height: 8),
          Text(
            'Belum ada motor dengan status ini',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}