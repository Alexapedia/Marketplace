import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/connection/concept/end_points.dart';
import '../../core/connection/interfaces/api_consumer.dart';
import '../../core/models/app_models.dart';
import '../../core/repository/push/push_notification_service.dart';
import '../../core/utils/constant/app_enum.dart';
import '../../core/utils/constant/storage_key.dart';
import '../../core/utils/functions/app_toast.dart';
import '../../core/utils/functions/bloc_observer.dart';
import '../../core/utils/functions/handle_multi_callback.dart';
import '../../core/utils/functions/json_helpers.dart';
import '../../core/utils/functions/require_auth.dart';
import '../../core/utils/functions/service_locator.dart';
import '../../core/utils/functions/shared_preferance_utils.dart';

part 'app_controller_state.dart';

class AppControllerCubit extends Cubit<AppControllerState> {
  AppControllerCubit() : super(const AppControllerState());

  static AppControllerCubit get(context) => BlocProvider.of(context);

  Future<void> initServices() async {
    if (kDebugMode) {
      Bloc.observer = MyBlocObserver();
    }
    _loadTheme();
    await loadSession();
    await loadConfig();
    unawaited(trackVisit());
    PushNotificationService.instance.consumePending();
  }

  Future<void> trackVisit() async {
    var session = PreferenceUtils.getString(StorageKey.analyticsSession);
    if (session.isEmpty) {
      session = DateTime.now().microsecondsSinceEpoch.toString();
      await PreferenceUtils.setString(StorageKey.analyticsSession, session);
    }
    await sl.get<ApiConsumer>().post(
      EndPoints.analyticsVisit,
      body: {
        'platform': 'mobile',
        'path': '/',
        'sessionId': session,
      },
    );
  }

  Future<void> loadSession() async {
    final token = await sl.get<HandleMultiCallLocal>().getLocalData(
      keyType: LocalEnumKey.accessToken,
    );
    if (token != null && token.isNotEmpty) {
      emit(state.copyWith(isGuest: false));
      await PreferenceUtils.setBool(StorageKey.isGuestMode, false);
      await loadMe();
      await getCountOfCartItems();
      await getCountOfUnReadNot();
      await loadFavorites();
      await PushNotificationService.instance.registerToken();
    } else {
      emit(state.copyWith(isGuest: true, favoriteIds: const [], favoritesReady: true));
    }
  }

  Future<void> enterGuestMode() async {
    await PreferenceUtils.setBool(StorageKey.isGuestMode, true);
    emit(
      state.copyWith(
        isGuest: true,
        cartItemsCount: 0,
        countOfUnReadNot: 0,
        favoriteIds: const [],
        favoritesReady: true,
      ),
    );
  }

  Future<void> exitGuestMode() async {
    await PreferenceUtils.setBool(StorageKey.isGuestMode, false);
    emit(state.copyWith(isGuest: false));
    await loadMe();
    await getCountOfCartItems();
    await getCountOfUnReadNot();
    await loadFavorites();
  }

  void _loadTheme() {
    final saved = PreferenceUtils.getString(
      StorageKey.themeMode,
      StorageKey.themeModeSystem,
    );
    final themeMode = switch (saved) {
      StorageKey.themeModeDark => ThemeMode.dark,
      StorageKey.themeModeLight => ThemeMode.light,
      _ => ThemeMode.system,
    };
    final lang = PreferenceUtils.getString(StorageKey.lang, 'en');
    emit(
      state.copyWith(
        themeMode: themeMode,
        localeCode: lang.isEmpty ? 'en' : lang,
      ),
    );
  }

