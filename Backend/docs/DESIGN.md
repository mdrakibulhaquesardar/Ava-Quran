# Ava Quran — DESIGN.md
**Design System & UI/UX Specification**
Version 1.0 | Mobile-First (Flutter)

---

## 1. Design Vision & Aesthetic Direction

### 1.1 Core Concept
**"Sacred Stillness"** — A calm, immersive Islamic mobile experience that feels like holding a beautifully crafted book under moonlight. Every screen breathes with intentional space, soft illumination, and quiet reverence.

### 1.2 Aesthetic Identity
- **Tone:** Refined spiritual luxury. Not decorative clutter — deep calm with purposeful visual poetry.
- **Mood:** Like the quiet hour before Fajr. Still. Focused. Intimate.
- **Inspiration:** The reference screenshots (Qurania onboarding) — deep navy domes, crescent moons, starfields, glowing archways — blended with a modern social-feed structure (TCQ Community layout).
- **What makes it unforgettable:** The vertical ayah feed feels like turning pages of an illuminated manuscript, but as smooth as scrolling Instagram.

---

## 2. Color Palette

### 2.1 Primary Colors

| Token | Hex | Usage |
|---|---|---|
| `--color-bg-deep` | `#050D1A` | App background, darkest layer |
| `--color-bg-surface` | `#0A1628` | Card backgrounds, bottom sheets |
| `--color-bg-elevated` | `#0F1F3D` | Elevated cards, modals |
| `--color-navy-mid` | `#162B52` | Dividers, subtle containers |
| `--color-teal-glow` | `#1A7FAE` | Primary CTA, active states, buttons |
| `--color-teal-light` | `#2BA8D8` | Hover/press highlights, links |
| `--color-crescent` | `#5AC8FA` | Accent highlights, icons, moon glyph |
| `--color-gold` | `#C9A84C` | Premium accents, verse numbers, badges |
| `--color-gold-soft` | `#E8C97A` | Surah names, secondary gold |

### 2.2 Text Colors

| Token | Hex | Usage |
|---|---|---|
| `--color-text-primary` | `#F0F4FF` | Arabic ayah text, headlines |
| `--color-text-secondary` | `#A8BFDB` | Translations, subtitles |
| `--color-text-muted` | `#5A7A9E` | Timestamps, metadata, placeholders |
| `--color-text-inverse` | `#050D1A` | Text on light/teal buttons |

### 2.3 Semantic Colors

| Token | Hex | Usage |
|---|---|---|
| `--color-streak-fire` | `#FF6B35` | Streak counter, daily progress |
| `--color-mood-peaceful` | `#4ECDC4` | Peaceful mood tag |
| `--color-mood-grateful` | `#A8E6CF` | Grateful mood tag |
| `--color-mood-hopeful` | `#FFD93D` | Hopeful mood tag |
| `--color-mood-stressed` | `#FF8B94` | Stressed mood tag |
| `--color-mood-anxious` | `#C3A6FF` | Anxious mood tag |
| `--color-mood-distracted` | `#FFB347` | Distracted mood tag |
| `--color-success` | `#4CAF84` | Saved confirmation, streak milestone |
| `--color-error` | `#E05C5C` | Error states |

### 2.4 Gradients

```
/* Deep background — starfield feel */
background-gradient-bg: linear-gradient(180deg, #050D1A 0%, #0A1628 60%, #0F1F3D 100%);

/* CTA Button */
background-gradient-cta: linear-gradient(135deg, #1A7FAE 0%, #2BA8D8 100%);

/* Card shimmer glow — top edge */
background-gradient-card-glow: linear-gradient(180deg, rgba(26,127,174,0.15) 0%, transparent 40%);

/* Gold accent strip */
background-gradient-gold: linear-gradient(90deg, #C9A84C 0%, #E8C97A 50%, #C9A84C 100%);

/* Mood overlay on feed card */
background-gradient-card-overlay: linear-gradient(180deg, transparent 30%, rgba(5,13,26,0.95) 100%);
```

---

## 3. Typography

### 3.1 Font Stack

| Role | Font Family | Weight | Notes |
|---|---|---|---|
| **Arabic Quran Text** | `Amiri Quran` | 400 | Primary ayah text, RTL |
| **Arabic Surah Names** | `Scheherazade New` | 600 | Surah headers |
| **Latin Display** | `Cormorant Garamond` | 300–600 | Headlines, screen titles |
| **Latin Body** | `DM Sans` | 300–500 | Translations, UI labels |
| **Monospace / Metadata** | `JetBrains Mono` | 400 | Ayah refs like "2:255", timestamps |

