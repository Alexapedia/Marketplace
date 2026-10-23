import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../core/components/image_item.dart';
import '../../../../../core/connection/concept/end_points.dart';
import '../../../../../core/utils/functions/motion.dart';

class ProductGallery extends StatefulWidget {
  const ProductGallery({
    super.key,
    required this.images,
    this.showThumbs = false,
    this.heroTag = '',
    this.lip = true,
  });

  final List<String> images;
  final bool showThumbs;

  /// Shared-element tag for the first image ('' = none).
  final String heroTag;

  /// Draws the canvas-coloured rounded lip the details sheet rises from.
  final bool lip;

  @override
  State<ProductGallery> createState() => ProductGalleryState();
}

class ProductGalleryState extends State<ProductGallery> {
  final controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _go(int i) {
    if (context.reduceMotion) {
      controller.jumpToPage(i);
    } else {
      controller.animateToPage(
        i,
        duration: AppDurations.base,
        curve: AppCurves.easeOut,
      );
    }
  }

  void _openViewer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: PhotoViewGallery.builder(
            itemCount: widget.images.length,
            pageController: PageController(initialPage: _page),
            builder: (context, i) => PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(EndPoints.media(widget.images[i])),
              minScale: PhotoViewComputedScale.contained,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final many = widget.images.length > 1;
    return Semantics(
      label: 'a11y_open_gallery'.tr(),
      button: true,
      child: GestureDetector(
        onTap: _openViewer,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: m.surface2),
            PageView.builder(
              controller: controller,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => ImageItem(
                widget.images[i],
                fit: BoxFit.cover,
                heroTag: i == 0 && widget.heroTag.isNotEmpty
                    ? widget.heroTag
                    : null,
              ),
            ),
            // Soft top scrim so the glass buttons read on bright photos.
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x33000000), Color(0x00000000)],
                    ),
                  ),
                ),
              ),
            ),
            if (widget.lip)
              Positioned(
                left: 0,
                right: 0,
                bottom: -1,
                height: AppRadius.xxl + 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: m.canvas,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xxl),
                    ),
                  ),
                ),
              ),
            if (many)
              Positioned(
                bottom: widget.lip ? AppRadius.xxl + 14 : 18,
                left: 0,
                right: 0,
                child: Center(
                  child: widget.showThumbs
                      ? _Thumbs(images: widget.images, page: _page, onTap: _go)
                      : _Dots(count: widget.images.length, page: _page),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.page});
  final int count;
  final int page;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0x66000000),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: context.motion(AppDurations.base),
              curve: AppCurves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == page ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == page ? m.accent : const Color(0xB3FFFFFF),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
        ],
      ),
    );
  }
}

class _Thumbs extends StatelessWidget {
  const _Thumbs({
    required this.images,
    required this.page,
    required this.onTap,
  });
  final List<String> images;
  final int page;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: m.glass,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: m.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < images.length; i++)
            Semantics(
              button: true,
              selected: i == page,
              label: 'a11y_go_to_slide'.tr(),
              child: InkWell(
                onTap: () => onTap(i),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: AnimatedContainer(
                    duration: context.motion(AppDurations.fast),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                      border: Border.all(
                        color: i == page ? m.accent : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ImageItem(
                      images[i],
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
