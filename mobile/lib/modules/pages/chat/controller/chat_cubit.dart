import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/custom_order_models.dart';
import '../../../../core/utils/constant/app_enum.dart';

import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/handle_multi_callback.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/service_locator.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatState());

  final text = TextEditingController();

  Future<void> load(String orderId) async {
    emit(state.copyWith(status: RequestStatus.loading, orderId: orderId));
    final myId = await sl.get<HandleMultiCallLocal>().getLocalData(
      keyType: LocalEnumKey.userId,
    );
    final response = await sl.get<ApiConsumer>().get(
      EndPoints.customOrderMessages(orderId),
    );
    response.fold(
      (l) => emit(state.copyWith(status: RequestStatus.failed, error: l)),
      (s) {
        final data = unwrapData(s.response);
        final list = asList(data is List ? data : asMap(data)['items'])
            .map((e) => ChatMessageModel.fromJson(e, myId: myId))
            .toList();
        emit(state.copyWith(status: RequestStatus.loaded, messages: list));
      },
    );
  }

  Future<void> send({String? imagePath}) async {
    final orderId = state.orderId;
    if (orderId.isEmpty) return;
    final bodyText = text.text.trim();
    if (bodyText.isEmpty && imagePath == null) return;
    final form = FormData.fromMap({
      if (bodyText.isNotEmpty) 'text': bodyText,
      'type': imagePath != null ? 'image' : 'text',
    });
    if (imagePath != null) {
      form.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last),
        ),
      );
    }
    text.clear();
    final response = await sl.get<ApiConsumer>().post(
      EndPoints.customOrderMessages(orderId),
      body: form,
    );
    response.fold((l) => AppToast(l, isError: true), (_) => load(orderId));
  }

  Future<void> pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) await send(imagePath: file.path);
  }

  @override
  Future<void> close() {
    text.dispose();
    return super.close();
  }
}
