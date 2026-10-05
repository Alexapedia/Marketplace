import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controller/splash_cubit.dart';
import 'widgets/splash_brand.dart';

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
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    Future.delayed(const Duration(milliseconds: 700), () {
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
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [Color(0xFF071345), Color(0xFF1C3190)]
                : [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 255, 255, 255), Color.fromARGB(162, 7, 19, 69)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SplashBrand(
            logoController: _logoController,
            textController: _textController,
          ),
        ),
      ),
    );
  }
}
