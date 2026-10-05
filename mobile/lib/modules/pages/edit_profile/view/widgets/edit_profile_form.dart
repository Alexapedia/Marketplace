import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/app_text_field.dart';
import '../../../../../core/components/circle_back_button.dart';
import '../../../../../core/components/image_item.dart';
import '../../../../../core/models/color_model.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../../../../core/utils/functions/validate.dart';
import '../../controller/edit_profile_cubit.dart';

class EditProfileForm extends StatelessWidget {
  const EditProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditProfileCubit>();
    final user = AppControllerCubit.get(context).state.user;
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    return BlocListener<EditProfileCubit, EditProfileState>(
      listenWhen: (p, n) => !p.saved && n.saved,
      listener: (context, state) => context.pop(),
      child: Scaffold(
        appBar: AppBar(
          leading: const CircleBackButton(),
          title: Text('edit_profile'.tr()),
        ),
        body: SafeArea(
          child: Form(
            key: cubit.formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.blackColor,
                        child: ClipOval(
                          child: BlocBuilder<EditProfileCubit, EditProfileState>(
                            builder: (context, state) {
                              if (state.avatar.isNotEmpty) {
                                return ImageItem(
                                  state.avatar,
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                );
                              }
                              return Text(
                                (user?.name.isNotEmpty == true
                                        ? user!.name[0]
                                        : 'Z')
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: BlocBuilder<EditProfileCubit, EditProfileState>(
                          builder: (context, state) {
                            return IconButton.filled(
                              style: IconButton.styleFrom(
                                backgroundColor: gold,
                              ),
                              onPressed: state.status == RequestStatus.loading
                                  ? null
                                  : cubit.pickPhoto,
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(child: Text('change_photo'.tr())),
                const SizedBox(height: 20),
                AppTextField(
                  controller: cubit.email,
                  title: 'email'.tr(),
                  isReadOnly: true,
                ),
                AppTextField(
                  controller: cubit.name,
                  title: 'name'.tr(),
                  validator: (v) => Validate.notEmpty(v ?? ''),
                ),
                AppTextField(
                  controller: cubit.phone,
                  title: 'phone'.tr(),
                  textInputType: TextInputType.phone,
                  validator: (v) => Validate.validatePhoneNumber(v),
                ),
                const SizedBox(height: 16),
                BlocBuilder<EditProfileCubit, EditProfileState>(
                  builder: (context, state) {
                    if (state.status == RequestStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return AppButton(
                      onTap: () => cubit.save(context),
                      title: 'save'.tr(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
