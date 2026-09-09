part of 'register_cubit.dart';

class RegisterState extends Equatable {
  const RegisterState({
    this.status = RequestStatus.init,
    this.isShowPassword = true,
  });
  final RequestStatus status;
  final bool isShowPassword;

  @override
  List<Object> get props => [status, isShowPassword];

  RegisterState copyWith({RequestStatus? status, bool? isShowPassword}) =>
      RegisterState(
        status: status ?? this.status,
        isShowPassword: isShowPassword ?? this.isShowPassword,
      );
}
