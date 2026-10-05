import 'package:flutter/material.dart';

import '../../../../core/models/color_model.dart';
import 'widgets/onboarding_body.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.blackColor : AppColors.whiteColor,
      body: const OnboardingBody(),
    );
  }
}
