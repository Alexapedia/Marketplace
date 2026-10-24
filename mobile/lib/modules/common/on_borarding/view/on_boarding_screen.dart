import 'package:flutter/material.dart';

import 'widgets/onboarding_body.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The scaffold takes the Maison canvas (ivory / onyx) from the theme.
    return const Scaffold(body: OnboardingBody());
  }
}
