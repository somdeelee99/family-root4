import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

/// ກາດຂໍ້ມູນມາດຕະຖານຂອງຟອມສະມາຊິກ
class FormSectionCard extends StatelessWidget {
  const FormSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
        boxShadow: AppSizes.softShadow,
      ),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
          side: const BorderSide(color: AppColors.divider),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(icon, size: 16.sp, color: AppColors.primary),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// ປ້າຍກຳກັບຂອງຊ່ອງຂໍ້ມູນ
class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel(this.text, {super.key, this.isRequired = false});

  final String text;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(color: AppColors.danger, fontSize: 13.sp),
          ),
      ],
    );
  }
}

/// ປຸ່ມເລືອກແບບ segmented (ເພດ / ສະຖານະ)
class FormSegmented<T> extends StatelessWidget {
  const FormSegmented({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.iconOf,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final IconData Function(T) iconOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < values.length; i++) ...[
          if (i > 0) SizedBox(width: 8.w),
          Expanded(
            child: InkWell(
              onTap: () => onChanged(values[i]),
              borderRadius: BorderRadius.circular(14.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: values[i] == selected
                      ? AppColors.primary
                      : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: values[i] == selected
                        ? AppColors.primary
                        : AppColors.divider,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      iconOf(values[i]),
                      size: 18.sp,
                      color: values[i] == selected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      labelOf(values[i]),
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: values[i] == selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// ເປີດ date picker ທີ່ໃຊ້ສີຫຼັກຂອງແອັບ
Future<DateTime?> showFormDatePicker({
  required BuildContext context,
  DateTime? initial,
  DateTime? lastDate,
}) async {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: initial ?? DateTime(now.year - 20),
    firstDate: DateTime(1900),
    lastDate: lastDate ?? now,
    helpText: 'ເລືອກວັນທີ',
    cancelText: AppStrings.cancel,
    confirmText: 'ຕົກລົງ',
    builder: (context, child) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme
            .copyWith(primary: AppColors.primary),
      ),
      child: child!,
    ),
  );
}
