import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Future<bool> get hasConnection;
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}
