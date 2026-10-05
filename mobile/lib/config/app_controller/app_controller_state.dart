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
    this.favoriteIds = const [],
    this.favoritesReady = false,
    this.supportEmail = '',
    this.supportPhone = '',
  });

  final int countOfUnReadNot;
  final int cartItemsCount;
  final RequestStatus addCartStatus;
  final ThemeMode themeMode;
  final bool isGuest;
  final String localeCode;
  final UserModel? user;
  final List<String> favoriteIds;
  final bool favoritesReady;
  final String supportEmail;
  final String supportPhone;

  bool get isDark => themeMode == ThemeMode.dark;
  bool isFavorite(String productId) => favoriteIds.contains(productId);

  @override
  List<Object?> get props => [
    countOfUnReadNot,
    cartItemsCount,
    addCartStatus,
    themeMode,
    isGuest,
    localeCode,
    user,
    favoriteIds,
    favoritesReady,
    supportEmail,
    supportPhone,
  ];

  AppControllerState copyWith({
    int? countOfUnReadNot,
    int? cartItemsCount,
    RequestStatus? addCartStatus,
    ThemeMode? themeMode,
    bool? isGuest,
    String? localeCode,
    UserModel? user,
    List<String>? favoriteIds,
    bool? favoritesReady,
    String? supportEmail,
    String? supportPhone,
  }) => AppControllerState(
    countOfUnReadNot: countOfUnReadNot ?? this.countOfUnReadNot,
    cartItemsCount: cartItemsCount ?? this.cartItemsCount,
    addCartStatus: addCartStatus ?? this.addCartStatus,
    themeMode: themeMode ?? this.themeMode,
    isGuest: isGuest ?? this.isGuest,
    localeCode: localeCode ?? this.localeCode,
    user: user ?? this.user,
    favoriteIds: favoriteIds ?? this.favoriteIds,
    favoritesReady: favoritesReady ?? this.favoritesReady,
    supportEmail: supportEmail ?? this.supportEmail,
    supportPhone: supportPhone ?? this.supportPhone,
  );
}
