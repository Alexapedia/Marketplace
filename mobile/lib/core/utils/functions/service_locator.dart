import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../../config/app_controller/app_controller_cubit.dart';
import '../../connection/implementation/dio_consumer.dart';
import '../../connection/implementation/network_info_impl.dart';
import '../../connection/interfaces/api_consumer.dart';
import '../../connection/interfaces/network_info.dart';
import 'handle_multi_callback.dart';

final sl = GetIt.instance;

Future<void> serviceLocator() async {
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerSingleton<ApiConsumer>(DioConsumer(client: sl<Dio>()));
  sl.registerSingleton<AppControllerCubit>(AppControllerCubit());
  sl.registerSingleton<HandleMultiCallLocal>(HandleMultiCallLocal());
}
