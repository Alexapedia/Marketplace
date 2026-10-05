import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/components/loading_item.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../../../../core/utils/functions/responsive.dart';
import '../../controller/product_details_cubit.dart';
import 'product_portrait_view.dart';
import 'product_split_view.dart';

class ProductDetailsBody extends StatelessWidget {
  const ProductDetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
      builder: (context, state) {
        if (state.status == RequestStatus.loading ||
            state.status == RequestStatus.init) {
          return const Scaffold(body: LoadingItem());
        }
        if (state.status == RequestStatus.failed || state.product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: FailedShape(
              msg: state.error,
              onTapRefresh: () =>
                  context.read<ProductDetailsCubit>().load(state.productId),
            ),
          );
        }
        final product = state.product!;
        if (context.useNavRail) {
          return ProductSplitView(product: product, state: state);
        }
        return ProductPortraitView(product: product, state: state);
      },
    );
  }
}
