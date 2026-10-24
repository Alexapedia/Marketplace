import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/address_models.dart';
import '../controller/address_form_cubit.dart';
import 'widgets/address_form_body.dart';

class AddressFormScreen extends StatelessWidget {
  const AddressFormScreen({super.key, this.initial});

  final AddressModel? initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddressFormCubit(initial),
      child: const AddressFormBody(),
    );
  }
}
