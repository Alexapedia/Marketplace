# Maison — full visual redesign (mobile, storefront, admin, holder)

## Intent

The owner wants every surface of the platform to feel like walking into a
**10-star mall**: calm, expensive, precise, with high-quality motion. One
design language across the Flutter app (phones + tablets), the web
storefront, the store admin dashboard and the platform holder dashboard.

Every store (tenant) sets its own primary colour, accent colour and logo from
the holder dashboard, so the language must look premium with *any* brand
colours, not only navy/gold.

## Goals

- One visual system ("Maison") with identical tokens in all four apps.
- High-quality, meaningful motion everywhere (entrances, scroll reveals,
  hover/press, page transitions, counters, feedback), always honouring
  reduced-motion.
- Flawless at 360, 390, 412, 768, 1024, 1280 and 1440 px widths, portrait
  and landscape, LTR (en) and RTL (ar), light and dark.
- Holder can upload a store logo (light + dark variant) with live preview; the
  logo then shows in the storefront, admin and mobile app.

## Non-goals / anti-goals

- No business-logic, API-shape, routing or data-model changes. The only
  backend addition is the holder logo upload (approved by the owner).
- No new npm/pub packages. Fonts are assets (OFL), not packages.
- Anti-goal: "gaudy luxury" — no glitter, no heavy gradients everywhere, no
  motion that delays a task. Luxury here = restraint, space, precision.
- Anti-goal: brand colours that break contrast. Text on tenant colours must be
  computed, never assumed.

## Visual language

### Neutrals (warm stone, fixed — not tenant-controlled)

| Token | Light | Dark |
|---|---|---|
| canvas (page bg) | `#F7F4EE` ivory | `#0C0B09` onyx |
| surface (cards) | `#FFFFFF` | `#15130F` |
| surface-2 (wells, inputs) | `#F1ECE3` | `#1E1B16` |
| line (hairlines) | `#E5DED2` | `#2C2821` |
| ink (text) | `#16130F` | `#F5F0E6` |
| ink-muted | `#5E574D` | `#A79F92` |
| danger | `#B4232F` | `#F07178` |
| success | `#2F6B4F` | `#7BC8A0` |

### Brand (tenant-controlled)

- `brand-primary` (default `#071345`), `brand-accent` (default `#C9A45C`).
- Derived at runtime: `on-primary`, `on-accent` = `#16130F` or `#FFFFFF`,
  whichever has the higher WCAG contrast.
- `accent-ink` = accent text usable on light surfaces: in light mode
  `color-mix(in oklab, accent 62%, black)`; in dark mode the accent itself.
- Usage: accent = the "light" of the mall: primary CTA fill, price, active
  indicators, focus ring, hairline gold rules. Primary = deep brand band:
  hero band, dashboard sidebar (light mode), footer.

### Typography

- Display: `"Playfair Display", "El Messiri", serif` — Playfair renders
  Latin, El Messiri renders Arabic. Used for hero, page titles, section
  titles, KPI numbers, brand wordmark fallback.
- Body/UI: `"IBM Plex Sans Arabic", system-ui, sans-serif` (covers Latin too).
- Eyebrow labels: 12px, weight 600, uppercase + `letter-spacing: .16em` for
  Latin only; Arabic gets no letter-spacing.
- Scale (web px / Flutter sp): 12, 14, 16 (body), 18, 22, 28, 36, 48, 60
  (hero desktop). Line-height 1.6 body, 1.15 display.
- Numbers (prices, KPIs): `font-variant-numeric: tabular-nums`.

### Shape, space, depth

- Radius: 8 / 12 / 16 / 24 / 32 / pill.
- Spacing scale: 4, 8, 12, 16, 24, 32, 48, 64, 96.
- Shadow-1 (rest): `0 1px 2px rgb(22 19 15 / .05), 0 8px 24px -12px rgb(22 19 15 / .12)`.
- Shadow-2 (lift): `0 28px 56px -28px rgb(22 19 15 / .35)`.
- Dark mode adds a 1px top inner highlight `rgb(255 255 255 / .04)` on cards.
- Glass chrome (headers, bottom bars, sticky CTAs): surface at 72% alpha +
  `backdrop-filter: blur(18px) saturate(1.4)` + hairline line border.
- Signature detail: a 1px "gold rule" (accent → transparent gradient) under
  section titles and at the top edge of hero and footer.

### Motion ("concierge motion")

| Token | Value |
|---|---|
| ease-out | `cubic-bezier(.16, 1, .3, 1)` (expo-out) |
| ease-in-out | `cubic-bezier(.65, 0, .35, 1)` |
| ease-spring | `cubic-bezier(.34, 1.56, .64, 1)` (badges only) |
| instant / fast / base / slow / lavish | 120 / 200 / 320 / 560 / 900 ms |

