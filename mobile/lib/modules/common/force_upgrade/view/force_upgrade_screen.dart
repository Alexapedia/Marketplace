import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/app_models.dart';
import '../controller/force_upgrade_cubit.dart';
import 'widgets/force_upgrade_body.dart';

class ForceUpgradeScreen extends StatelessWidget {
  const ForceUpgradeScreen({super.key, required this.version});

  final AppVersionModel version;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForceUpgradeCubit(version),
      child: const PopScope(
        canPop: false,
        child: Scaffold(body: ForceUpgradeBody()),
      ),
    );
  }
}
