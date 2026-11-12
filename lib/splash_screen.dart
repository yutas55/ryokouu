import 'package:flutter/material.dart';

import 'theme/app_assets.dart';
import 'widgets/common_widgets.dart';
import 'widgets/navbar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, NavTab.beranda.route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AssetImg(
          AppAssets.logo,
          width: 160,
          height: 160,
          fallbackIcon: Icons.two_wheeler,
        ),
      ),
    );
  }
}
