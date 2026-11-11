import 'package:flutter/material.dart';

import 'beranda_screen.dart';
import 'produk_screen.dart';
import 'profile_screen.dart';
import 'theme/app_colors.dart';
import 'widgets/common_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  late final List<Widget> _pages = [
    BerandaScreen(onLihatSemua: () => setState(() => _index = 1)),
    const ProdukScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const RyokouAppBar(),
            Expanded(child: IndexedStack(index: _index, children: _pages)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              _navItem(0, Icons.home_outlined, 'Beranda'),
              _navItem(1, Icons.two_wheeler, 'Produk'),
              _navItem(2, Icons.settings_outlined, 'Setting'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, String label) {
    final active = _index == i;
    final color = active ? AppColors.primary : Colors.black;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _index = i),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
