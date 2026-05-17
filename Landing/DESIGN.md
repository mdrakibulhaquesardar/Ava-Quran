# Ava Quran — Web Landing Page Design System
**Design Specification & UI/UX Guidelines**

---

## 1. Design Vision & Aesthetic Direction

### 1.1 Core Concept
**"Sacred Stillness on the Web"** — Extending the mobile app's immersive, calm Islamic experience to the browser. The landing page acts as a digital portal that feels like a quiet, moonlit sanctuary, encouraging users to download the app and experience peace.

### 1.2 Aesthetic Identity
- **Tone:** Refined spiritual luxury, deep calm, focused.
- **Mood:** Like the quiet hour before Fajr.
- **Inspiration:** The mobile app's deep navy domes, glowing crescent moons, and framed archways, translated into a responsive, smooth-scrolling web layout.
- **Motion:** Gentle hover effects, soft fade-ins on scroll, and subtle glowing auras to make the page feel alive but not distracting.

---

## 2. Color Palette (Web Tokens)

The web landing page uses identical CSS variables from the mobile app to maintain strict brand consistency.

| CSS Variable | Hex | Usage |
|---|---|---|
| `--color-bg-deep` | `#050D1A` | Main page background |
| `--color-bg-surface` | `#0A1628` | Feature cards, navbar background |
| `--color-bg-elevated` | `#0F1F3D` | Elevated sections, hover states |
| `--color-navy-mid` | `#162B52` | Dividers, subtle borders |
| `--color-teal-glow` | `#1A7FAE` | Primary CTA gradients |
| `--color-teal-light` | `#2BA8D8` | Hover highlights, links |
| `--color-crescent` | `#5AC8FA` | Accent highlights, logos |
| `--color-gold` | `#C9A84C` | Premium accents, icons |
| `--color-text-primary` | `#F0F4FF` | Headlines, main text |
| `--color-text-secondary` | `#A8BFDB` | Subtitles, descriptions |
| `--color-text-muted` | `#5A7A9E` | Footer text, minor details |
| `--color-text-inverse` | `#050D1A` | Text on teal buttons |

---

## 3. Typography

| Font Family | Usage | Fallback |
|---|---|---|
| **Cormorant Garamond** | `<h1>`, `<h2>`, Screen Titles, Logo | `serif` |
| **DM Sans** | `<p>`, `<a>`, Buttons, Body text | `sans-serif` |
| **Amiri Quran** | Arabic Verse text (mockups) | `serif` |
| **JetBrains Mono** | Verse references (e.g., 2:255) | `monospace` |

---

## 4. Component Library

### 4.1 Navigation Bar (`Navbar.jsx`)
- **Style:** Fixed top, blurred background (`backdrop-filter: blur(10px)`), `rgba(5, 13, 26, 0.8)`.
- **Logo:** Crescent icon (`--color-crescent`) + "Ava Quran" in `Cormorant Garamond`.
- **Actions:** "Download App" button using `--gradient-cta` and full pill radius.

### 4.2 Hero Section (`HeroSection.jsx`)
- **Layout (Desktop):** 2-column grid. Left side text & CTAs, right side visual mockup.
- **Layout (Mobile):** 1-column stack. Text centered, visual mockup hidden or scaled down.
- **Background:** Deep navy (`--color-bg-deep`).
- **Visuals:** A CSS-rendered or image mockup of the mobile app (Feed Card with an Ayah). Behind the mockup, a soft radial blur (`--color-teal-glow` at 40% opacity) and a fine archway border (`--color-navy-mid`) act as framing.

### 4.3 Feature Cards (`FeaturesSection.jsx`)
- **Card Background:** `--color-bg-surface` with a top-down glowing gradient.
- **Borders:** 1px solid `rgba(90,200,250,0.05)`.
- **Hover State:** Transform `translateY(-8px)`, box-shadow expands, border color brightens to `rgba(90,200,250,0.2)`.
- **Icons:** Gold (`--color-gold`) embedded in a slightly lighter gold translucent box.

### 4.4 Buttons
- **Primary CTA:** Pill-shaped (`border-radius: 50px`), Background `--gradient-cta`. Hover state shrinks slightly (`scale: 0.96`) and expands the teal box-shadow glow.
- **Secondary CTA:** Transparent background, 1.5px solid `--color-teal-glow` border, text is `--color-teal-light`.

---

## 5. Web Layout & Responsiveness

- **Container Max-Width:** `1200px` for optimal readability on ultra-wide monitors.
- **Mobile Breakpoint:** `< 968px`.
  - Grids collapse into single columns.
  - Text alignment shifts from left to center in the Hero section.
  - Padding reduces from `80px` to `40px` for tighter vertical flow.
- **Spacing:** Based on multiples of `8px`. Major sections have `100px` top/bottom padding.

---

## 6. Motion & Animations

- **Hover effects:** 300ms–400ms `ease` transitions on all buttons and cards. No abrupt changes.
- **Focus:** Smooth, calm. We avoid flashy or bouncing animations to preserve the spiritual, quiet tone of the brand.
