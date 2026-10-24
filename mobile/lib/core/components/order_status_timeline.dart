import 'package:flutter/material.dart';

import '../../config/theme/maison.dart';
import '../../config/theme/tokens.dart';
import '../utils/functions/motion.dart';

/// Order journey: connected steps with a progress line that draws up to the
/// current step. Fits the card when there is room, scrolls otherwise (and
/// brings the current step into view).
class OrderStatusTimeline extends StatefulWidget {
  const OrderStatusTimeline({
    super.key,
    required this.status,
    required this.steps,
    required this.labelOf,
  });

  final String status;
  final List<String> steps;
  final String Function(String) labelOf;

  @override
  State<OrderStatusTimeline> createState() => _OrderStatusTimelineState();
}

class _OrderStatusTimelineState extends State<OrderStatusTimeline> {
  static const double _minStep = 76;
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final steps = widget.steps;
    final failedStatus =
        widget.status == 'rejected' || widget.status == 'cancelled';
    final idx = steps.indexOf(widget.status);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 14),
      decoration: BoxDecoration(
        color: m.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: m.line),
        boxShadow: AppShadows.one(m.brightness),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final step = (box.maxWidth / steps.length).clamp(_minStep, 200.0);
          final total = step * steps.length;
          final progress = failedStatus || idx < 0
              ? 0.0
              : (idx / (steps.length - 1)).clamp(0.0, 1.0);
          final rtl = Directionality.of(context) == TextDirection.rtl;
          final track = SizedBox(
            width: total,
            child: Stack(
              children: [
                // Rail (between the first and last dot centres).
                PositionedDirectional(
                  top: 11,
                  start: step / 2,
                  end: step / 2,
                  height: 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: m.line,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 11,
                  start: step / 2,
                  end: step / 2,
                  height: 2,
                  child: LayoutBuilder(
                    builder: (context, rail) => Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AnimatedContainer(
                        duration: context.motion(AppDurations.lavish),
                        curve: AppCurves.easeOut,
                        width: rail.maxWidth * progress,
                        height: 2,
                        decoration: BoxDecoration(
                          color: m.accentFill,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < steps.length; i++)
                      SizedBox(
                        width: step,
                        child: _Step(
                          label: widget.labelOf(steps[i]),
                          done: !failedStatus && idx > i,
                          current: !failedStatus && idx == i,
                          failed: failedStatus && steps[i] == widget.status,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
          if (total <= box.maxWidth + 0.5) return track;
          // Bring the current step into view once laid out.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_scroll.hasClients || idx < 0) return;
            final target = (step * idx - (box.maxWidth - step) / 2).clamp(
              0.0,
              _scroll.position.maxScrollExtent,
            );
            _scroll.jumpTo(rtl ? 0 : target);
          });
          return SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            child: track,
          );
        },
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.done,
    required this.current,
    required this.failed,
  });

  final String label;
  final bool done;
  final bool current;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final fill = failed
        ? m.danger
        : current || done
        ? m.accentFill
        : m.surface;
    final onFill = failed ? Maison.onColor(m.danger) : m.onAccentFill;
    final border = failed
        ? m.danger
        : current || done
        ? m.accentFill
        : m.line;
    return Semantics(
      label: label,
      selected: current,
      child: ExcludeSemantics(
        child: Column(
          children: [
            AnimatedContainer(
              duration: context.motion(AppDurations.base),
              curve: AppCurves.easeOut,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: fill,
                shape: BoxShape.circle,
                border: Border.all(color: border, width: 1.5),
                boxShadow: current
                    ? [
                        BoxShadow(
                          color: m.accentFill.withValues(alpha: 0.35),
                          blurRadius: 0,
                          spreadRadius: 4,
                        ),
                      ]
                    : null,
              ),
              child: failed || done
                  ? Icon(
                      failed ? Icons.close_rounded : Icons.check_rounded,
                      size: 14,
                      color: onFill,
                    )
                  : current
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: m.onAccentFill,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  height: 1.25,
                  fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                  color: current || done || failed ? m.ink : m.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
