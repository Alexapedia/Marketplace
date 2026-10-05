part of 'login_cubit.dart';

mixin LoginSocialMixin on Cubit<LoginState> {
  Future<void> persistSession(dynamic json);

  Future<void> googleSignIn(BuildContext context) async {
    if (!FirebaseService.initialized) {
      AppToast('google_unavailable'.tr(), isError: true);
      return;
    }
    try {
      emit(state.copyWith(loginStatus: RequestStatus.loading));
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        emit(state.copyWith(loginStatus: RequestStatus.init));
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final idToken = await userCred.user?.getIdToken();
      if (idToken == null) throw Exception('no token');
      if (!context.mounted) return;
      await _firebaseBackend(context, idToken);
    } catch (e) {
      printState(e);
      AppToast('auth_failed'.tr(), isError: true);
      emit(state.copyWith(loginStatus: RequestStatus.failed));
    }
  }

  Future<void> appleSignIn(BuildContext context) async {
    if (!FirebaseService.initialized) {
      AppToast('apple_unavailable'.tr(), isError: true);
      return;
    }
    try {
      emit(state.copyWith(loginStatus: RequestStatus.loading));
      final provider = AppleAuthProvider();
      final userCred = await FirebaseAuth.instance.signInWithProvider(provider);
      final idToken = await userCred.user?.getIdToken();
      if (idToken == null) throw Exception('no token');
      if (!context.mounted) return;
      await _firebaseBackend(context, idToken);
    } catch (e) {
      printState(e);
      AppToast('auth_failed'.tr(), isError: true);
      emit(state.copyWith(loginStatus: RequestStatus.failed));
    }
  }

  Future<void> _firebaseBackend(BuildContext context, String idToken) async {
    final response = await sl.get<ApiConsumer>().auth(
      EndPoints.firebaseAuth,
      body: {'idToken': idToken},
    );
    await response.fold(
      (l) {
        AppToast(l, isError: true);
        emit(state.copyWith(loginStatus: RequestStatus.failed));
      },
      (r) async {
        await persistSession(r.response);
        if (context.mounted) {
          RouterHandler.navigate(
            context,
            AppRouterKeys.navigatorBarScreen,
            routerType: RouterType.goName,
          );
        }
      },
    );
  }
}