### 3.2 Type Scale

| Token | Size | Line Height | Usage |
|---|---|---|---|
| `--text-arabic-ayah` | 26–32sp | 1.8 | Main ayah text (RTL) |
| `--text-arabic-surah` | 20sp | 1.5 | Surah name header |
| `--text-display` | 28sp | 1.2 | Screen titles (Cormorant) |
| `--text-title` | 20sp | 1.3 | Section headers |
| `--text-body` | 15sp | 1.6 | Translation text |
| `--text-caption` | 12sp | 1.4 | Metadata, tags |
| `--text-micro` | 10sp | 1.3 | Verse refs, timestamps |

### 3.3 Typography Rules
- Arabic text always Right-to-Left, centered on feed cards
- Never mix Arabic and Latin on the same line
- Translation text is left-aligned, lighter weight than ayah
- Verse references (e.g. "Al-Baqarah 2:255") use JetBrains Mono in `--color-gold-soft`

---

## 4. Spacing & Layout

### 4.1 Base Grid
- **Base unit:** 4dp
- **Screen padding:** 20dp horizontal
- **Safe area:** Respect top/bottom safe areas (iOS notch, Android gesture bar)
- **Card border-radius:** 20dp (large cards), 12dp (chips/tags), 50dp (pills)

### 4.2 Spacing Scale

| Token | Value | Usage |
|---|---|---|
| `--space-xs` | 4dp | Icon gap, badge padding |
| `--space-sm` | 8dp | Tag internal padding |
| `--space-md` | 16dp | Standard component spacing |
| `--space-lg` | 24dp | Card internal padding |
| `--space-xl` | 32dp | Section separation |
| `--space-2xl` | 48dp | Screen-level sections |
| `--space-3xl` | 64dp | Hero areas, onboarding |

### 4.3 Bottom Navigation Height
- 72dp total height (including safe area padding)
- Icon area: 48dp

---

## 5. Component Library

---

### 5.1 Feed Card (Core Component)

The central UI unit. Inspired by the Qurania onboarding screenshot's framed arch visual.

```
┌─────────────────────────────────────┐
│  [Surah Name]              [2:255]  │  ← gold text, top row
│                                     │
│         ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ         │  ← Arabic ayah, centered, 28–32sp
│         ٱلْحَىُّ ٱلْقَيُّومُ ۚ              │
│                                     │
│  "Allah — there is no deity except  │  ← Translation, 15sp, muted
│  Him, the Ever-Living, the          │
│  Sustainer of existence…"           │
│                                     │
│  ╔═══════════════════════════════╗  │  ← AI Reflection box
│  ║ 💡 "When you feel overwhelmed │  │
│  ║    remember Who holds all…"  ║  │
│  ╚═══════════════════════════════╝  │
│                                     │
│  [🎵 Play]  [🔖 Save]  [✏️ Reflect] │  ← Action row
│                                     │
│  😌 Peaceful  🤲 Gratitude          │  ← Mood tags
└─────────────────────────────────────┘
```

**Specs:**
- Background: `--color-bg-surface` with subtle top glow (`--background-gradient-card-glow`)
- Border: 1dp `rgba(90,200,250,0.1)` (very subtle teal rim)
- Border-radius: 20dp
- Card padding: 24dp
- Arabic text: centered, `--color-text-primary`
- Translation text: left-aligned, `--color-text-secondary`
- Bottom gradient overlay when image/mosque art is used as background
- **Swipe left:** dismiss / not interested
- **Swipe right:** quick-save to bookmarks
- **Tap card:** expand to full-screen verse detail

---

### 5.2 Mood Selector

Displayed as a horizontal scrollable chip row on the Feed screen.

```
[😌 Peaceful]  [🙏 Grateful]  [🌟 Hopeful]  [😟 Stressed]  [😰 Anxious]
```

**Specs:**
- Chip height: 36dp
- Chip padding: 12dp horizontal, 8dp vertical
- Border-radius: 50dp (fully rounded pill)
- **Unselected:** `--color-bg-elevated`, border 1dp `--color-navy-mid`, text `--color-text-muted`
- **Selected:** background uses the mood's specific color (e.g. `--color-mood-peaceful`), text `--color-text-inverse`, subtle glow shadow
- Emoji + label side-by-side
- Horizontal scroll, no scroll indicator

---

### 5.3 Audio Player Bar

