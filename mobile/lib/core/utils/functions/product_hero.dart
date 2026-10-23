/// Shared-element bridge between a product card and the details screen.
///
/// Cards use scoped hero tags (the same product can appear in several rows),
/// and the route only carries the product id, so the card records which tag
/// and image it is flying from right before it navigates. The details screen
/// claims that tag for its first image, including while it is still loading,
/// so the flight has a target on the first frame.
abstract final class ProductHero {
  static final Map<String, ({String tag, String image})> _pending = {};

  static void prime(String productId, String tag, String image) =>
      _pending[productId] = (tag: tag, image: image);

  /// The tag/image the details screen for [productId] should use; stays
  /// stable for that screen's lifetime once claimed.
  static ({String tag, String image}) claim(String productId) =>
      _pending.remove(productId) ?? (tag: 'product-$productId', image: '');
}
