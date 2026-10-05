import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/log_out_function.dart';
import '../../../../core/utils/functions/service_locator.dart';

part 'profile_state.dart';
part 'profile_account_mixin.dart';

class ProfileCubit extends Cubit<ProfileState> with ProfileAccountMixin {
  ProfileCubit() : super(const ProfileState());
}
