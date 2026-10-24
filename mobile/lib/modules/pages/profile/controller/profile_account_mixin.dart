part of 'profile_cubit.dart';

mixin ProfileAccountMixin on Cubit<ProfileState> {
  Future<void> rateApp(double rating, String comment) async {
    emit(state.copyWith(status: RequestStatus.loading));
    final res = await sl.get<ApiConsumer>().post(
      EndPoints.reviews,
      body: {
        'targetType': 'app',
        'rating': rating,
        'comment': comment,
      },
    );
    res.fold(
      (l) {
        AppToast(l, isError: true);
        emit(state.copyWith(status: RequestStatus.failed));
      },
      (_) {
        AppToast('rating_thanks');
        emit(state.copyWith(status: RequestStatus.loaded));
      },
    );
  }

  Future<void> logout() => logOut(isUseLogoutApi: true);

  Future<void> deleteAccount() async {
    emit(state.copyWith(status: RequestStatus.loading));
    final res = await sl.get<ApiConsumer>().delete(EndPoints.deleteAccount);
    await res.fold(
      (l) async {
        AppToast(l, isError: true);
        emit(state.copyWith(status: RequestStatus.failed));
      },
      (_) async {
        AppToast('delete_account_done');
        emit(state.copyWith(status: RequestStatus.loaded));
        await logOut(isUseLogoutApi: false);
      },
    );
  }
}
