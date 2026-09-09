part of 'check_out_cubit.dart';

class CheckOutState extends Equatable {
  const CheckOutState({this.status = RequestStatus.init});
  final RequestStatus status;
  @override
  List<Object> get props => [status];
  CheckOutState copyWith({RequestStatus? status}) =>
      CheckOutState(status: status ?? this.status);
}
