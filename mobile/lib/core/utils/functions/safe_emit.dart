import 'package:flutter_bloc/flutter_bloc.dart';

/// Drops state updates that arrive after the cubit was closed, e.g. when a
/// request completes after the user already left the screen.
mixin SafeEmitMixin<S> on BlocBase<S> {
  @override
  void emit(S state) {
    if (isClosed) return;
    super.emit(state);
  }
}
