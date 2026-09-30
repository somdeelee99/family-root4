import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

/// ຟອມເຂົ້າລະບົບດ້ວຍ ອີແມວ ແລະ ລະຫັດຜ່ານ (ສຳລັບ Member)
class LoginFormCard extends GetView<AuthController> {
  const LoginFormCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
        boxShadow: AppSizes.cardShadow,
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.groups_rounded,
                        size: 13.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Member',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    AppStrings.orLoginWithEmail,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            AppTextField(
              controller: controller.emailController,
              label: AppStrings.email,
              hint: 'member@familyroot.app',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              textCapitalization: TextCapitalization.none,
              autofillHints: const [AutofillHints.email],
            ),
            SizedBox(height: 14.h),
            AppPasswordField(
              controller: controller.passwordController,
              label: AppStrings.password,
              isRequired: true,
              validator: Validators.password,
            ),
            // Align(
            //   alignment: Alignment.centerRight,
            //   child: TextButton(
            //     onPressed: controller.forgotPassword,
            //     style: TextButton.styleFrom(
            //       foregroundColor: AppColors.primary,
            //       padding: EdgeInsets.zero,
            //       minimumSize: Size.zero,
            //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //     ),
            //     child: Text(
            //       AppStrings.forgotPassword,
            //       style: TextStyle(
            //         fontSize: 12.sp,
            //         fontWeight: FontWeight.w700,
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(height: 14.h),
            Obx(
              () => AppButton(
                label: AppStrings.login,
                icon: Icons.login_rounded,
                gradient: true,
                isLoading: controller.isBusy,
                onPressed: controller.isBusy
                    ? null
                    : controller.signInWithEmail,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
