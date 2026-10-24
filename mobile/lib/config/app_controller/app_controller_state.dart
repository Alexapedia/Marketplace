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
    this.currency = 'SAR',
    this.brandPrimary = '',
    this.brandAccent = '',
    this.brandLogo = '',
    this.brandLogoDark = '',
    this.brandSplash = '',
    this.brandName = '',
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
  final String currency;

  /// Tenant brand colors as #RRGGBB ('' = app defaults).
  final String brandPrimary;
  final String brandAccent;

  /// Tenant logo URLs from the app config ('' = bundled logo).
  final String brandLogo;
  final String brandLogoDark;

  /// Tenant splash image URL from the app config ('' = built-in splash).
  final String brandSplash;

  /// Store display name from the app config ('' = bundled `app_name`).
  final String brandName;

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
    currency,
    brandPrimary,
    brandAccent,
    brandLogo,
    brandLogoDark,
    brandSplash,
    brandName,
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
    String? currency,
    String? brandPrimary,
    String? brandAccent,
    String? brandLogo,
    String? brandLogoDark,
    String? brandSplash,
    String? brandName,
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
    currency: currency ?? this.currency,
    brandPrimary: brandPrimary ?? this.brandPrimary,
    brandAccent: brandAccent ?? this.brandAccent,
    brandLogo: brandLogo ?? this.brandLogo,
    brandLogoDark: brandLogoDark ?? this.brandLogoDark,
    brandSplash: brandSplash ?? this.brandSplash,
    brandName: brandName ?? this.brandName,
  );
}
