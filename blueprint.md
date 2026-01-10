# Vivant Application Blueprint

## Overview

Vivant is a mobile application designed to help users discover, save, and organize their favorite places. It allows users to create lists of places, view them on a map, and get details about each location.

## Style, Design, and Features

### Initial Version

*   **Authentication:** Google Sign-In.
*   **Backend:** Convex.
*   **State Management:** Provider.
*   **UI:** Basic Material Design.

### Current Version (with Material 3)

*   **Theming:**
    *   Material 3 (`useMaterial3: true`).
    *   Color scheme generated from a deep purple seed color using `ColorScheme.fromSeed`.
    *   Custom typography using `google_fonts` (Oswald, Roboto, Open Sans).
    *   Light and Dark mode support with a theme toggle.
*   **Authentication Screen (`LoginScreen`):**
    *   Updated UI to match the `vivant_welcome_screen.png` mockup.
    *   Centered layout with a large icon, app title, and tagline.
    *   Expressive and modern button style.

## Current Task: Update UI based on Mockups

### Plan

1.  **Update Theme:**
    *   [x] Add `google_fonts` dependency.
    *   [x] Create a `ThemeProvider` for light/dark mode switching.
    *   [x] Implement a Material 3 theme with `ColorScheme.fromSeed` and custom fonts in `lib/main.dart`.
2.  **Update Login Screen:**
    *   [ ] Modify `lib/screens/auth/login_screen.dart` to reflect the `vivant_welcome_screen.png` mockup.
3.  **Update Home Screen:**
    *   [ ] Modify `lib/screens/home_screen.dart` to match the `map_discovery_view.png` mockup.
4.  **Update Lists Screen:**
    *   [ ] Modify `lib/screens/lists/lists_screen.dart` to match the `saved_lists_screen.png` mockup.
5.  **Update List Detail Screen:**
    *   [ ] Modify `lib/screens/lists/list_detail_screen.dart` to match the `place_details_view.png` mockup.
6.  **Implement Search Filters:**
    *   [ ] Add search filter functionality, potentially as a modal on the home screen, based on `search_filters.png`.
