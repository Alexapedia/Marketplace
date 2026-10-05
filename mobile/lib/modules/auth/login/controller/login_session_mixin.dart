part of 'login_cubit.dart';

mixin LoginSessionMixin on Cubit<LoginState> {
  Future<void> persistSession(dynamic json) async {
    final token = extractToken(json);
    final user = UserModel.fromJson(json);
    await sl.get<HandleMultiCallLocal>().saveLocalData(
      data: token,
      keyType: LocalEnumKey.accessToken,
    );
    if (user.id.isNotEmpty) {
      await sl.get<HandleMultiCallLocal>().saveLocalData(
        data: user.id,
        keyType: LocalEnumKey.userId,
      );
    }
    if (user.name.isNotEmpty) {
      await PreferenceUtils.setString(StorageKey.userFullName, user.name);
    }
    if (user.email.isNotEmpty) {
      await PreferenceUtils.setString(StorageKey.userEmail, user.email);
    }
    emit(state.copyWith(loginStatus: RequestStatus.loaded));
    await sl.get<AppControllerCubit>().exitGuestMode();
  }
}
