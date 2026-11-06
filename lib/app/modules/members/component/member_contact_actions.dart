import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/app_user.dart';

/// ປຸ່ມຕິດຕໍ່ສະມາຊິກ: ແຊັດ, ໂທ ແລະ WhatsApp
class MemberContactActions extends StatelessWidget {
  const MemberContactActions({
    super.key,
    required this.account,
    required this.isSelf,
    required this.onChat,
    required this.onCall,
    required this.onWhatsApp,
  });

  final AppUser account;
  final bool isSelf;
  final VoidCallback onChat;
  final ValueChanged<String> onCall;
  final ValueChanged<String> onWhatsApp;

  @override
  Widget build(BuildContext context) {
    final phone = account.phone ?? account.whatsapp ?? '';
    final whatsapp = account.whatsapp ?? '';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          if (!isSelf)
            Expanded(
              child: _actionButton(
                icon: Icons.forum_rounded,
                label: AppStrings.chatNow,
                color: AppColors.primary,
                onTap: onChat,
              ),
            ),
          if (!isSelf && phone.isNotEmpty) SizedBox(width: 10.w),
          if (phone.isNotEmpty)
            Expanded(
              child: _actionButton(
                icon: Icons.call_rounded,
                label: AppStrings.call,
                color: AppColors.info,
                onTap: () => onCall(phone),
              ),
            ),
          if (whatsapp.isNotEmpty) SizedBox(width: 10.w),
          if (whatsapp.isNotEmpty)
            Expanded(
              child: _actionButton(
                icon: Icons.chat_bubble_rounded,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () => onWhatsApp(whatsapp),
              ),
            ),
          if (isSelf)
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10.w),
                alignment: Alignment.center,
                child: Text(
                  'ນີ້ແມ່ນບັນຊີຂອງທ່ານເອງ',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textHint),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 19.sp, color: color),
            SizedBox(height: 5.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
