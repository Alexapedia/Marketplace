part of 'forget_password_cubit.dart';

class ForgetPasswordState extends Equatable {
  const ForgetPasswordState({this.status = RequestStatus.init});
  final RequestStatus status;
  @override
  List<Object> get props => [status];
  ForgetPasswordState copyWith({RequestStatus? status}) =>
      ForgetPasswordState(status: status ?? this.status);
}