  void setTheme(ThemeMode mode) {
    final key = switch (mode) {
      ThemeMode.dark => StorageKey.themeModeDark,
      ThemeMode.light => StorageKey.themeModeLight,
      ThemeMode.system => StorageKey.themeModeSystem,
    };
    PreferenceUtils.setString(StorageKey.themeMode, key);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setLocale(BuildContext context, String lang) async {
    await PreferenceUtils.setString(StorageKey.lang, lang);
    if (context.mounted) {
      await context.setLocale(Locale(lang));
    }
    emit(state.copyWith(localeCode: lang));
  }

  Future<void> loadConfig() async {
    final response = await sl.get<ApiConsumer>().get(EndPoints.appConfig);
    response.fold((_) {}, (success) {
      final settings = AppConfigModel.fromJson(success.response).settings;
      emit(
        state.copyWith(
          supportEmail: asString(settings['supportEmail']),
          supportPhone: asString(settings['supportPhone']),
          currency: asString(settings['currency']).toUpperCase().isEmpty
              ? 'SAR'
              : asString(settings['currency']).toUpperCase(),
        ),
      );
    });
  }

  Future<void> loadMe() async {
    if (state.isGuest) return;
    final response = await sl.get<ApiConsumer>().get(EndPoints.me);
    response.fold((_) {}, (success) {
      emit(state.copyWith(user: UserModel.fromJson(success.response)));
    });
  }

  Future<void> getCountOfCartItems() async {
    if (state.isGuest) return;
    final response = await sl.get<ApiConsumer>().get(EndPoints.cart);
    response.fold((_) {}, (success) {
      final data = unwrapData(success.response);
      final items = asList(asMap(data)['items']);
      emit(state.copyWith(cartItemsCount: items.length));
    });
  }

  Future<void> getCountOfUnReadNot() async {
    if (state.isGuest) return;
    final response = await sl.get<ApiConsumer>().get(EndPoints.notifications);
    response.fold((_) {}, (success) {
      final data = unwrapData(success.response);
      final list = data is List ? data : asList(asMap(data)['items'] ?? data);
      final unread = list
          .where((e) => !asBool(asMap(e)['isRead'] ?? asMap(e)['read']))
          .length;
      emit(state.copyWith(countOfUnReadNot: unread));
    });
  }

  void resetCountOfUnReadNot({int count = 0}) {
    emit(state.copyWith(countOfUnReadNot: count));
  }

  Future<void> addToCart(
    BuildContext context, {
    required String productId,
    String? variant,
    String? size,
    int quantity = 1,
  }) async {
    requireAuth(context, () async {
      emit(state.copyWith(addCartStatus: RequestStatus.loading));
      final response = await sl.get<ApiConsumer>().post(
        EndPoints.cartItems,
        body: {
          'productId': productId,
          if (variant != null) 'variant': variant,
          if (size != null) 'size': size,
          'quantity': quantity,
        },
      );
      response.fold(
        (failed) {
          AppToast(failed, isError: true);
          emit(state.copyWith(addCartStatus: RequestStatus.failed));
        },
        (_) {
          AppToast('added_to_cart');
          emit(state.copyWith(addCartStatus: RequestStatus.loaded));
          getCountOfCartItems();
        },
      );
    });
  }

  Future<void> loadFavorites() async {
    if (state.isGuest) {
      emit(state.copyWith(favoriteIds: const [], favoritesReady: true));
      return;
    }
    final response = await sl.get<ApiConsumer>().get(EndPoints.favorites);
    response.fold(
      (_) => emit(state.copyWith(favoritesReady: true)),
      (success) {
        emit(
          state.copyWith(
            favoriteIds: _idsFromFavorites(success.response),
            favoritesReady: true,
          ),
        );
      },
    );
  }

  Future<void> toggleFavorite(BuildContext context, String productId) async {
    requireAuth(context, () async {
      if (productId.isEmpty) return;
      final wasFav = state.favoriteIds.contains(productId);
      final original = List<String>.from(state.favoriteIds);
      final next = List<String>.from(state.favoriteIds);
      if (wasFav) {
        next.remove(productId);
      } else if (!next.contains(productId)) {
        next.add(productId);
      }
      emit(state.copyWith(favoriteIds: next, favoritesReady: true));
      final response = wasFav
          ? await sl.get<ApiConsumer>().delete(EndPoints.favorite(productId))
          : await sl.get<ApiConsumer>().post(
              EndPoints.favorites,
              body: {'productId': productId},
            );
      response.fold(
        (failed) {
          emit(state.copyWith(favoriteIds: original));
          AppToast(failed, isError: true);
        },
        (_) => AppToast(wasFav ? 'removed_from_favorites' : 'added_to_favorites'),
      );
    });
  }
}

List<String> _idsFromFavorites(dynamic raw) {
  final data = unwrapData(raw);
  final list = asList(data is List ? data : asMap(data)['items']);
  final ids = <String>[];
  for (final e in list) {
    final map = asMap(e);
    var id = '';
    final productId = map['productId'];
    if (productId is Map) {
      id = asString(productId['_id'] ?? productId['id']);
    } else {
      id = asString(productId);
    }
    if (id.isEmpty && map['product'] is Map) {
      final product = asMap(map['product']);
      id = asString(product['_id'] ?? product['id']);
    }
    if (id.isNotEmpty) ids.add(id);
  }
  return ids;
}
