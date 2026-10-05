import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/catalog_models.dart';
import '../../../../core/models/custom_order_models.dart';
import '../../../../core/repository/package_handler/router_handler.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/service_locator.dart';

part 'custom_order_state.dart';
part 'custom_order_submit_mixin.dart';

class CustomOrderCubit extends Cubit<CustomOrderState>
    with CustomOrderSubmitMixin {
  CustomOrderCubit() : super(const CustomOrderState());

  @override
  final desc = TextEditingController();
  @override
  final Map<String, TextEditingController> fieldCtrls = {};

  Future<void> loadCategories() async {
    emit(state.copyWith(status: RequestStatus.loading));
    final cats = await sl.get<ApiConsumer>().get(EndPoints.categories);
    cats.fold(
      (l) => emit(state.copyWith(status: RequestStatus.failed, error: l)),
      (s) {
        final data = unwrapData(s.response);
        final all = asList(data is List ? data : asMap(data)['items'])
            .map(CategoryModel.fromJson)
            .toList();
        final custom = all.where((c) => c.allowsCustom).toList();
        emit(
          state.copyWith(
            status: RequestStatus.loaded,
            categories: custom.isNotEmpty ? custom : all,
          ),
        );
      },
    );
  }

  Future<void> selectCategory(String id) async {
    for (final c in fieldCtrls.values) {
      c.dispose();
    }
    fieldCtrls.clear();
    emit(state.copyWith(categoryId: id, fields: const [], answers: const {}));
    final response = await sl.get<ApiConsumer>().get(
      EndPoints.customFields,
      queryParameters: {'categoryId': id},
    );
    response.fold((_) {}, (s) {
      final data = unwrapData(s.response);
      final fields = asList(data is List ? data : asMap(data)['items'])
          .map(CustomFieldModel.fromJson)
          .toList();
      for (final f in fields) {
        fieldCtrls[f.key] = TextEditingController();
      }
      emit(state.copyWith(fields: fields, answers: const {}));
    });
  }

  void setAnswer(String key, dynamic value) {
    emit(state.copyWith(answers: {...state.answers, key: value}));
  }

  void toggleMulti(String key, String option) {
    final current = List<String>.from((state.answers[key] as List?) ?? const []);
    if (current.contains(option)) {
      current.remove(option);
    } else {
      current.add(option);
    }
    setAnswer(key, current);
  }

  void removeImage(int index) {
    final next = [...state.images]..removeAt(index);
    emit(state.copyWith(images: next));
  }

  Future<void> pickImages() async {
    final files = await ImagePicker().pickMultiImage(imageQuality: 80);
    if (files.isEmpty) return;
    emit(state.copyWith(images: [...state.images, ...files.map((e) => e.path)]));
  }

  @override
  Future<void> close() {
    desc.dispose();
    for (final c in fieldCtrls.values) {
      c.dispose();
    }
    return super.close();
  }
}

