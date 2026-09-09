part of 'navigation_bar_cubit.dart';

class NavigationBarState extends Equatable {
  const NavigationBarState({this.selectedPage = 0});
  final int selectedPage;
  @override
  List<Object> get props => [selectedPage];
  NavigationBarState copyWith({int? selectedPage}) =>
      NavigationBarState(selectedPage: selectedPage ?? this.selectedPage);
}
