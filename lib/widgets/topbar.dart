import 'package:flutter/material.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import 'common_widgets.dart';
import 'navbar.dart';

class RyokouTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const RyokouTopBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final sedangDiSetting =
        ModalRoute.of(context)?.settings.name == NavTab.setting.route;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      titleSpacing: 16,
      shape: const Border(
        bottom: BorderSide(color: AppColors.border, width: 0.5),
      ),
      title: Row(
        children: [
          const AssetImg(
            AppAssets.logo,
            width: 34,
            height: 34,
            fallbackIcon: Icons.circle,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            // Tap avatar -> buka halaman Setting (kalau belum di sana)
            onTap: sedangDiSetting
                ? null
                : () =>
                      Navigator.of(context)
                          .pushReplacementNamed(NavTab.setting.route),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
