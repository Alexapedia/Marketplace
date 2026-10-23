# Mobile UI Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix every issue in the mobile UI audit (findings 1–16) and lift the app to a modern premium look (luxury navy + gold, bilingual typography, glass navigation, purposeful motion) without touching business logic, API calls, models, or routing.

**Architecture:** A token layer (`AppSpacing`, `AppRadius`, `AppDurations`, `AppTypography`, contrast-safe colors) lands first; shared components (`AppButton`, `ProductCard`, nav, states) are rebuilt on it; screens adopt the components. Every visual rule that can be measured (contrast, touch size, semantics, reduced motion) is pinned by a widget/unit test.

**Tech Stack:** Flutter 3.9, Material 3, flutter_bloc, flutter_animate 4.5 and skeletonizer 2 (both already installed), bundled IBM Plex Sans Arabic (OFL font files, no package).

**Spec:** Mobile UI/UX audit (findings 1–16) from this session; design direction from ui-ux-pro-max (`luxury e-commerce perfume watches mobile`): premium dark + gold, standard density, motion 4/10, stagger lists 300–450 ms, reduced-motion respected.

## Global Constraints

- Do NOT change business logic, API calls, data models, routing, or anything under `lib/core/connection`, `lib/core/models`, `lib/config/routing`, `*/controller/*`.
- Keep BLoC, folder structure, and go_router. Keep tenant brand overrides working (`AppColors.fromJson` keys unchanged; new tokens get defaults).
- No new packages. Fonts are bundled TTF assets.
- Touch targets ≥ 48×48 dp. Text ≥ 12 sp. Text contrast ≥ 4.5:1, control boundaries/icons ≥ 3:1, in light and dark.
- Every animation checks `MediaQuery.disableAnimationsOf(context)`.
- All new user-facing strings go in both `assets/translations/en.json` and `ar.json`.
- One problem per commit; commits end with the session attribution trailer.

## Review Focus

- **Arabic (RTL) + largest system text size** → no overflow on product card, nav bar, checkout bar. (Task U5 test pumps `textScaler: TextScaler.linear(1.6)` in `ar`.)
- **Tenant overrides accent to a pale color (e.g. `#F5E6B8`)** → text using the accent still passes 4.5:1 because text uses `goldText`, derived by darkening the accent until it passes. (Task U1)
- **Out-of-stock product / un-checkoutable cart** → button visibly disabled and announced disabled. (Task U2)
- **Reduce-motion enabled** → carousel does not auto-advance, no entrance animations. (Task U7)
- **Screen reader on product card** → card, favorite, and add-to-cart are separate, labeled, actionable nodes. (Task U4)

---

### Task U1: Tokens, contrast-safe colors, typography, theme fixes

**Files:**
- Create: `mobile/lib/config/theme/tokens.dart`, `mobile/lib/core/utils/functions/contrast.dart`, `mobile/assets/fonts/IBMPlexSansArabic-{Regular,Medium,SemiBold,Bold}.ttf`
- Modify: `mobile/pubspec.yaml` (fonts block), `mobile/lib/core/models/color_model.dart`, `mobile/lib/config/theme/light_mode.dart`, `mobile/lib/config/theme/dark_mode.dart`
- Test: `mobile/test/theme/contrast_test.dart`

**Interfaces — Produces:**
- `abstract final class AppSpacing { xxs=4, xs=8, sm=12, md=16, lg=24, xl=32, xxl=48 }` (doubles)
- `abstract final class AppRadius { sm=8, md=12, lg=16, xl=24, pill=999 }` and `BorderRadius` getters `AppRadius.card` (lg), `.input` (md), `.button` (lg), `.sheet` (xl top)
- `abstract final class AppDurations { fast=150ms, base=250ms, slow=400ms }` and `AppCurves.standard = Curves.easeOutCubic`
- `double contrastRatio(Color a, Color b)`; `Color ensureContrast(Color fg, Color bg, {double min = 4.5})` (darkens/lightens `fg` in HSL lightness until it passes)
- New `AppColors` fields with defaults (JSON keys optional): `goldText` (light `#85641F`, dark = `gold`), `inputBorder` (`#767D96` / `#3A3F52`), `navMuted` (`#5B6385` / `#A3A9BF`). `hint` default becomes `#5F6788`, `warning` `#B54300`. `goldText` is recomputed as `ensureContrast(gold, surfaceLight)` when a tenant overrides `gold`.
- `fontFamily: 'IBMPlexSansArabic'` and a full M3 `textTheme` (display→label) with sizes 32/28/24/20/18/16/14/14/12/12 sp, line height 1.4 body / 1.2 titles, in both themes.

