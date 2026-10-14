import 'package:flutter/material.dart';

/// Pull-to-refresh + "load more when near the bottom" around a scrollable.
class InfiniteScroll extends StatelessWidget {
  const InfiniteScroll({
    super.key,
    required this.child,
    required this.onRefresh,
    required this.onLoadMore,
  });

  final Widget child;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.axis == Axis.vertical &&
              n.metrics.pixels >= n.metrics.maxScrollExtent - 300) {
            onLoadMore();
          }
          return false;
        },
        child: child,
      ),
    );
  }
}

/// Footer spinner shown while the next page loads.
class LoadMoreFooter extends StatelessWidget {
  const LoadMoreFooter({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
}
