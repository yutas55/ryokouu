import 'package:flutter/material.dart';

import 'beranda_screen.dart';
import 'produk_screen.dart';
import 'setting_screen.dart';
import 'splash_screen.dart';
import 'theme/app_colors.dart';
import 'widgets/navbar.dart';

void main() => runApp(const RyokouApp());

class RyokouApp extends StatelessWidget {
  const RyokouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RYOKOU',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        final Widget page;
        if (settings.name == NavTab.produk.route) {
          page = const ProdukScreen();
        } else if (settings.name == NavTab.setting.route) {
          page = const SettingScreen();
        } else {
          page = const BerandaScreen();
        }
        return PageRouteBuilder<void>(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}
