import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constant/app_enum.dart';
import 'app_toast.dart';
import 'fetch_page.dart';
import 'safe_emit.dart';

class PagedState<T> extends Equatable {
  const PagedState({
    this.status = RequestStatus.init,
    this.items = const [],
    this.error = '',
    this.page = 1,
    this.hasMore = false,
    this.loadingMore = false,
  });
  final RequestStatus status;
  final List<T> items;
  final String error;
  final int page;
  final bool hasMore;
  final bool loadingMore;

  @override
  List<Object?> get props => [status, items, error, page, hasMore, loadingMore];

  PagedState<T> copyWith({
    RequestStatus? status,
    List<T>? items,
    String? error,
    int? page,
    bool? hasMore,
    bool? loadingMore,
  }) =>
      PagedState<T>(
        status: status ?? this.status,
        items: items ?? this.items,
        error: error ?? this.error,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

/// Cubit for a paginated `{ data, meta }` endpoint with refresh + load more.
abstract class PagedCubit<T> extends Cubit<PagedState<T>> with SafeEmitMixin<PagedState<T>> {
  PagedCubit() : super(PagedState<T>());

  String get path;
  T parse(dynamic json);
  Map<String, dynamic> get query => const {};

  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(status: RequestStatus.loading));
    final response = await fetchPage(path, page: 1, parse: parse, query: query);
    if (isClosed) return;
    response.fold(
      (l) => silent
          ? AppToast(l, isError: true)
          : emit(state.copyWith(status: RequestStatus.failed, error: l)),
      (r) => emit(state.copyWith(
        status: RequestStatus.loaded,
        items: r.items,
        page: 1,
        hasMore: r.hasMore,
      )),
    );
  }

  Future<void> refresh() => load(silent: state.status == RequestStatus.loaded);

  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore || state.status != RequestStatus.loaded) return;
    emit(state.copyWith(loadingMore: true));
    final next = state.page + 1;
    final response = await fetchPage(path, page: next, parse: parse, query: query);
    if (isClosed) return;
    response.fold(
      (l) {
        AppToast(l, isError: true);
        emit(state.copyWith(loadingMore: false));
      },
      (r) => emit(state.copyWith(
        items: [...state.items, ...r.items],
        page: next,
        hasMore: r.hasMore,
        loadingMore: false,
      )),
    );
  }
}
