part of 'login_cubit.dart';

class LoginState extends Equatable {
  const LoginState({
    this.loginStatus = RequestStatus.init,
    this.isShowPassword = true,
  });

  final RequestStatus loginStatus;
  final bool isShowPassword;

  @override
  List<Object> get props => [loginStatus, isShowPassword];

  LoginState copyWith({RequestStatus? loginStatus, bool? isShowPassword}) =>
      LoginState(
        loginStatus: loginStatus ?? this.loginStatus,
        isShowPassword: isShowPassword ?? this.isShowPassword,
      );
}
