import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/service_locator.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit() : super(const EditProfileState());

  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();

  void load(BuildContext context) {
    final user = AppControllerCubit.get(context).state.user;
    name.text = user?.name ?? '';
    phone.text = user?.phone ?? '';
    email.text = user?.email ?? '';
    emit(state.copyWith(avatar: user?.avatar ?? ''));
  }

  Future<void> pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1200,
    );
    if (picked == null) return;
    emit(state.copyWith(status: RequestStatus.loading));
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(picked.path, filename: picked.name),
    });
    final response = await sl.get<ApiConsumer>().post(
      EndPoints.uploads,
      body: form,
    );
    response.fold(
      (l) {
        AppToast(l, isError: true);
        emit(state.copyWith(status: RequestStatus.loaded));
      },
      (s) {
        final url = asString(asMap(unwrapData(s.response))['url']);
        emit(state.copyWith(status: RequestStatus.loaded, avatar: url));
      },
    );
  }

  Future<void> save(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    emit(state.copyWith(status: RequestStatus.loading));
    final response = await sl.get<ApiConsumer>().patch(
      EndPoints.me,
      body: {
        'name': name.text.trim(),
        'phone': phone.text.trim(),
        if (state.avatar.isNotEmpty) 'avatar': state.avatar,
      },
    );
    await response.fold(
      (l) async {
        AppToast(l, isError: true);
        emit(state.copyWith(status: RequestStatus.loaded));
      },
      (_) async {
        AppToast('profile_updated');
        await AppControllerCubit.get(context).loadMe();
        emit(state.copyWith(status: RequestStatus.loaded, saved: true));
      },
    );
  }

  @override
  Future<void> close() {
    name.dispose();
    phone.dispose();
    email.dispose();
    return super.close();
  }
}
