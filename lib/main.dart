import 'package:flutter/material.dart' hide Text;
import 'package:ryokou/bahasa.dart';

import 'beranda_screen.dart';
import 'produk_screen.dart';
import 'profil_screen.dart';
import 'splash_screen.dart';
import 'theme/app_colors.dart';
import 'widgets/navbar.dart';

void main() => runApp(const RyokouApp());

class RyokouApp extends StatefulWidget {
  const RyokouApp({super.key});

  @override
  State<RyokouApp> createState() => _RyokouAppState();
}

class _RyokouAppState extends State<RyokouApp> {
  @override
  void initState() {
    super.initState();
    bahasaAktif.addListener(_bahasaBerubah);
  }

  @override
  void dispose() {
    bahasaAktif.removeListener(_bahasaBerubah);
    super.dispose();
  }

  
  void _bahasaBerubah() {
    if (mounted) bangunUlangSemua(context);
  }

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
        } else if (settings.name == NavTab.profil.route) {
          page = const ProfilScreen();
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