part of 'profile_cubit.dart';

class ProfileState extends Equatable {
  const ProfileState({this.status = RequestStatus.init});

  final RequestStatus status;

  @override
  List<Object> get props => [status];

  ProfileState copyWith({RequestStatus? status}) =>
      ProfileState(status: status ?? this.status);
}
