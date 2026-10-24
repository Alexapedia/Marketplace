import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/maison.dart';
import '../controller/splash_cubit.dart';
import 'widgets/splash_brand.dart';
import 'widgets/splash_image.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView();

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );
    Future.delayed(const Duration(milliseconds: 420), () {
      if (mounted) _textController.forward();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SplashCubit>().boot(context);
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    // The deep brand band, lit by a soft accent bloom behind the mark.
    return Scaffold(
      backgroundColor: m.band,
      body: SplashImage(
        fallback: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.15),
              radius: 0.9,
              colors: [
                Color.alphaBlend(m.accent.withValues(alpha: 0.14), m.band),
                m.band,
              ],
            ),
          ),
          child: SizedBox.expand(
            child: Center(
              child: SplashBrand(
                logoController: _logoController,
                textController: _textController,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