Persistent mini-player when audio is active (anchored above bottom nav).

```
┌────────────────────────────────────────────────────┐
│ 🎵  Al-Fatiha 1:1 — Sheikh Mishary              ⏸ │
│ ══════════════╸━━━━━━━━━━━━━━━━━━━━  2:34 / 5:12  │
└────────────────────────────────────────────────────┘
```

**Specs:**
- Height: 56dp
- Background: `--color-bg-elevated` with blur backdrop
- Progress bar: `--color-teal-glow` fill on `--color-navy-mid` track
- Tap to expand to full player sheet

**Full Player Sheet (Bottom Sheet, 70% height):**
- Large surah name in display font
- Circular waveform or animated pulsing ring in `--color-teal-glow`
- Reciter name, ayah reference
- Scrubber bar with timestamps
- Previous / Play-Pause / Next controls
- Speed selector (0.75x, 1x, 1.25x, 1.5x)

---

### 5.4 Bottom Navigation

5 tabs — inspired by TCQ Community's tab structure.

| Tab | Icon | Label |
|---|---|---|
| Feed | crescent + lines | Feed |
| Search | magnifier | Explore |
| Saved | bookmark | Library |
| Journal | pen + lines | Reflect |
| Profile | person | You |

**Specs:**
- Height: 72dp (+ safe area)
- Background: `--color-bg-surface` with top 1dp border `--color-navy-mid`
- Active tab: icon + label in `--color-teal-light`, with a small 3dp dot indicator below
- Inactive: `--color-text-muted`
- Center tab (Explore or special action) can be elevated with a circular teal button

---

### 5.5 Streak Badge

Displayed on the Profile tab and optionally in the Feed header.

```
🔥 14
```

- Flame icon in `--color-streak-fire`
- Count in `--text-title` weight
- On tap: opens Streak Detail sheet showing current streak, longest streak, calendar heatmap

**Streak Detail Sheet:**
- Monthly calendar where each day is a filled circle (teal = active, outline = missed)
- Current streak: large number in display font
- Longest streak shown below
- Motivational message from AI (e.g. "You've read for 14 days. Keep going.")

---

### 5.6 Reflection Journal Entry Card

Used in the Reflect tab and Saved verses.

```
┌─────────────────────────────────────┐
│  Al-Imran 3:200            Oct 12  │
│  "O you who believe, persevere…"   │
│  ─────────────────────────────────  │
│  My reflection: "This verse helped │
│  me during my hardest week. I felt │
│  like Allah was speaking to me…"   │
│                      😌 Peaceful   │
└─────────────────────────────────────┘
```

- Card background: `--color-bg-surface`
- Top row: ayah reference in gold, date in muted mono
- Quoted verse in italic, muted
- Divider: 1dp `--color-navy-mid`
- User text: body font, `--color-text-primary`
- Mood chip bottom-right

---

### 5.7 Collection Card

Used in the Library tab.

```
┌────────────────────────┐
│  ✦ Comfort             │
│  12 Ayahs              │
│  Last updated 3d ago   │
└────────────────────────┘
```

- Grid layout (2 columns)
- Icon: decorative Islamic geometric icon (star/diamond) in gold
- Title: `--text-title`
- Count + date: `--text-caption`, muted

---

### 5.8 Onboarding Screens

**Directly modeled after the Qurania reference (Image 1).**

3-screen swipeable onboarding:

**Screen 1 — Welcome**
- Full-screen illustrated scene: mosque dome silhouette against deep navy starfield, crescent moon glowing at top
- Illustration style: layered flat SVG/Lottie, dark teal/navy tones
- Title: "Read Quran with Peace Daily" (Cormorant Garamond, 28sp, centered, white)
- Subtitle: smaller body text
- CTA: "Get Started" — pill button, teal gradient
- "Skip" top-right in muted text

**Screen 2 — Personalization**
- Arch/window framing the mosque scene (same as reference Image 1 center)
- Title: "Your Quran, Your Mood"
- Subtitle: "Tell us how you feel. We'll find the verse for this moment."
- CTA: "Next"

**Screen 3 — Mood Selection (Interactive)**
- Title: "How are you feeling today?"
- Mood chips in a 2×3 grid (large, 56dp chips with emoji + label)
- User taps their mood to complete onboarding
- CTA: "Begin My Journey" → goes to personalized feed

**Page indicators:** Centered dots below illustration, active dot wider (pill shape)

---

### 5.9 Search / Explore Screen

