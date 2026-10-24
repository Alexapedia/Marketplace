part of 'forget_password_cubit.dart';

enum ForgetPasswordStep { email, reset }

class ForgetPasswordState extends Equatable {
  const ForgetPasswordState({
    this.status = RequestStatus.init,
    this.step = ForgetPasswordStep.email,
    this.done = false,
  });
  final RequestStatus status;
  final ForgetPasswordStep step;

  /// True once the password was reset; the view navigates back to sign in.
  final bool done;

  @override
  List<Object> get props => [status, step, done];

  ForgetPasswordState copyWith({
    RequestStatus? status,
    ForgetPasswordStep? step,
    bool? done,
  }) => ForgetPasswordState(
    status: status ?? this.status,
    step: step ?? this.step,
    done: done ?? this.done,
  );
}