Theme fixes in both modes: `appBarTheme.actionsIconTheme` uses `onSurface` (light) instead of gold; focused input border = `colorScheme.primary` 2 px; add `errorBorder`/`focusedErrorBorder` = `colorScheme.error`; input `fillColor` = surface (white) with `enabledBorder` `inputBorder`; set `inverseSurface`/`onInverseSurface` to brand navy/white; `outlinedButtonTheme` border = `primary`.

- [ ] **Step 1: Write failing tests** `contrast_test.dart`:
  - `light goldText on white and background ≥ 4.5`, `dark gold on surfaceDark ≥ 4.5`
  - `inputBorder vs background and vs fill ≥ 3.0`, `hint on surfaceContainerLight ≥ 4.5`, `warning on white ≥ 4.5`
  - `ensureContrast(#F5E6B8 on white) ≥ 4.5`
  - `theme focusedBorder color is colorScheme.primary` and `errorBorder exists` (build `light(AppColors.lightDefaults)`)
- [ ] **Step 2: Run** `cd mobile && flutter test test/theme/contrast_test.dart` → FAIL (symbols missing).
- [ ] **Step 3: Implement** tokens, contrast helpers, color fields, theme changes; download the four OFL TTFs from `https://github.com/google/fonts/tree/main/ofl/ibmplexsansarabic` and declare them.
- [ ] **Step 4: Run** the test file → PASS; `flutter analyze --no-fatal-infos` → no errors; `flutter test` → all pass.
- [ ] **Step 5: Commit** `feat(mobile-ui): add design tokens, contrast-safe colors and bilingual typography`.

### Task U2: AppButton — real disabled & loading states, single tap path

**Files:** Modify `mobile/lib/core/components/app_button.dart`; Test `mobile/test/components/app_button_test.dart`
**Interfaces — Produces:** `AppButton(..., bool isLoading = false)` — additive; existing params unchanged.
- Tests: `tap calls onTap exactly once`; `onTap null renders disabled colors (surfaceContainerHighest bg, onSurface @0.38 label) and Semantics(enabled:false, button:true)`; `isLoading shows a progress indicator, ignores taps, keeps size`; `no fade-in when disableAnimations is true`.
- Implementation: one `InkWell` owns the tap; press-scale driven by `onHighlightChanged`; radius `AppRadius.button`, height 52.
- Commit `fix(mobile-ui): make AppButton disabled and loading states visible and tap once`.

### Task U3: Touch targets and press feedback

**Files:** Modify `core/components/product_card.dart`, `core/components/circle_back_button.dart`, `modules/common/navigation_bar/view/widgets/navbar_btn.dart`, `modules/pages/home/view/widgets/custom_order_cta.dart`, `modules/pages/cart/view/widgets/cart_item_tile.dart`, `modules/pages/product_details/view/widgets/product_qty_add_bar.dart`; Test `mobile/test/components/touch_targets_test.dart`
- Tests (each asserts `tester.getSize(...)` ≥ 48×48 for the hit area): product card favorite, product card add-to-cart, back button, nav item, cart qty ±, product qty ±; `product card shows ink splash on tap` (finds `InkWell`).
- Remove `MaterialTapTargetSize.shrinkWrap`; visual icons may stay small inside a 48 hit box. Nav unselected color = `navMuted`, labels 12 sp.
- Commit `fix(mobile-ui): raise touch targets to 48dp and add press feedback`.

### Task U4: Screen-reader semantics

**Files:** Modify `core/components/app_text_field.dart`, `product_card.dart`, `image_item.dart` (optional `semanticLabel`), `circle_back_button.dart`, `home/view/widgets/cart_btn.dart`, `notif_btn.dart`, `product_details/view/widgets/product_share_button.dart`, `product_favorite_button.dart`, cart/product qty controls; translations; Test `mobile/test/components/semantics_test.dart`
- Tests: `AppTextField exposes its title as the field label` (`find.bySemanticsLabel(title)` resolves to a text field node); `favorite announces "Add to favorites"/"Remove from favorites" and selected state`; `add-to-cart labeled "Add <name> to cart"`; `cart button announces item count`; `qty buttons labeled "Increase quantity"/"Decrease quantity"`.
- `AppTextField`: keep the visual title, wrap field in `Semantics(label: title, textField: true)` (no layout change).
- New keys: `a11y_back`, `a11y_add_to_cart`, `a11y_add_favorite`, `a11y_remove_favorite`, `a11y_cart_items`, `a11y_notifications`, `a11y_increase_qty`, `a11y_decrease_qty`, `a11y_share`.
- Commit `feat(mobile-ui): label icon controls and form fields for screen readers`.

### Task U5: Typography and spacing on shared components

