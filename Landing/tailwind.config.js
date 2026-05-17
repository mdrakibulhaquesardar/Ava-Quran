import forms from '@tailwindcss/forms';
import containerQueries from '@tailwindcss/container-queries';

/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: "class",
  theme: {
    extend: {
        "colors": {
            "error-container": "#ffdad6",
            "surface-container-lowest": "#ffffff",
            "surface-container-high": "#e6e9e8",
            "primary-fixed-dim": "#8fd4be",
            "surface-tint": "#216a58",
            "surface-variant": "#e1e3e2",
            "surface-dim": "#d8dada",
            "on-secondary-fixed": "#0e1e1e",
            "primary-fixed": "#aaf1da",
            "on-primary-fixed": "#002019",
            "inverse-surface": "#2e3131",
            "tertiary": "#2d3d3d",
            "surface": "#f8faf9",
            "on-background": "#191c1c",
            "primary": "#004335",
            "primary-container": "#0d5c4b",
            "on-secondary-fixed-variant": "#3a4a49",
            "inverse-on-surface": "#eff1f0",
            "secondary": "#516161",
            "surface-container-highest": "#e1e3e2",
            "on-tertiary-container": "#b6c8c7",
            "on-tertiary-fixed-variant": "#3a4a49",
            "on-tertiary": "#ffffff",
            "background": "#f8faf9",
            "on-secondary-container": "#576867",
            "on-surface-variant": "#3f4945",
            "tertiary-fixed-dim": "#b8cac9",
            "surface-container-low": "#f2f4f3",
            "on-primary": "#ffffff",
            "outline": "#6f7975",
            "on-primary-container": "#8dd2bc",
            "on-surface": "#191c1c",
            "tertiary-container": "#445454",
            "on-secondary": "#ffffff",
            "error": "#ba1a1a",
            "on-primary-fixed-variant": "#005141",
            "secondary-container": "#d4e6e5",
            "outline-variant": "#bfc9c4",
            "on-error": "#ffffff",
            "on-error-container": "#93000a",
            "inverse-primary": "#8fd4be",
            "surface-bright": "#f8faf9",
            "secondary-fixed": "#d4e6e5",
            "surface-container": "#eceeed",
            "secondary-fixed-dim": "#b8cac9",
            "tertiary-fixed": "#d4e6e5",
            "on-tertiary-fixed": "#0e1e1e"
        },
        "borderRadius": {
            "DEFAULT": "0.25rem",
            "lg": "0.5rem",
            "xl": "0.75rem",
            "full": "9999px"
        },
        "spacing": {
            "stack-lg": "4rem",
            "stack-md": "1.5rem",
            "gutter-grid": "1.5rem",
            "stack-sm": "0.5rem",
            "margin-page": "2rem"
        },
        "fontFamily": {
            "label-md": ["Manrope", "sans-serif"],
            "headline-lg": ["Plus Jakarta Sans", "sans-serif"],
            "headline-xl": ["Plus Jakarta Sans", "sans-serif"],
            "body-lg": ["Manrope", "sans-serif"],
            "headline-lg-mobile": ["Plus Jakarta Sans", "sans-serif"],
            "body-md": ["Manrope", "sans-serif"]
        },
        "fontSize": {
            "label-md": ["14px", {"lineHeight": "1.4", "letterSpacing": "0.05em", "fontWeight": "600"}],
            "headline-lg": ["32px", {"lineHeight": "1.2", "letterSpacing": "-0.01em", "fontWeight": "600"}],
            "headline-xl": ["48px", {"lineHeight": "1.1", "letterSpacing": "-0.02em", "fontWeight": "700"}],
            "body-lg": ["18px", {"lineHeight": "1.6", "fontWeight": "400"}],
            "headline-lg-mobile": ["28px", {"lineHeight": "1.2", "fontWeight": "600"}],
            "body-md": ["16px", {"lineHeight": "1.5", "fontWeight": "400"}]
        }
    },
  },
  plugins: [forms, containerQueries],
}
