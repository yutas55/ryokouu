import 'package:flutter/material.dart';

import 'widgets/navbar.dart';
import 'widgets/topbar.dart';
import 'models/motor.dart';
import 'theme/app_colors.dart';
import 'widgets/motor_cards.dart';

class ProdukScreen extends StatefulWidget {
  const ProdukScreen({super.key});

  @override
  State<ProdukScreen> createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  String _searchText = '';

    @override
  Widget build(BuildContext context) {
    final query = _searchText.toLowerCase();
    final motorFiltered = dataMotor.where((motor) {
      return motor.nama.toLowerCase().contains(query) ||
          motor.platNo.toLowerCase().contains(query);
    }).toList();
    final jumlahTersedia =
        dataMotor.where((m) => m.status == StatusMotor.tersedia).length;
    final jumlahDisewa =
        dataMotor.where((m) => m.status == StatusMotor.disewa).length;

    return Scaffold(
      appBar: const RyokouTopBar(title: 'KATALOG PRODUK'),
      bottomNavigationBar: const RyokouNavBar(current: NavTab.produk),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (value) =>
                          setState(() => _searchText = value),
                      decoration: const InputDecoration(
                        hintText: 'Cari merek atau tipe motor',
                        hintStyle:
                            TextStyle(fontSize: 12, color: AppColors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Chip status
            Row(
              children: [
                StatusChip(
                  icon: Icons.check_circle_outline,
                  label: 'Motor Yang Tersedia',
                  count: jumlahTersedia,
                ),
                const SizedBox(width: 8),
                StatusChip(
                  icon: Icons.access_time,
                  label: 'Motor Sedang Disewa',
                  count: jumlahDisewa,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Grid motor
            Expanded(
              child: motorFiltered.isEmpty
                  ? const Center(child: Text('Motor tidak ditemukan'))
                  : GridView.builder(
                      itemCount: motorFiltered.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (_, i) =>
                          MotorGridCard(motor: motorFiltered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

class StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  const StatusChip({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '$label  $count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
