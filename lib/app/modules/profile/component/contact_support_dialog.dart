import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/menu_item.dart';

/// ກ່ອງໂຕ້ຕອບຕິດຕໍ່ທີມງານ (ອີແມວ, ໂທ ແລະ WhatsApp)
class ContactSupportDialog extends StatelessWidget {
  const ContactSupportDialog({
    super.key,
    required this.email,
    required this.phone,
    required this.onEmail,
    required this.onPhone,
    required this.onWhatsApp,
  });

  final String email;
  final String phone;
  final VoidCallback onEmail;
  final VoidCallback onPhone;
  final VoidCallback onWhatsApp;

  static Future<void> show({
    required String email,
    required String phone,
    required VoidCallback onEmail,
    required VoidCallback onPhone,
    required VoidCallback onWhatsApp,
  }) async {
    await Get.dialog(
      ContactSupportDialog(
        email: email,
        phone: phone,
        onEmail: onEmail,
        onPhone: onPhone,
        onWhatsApp: onWhatsApp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  MenuItem(
                    icon: FaIcon(FontAwesomeIcons.envelope),
                    title: 'Email',
                    subtitle: email,
                    onTap: onEmail,
                  ),
                  SizedBox(height: 10.h),
                  MenuItem(
                    icon: FaIcon(FontAwesomeIcons.phone),
                    title: 'Phone',
                    subtitle: phone,
                    onTap: onPhone,
                  ),
                  SizedBox(height: 10.h),
                  MenuItem(
                    icon: FaIcon(FontAwesomeIcons.whatsapp),
                    title: 'WhatsApp',
                    subtitle: phone,
                    onTap: onWhatsApp,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: SizedBox(
                height: 48.h,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: Text(
                    'ຕົກລົງ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 36.sp,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'ຕິດຕໍ່ຫາ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'ທ່ານສາມາດຕິດຕໍ່ຫາທີມງານ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
