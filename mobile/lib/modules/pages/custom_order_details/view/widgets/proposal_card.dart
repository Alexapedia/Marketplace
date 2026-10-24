import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../config/theme/typography.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/app_text_field.dart';
import '../../../../../core/models/custom_order_models.dart';
import '../../../../../core/utils/constant/app_string.dart';
import '../../../addresses/view/widgets/pick_address_sheet.dart';
import '../../controller/custom_order_details_cubit.dart';

class ProposalCard extends StatelessWidget {
  const ProposalCard({
    super.key,
    required this.orderId,
    required this.proposal,
  });

  final String orderId;
  final ProposalModel proposal;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: m.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: m.accent, width: 1.2),
          boxShadow: AppShadows.one(m.brightness),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow('quote_from_support'.tr()),
            const SizedBox(height: 8),
            AnimatedNumber(
              value: proposal.price,
              format: (v) => '${v.toStringAsFixed(0)} ${AppString.currency}',
              style: displayStyle(size: 34, color: m.ink),
            ),
            const SizedBox(height: 10),
            const GoldRule(width: 48),
            if (proposal.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                proposal.notes,
                style: text.bodyMedium?.copyWith(color: m.inkMuted),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.payments_outlined, size: 18, color: m.accentInk),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'cod'.tr(),
                  style: text.labelLarge?.copyWith(color: m.ink),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (proposal.canRespond)
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      onTap: () async {
                        final address = await PickAddressSheet.show(context);
                        if (address == null || !context.mounted) return;
                        await context.read<CustomOrderDetailsCubit>().confirm(
                          orderId,
                          proposal.id,
                          addressId: address.id,
                        );
                      },
                      title: 'confirm_proposal'.tr(),
                      size: const Size.fromHeight(48),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      isOutlined: true,
                      onTap: () => _reject(context),
                      title: 'reject_proposal'.tr(),
                      size: const Size.fromHeight(48),
                    ),
                  ),
                ],
              )
            else
              StatusPill(
                status: proposal.status,
                label: proposal.status == 'confirmed'
                    ? 'quote_confirmed'.tr()
                    : proposal.status,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _reject(BuildContext context) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('reject_proposal'.tr()),
        content: AppTextField(controller: ctrl, title: 'reject_reason'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('confirm'.tr()),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<CustomOrderDetailsCubit>().reject(
        orderId,
        proposal.id,
        ctrl.text,
      );
    }
  }
}
