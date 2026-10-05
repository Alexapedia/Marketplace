import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/app_text_field.dart';
import '../../../../../core/components/circle_back_button.dart';
import '../../../../../core/components/map_picker.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../../../../core/utils/functions/validate.dart';
import '../../controller/address_form_cubit.dart';

class AddressFormBody extends StatelessWidget {
  const AddressFormBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddressFormCubit>();
    return BlocListener<AddressFormCubit, AddressFormState>(
      listenWhen: (p, n) => !p.saved && n.saved,
      listener: (context, state) => context.pop(true),
      child: Scaffold(
        appBar: AppBar(
          leading: const CircleBackButton(),
          title: Text(
            cubit.initial == null ? 'add_address'.tr() : 'edit_address'.tr(),
          ),
        ),
        body: Form(
          key: cubit.formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'tap_map'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              BlocBuilder<AddressFormCubit, AddressFormState>(
                buildWhen: (p, n) => p.lat != n.lat || p.lng != n.lng,
                builder: (context, state) {
                  return MapPicker(
                    lat: state.lat,
                    lng: state.lng,
                    onChanged: (LatLng p) => cubit.setPoint(p),
                  );
                },
              ),
              const SizedBox(height: 16),
              AppTextField(controller: cubit.label, title: 'label'.tr()),
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
              AppTextField(
                controller: cubit.city,
                title: 'city'.tr(),
                validator: (v) => Validate.notEmpty(v ?? ''),
              ),
              AppTextField(
                controller: cubit.street,
                title: 'street'.tr(),
                validator: (v) => Validate.notEmpty(v ?? ''),
              ),
              AppTextField(controller: cubit.notes, title: 'notes'.tr(), maxlines: 2),
              BlocBuilder<AddressFormCubit, AddressFormState>(
                buildWhen: (p, n) => p.isDefault != n.isDefault,
                builder: (context, state) {
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('default_address'.tr()),
                    value: state.isDefault,
                    onChanged: cubit.setDefault,
                  );
                },
              ),
              const SizedBox(height: 12),
              BlocBuilder<AddressFormCubit, AddressFormState>(
                builder: (context, state) {
                  if (state.status == RequestStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return AppButton(onTap: cubit.save, title: 'save'.tr());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