Choreography (all apps):

1. **Page enter** — content blocks fade + rise 16px + blur 6px→0 over
   `slow`, staggered 60ms, max 8 staggered items (the rest appear with the
   8th). Web uses the View Transitions API for route cross-fade (`base`).
2. **Scroll reveal** — the same entrance, triggered once when 12% visible.
3. **Hover (fine pointers only)** — cards rise 4px with shadow-2; product
   images scale 1.06 over `lavish`; a soft light sheen sweeps across primary
   buttons.
4. **Press** — scale .97 over `instant`; haptics on mobile.
5. **Chrome** — header turns glass after 8px of scroll; mobile app nav
   indicator slides between items.
6. **Hero** — slow 18s Ken-Burns drift on hero media; headline lines rise in
   sequence; gold rule draws from 0 to full width.
7. **Feedback** — cart/badge count bumps (spring); toasts rise in over
   `base`, leave over `fast` (exit faster than enter); dialogs scale .96→1 +
   fade.
8. **Data** — KPI numbers count up over `lavish`; bars/sparklines grow from
   baseline; first 12 table rows stagger 30ms.
9. **Loading** — warm shimmer skeletons shaped like the final content.
10. **Reduced motion** — all of the above collapse to an instant state change
    (no transforms, no count-up, no Ken-Burns). Only opacity cross-fades
    ≤ `fast` remain.

Only `transform` and `opacity` (plus `filter: blur` on entrance) animate —
never width/height/top/left.

## Per-app scope

### Web storefront (Angular, global SCSS, no Material)

New header (glass, logo, search pill, icon actions with badges), phone bottom
tab bar (shop / cart / orders / account) under 768px, cinematic hero, category
rail, premium product card, product detail with sticky buy box and shared-
element image transition, cart/checkout with an elegant summary card, auth
screens, account/orders/notifications/custom-orders/addresses pages, empty /
error / skeleton states, footer. Every existing feature page restyled.

### Admin dashboard (Angular Material)

Material M3 theme mapped onto Maison tokens (`--mat-sys-*`), new sidebar
(primary band in light mode, onyx in dark, accent active pill), glass top
bar, KPI cards with count-up, charts in accent/primary, data tables with
hairline rows and staggered entrance, forms with filled-tonal fields, dialogs,
login screen. All feature pages restyled. Sidebar becomes an overlay drawer
under 1024px.

### Holder dashboard (Angular Material)

Same treatment as admin with the platform's own default brand (navy/gold).
Tenant detail gets the **logo uploader** (drag-and-drop, light + dark slots,
live preview on light and dark surfaces) and a live brand preview card that
shows the chosen colours + logo as a mini storefront header.

### Mobile app (Flutter, phones + tablets)

Theme rebuilt on Maison tokens (light ivory / dark onyx), bundled Playfair
Display + El Messiri for display text, page transitions via
`pageTransitionsTheme` (fade + 16px rise, no router edits), Hero shared-element
for product images, staggered entrances, glass nav with sliding indicator,
premium product card, all screens restyled; tablet layouts (nav rail, split
views) polished. Tenant logo from `/app/config` used by `AppLogo`, falling
back to the bundled asset.

## Logo upload (backend + holder + clients)

- `POST /platform/uploads` (PlatformJwtGuard, multipart `file`, image MIME
  types only, existing size limit) → `{ url }`. Same storage as `/uploads`.
- `PATCH /platform/tenants/:id` merges `branding` keys instead of replacing
  the whole object, and only accepts known keys (`name, primary, accent,
  logo, logoDark, favicon, splash`), so saving colours never wipes the logo.
- Clients pick `logoDark` on dark surfaces when present, else `logo`.

## Constraints

- Separate branch `maison-redesign` from `release-candidate`.
- Small commits, one concern per commit; Opus attribution trailer only.
- Angular apps have no unit-test runner; verify with `ng build` + headless
  Chrome screenshots at 390 / 768 / 1280 widths, ar + en, light + dark.
- Flutter: existing 67 tests stay green; new widget tests for tokens/contrast,
  reduced motion and layout at phone + tablet sizes.
- Backend: e2e tests for the upload endpoint and the branding merge.

## Calls made by the builder (owner opted out of questions)

- Name "Maison", warm stone neutrals, Playfair + El Messiri + IBM Plex Sans
  Arabic, accent-as-light usage, and the motion tokens above.
- Phone storefront gets a bottom tab bar (layout only, same routes).
- Branding PATCH becomes a merge (prevents the logo being wiped).
