import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../core/components/image_item.dart';
import '../../../../../core/models/color_model.dart';

class ProductGallery extends StatefulWidget {
  const ProductGallery({
    super.key,
    required this.images,
    this.showThumbs = false,
  });

  final List<String> images;
  final bool showThumbs;

  @override
  State<ProductGallery> createState() => ProductGalleryState();
}

class ProductGalleryState extends State<ProductGallery> {
  final controller = PageController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(backgroundColor: Colors.black),
              body: PhotoViewGallery.builder(
                itemCount: widget.images.length,
                builder: (context, i) => PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(widget.images[i]),
                  minScale: PhotoViewComputedScale.contained,
                ),
              ),
            ),
          ),
        );
      },
      child: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: widget.images.length,
            itemBuilder: (context, i) =>
                ImageItem(widget.images[i], fit: BoxFit.cover),
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: widget.showThumbs
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(widget.images.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: GestureDetector(
                              onTap: () => controller.animateToPage(
                                i,
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeOut,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .extension<AppColors>()!
                                          .gold,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ImageItem(
                                    widget.images[i],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      )
                    : SmoothPageIndicator(
                        controller: controller,
                        count: widget.images.length,
                        effect: WormEffect(
                          dotHeight: 7,
                          dotWidth: 7,
                          activeDotColor: Theme.of(
                            context,
                          ).extension<AppColors>()!.gold,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
