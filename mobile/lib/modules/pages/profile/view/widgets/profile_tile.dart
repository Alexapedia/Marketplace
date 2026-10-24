import 'package:flutter/material.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../core/components/maison.dart';

/// One settings / menu row: tinted icon, title and a trailing control.
/// Pass [onTap] to make the whole row a 56dp-tall tappable target.
class ProfileTile extends StatelessWidget {
  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: m.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: m.accentInk),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: m.ink),
              ),
            ),
            Flexible(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: trailing,
              ),
            ),
          ],
        ),
      ),
    );
    if (onTap == null) return row;
    return Semantics(
      button: true,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

/// Rounded card that groups [ProfileTile] rows with hairline dividers.
class ProfileGroup extends StatelessWidget {
  const ProfileGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    return SurfaceCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(height: 1, indent: 66, endIndent: 0, color: m.line),
            children[i],
          ],
        ],
      ),
    );
  }
}
