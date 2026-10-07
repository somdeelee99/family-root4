import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/stat_card.dart';
import '../controllers/home_controller.dart';

/// ກາດສະຖິຕິ 6 ຫຼັກ (ສະແດງໃຫ້ທັງ admin ແລະ member ເໝືອນກັນ)
class HomeStatGrid extends GetView<HomeController> {
  const HomeStatGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.stats.value;
      final cards = [
        _StatData(
          label: AppStrings.totalMembers,
          value: s.total,
          icon: Icons.people_alt_rounded,
          color: AppColors.primary,
        ),
        _StatData(
          label: AppStrings.under18,
          value: s.under18,
          icon: Icons.child_care_rounded,
          color: AppColors.info,
        ),
        _StatData(
          label: AppStrings.male,
          value: s.male,
          icon: Icons.male_rounded,
          color: AppColors.male,
        ),
        _StatData(
          label: AppStrings.female,
          value: s.female,
          icon: Icons.female_rounded,
          color: AppColors.female,
        ),
        _StatData(
          label: AppStrings.deceased,
          value: s.deceased,
          icon: Icons.spa_rounded,
          color: AppColors.deceased,
        ),
        _StatData(
          label: AppStrings.alive,
          value: s.alive,
          icon: Icons.favorite_rounded,
          color: AppColors.alive,
        ),
      ];

      return StatCardGrid(
        cards: [
          for (var i = 0; i < cards.length; i++)
            StatCard(
              label: cards[i].label,
              value: cards[i].value,
              icon: cards[i].icon,
              color: cards[i].color,
              index: i,
            ),
        ],
      );
    });
  }
}

class _StatData {
  const _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final int value;
  final IconData icon;
  final Color color;
}
