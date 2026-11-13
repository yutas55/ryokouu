import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

enum NavTab {
  beranda('/beranda', 'Beranda', 'assets/icons/home.svg'),
  produk('/produk', 'Produk', 'assets/icons/motor.svg'),
  setting('/setting', 'Setting', 'assets/icons/settings.svg');

  final String route;
  final String label;
  final String icon;
  const NavTab(this.route, this.label, this.icon);
}

class RyokouNavBar extends StatelessWidget {
  final NavTab current;
  const RyokouNavBar({super.key, required this.current});

  void _onTap(BuildContext context, NavTab tab) {
    if (tab == current) return;
    HapticFeedback.selectionClick();
    Navigator.of(context).pushReplacementNamed(tab.route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            for (final tab in NavTab.values)
              Expanded(
                child: _NavItem(
                  tab: tab,
                  active: tab == current,
                  onTap: () => _onTap(context, tab),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final NavTab tab;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        // t: 0 = tidak aktif, 1 = aktif. Satu animasi mengatur warna,
        // ukuran icon, dan lebar garis bawah sekaligus.
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: active ? 1 : 0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, t, _) {
            final color = Color.lerp(Colors.black, AppColors.primary, t)!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 1 + 0.12 * t,
                  child: SvgPicture.asset(
                    tab.icon,
                    width: 26,
                    height: 26,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  ),
                ),
                const SizedBox(height: 3),
                // Teks + garis bawah. Lebar garis mengikuti lebar teks
                // (ukuran Stack ditentukan oleh Text, bukan perhitungan
                // intrinsic yang bisa menghasilkan NaN).
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 2,
                      child: Align(
                        child: FractionallySizedBox(
                          widthFactor: t,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
