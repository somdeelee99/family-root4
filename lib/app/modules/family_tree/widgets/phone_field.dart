import 'package:family_root/app/core/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

Widget PhoneField({
  required TextEditingController textController,
  required String label,
  required IconData icon,
  required ValueChanged<PhoneNumber> onChanged,
}) {
  return InternationalPhoneNumberInput(
    textFieldController: textController,
    initialValue: PhoneNumber(isoCode: 'LA'),
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
