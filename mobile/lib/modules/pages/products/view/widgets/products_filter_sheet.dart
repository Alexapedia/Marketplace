import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/typography.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/maison.dart';
import '../../controller/products_cubit.dart';

const _sorts = <String, String>{
  '': 'sort_recommended',
  '-createdAt': 'sort_newest',
  'price': 'sort_price_asc',
  '-price': 'sort_price_desc',
  '-ratingAvg': 'sort_rating',
};

/// Bottom sheet for sort + price range. Applies through [ProductsCubit.applyFilters].
Future<void> showProductsFilterSheet(
  BuildContext context,
  ProductsCubit cubit,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FilterSheet(cubit: cubit),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.cubit});
  final ProductsCubit cubit;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _sort = widget.cubit.state.sort;
  late final _min = TextEditingController(
    text: _fmt(widget.cubit.state.minPrice),
  );
  late final _max = TextEditingController(
    text: _fmt(widget.cubit.state.maxPrice),
  );

  static String _fmt(double? v) => v == null ? '' : v.toStringAsFixed(0);
  static double? _parse(String v) =>
      v.trim().isEmpty ? null : double.tryParse(v.trim());

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final digits = [FilteringTextInputFormatter.digitsOnly];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'filters'.tr(),
            style: displayStyle(size: 24, color: context.maison.ink),
          ),
          const SizedBox(height: 10),
          const GoldRule(width: 48),
          const SizedBox(height: 22),
          Eyebrow('sort_by'.tr(), color: context.maison.inkMuted),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sorts.entries
                .map(
                  (e) => ChoiceChip(
                    showCheckmark: false,
                    label: Text(e.value.tr()),
                    selected: _sort == e.key,
                    onSelected: (_) => setState(() => _sort = e.key),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          Eyebrow('price_range'.tr(), color: context.maison.inkMuted),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _min,
                  keyboardType: TextInputType.number,
                  inputFormatters: digits,
                  decoration: InputDecoration(labelText: 'min_price'.tr()),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('–'),
              ),
              Expanded(
                child: TextField(
                  controller: _max,
                  keyboardType: TextInputType.number,
                  inputFormatters: digits,
                  decoration: InputDecoration(labelText: 'max_price'.tr()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  isOutlined: true,
                  title: 'clear_filters'.tr(),
                  onTap: () {
                    widget.cubit.clearFilters();
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  onTap: () {
                    widget.cubit.applyFilters(
                      sort: _sort,
                      minPrice: _parse(_min.text),
                      maxPrice: _parse(_max.text),
                    );
                    Navigator.pop(context);
                  },
                  title: 'apply'.tr(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
