import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../controllers/member_form_controller.dart';
import 'form_controls.dart';

/// ຜູກສະມາຊິກໃນຜັງກັບບັນຊີເຂົ້າລະບົບ
class MemberAccountLinkSection extends GetView<MemberFormController> {
  const MemberAccountLinkSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'ຜູກກັບບັນຊີເຂົ້າລະບົບ',
      icon: Icons.link_rounded,
      children: [
        Obx(
          () => RadioGroup<String?>(
            groupValue: controller.linkedUserId.value,
            onChanged: (value) => controller.linkedUserId.value = value,
            child: Column(
              children: [
                for (final account in controller.accounts)
                  Material(
                    type: MaterialType.transparency,
                    child: RadioListTile<String?>(
                      value: account.uid,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      activeColor: AppColors.primary,
                      title: Text(
                        account.displayName,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        account.email ?? account.phone ?? '',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                Material(
                  type: MaterialType.transparency,
                  child: RadioListTile<String?>(
                    value: null,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    activeColor: AppColors.primary,
                    title: Text(
                      'ບໍ່ຜູກບັນຊີ (ບຸກຄົນໃນຜັງເທົ່ານັ້ນ)',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
