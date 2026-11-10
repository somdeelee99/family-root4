import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 0 = ໜ້າຫຼັກ ຈະຖືກເລືອກເປັນຄ່າເລີ່ມຕົ້ນ
  int _currentIndex = 0;

  // ປ່ຽນ PlaceholderPage ເປັນໜ້າຈິງຂອງແອັບເຈົ້າ
  late final List<Widget> _pages = const [
    _PlaceholderPage(title: 'ໜ້າຫຼັກ'),
    _PlaceholderPage(title: 'ຜັງຄອບຄົວ'),
    _PlaceholderPage(title: 'ສະມາຊິກ'),
    _PlaceholderPage(title: 'ສົນທະນາ'),
    _PlaceholderPage(title: 'ໂປຣໄຟລ໌'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        unreadCount: 3, // ປ່ຽນເປັນຈຳນວນຂໍ້ຄວາມທີ່ຍັງບໍ່ອ່ານ
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
      ),
    );
  }
}

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
    _NavItem(
      label: 'ໜ້າຫຼັກ',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _NavItem(
      label: 'ຜັງຄອບຄົວ',
      icon: Icons.account_tree_outlined,
      activeIcon: Icons.account_tree_rounded,
    ),
    _NavItem(
      label: 'ສະມາຊິກ',
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups_rounded,
    ),
    _NavItem(
      label: 'ສົນທະນາ',
      icon: Icons.forum_outlined,
      activeIcon: Icons.forum_rounded,
    ),
    _NavItem(
      label: 'ໂປຣໄຟລ໌',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
        child: Container(
          height: 68.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (index) {
              return Expanded(
                child: _NavTile(
                  item: _items[index],
                  selected: index == currentIndex,
                  unreadCount: index == 3 ? unreadCount : 0,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.selected,
    required this.unreadCount,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final int unreadCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(24.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: selected ? AppColors.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    selected ? item.activeIcon : item.icon,
                    key: ValueKey<bool>(selected),
                    size: 22.sp,
                    color: selected ? AppColors.primary : AppColors.textHint,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: -8.w,
                    top: -5.h,
                    child: _Badge(count: unreadCount),
                  ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              item.label,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: selected ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.h),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
