part of 'app_controller_cubit.dart';

class AppControllerState extends Equatable {
  const AppControllerState({
    this.countOfUnReadNot = 0,
    this.cartItemsCount = 0,
    this.addCartStatus = RequestStatus.init,
    this.themeMode = ThemeMode.system,
    this.isGuest = true,
    this.localeCode = 'en',
    this.user,
  });

  final int countOfUnReadNot;
  final int cartItemsCount;
  final RequestStatus addCartStatus;
  final ThemeMode themeMode;
  final bool isGuest;
  final String localeCode;
  final UserModel? user;

  bool get isDark => themeMode == ThemeMode.dark;

  @override
  List<Object?> get props => [
    countOfUnReadNot,
    cartItemsCount,
    addCartStatus,
    themeMode,
    isGuest,
    localeCode,
    user,
  ];

  AppControllerState copyWith({
    int? countOfUnReadNot,
    int? cartItemsCount,
    RequestStatus? addCartStatus,
    ThemeMode? themeMode,
    bool? isGuest,
    String? localeCode,
    UserModel? user,
  }) => AppControllerState(
    countOfUnReadNot: countOfUnReadNot ?? this.countOfUnReadNot,
    cartItemsCount: cartItemsCount ?? this.cartItemsCount,
    addCartStatus: addCartStatus ?? this.addCartStatus,
    themeMode: themeMode ?? this.themeMode,
    isGuest: isGuest ?? this.isGuest,
    localeCode: localeCode ?? this.localeCode,
    user: user ?? this.user,
  );
}
