import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/family_member.dart';
import '../../../routes/app_routes.dart';
import '../controllers/family_tree_controller.dart';
import 'member_detail_sheet.dart';
import 'tree_connector_painter.dart';
import 'tree_controls.dart';
import 'tree_grid_painter.dart';
import 'tree_node_card.dart';

/// canvas ຂອງຜັງໄມ້ຄອບຄົວ (zoom / pan / ຄົ້ນຫາ / ປຸ່ມຄວບຄຸມ)
class FamilyTreeCanvas extends StatelessWidget {
  const FamilyTreeCanvas({super.key, required this.controller});

  final FamilyTreeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.members.isEmpty) {
        return EmptyState(
          title: AppStrings.noMembers,
          description: controller.isAdmin
              ? 'ເລີ່ມສ້າງຜັງໄມ້ຄອບຄົວໂດຍການເພີ່ມສະມາຊິກຄົນທຳອິດ'
              : 'Admin ຍັງບໍ່ໄດ້ເພີ່ມສະມາຊິກໃນຜັງ',
          icon: Icons.account_tree_outlined,
          actionLabel: controller.isAdmin ? AppStrings.addNode : null,
          onAction: controller.isAdmin
              ? () => Get.toNamed(Routes.MEMBER_FORM)
              : null,
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          controller.updateViewport(constraints.biggest);
          controller.maybeAutoFit();

          return Stack(
            children: [
              InteractiveViewer(
                transformationController: controller.transformation,
                minScale: 0.35,
                maxScale: 2.6,
                boundaryMargin: EdgeInsets.all(220.w),
                constrained: false,
                child: RepaintBoundary(
                  key: controller.boundaryKey,
                  child: Obx(() {
                    final size = controller.nodes.isEmpty
                        ? const Size(800, 800)
                        : controller.canvasSize;
                    return Container(
                      width: size.width,
                      height: size.height,
                      color: AppColors.background,
                      child: _canvasContent(),
                    );
                  }),
                ),
              ),
              Positioned(
                left: 12.w,
                top: 12.h,
                child: _SearchBadge(controller: controller),
              ),
              Positioned(
                right: 14.w,
                bottom: 96.h,
                child: TreeControls(
                  onZoomIn: controller.zoomIn,
                  onZoomOut: controller.zoomOut,
                  onReset: controller.resetZoom,
                  onCenter: controller.focusFirstMatch,
                  onFit: controller.fitToScreen,
                ),
              ),
              Positioned(left: 14.w, bottom: 16.h, child: const TreeLegend()),
            ],
          );
        },
      );
    });
  }

  Widget _canvasContent() {
    return Obx(() {
      final selectedId = controller.selected.value?.id;
      final layout = controller.layoutResult;
      final matchedIds = controller.matchedIds;

      // Highlight ຄຳນວນຢູ່ UI ເພື່ອບໍ່ໃຫ້ຕ້ອງ layout ໃໝ່ທຸກຄັ້ງທີ່ພິມຄົ້ນຫາ.
      final visibleNodes = [
        for (final node in controller.nodes)
          TreeNodePosition(
            member: node.member,
            offset: node.offset,
            isHighlighted: matchedIds.contains(node.member.id),
          ),
      ];

      return Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: TreeCanvasGridPainter()),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: TreeConnectorPainter(
                nodes: visibleNodes,
                edges: layout.edges,
                revision: layout.revision,
                selectedId: selectedId,
              ),
            ),
          ),
          for (final node in visibleNodes)
            Positioned(
              left: node.offset.dx,
              top: node.offset.dy,
              child: TreeNodeCard(
                member: node.member,
                isSelected: selectedId == node.member.id,
                isHighlighted: node.isHighlighted,
                onTap: () => _openDetail(node.member),
                onLongPress: controller.isAdmin
                    ? () => Get.toNamed(
                        Routes.MEMBER_FORM,
                        arguments: {'memberId': node.member.id},
                      )
                    : null,
              ),
            ),
        ],
      );
    });
  }

  void _openDetail(FamilyMember member) {
    controller.selected.value = member;
    showMemberDetailSheet(
      member,
      allMembers: controller.members,
      onChanged: controller.refreshSelected,
    );
  }
}

/// ຈຳນວນສະມາຊິກ / ຜົນການຄົ້ນຫາ
class _SearchBadge extends StatelessWidget {
  const _SearchBadge({required this.controller});

  final FamilyTreeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final queryActive = controller.query.value.isNotEmpty;
      final matched = controller.matchedIds.length;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(13.r),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              queryActive
                  ? Icons.manage_search_rounded
                  : Icons.groups_2_rounded,
              size: 16.sp,
              color: queryActive ? AppColors.accent : AppColors.primary,
            ),
            SizedBox(width: 6.w),
            Text(
              queryActive
                  ? 'ພົບ $matched ຄົນ'
                  : '${controller.members.length} ສະມາຊິກ',
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (queryActive && matched > 0) ...[
              SizedBox(width: 4.w),
              InkWell(
                onTap: controller.focusFirstMatch,
                borderRadius: BorderRadius.circular(20.r),
                child: Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Icon(
                    Icons.center_focus_strong_rounded,
                    size: 15.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
