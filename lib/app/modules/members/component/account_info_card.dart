import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/section_card.dart';
import '../../../data/models/app_user.dart';

/// ການດຂໍ້ມູນບັນຊີເຂົ້າລະບົບ
class AccountInfoCard extends StatelessWidget {
  const AccountInfoCard({
    super.key,
    required this.account,
    required this.onEmail,
    required this.onCall,
    required this.onWhatsApp,
  });

  final AppUser account;
  final ValueChanged<String> onEmail;
  final ValueChanged<String> onCall;
  final ValueChanged<String> onWhatsApp;

  @override
  Widget build(BuildContext context) {
    final email = account.email ?? '';
    final phone = account.phone ?? '';
    final whatsapp = account.whatsapp ?? '';

    return SectionCard(
      title: AppStrings.accountInfo,
      icon: Icons.account_circle_outlined,
      children: [
        InfoRow(
          icon: Icons.mail_outline_rounded,
          label: AppStrings.email,
          value: email.isEmpty ? '-' : email,
          onTap: email.isEmpty ? null : () => onEmail(email),
          showOpenIcon: true,
        ),
        InfoRow(
          icon: Icons.call_outlined,
          label: AppStrings.phone,
          value: phone.isEmpty ? '-' : phone,
          onTap: phone.isEmpty ? null : () => onCall(phone),
          showOpenIcon: true,
        ),
        InfoRow(
          icon: Icons.chat_outlined,
          label: AppStrings.whatsapp,
          value: whatsapp.isEmpty ? '-' : whatsapp,
          onTap: whatsapp.isEmpty ? null : () => onWhatsApp(whatsapp),
          showOpenIcon: true,
        ),
        InfoRow(
          icon: Icons.verified_user_outlined,
          label: AppStrings.role,
          value: account.role.label,
        ),
        InfoRow(
          icon: Icons.event_available_outlined,
          label: 'ເຂົ້າໃຊ້ຫຼ້າສຸດ',
          value: account.lastSeenAt == null
              ? '-'
              : AppDateUtils.relative(account.lastSeenAt),
        ),
        InfoRow(
          icon: Icons.login_rounded,
          label: 'ຊ່ອງທາງເຂົ້າລະບົບ',
          value: account.providers.isEmpty
              ? '-'
              : account.providers.map((provider) => provider.label).join(', '),
        ),
      ],
    );
  }
}
