import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';

/// ແຖບນຳທາງດ້ານລຸ່ມ ແບບມືອາຊີບ (ມີ badge ຈຳນວນຂໍ້ຄວາມໃໝ່)
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int unreadCount;

  static const List<_NavItem> _items = [
    _NavItem(label: 'ໜ້າຫຼັກ', icon: Icons.home_outlined, activeIcon: Icons.home_rounded),
    _NavItem(label: 'ຜັງຄອບຄົວ', icon: Icons.account_tree_outlined, activeIcon: Icons.account_tree_rounded),
    _NavItem(label: 'ສະມາຊິກ', icon: Icons.groups_outlined, activeIcon: Icons.groups_rounded),
    _NavItem(label: 'ສົນທະນາ', icon: Icons.forum_outlined, activeIcon: Icons.forum_rounded),
    _NavItem(label: 'ໂປຣໄຟລ໌', icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66.h,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final selected = index == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primarySoft : Colors.transparent,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              selected ? item.activeIcon : item.icon,
                              size: 22.sp,
                              color: selected ? AppColors.primary : AppColors.textHint,
                            ),
                            if (index == 3 && unreadCount > 0)
                              Positioned(
                                right: -6.w,
                                top: -5.h,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                                  constraints: BoxConstraints(minWidth: 17.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger,
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(color: Colors.white, width: 1.4),
                                  ),
                                  child: Text(
                                    unreadCount > 99 ? '99+' : '$unreadCount',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                          color: selected ? AppColors.primary : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.label, required this.icon, required this.activeIcon});
  final String label;
  final IconData icon;
  final IconData activeIcon;
}
