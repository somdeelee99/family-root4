import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// ຊ່ອງປ້ອນຂໍ້ມູນມາດຕະຖານ ພ້ອມປ້າຍກຳກັບ
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.enabled = true,
    this.isRequired = false,
    this.isOptional = false,
    this.suffixText,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final bool isRequired;
  final bool isOptional;
  final String? suffixText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              if (isRequired)
                Text(' *',
                    style: TextStyle(color: AppColors.danger, fontSize: 13.sp)),
              if (isOptional) ...[
                SizedBox(width: 6.w),
                Text(
                  '(ບໍ່ບັງຄັບ)',
                  style: TextStyle(fontSize: 11.sp, color: AppColors.textHint),
                ),
              ],
            ],
          ),
          SizedBox(height: 7.h),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          maxLength: maxLength,
          enabled: enabled,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          style: TextStyle(fontSize: 14.5.sp),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            prefixIcon:
                prefixIcon == null ? null : Icon(prefixIcon, size: 20.sp),
            suffixIcon: suffixIcon,
            suffixText: suffixText,
            suffixStyle: TextStyle(fontSize: 12.sp, color: AppColors.textHint),
          ),
        ),
      ],
    );
  }
}

/// ຊ່ອງປ້ອນລະຫັດຜ່ານ ພ້ອມປຸ່ມສະແດງ/ປິດ
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    this.controller,
    this.label = 'ລະຫັດຜ່ານ',
    this.validator,
    this.isRequired = false,
    this.onChanged,
    this.hint,
  });

  final TextEditingController? controller;
  final String label;
  final String? Function(String?)? validator;
  final bool isRequired;
  final void Function(String)? onChanged;
  final String? hint;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint ?? '••••••••',
      prefixIcon: Icons.lock_outline_rounded,
      obscure: !_visible,
      isRequired: widget.isRequired,
      validator: widget.validator,
      onChanged: widget.onChanged,
      suffixIcon: IconButton(
        onPressed: () => setState(() => _visible = !_visible),
        icon: Icon(
          _visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20.sp,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}

/// ຊ່ອງປ້ອນວັນທີ
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    this.value,
    this.onTap,
    this.isOptional = false,
    this.isRequired = false,
    this.icon = Icons.calendar_today_rounded,
  });

  final String label;
  final DateTime? value;
  final VoidCallback? onTap;
  final bool isOptional;
  final bool isRequired;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? 'ເລືອກວັນທີ'
        : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            if (isRequired)
              Text(' *',
                  style: TextStyle(color: AppColors.danger, fontSize: 13.sp)),
            if (isOptional) ...[
              SizedBox(width: 6.w),
              Text('(ບໍ່ບັງຄັບ)',
                  style: TextStyle(fontSize: 11.sp, color: AppColors.textHint)),
            ],
          ],
        ),
        SizedBox(height: 7.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
          child: Container(
            height: AppSizes.inputHeight.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20.sp, color: AppColors.textSecondary),
                SizedBox(width: 12.w),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    color: value == null
                        ? AppColors.textHint
                        : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textHint, size: 22.sp),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