**Modeled after TCQ Community's Explore Topics + Feed (Image 2).**

```
[Search bar: "Search by topic, feeling, or keyword..."]

Trending Topics
[Patience]  [Gratitude]  [Forgiveness]  [Anxiety]  [Death]  [Hereafter]

Recommended Ayahs
[Feed Card]
[Feed Card]

Featured Collections
[Collection Card]  [Collection Card]
```

- Search bar: rounded, `--color-bg-elevated`, search icon in teal, placeholder in muted
- Topic chips: same pill style as mood chips but using `--color-gold` border for "editorial" feel
- Results render as feed cards below

---

### 5.10 Buttons

| Variant | Style |
|---|---|
| **Primary** | Teal gradient fill, white text, 50dp radius, 52dp height |
| **Secondary** | Outlined, 1.5dp `--color-teal-glow` border, teal text, transparent bg |
| **Ghost** | No border, muted text, used for "Skip", "Cancel" |
| **Icon Button** | 40dp circle, `--color-bg-elevated` bg, icon in teal |
| **Destructive** | `--color-error` border/text, used for delete actions |

All buttons: 300ms ease press animation (scale to 0.96)

---

## 6. Screen Inventory & Layouts

### 6.1 Screens List

| Screen | Route | Description |
|---|---|---|
| Splash | `/splash` | Logo + background, 2s then auto-navigate |
| Onboarding 1–3 | `/onboard` | 3-step illustrated onboarding |
| Mood Onboarding | `/onboard/mood` | Initial mood selection |
| Login | `/login` | OAuth login via Quran.Foundation |
| Feed (Home) | `/feed` | Vertical swipeable ayah feed |
| Ayah Detail | `/ayah/:key` | Full-screen expanded verse view |
| Audio Player | `/player` | Full audio player sheet |
| Explore | `/explore` | Search + topics + trending |
| Search Results | `/search` | Filtered results |
| Library | `/library` | Collections + bookmarks |
| Collection Detail | `/collections/:id` | Ayahs in a collection |
| Reflect (Journal) | `/journal` | All reflection entries |
| Reflection Write | `/journal/write` | Write/edit a reflection |
| Profile | `/profile` | User info + streak + preferences |
| Streak Detail | `/streak` | Calendar heatmap + milestone |
| Settings | `/settings` | Preferences (reciter, language, notif) |

---

### 6.2 Feed Screen Layout

```
┌─────────────────────────────────────┐
│  Ava Quran          🔥 14   [⚙️]    │  ← Top bar
├─────────────────────────────────────┤
│ [😌 All] [🙏 Grateful] [😟 Stressed]│  ← Mood chips (scrollable)
├─────────────────────────────────────┤
│                                     │
│         [FEED CARD]                 │  ← Vertical scrollable
│                                     │
│         [FEED CARD]                 │
│                                     │
│         [FEED CARD]                 │
│                                     │
├─────────────────────────────────────┤
│ [Feed]  [Explore]  [Library]  [Reflect]  [You] │ ← Bottom Nav
└─────────────────────────────────────┘
```

- Pull-to-refresh: crescent moon animation spinning
- Infinite scroll (paginated from backend)
- Each card is full-width, variable height

---

### 6.3 Ayah Detail Screen

Full-screen immersive view when a card is tapped.

```
┌─────────────────────────────────────┐
│  ← Back                    [Share] │
├─────────────────────────────────────┤
│                                     │
│  Al-Baqarah                  2:255  │  ← Surah + ref (centered)
│                                     │
│  ┌─────────────────────────────┐   │
│  │  [Decorative arch border]   │   │
│  │                             │   │
│  │   ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ    │   │  ← Arabic, large
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  "Allah — there is no deity        │  ← Translation
│  except Him…"                       │
│                                     │
│  ─── AI Reflection ───             │
│  Short insight text here            │
│                                     │
│  ─── Your Reflection ───           │
│  [Tap to write your thoughts…]     │
│                                     │
│  [▶️ Play Recitation]              │
│  [🔖 Save]  [➕ Add to Collection] │
└─────────────────────────────────────┘
```

---

## 7. Motion & Animation

### 7.1 Animation Principles
- **Purposeful:** Animation communicates state, not decoration
- **Calm:** Nothing fast or jarring — max 400ms for transitions
- **Islamic-inspired:** Geometric unfold patterns, crescent reveals, arch expansions

### 7.2 Animation Catalog

