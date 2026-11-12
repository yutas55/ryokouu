import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
            Expanded(
              child: IndexedStack(index: _index, children: _pages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
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
        onTap: () {
          if (_index == i) return;
          HapticFeedback.selectionClick(); // getar halus saat pindah tab
          setState(() => _index = i);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          // Warna icon + teks berubah halus (fade) antara hitam <-> warna utama
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: color),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            builder: (context, c, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon sedikit membesar saat aktif
                  AnimatedScale(
                    scale: active ? 1.12 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    child: Icon(icon, size: 28, color: c),
                  ),
                  const SizedBox(height: 2),
                  // Lebar garis bawah mengikuti lebar teks
                  IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: c,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Garis bawah melebar dari tengah saat aktif
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(end: active ? 1.0 : 0.0),
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          builder: (context, v, _) {
                            return SizedBox(
                              height: 2,
                              child: Align(
                                child: FractionallySizedBox(
                                  widthFactor: v,
                                  child: Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
