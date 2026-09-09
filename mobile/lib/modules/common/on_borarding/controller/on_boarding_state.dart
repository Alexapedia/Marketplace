part of 'on_boarding_bloc.dart';

class OnBoardingState extends Equatable {
  const OnBoardingState({this.selectedPage = 0, this.tick = 0});
  final int selectedPage;
  final int tick;
  @override
  List<Object> get props => [selectedPage, tick];
  OnBoardingState copyWith({int? selectedPage, int? tick}) => OnBoardingState(
    selectedPage: selectedPage ?? this.selectedPage,
    tick: tick ?? this.tick,
  );
}
