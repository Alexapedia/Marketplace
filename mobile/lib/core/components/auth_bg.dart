import 'package:flutter/material.dart';

import '../models/color_model.dart';
import '../utils/functions/responsive.dart';
import 'circle_back_button.dart';

class AuthBg extends StatelessWidget {
  const AuthBg({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.belowSheet,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? belowSheet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.extension<AppColors>()!.gold;
    final dark = theme.brightness == Brightness.dark;
    final canPop = Navigator.of(context).canPop();
    final landscape = context.isLandscape;

    final header = Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + (landscape ? 8 : 12),
        16,
        landscape ? 24 : 50,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF1A1D2E), Color(0xFF2A2F4D)]
              : const [AppColors.blackColor, Color(0xFF1C3190)],
        ),
        borderRadius: landscape
            ? BorderRadius.zero
            : const BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Column(
        mainAxisAlignment: landscape ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (canPop)
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: CircleBackButton( ),
            ),
          SizedBox(height: landscape ? 4 : 8),
          Container(
            width: landscape ? 48 : 62,
            height: landscape ? 48 : 62,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: gold, width: 2),
            ),
            child: Text(
              'Z',
              style: TextStyle(
                color: gold,
                fontSize: landscape ? 22 : 28,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: 10),
            Text(
              title!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFCDD3F0), fontSize: 12),
            ),
          ],
        ],
      ),
    );

    final sheet = ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Material(
          color: theme.colorScheme.surface,
          elevation: 12,
          shadowColor: AppColors.blackColor.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: child,
          ),
        ),
        if (belowSheet != null) ...[
          const SizedBox(height: 16),
          belowSheet!,
        ],
      ],
    );

    if (landscape) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(flex: 9, child: header),
            Expanded(flex: 11, child: SafeArea(child: sheet)),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          header,
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -34),
              child: sheet,
            ),
          ),
        ],
      ),
    );
  }
}