| Animation | Duration | Easing | Trigger |
|---|---|---|---|
| Screen entry (slide up) | 320ms | easeOutCubic | Route push |
| Card scroll reveal (fade + slide up) | 280ms | easeOut | Card enters viewport |
| Mood chip select | 200ms | easeInOut | Tap |
| Save bookmark | 350ms | spring | Tap 🔖 |
| Audio play button | 250ms | easeOut | Tap ▶️ |
| Streak milestone | 600ms | bounceOut | New streak day |
| Pull to refresh | 800ms loop | linear | Pull gesture |
| Ayah expand | 400ms | easeOutCubic | Tap card |
| Bottom sheet open | 350ms | easeOutCubic | Action trigger |
| Onboarding page change | 400ms | easeInOut | Swipe |

### 7.3 Lottie Animations (Suggested)
- **Splash logo:** Crescent + star forming the Ava logo
- **Bookmark saved:** Bookmark fills with golden light
- **Streak new day:** Flame flickers and grows
- **Loading feed:** Rotating calligraphy-style ornament
- **Empty state:** Gentle mosque dome with floating stars

---

## 8. Iconography

### 8.1 Icon Style
- **Line icons** (2dp stroke), rounded caps
- Size: 24dp standard, 20dp compact, 28dp featured
- Color: `--color-teal-light` for active, `--color-text-muted` for inactive

### 8.2 Custom Islamic Icons Needed
- Crescent moon (nav/logo use)
- Mosque dome (decorative, empty states)
- Prayer beads (streak or reflection)
- Geometric star/mandala (collection icon)
- Open Quran book (library)
- Arabic calligraphy brush stroke (reflection journal)
- Arch/mihrab frame (verse card border decoration)

