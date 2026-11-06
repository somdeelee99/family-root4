import 'package:family_root/app/modules/members/component/card_widget.dart';
import 'package:family_root/app/modules/members/component/role_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/enums.dart';
import '../controllers/account_form_controller.dart';

class AccountFormView extends GetView<AccountFormController> {
  const AccountFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          controller.isEdit ? AppStrings.editAccount : AppStrings.addAccount,
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 120.h),
          physics: const BouncingScrollPhysics(),
          children: [
            Center(
              child: Obx(
                () => GestureDetector(
                  onTap: controller.chooseImageSource,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (controller.pickedImage.value != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32.r),
                          child: Image.file(
                            controller.pickedImage.value!,
                            width: 110.w,
                            height: 110.w,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        AppAvatar(
                          imageUrl: controller.avatarUrl.value,
                          name: controller.nameController.text.isEmpty
                              ? 'ສ'
                              : controller.nameController.text,
                          size: 110,
                          borderRadius: BorderRadius.circular(32.r),
                        ),
                      Positioned(
                        right: -3.w,
                        bottom: -3.h,
                        child: Container(
                          padding: EdgeInsets.all(9.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.add_a_photo_rounded,
                            size: 15.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Center(
              child: TextButton(
                onPressed: controller.chooseImageSource,
                child: const Text(AppStrings.changePhoto),
              ),
            ),
            SizedBox(height: 12.h),

            CardWidget(
              title: 'ຂໍ້ມູນບັນຊີ',
              icon: Icons.badge_outlined,
              children: [
                AppTextField(
                  controller: controller.nameController,
                  label: AppStrings.fullName,
                  hint: 'ຊື່ ແລະ ນາມສະກຸນ',
                  prefixIcon: Icons.person_outline_rounded,
                  isRequired: true,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => Validators.required(v, field: 'ຊື່'),
                ),
                SizedBox(height: 14.h),
                AppTextField(
                  controller: controller.phoneController,
                  label: AppStrings.phone,
                  hint: '020 xxxx xxxx',
                  prefixIcon: Icons.call_outlined,
                  keyboardType: TextInputType.phone,
                  isOptional: true,
                  validator: (v) => Validators.phone(v),
                ),
                SizedBox(height: 14.h),
                AppTextField(
                  controller: controller.whatsappController,
                  label: AppStrings.whatsapp,
                  hint: '020 xxxx xxxx',
                  prefixIcon: Icons.chat_outlined,
                  keyboardType: TextInputType.phone,
                  isOptional: true,
                  validator: (v) => Validators.phone(v),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            CardWidget(
              title: 'ການເຂົ້າລະບົບ',
              icon: Icons.lock_outline_rounded,
              children: [
                AppTextField(
                  controller: controller.emailController,
                  label: AppStrings.email,
                  hint: 'member@email.com',
                  prefixIcon: Icons.mail_outline_rounded,
                  isRequired: true,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !controller.isEdit,
                  validator: Validators.email,
                ),
                if (controller.isEdit)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      'ບໍ່ສາມາດປ່ຽນອີແມວໄດ້ ເນື່ອງຈາກເປັນບັນຊີເຂົ້າລະບົບ',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                if (!controller.isEdit) ...[
                  SizedBox(height: 14.h),
                  // FIX: เอา Obx ออก เพราะไม่มี .value ข้างใน
                  AppTextField(
                    controller: controller.passwordController,
                    label: 'ລະຫັດຜ່ານ (ສຳລັບເຂົ້າລະບົບ)',
                    hint: 'ຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ',
                    isRequired: true,
                    // obscureText: true,
                    validator: Validators.password,
                  ),
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: controller.generatePassword,
                      icon: const Icon(Icons.casino_outlined, size: 16),
                      label: Text(
                        'ສ້າງລະຫັດແບບສຸ່ມ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 14.h),

            CardWidget(
              title: AppStrings.role,
              icon: Icons.admin_panel_settings_outlined,
              children: [
                // FIX: ເອົາ Obx ออกจาก Column ໃຫ້ ໄປໃນ _roleOption  thay
                RoleOption(
                  role: UserRole.member,
                  icon: Icons.person_rounded,
                  title: AppStrings.roleMember,
                  description: 'ເບິ່ງຂໍ້ມູນ, ແຊັດຫາ ແລະ ແກ້ໄຂໂປຣໄຟລ໌ຂອງຕົນເອງ',
                ),
                SizedBox(height: 10.h),
                RoleOption(
                  role: UserRole.admin,
                  icon: Icons.verified_rounded,
                  title: AppStrings.roleAdmin,
                  description: 'ຈັດການຜັງ, ສ້າງບັນຊີ ແລະ ຈັດການຂໍ້ມູນທັງໝົດ',
                  isGold: true,
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 15.sp,
                        color: AppColors.info,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Admin ສາມາດກຳນົດ role ຂອງບັນຊີນີ້ໄດ້ທັງ member ແລະ admin',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // FIX: isEdit ไม่ใช่ observable ไม่ต้องห่อ Obx ทั้งก้อน
            if (controller.isEdit)
              Padding(
                padding: EdgeInsets.only(top: 14.h),
                child: Obx(
                  () => Material(
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: AppColors.primary,
                        value: controller.isActive.value,
                        onChanged: (value) => controller.isActive.value = value,
                        title: Text(
                          'ເປີດໃຊ້ງານບັນຊີ',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          'ຖ້າປິດ ສະມາຊິກຈະບໍ່ສາມາດເຂົ້າລະບົບໄດ້',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: FilledButton.icon(
              onPressed: controller.isSaving.value ? null : controller.save,
              icon: controller.isSaving.value
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      controller.isEdit
                          ? Icons.check_rounded
                          : Icons.person_add_alt_1_rounded,
                      size: 20,
                    ),
              label: Text(
                controller.isEdit ? AppStrings.update : 'ສ້າງບັນຊີ',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                minimumSize: Size.fromHeight(54.h),
                backgroundColor: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
