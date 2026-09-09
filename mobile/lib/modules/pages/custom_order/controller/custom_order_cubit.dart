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

class CustomOrderCubit extends Cubit<CustomOrderState> {
  CustomOrderCubit() : super(const CustomOrderState());

  final desc = TextEditingController();
  final Map<String, TextEditingController> fieldCtrls = {};

  Future<void> loadCategories() async {
    emit(state.copyWith(status: RequestStatus.loading));
    final cats = await sl.get<ApiConsumer>().get(EndPoints.categories);
    cats.fold(
      (l) => emit(state.copyWith(status: RequestStatus.failed, error: l)),
      (s) {
        final data = unwrapData(s.response);
        emit(
          state.copyWith(
            status: RequestStatus.loaded,
            categories: asList(data is List ? data : asMap(data)['items'])
                .map(CategoryModel.fromJson)
                .toList(),
          ),
        );
      },
    );
  }

  Future<void> selectCategory(String id) async {
    emit(state.copyWith(categoryId: id));
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
        fieldCtrls[f.name] = TextEditingController();
      }
      emit(state.copyWith(fields: fields));
    });
  }

  Future<void> pickImages() async {
    final files = await ImagePicker().pickMultiImage(imageQuality: 80);
    if (files.isEmpty) return;
    emit(state.copyWith(images: [...state.images, ...files.map((e) => e.path)]));
  }

  Future<void> submit(BuildContext context) async {
    if (state.categoryId.isEmpty) {
      AppToast('pick_category'.tr(), isError: true);
      return;
    }
    emit(state.copyWith(submitStatus: RequestStatus.loading));
    final map = <String, dynamic>{
      'categoryId': state.categoryId,
      'description': desc.text.trim(),
    };
    for (final f in state.fields) {
      map[f.name] = fieldCtrls[f.name]?.text ?? '';
    }
    final form = FormData.fromMap({
      ...map,
      'fields': map,
    });
    for (final path in state.images) {
      form.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(path, filename: path.split('/').last),
        ),
      );
    }
    final response = await sl.get<ApiConsumer>().post(
      EndPoints.customOrders,
      body: form,
    );
    response.fold(
      (l) {
        AppToast(l, isError: true);
        emit(state.copyWith(submitStatus: RequestStatus.failed));
      },
      (s) {
        AppToast('custom_order_submitted');
        emit(state.copyWith(submitStatus: RequestStatus.loaded));
        final created = CustomOrderModel.fromJson(s.response);
        if (context.mounted) {
          RouterHandler.navigate(
            context,
            AppRouterKeys.customOrderDetails,
            extra: created.id,
            routerType: RouterType.goName,
          );
        }
      },
    );
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

class CustomOrderDetailsCubit extends Cubit<CustomOrderDetailsState> {
  CustomOrderDetailsCubit() : super(const CustomOrderDetailsState());

  Future<void> load(String id) async {
    emit(state.copyWith(status: RequestStatus.loading));
    final response = await sl.get<ApiConsumer>().get(EndPoints.customOrder(id));
    response.fold(
      (l) => emit(state.copyWith(status: RequestStatus.failed, error: l)),
      (s) => emit(
        state.copyWith(
          status: RequestStatus.loaded,
          order: CustomOrderModel.fromJson(s.response),
        ),
      ),
    );
  }

  Future<void> confirm(String orderId, String proposalId) async {
    final response = await sl.get<ApiConsumer>().post(
      EndPoints.confirmCustomOrder(orderId),
      body: {'proposalId': proposalId},
    );
    response.fold((l) => AppToast(l, isError: true), (_) => load(orderId));
  }

  Future<void> reject(String orderId, String proposalId, String reason) async {
    final response = await sl.get<ApiConsumer>().post(
      EndPoints.rejectCustomOrder(orderId),
      body: {'proposalId': proposalId, 'reason': reason},
    );
    response.fold((l) => AppToast(l, isError: true), (_) => load(orderId));
  }
}
