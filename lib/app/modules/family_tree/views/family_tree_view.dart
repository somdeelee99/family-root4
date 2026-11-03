import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/family_tree_controller.dart';
import '../widgets/family_tree_canvas.dart';
import '../widgets/family_tree_header.dart';
import '../widgets/family_tree_list_view.dart';

/// ໜ້າຜັງໄມ້ຄອບຄົວ
/// - Admin: ເບິ່ງແບບເຕັມ (zoom/pan) + ເພີ່ມ / ແກ້ໄຂ / ລຶບ + Export PDF
/// - Member: ເບິ່ງແບບ read-only + ຄົ້ນຫາ + ເບິ່ງລາຍລະອຽດ
///
/// ໄຟລ໌ນີ້ເປັນພຽງ orchestrator. ລາຍລະອຽດຖືກແຍກໄປຢູ່ widgets:
/// - [FamilyTreeHeader]    ຫົວໜ້າ + ຄົ້ນຫາ + export
/// - [FamilyTreeCanvas]    ຜັງ (zoom/pan/node/ເສັ້ນເຊື່ອມ)
/// - [FamilyTreeListView]  ໂໝດລາຍການ
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
            FamilyTreeHeader(controller: controller),
            Obx(
              () => controller.isTreeMode.value
                  ? Expanded(child: FamilyTreeCanvas(controller: controller))
                  : Expanded(child: FamilyTreeListView(controller: controller)),
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
