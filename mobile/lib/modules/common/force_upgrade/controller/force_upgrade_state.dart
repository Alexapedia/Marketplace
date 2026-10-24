part of 'force_upgrade_cubit.dart';

class ForceUpgradeState extends Equatable {
  const ForceUpgradeState({required this.version});

  final AppVersionModel version;

  @override
  List<Object> get props => [version];
}
