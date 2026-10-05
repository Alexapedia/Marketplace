import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdsPagerCubit extends Cubit<int> {
  AdsPagerCubit() : super(0);

  final PageController pageController = PageController(
   );
  Timer? _timer;
  int _itemCount = 0;
  bool _fromAutoScroll = false;
  bool _running = false;

  bool get isRunning => _running;

  void setRunning(bool running) {
    if (_running == running || isClosed) return;
    _running = running;
    _timer?.cancel();
    _timer = null;
    if (!running) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _autoScroll());
  }

  void syncItemCount(int count) {
    _itemCount = count;
  }

  void onPageChanged(int page, {required bool fromUser}) {
    if (!fromUser) {
      _fromAutoScroll = true;
    }
    if (isClosed) return;
    emit(page);
  }

  bool takeUserSwipe() {
    if (_fromAutoScroll) {
      _fromAutoScroll = false;
      return false;
    }
    return true;
  }

  void _autoScroll() {
    if (_itemCount <= 1) return;
    if (isClosed) return;
    if (!pageController.hasClients) return;
    final nextPage = (state + 1) % _itemCount;
    _fromAutoScroll = true;
    pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    pageController.dispose();
    return super.close();
  }
}
