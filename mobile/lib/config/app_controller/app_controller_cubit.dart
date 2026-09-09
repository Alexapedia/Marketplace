import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/connection/concept/end_points.dart';
import '../../core/connection/interfaces/api_consumer.dart';
import '../../core/models/app_models.dart';
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
    } else {
      emit(state.copyWith(isGuest: true));
    }
  }

  Future<void> enterGuestMode() async {
    await PreferenceUtils.setBool(StorageKey.isGuestMode, true);
    emit(state.copyWith(isGuest: true, cartItemsCount: 0, countOfUnReadNot: 0));
  }

  Future<void> exitGuestMode() async {
    await PreferenceUtils.setBool(StorageKey.isGuestMode, false);
    emit(state.copyWith(isGuest: false));
    await loadMe();
    await getCountOfCartItems();
    await getCountOfUnReadNot();
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
    emit(state.copyWith(themeMode: themeMode));
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

  Future<void> toggleFavorite(BuildContext context, String productId) async {
    requireAuth(context, () async {
      await sl.get<ApiConsumer>().post(EndPoints.favorite(productId), body: {});
    });
  }
}