**Files:** Modify every file in the audit's "<12 px" list plus `gold_stepper.dart`, `ad_banner_tile.dart`, `order_status_timeline.dart`, `star_rating.dart`; replace raw `fontSize`/magic gaps in those files with `textTheme` + `AppSpacing`; Test `mobile/test/components/text_scale_test.dart`
- Tests: `no Text under 12sp in ProductCard, NavbarBtn, GoldDotStepper, badges` (walk `RenderParagraph`s, check `text.style.fontSize * textScaleFactor ≥ 12`); `ProductCard and nav bar render in Arabic at TextScaler 1.6 without overflow` (no `FlutterError` overflow).
- `GoldBarStepper`/`GoldDotStepper`: colors from theme (`onPrimary` on brand gradient contexts via a `onDark` param).
- Commit `fix(mobile-ui): enforce 12sp minimum and token spacing in shared components`.

### Task U6: Loading, empty, and error states

**Files:** Modify `core/components/failed_shape.dart`, `home_body.dart`, `products_body.dart`, and the spinner screens (addresses, custom_orders_list, product_details, order_details, custom_order_details, chat) to `Skeletonizer`; add `RefreshIndicator` to cart, addresses, order_details, custom_orders_list; Test `mobile/test/components/states_test.dart`
**Interfaces — Produces:** `FailedShape({required String msg, required VoidCallback onTapRefresh, FailureKind? kind})`, `enum FailureKind { offline, server, generic }`, `FailureKind classifyFailure(String msg)` (offline when msg equals `'no_internet'.tr()` or contains the no-connection copy); `EmptyState` unchanged API.
- Tests: `offline message shows wifi_off icon, server message shows cloud_off, generic shows error_outline`; `retry is a labeled FilledButton.tonal "Try again"`; `products empty with active filters shows "Clear filters" action that calls the existing clear method`; `home failure fills the viewport` (`SliverFillRemaining`).
- Messages: `msg` passed through `.tr()` (keys pass through; raw server text shows as-is).
- Commit per area: `feat(mobile-ui): typed error states`, `feat(mobile-ui): skeleton loading on detail screens`, `feat(mobile-ui): pull to refresh on remaining lists`, `feat(mobile-ui): actionable empty states`.

### Task U7: Motion, carousel, haptics, polish

**Files:** Create `core/utils/functions/motion.dart`; Modify `home/view/widgets/ads_carousel.dart` (+ `ads_pager_cubit.dart` only for a `pause()/resume()` that already maps to `setRunning` — no logic change), `app_button.dart`, `image_item.dart`, `cart_summary.dart`, `proposal_card.dart`, `core/utils/functions/app_toast.dart`; Test `mobile/test/components/motion_test.dart`
**Interfaces — Produces:** `extension MotionContext on BuildContext { bool get reduceMotion; Duration motion(Duration d); }`
- Tests: `carousel does not auto-advance when reduceMotion`; `carousel dots are tappable 48dp targets that jump to the page`; `tapping the carousel pauses auto-advance and announces state`; `ImageItem placeholder animates (shimmer) and passes memCacheWidth`; `no emoji in cart summary`.
- Haptics: `HapticFeedback.selectionClick()` on favorite and add-to-cart taps (view layer).
- `AppToast` uses theme snackbar colors; optional `actionLabel`/`onAction`.
- Commit per concern.

### Task U8: Premium visual layer

**Files:** Modify `navigation_bar/view/widgets/bottom_navbar_item.dart`, `navbar_btn.dart`, `core/components/product_card.dart`, `home/view/widgets/home_search_bar.dart`, `home/view/widgets/portrait_home.dart`, `product_details/view/widgets/product_qty_add_bar.dart`, `cart/view/widgets/cart_summary.dart`; Test `mobile/test/components/premium_layer_test.dart`
- Glass bottom nav: `ClipRect` + `BackdropFilter(blur 20)` over `surface @0.82`, top hairline `outlineVariant`, selected pill animates with `AnimatedContainer(AppDurations.base)`; `Scaffold.extendBody: true` with list bottom padding so content is not hidden.
- Product card: radius `AppRadius.lg`, image 4:5, price in `goldText` `titleMedium` w700, sale price struck in `onSurfaceVariant`, sale badge `goldText` bg with white label (5.47:1).
- Lists: staggered entrance (`flutter_animate` `fadeIn + slideY(0.06)`, 300 ms, 40 ms stagger, max 8 items) skipped when `reduceMotion`.
- Sticky CTA bars (product, cart): elevated glass surface + `SafeArea`.
- Tests: `bottom nav content is not obscured: last list item fully visible when scrolled to end`; `stagger disabled under reduceMotion`; `sale badge contrast ≥ 4.5`.
- Commit per component.

---

## Execution

Each task is dispatched to a Sonnet subagent in the `../Marketplace-ui` worktree, one at a time (they share theme files). After each: review diff, run `flutter analyze --no-fatal-infos && flutter test`, then commit.
