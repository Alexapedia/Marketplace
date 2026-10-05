part of 'custom_order_cubit.dart';

mixin CustomOrderSubmitMixin on Cubit<CustomOrderState> {
  TextEditingController get desc;
  Map<String, TextEditingController> get fieldCtrls;

  Future<void> submit(BuildContext context) async {
    if (state.categoryId.isEmpty) {
      AppToast('pick_category'.tr(), isError: true);
      return;
    }
    emit(state.copyWith(submitStatus: RequestStatus.loading));
    final answers = <String, dynamic>{...state.answers};
    for (final f in state.fields) {
      if (fieldCtrls.containsKey(f.key)) {
        final text = fieldCtrls[f.key]?.text.trim() ?? '';
        if (text.isNotEmpty) answers[f.key] = text;
      }
    }
    final form = FormData.fromMap({
      'categoryId': state.categoryId,
      'description': desc.text.trim(),
      'status': 'submitted',
      'fields': jsonEncode(answers),
    });
    for (final path in state.images) {
      form.files.add(
        MapEntry(
          'attachments',
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
}
