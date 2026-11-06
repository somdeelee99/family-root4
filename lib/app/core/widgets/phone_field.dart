import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../utils/validators.dart';

/// ຊ່ອງປ້ອນເບີໂທລະສັບສາກົນ ພ້ອມເລືອກປະເທດ
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.textController,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.initialIsoCode = 'LA',
  });

  final TextEditingController textController;
  final String label;
  final IconData icon;
  final ValueChanged<PhoneNumber> onChanged;
  final String initialIsoCode;

  @override
  Widget build(BuildContext context) {
    return InternationalPhoneNumberInput(
      textFieldController: textController,
      initialValue: PhoneNumber(isoCode: initialIsoCode),
      onInputChanged: onChanged,
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.DIALOG,
        showFlags: true,
        setSelectorButtonAsPrefixIcon: true,
      ),
      keyboardType: TextInputType.phone,
      formatInput: true,
      validator: (value) => Validators.phone(value),
      inputDecoration: InputDecoration(
        labelText: label,
        hintText: '20 xxxx xxxx',
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}
