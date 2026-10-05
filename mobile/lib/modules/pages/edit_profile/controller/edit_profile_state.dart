part of 'edit_profile_cubit.dart';

class EditProfileState extends Equatable {
  const EditProfileState({
    this.status = RequestStatus.init,
    this.avatar = '',
    this.saved = false,
  });

  final RequestStatus status;
  final String avatar;
  final bool saved;

  @override
  List<Object?> get props => [status, avatar, saved];

  EditProfileState copyWith({
    RequestStatus? status,
    String? avatar,
    bool? saved,
  }) =>
      EditProfileState(
        status: status ?? this.status,
        avatar: avatar ?? this.avatar,
        saved: saved ?? this.saved,
      );
}
