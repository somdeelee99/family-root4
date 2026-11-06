import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/family_tree_controller.dart';
import '../widgets/family_tree_canvas.dart';
import '../widgets/family_tree_header.dart';
import '../widgets/family_tree_list_view.dart';

class FamilyTreeView extends GetView<FamilyTreeController> {
  const FamilyTreeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const FamilyTreeHeader(),
            Obx(
              () => controller.isTreeMode.value
                  ? const Expanded(child: FamilyTreeCanvas())
                  : const Expanded(child: FamilyTreeListView()),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => controller.isAdmin
            ? FloatingActionButton.extended(
                heroTag: 'family_tree_fab',
                onPressed: () => Get.toNamed(Routes.MEMBER_FORM),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add_rounded),
                label: const Text('ເພີ່ມສະມາຊິກ'),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