Use [Phosphor Icons](https://phosphoricons.com/) or [Lucide](https://lucide.dev/) as base, with custom additions for Islamic motifs.

---

## 9. Imagery & Illustrations

### 9.1 Illustration Style
Flat SVG layered scenes — identical approach to the Qurania reference (Image 1):
- Deep navy/teal layered silhouettes
- Mosque domes, minarets, starfields
- Crescent moon as primary focal element
- Atmospheric depth: foreground darker, background lighter teal

### 9.2 Where Illustrations Appear
- Onboarding screens (full-bleed background illustration per screen)
- Empty states (smaller centered illustration)
- Splash screen
- Streak milestones (celebratory mosque + stars)

### 9.3 No Photography
Do not use real photography. All visuals are SVG illustrations or Lottie animations.

---

## 10. Elevation & Shadows

| Level | Shadow | Usage |
|---|---|---|
| 0 | None | Flat elements, backgrounds |
| 1 | `0 2dp 8dp rgba(0,0,0,0.3)` | Cards at rest |
| 2 | `0 4dp 16dp rgba(0,0,0,0.4)` | Elevated cards, selected |
| 3 | `0 8dp 24dp rgba(26,127,174,0.15)` | Bottom sheets, modals |
| 4 | `0 0 40dp rgba(26,127,174,0.2)` | Teal glow on CTA buttons |

---

## 11. Accessibility

- **Minimum contrast ratio:** 4.5:1 for body text, 3:1 for large text (WCAG AA)
- **Touch targets:** Minimum 48×48dp for all interactive elements
- **Font scaling:** Support system font size scaling (Flutter `textScaleFactor`)
- **Screen readers:** All interactive elements have semantic labels
- **Arabic text:** Ensure RTL layout support throughout (Flutter `Directionality`)
- **Audio:** Provide visual progress indicator alongside audio controls
- **Reduced motion:** Respect `AccessibilityFeatures.disableAnimations`

---

## 12. Empty States

Each major screen has a designed empty state:

| Screen | Illustration | Message |
|---|---|---|
| Feed (no verses yet) | Floating crescent + stars | "Your personal feed is being prepared…" |
| Library (no bookmarks) | Open Quran outline | "Save ayahs you love. They'll appear here." |
| Journal (no entries) | Pen + paper glow | "Your reflections will live here. Start with one verse." |
| Search (no results) | Magnifier + question mark | "No verses found. Try a different feeling or topic." |
| Collection (empty) | Star outline | "This collection is empty. Add ayahs from your feed." |

---

## 13. Loading States

- **Feed initial load:** Shimmer cards (animated gradient from `--color-bg-surface` to `--color-bg-elevated`)
- **Audio buffering:** Pulsing ring on play button
- **AI reflection loading:** Animated ellipsis in the reflection box
- **Search results:** Shimmer list items

---

## 14. Error States

- **Network error:** Bottom snackbar — "No connection. Check your network." with Retry button
- **AI unavailable:** Verse still shown, reflection box says "Reflection unavailable right now"
- **Auth error:** Full-screen state with login CTA
- All errors use `--color-error` sparingly — never alarming, always calm in tone

---

## 15. Onboarding Flow (Complete)

```
Splash (2s)
    ↓
Onboarding Screen 1 (Read Quran With Peace)
    ↓
Onboarding Screen 2 (Your Quran, Your Mood)
    ↓
Onboarding Screen 3 (How are you feeling today?) — Mood selection
    ↓
Login Screen (Sign in with Quran.Foundation)
    ↓
Personalization (Select reciters, translation language)
    ↓
Feed (Home)
```

---

## 16. Design Tokens Summary (Flutter)

```dart
// Colors
static const Color bgDeep = Color(0xFF050D1A);
static const Color bgSurface = Color(0xFF0A1628);
static const Color bgElevated = Color(0xFF0F1F3D);
static const Color navyMid = Color(0xFF162B52);
static const Color tealGlow = Color(0xFF1A7FAE);
static const Color tealLight = Color(0xFF2BA8D8);
static const Color crescent = Color(0xFF5AC8FA);
static const Color gold = Color(0xFFC9A84C);
static const Color goldSoft = Color(0xFFE8C97A);
static const Color textPrimary = Color(0xFFF0F4FF);
static const Color textSecondary = Color(0xFFA8BFDB);
static const Color textMuted = Color(0xFF5A7A9E);
static const Color streakFire = Color(0xFFFF6B35);

// Border radius
static const double radiusCard = 20.0;
static const double radiusChip = 50.0;
static const double radiusSmall = 12.0;

// Spacing
static const double spaceXS = 4.0;
static const double spaceSM = 8.0;
static const double spaceMD = 16.0;
static const double spaceLG = 24.0;
static const double spaceXL = 32.0;

// Font sizes
static const double fontAyah = 28.0;
static const double fontDisplay = 28.0;
static const double fontTitle = 20.0;
static const double fontBody = 15.0;
static const double fontCaption = 12.0;
static const double fontMicro = 10.0;
```

---

## 17. Screen-by-Screen Design Notes

### Feed Screen
- Top bar: left = "Ava Quran" (logo + wordmark), right = streak badge + settings icon
- Mood chips below top bar, sticky on scroll
- Feed cards are the hero — give them breathing room (16dp vertical gap between cards)
- No infinite empty space below last card; show "You're all caught up" state

### Explore Screen
- Large search bar at top (always visible)
- Below: "Today's Topics" chip row in gold-bordered pills
- Then: "For You" section with 2–3 ayah cards
- Then: "Collections to Explore" in 2-column grid
- Behavior: typing in search immediately filters by keyword/mood/topic

### Library Screen
- Tab bar within screen: "Saved Ayahs" | "My Collections"
- Saved Ayahs: list of feed cards (compact version, no AI reflection shown)
- Collections: 2-column grid of collection cards with + New Collection button (FAB)

### Journal / Reflect Screen
- List of reflection cards, newest first
- FAB (+) to write new reflection (opens ayah picker → then write screen)
- Reflection write screen: top shows the linked ayah (compact card), below is a plain text area with placeholder "What does this verse mean to you today?"

### Profile Screen
- Top: avatar, name, email (from Quran.Foundation OAuth)
- Streak section: large streak number + longest streak
- Monthly calendar heatmap
- Settings shortcut links (reciter, language, notifications)
- Sign out (ghost button, bottom)

---

## 18. Reference Screens Summary

| Reference | What to Adopt |
|---|---|
| **Qurania (Image 1)** | Full-bleed navy illustration style, crescent + mosque silhouette, arch framing, deep teal/navy palette, pill CTA buttons, 3-screen onboarding structure, "Skip" + "Next" navigation pattern |
| **TCQ Community (Image 2)** | Social feed tab structure (Feed/Peoples/Videos/Blogs), topic chip explorer, profile screen with stats (Posts/Followers/Following adapted to our: Streaks/Collections/Reflections), content card structure with actions |

---

*This DESIGN.md is the single source of truth for Ava Quran's visual design. All screens, components, and interactions should be built against these specifications. Update version number when significant changes are made.*

---
**Document:** DESIGN.md
**Product:** Ava Quran
**Version:** 1.0
**Stack:** Flutter (mobile)
