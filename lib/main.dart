import 'package:flutter/material.dart';

import 'splash_screen.dart';
import 'theme/app_colors.dart';

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
        // Kalau mau font Poppins: tambah package google_fonts lalu
        // pakai textTheme: GoogleFonts.poppinsTextTheme()
      ),
      home: const SplashScreen(),
    );
  }
}
