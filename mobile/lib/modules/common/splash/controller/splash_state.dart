part of 'splash_cubit.dart';

class SplashState extends Equatable {
  const SplashState({this.status = RequestStatus.init});

  final RequestStatus status;

  @override
  List<Object> get props => [status];
}
