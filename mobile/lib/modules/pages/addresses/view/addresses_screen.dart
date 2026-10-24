import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controller/addresses_cubit.dart';
import 'widgets/addresses_body.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddressesCubit()..load(),
      child: const AddressesBody(),
    );
  }
}
