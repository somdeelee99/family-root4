import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

/// ຊ່ອງຄົ້ນຫາມາດຕະຖານ ພ້ອມປຸ່ມລ້າງຄຳຄົ້ນຫາ
///
/// ປຸ່ມລ້າງຈະສະແດງອັດຕະໂນມັດ ເມື່ອມີຂໍ້ຄວາມ ແລະ ມີ [onClear].
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.filled = true,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          autofocus: autofocus,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            isDense: true,
            filled: filled,
            prefixIcon: Icon(Icons.search_rounded, size: 20.sp),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'ລ້າງຄຳຄົ້ນຫາ',
                    onPressed: () {
                      controller.clear();
                      onClear?.call();
                    },
                    icon: Icon(Icons.close_rounded, size: 18.sp),
                  ),
          ),
        );
      },
    );
  }
}
