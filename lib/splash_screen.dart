import 'package:flutter/material.dart';

import 'widgets/navbar.dart';
import 'theme/app_assets.dart';
import 'widgets/common_widgets.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            RyokouAppBar(),
            Expanded(
              child: Center(
                child: AssetImg(AppAssets.motorSplash, width: 220, height: 180),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
