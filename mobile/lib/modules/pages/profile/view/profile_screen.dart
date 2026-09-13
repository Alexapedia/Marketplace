import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/models/color_model.dart';
import '../../../../core/utils/functions/log_out_function.dart';
import '../../../../core/utils/functions/require_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('profile'.tr())),
      body: BlocBuilder<AppControllerCubit, AppControllerState>(
        builder: (context, state) {
          final guest = state.isGuest;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: Theme.of(context)
                      .extension<AppColors>()!
                      .brandGradient,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        guest ? Icons.person_outline : Icons.person,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guest
                                ? 'hello_guest'.tr()
                                : (state.user?.name.isNotEmpty == true
                                    ? state.user!.name
                                    : 'welcome'.tr()),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          if (!guest && state.user != null)
                            Text(
                              state.user!.email,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (guest) ...[
                const SizedBox(height: 16),
                Text('guest_profile_title'.tr(), style: const TextStyle(fontWeight: FontWeight.w800)),
                Text('guest_profile_body'.tr()),
                const SizedBox(height: 12),
                AppButton(
                  onTap: () => context.pushNamed(AppRouterKeys.signIn),
                  title: 'login'.tr(),
                ),
                const SizedBox(height: 8),
                AppButton(
                  onTap: () => context.pushNamed(AppRouterKeys.signUp),
                  title: 'register'.tr(),
                  isOutlined: true,
                ),
              ],
              const SizedBox(height: 24),
              Text('settings'.tr(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 8),
              _tile(
                context,
                Icons.language,
                'language'.tr(),
                trailing: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'en', label: Text('english'.tr())),
                    ButtonSegment(value: 'ar', label: Text('arabic'.tr())),
                  ],
                  selected: {context.locale.languageCode},
                  onSelectionChanged: (s) =>
                      context.read<AppControllerCubit>().setLocale(context, s.first),
                ),
              ),
              _tile(
                context,
                Icons.brightness_6_outlined,
                'theme'.tr(),
                trailing: DropdownButton<ThemeMode>(
                  value: state.themeMode,
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('theme_system'.tr())),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('theme_light'.tr())),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('theme_dark'.tr())),
                  ],
                  onChanged: (m) {
                    if (m != null) context.read<AppControllerCubit>().setTheme(m);
                  },
                ),
              ),
              if (!guest) ...[
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: Text('my_orders'.tr()),
                  onTap: () => context.pushNamed(AppRouterKeys.myOrdersScreen),
                ),
                ListTile(
                  leading: const Icon(Icons.auto_awesome),
                  title: Text('custom_orders'.tr()),
                  onTap: () => requireAuth(
                    context,
                    () => context.pushNamed(AppRouterKeys.customOrder),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_none),
                  title: Text('notifications'.tr()),
                  onTap: () => context.pushNamed(AppRouterKeys.notificationScreen),
                ),
                const SizedBox(height: 12),
                AppButton(
                  onTap: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('logout'.tr()),
                        content: Text('logout_confirm'.tr()),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('cancel'.tr())),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('logout'.tr())),
                        ],
                      ),
                    );
                    if (ok == true) await logOut(isUseLogoutApi: true);
                  },
                  title: 'logout'.tr(),
                  isOutlined: true,
                ),
              ],
              const SizedBox(height: 24),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snap) {
                  final v = snap.data?.version ?? '1.0.0';
                  return Center(child: Text('${'version'.tr()} $v'));
                },
              ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, {required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
          Flexible(child: trailing),
        ],
      ),
    );
  }
}
