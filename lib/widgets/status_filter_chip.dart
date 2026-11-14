import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/motor.dart';
import '../theme/status_style.dart';

class StatusFilterChip extends StatelessWidget {
  final StatusMotor status;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const StatusFilterChip({
    super.key,
    required this.status,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final warna = status.chipColor;

    return Semantics(
      button: true,
      selected: selected,
      label: '${status.chipLabel}, $count',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        // Ukuran selalu sama (border transparan saat tidak dipilih),
        // supaya chip lain tidak bergeser waktu ada yang dipilih.
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? warna : Colors.transparent,
            width: 2,
          ),
        ),
        child: Material(
          color: warna,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    status.iconAsset,
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    status.chipLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Kotak angka jumlah motor
                  Container(
                    constraints: const BoxConstraints(minWidth: 22),
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: status.chipCountBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
