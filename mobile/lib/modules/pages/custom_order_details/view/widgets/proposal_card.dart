import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/app_text_field.dart';
import '../../../../../core/models/color_model.dart';
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
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gold, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'quote_from_support'.tr(),
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          Text(
            '${proposal.price.toStringAsFixed(0)} ${AppString.currency}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: gold,
            ),
          ),
          if (proposal.notes.isNotEmpty) Text(proposal.notes),
          const SizedBox(height: 4),
          Text('💵 ${'cod'.tr()}'),
          const SizedBox(height: 10),
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
                    size: const Size.fromHeight(44),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    isOutlined: true,
                    onTap: () => _reject(context),
                    title: 'reject_proposal'.tr(),
                    size: const Size.fromHeight(44),
                  ),
                ),
              ],
            )
          else
            Text(
              proposal.status == 'confirmed'
                  ? 'quote_confirmed'.tr()
                  : proposal.status,
              style: TextStyle(fontWeight: FontWeight.w700, color: gold),
            ),
        ],
      ),
    );
  }

  Future<void> _reject(BuildContext context) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('reject_proposal'.tr()),
        content: AppTextField(
          controller: ctrl,
          title: 'reject_reason'.tr(),
        ),
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
