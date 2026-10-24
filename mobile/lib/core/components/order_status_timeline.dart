import 'package:flutter/material.dart';

import '../../config/theme/maison.dart';
import '../../config/theme/tokens.dart';
import '../utils/functions/motion.dart';

/// Order journey as a vertical list: a dot per step on one rail, the label
/// beside it. Every step stays readable on a phone, however many there are.
/// A cancelled or rejected order shows the steps it [reached], then the
/// failure.
class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({
    super.key,
    required this.status,
    required this.steps,
    required this.labelOf,
    this.reached = const [],
  });

  final String status;
  final List<String> steps;
  final String Function(String) labelOf;

  /// Statuses the order went through (its history); used for failed orders.
  final List<String> reached;

  bool get _failed => status == 'rejected' || status == 'cancelled';

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final rows = <_StepData>[];
    if (_failed) {
      for (final s in steps) {
        if (reached.contains(s)) rows.add(_StepData(s, _StepState.done));
      }
      rows.add(_StepData(status, _StepState.failed));
    } else {
      final idx = steps.indexOf(status);
      for (var i = 0; i < steps.length; i++) {
        rows.add(
          _StepData(
            steps[i],
            i < idx
                ? _StepState.done
                : i == idx
                ? _StepState.current
                : _StepState.upcoming,
          ),
        );
      }
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: m.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: m.line),
        boxShadow: AppShadows.one(m.brightness),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            _Step(
              label: labelOf(rows[i].status),
              state: rows[i].state,
              first: i == 0,
              last: i == rows.length - 1,
              // The rail into this dot is lit once this step is reached.
              railInLit: rows[i].state != _StepState.upcoming,
            ),
        ],
      ),
    );
  }
}

enum _StepState { done, current, upcoming, failed }

class _StepData {
  const _StepData(this.status, this.state);
  final String status;
  final _StepState state;
}

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.state,
    required this.first,
    required this.last,
    required this.railInLit,
  });

  final String label;
  final _StepState state;
  final bool first;
  final bool last;
  final bool railInLit;

  static const double _dot = 24;
  static const double _gap = 14;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final failed = state == _StepState.failed;
    final current = state == _StepState.current;
    final done = state == _StepState.done;
    final reachedState = failed || current || done;
    final fill = failed
        ? m.danger
        : reachedState
        ? m.accentFill
        : m.surface;
    final onFill = failed ? Maison.onColor(m.danger) : m.onAccentFill;
    final border = failed
        ? m.danger
        : reachedState
        ? m.accentFill
        : m.line;
    Widget rail(bool lit) => Expanded(
      child: Center(
        child: AnimatedContainer(
          duration: context.motion(AppDurations.base),
          width: 2,
          color: lit ? m.accentFill : m.line,
        ),
      ),
    );
    return Semantics(
      label: label,
      selected: current,
      child: ExcludeSemantics(
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: _dot,
                child: Column(
                  children: [
                    if (first)
                      const SizedBox(height: _gap / 2)
                    else
                      SizedBox(
                        height: _gap / 2,
                        child: Row(children: [rail(railInLit)]),
                      ),
                    AnimatedContainer(
                      key: const ValueKey('timeline-dot'),
                      duration: context.motion(AppDurations.base),
                      curve: AppCurves.easeOut,
                      width: _dot,
                      height: _dot,
                      decoration: BoxDecoration(
                        color: fill,
                        shape: BoxShape.circle,
                        border: Border.all(color: border, width: 1.5),
                        boxShadow: current
                            ? [
                                BoxShadow(
                                  color: m.accentFill.withValues(alpha: 0.35),
                                  spreadRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                      child: failed || done
                          ? Icon(
                              failed
                                  ? Icons.close_rounded
                                  : Icons.check_rounded,
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
                    if (last) const SizedBox(height: _gap / 2) else rail(done),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: _gap / 2),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: _dot),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.3,
                          fontWeight: current || failed
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: failed
                              ? m.danger
                              : reachedState
                              ? m.ink
                              : m.inkMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
