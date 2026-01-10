Objective:

Design a visually stunning, modern, and intuitive mobile UI (Flutter based) for "Vivant," a vibrant Point of Interest (POI) discovery app. The design should be clean, energetic, and map-centric, making it
easy and delightful for users to find, filter, and save locations like restaurants and bars.

Core App Vibe & Aesthetic:

* Vibrant & Energetic: The design should feel alive and engaging. Use a bold, modern color palette. Consider a primary color like a lively coral, a deep teal, or an electric blue,        
  balanced with clean neutrals (off-whites, soft grays) and a dark mode variant.
* Modern & Clean: Employ a minimalist approach with clear typography, ample white space, and a consistent visual hierarchy. Use a geometric sans-serif font like Poppins, Gilroy, or       
  Circular Std for its clean and friendly look.
* Polished & Tactile: Utilize soft, multi-layered drop shadows on cards and interactive elements to create a sense of depth and lift. Interactive elements should have a subtle "glow" or  
  scaling effect on tap to feel responsive.
* Iconography: Use a high-quality, consistent icon set (e.g., Feather Icons, Material Icons) that is clear and easily understandable.

  ---                                                                                                                                                                                         

Screen-by-Screen Design Breakdown:

1. Onboarding / Authentication Screen:

* Goal: Get the user into the app seamlessly.
* Layout: A single, clean screen.
* Elements:
    * The "Vivant" logo, prominently displayed.
    * A catchy, welcoming tagline below the logo, like "Discover your city's pulse." or "Your guide to the best spots."
    * A single, primary call-to-action button: "Continue with Google", featuring the Google logo.
    * A subtle link to "Terms of Service & Privacy Policy" at the bottom.

2. Main Interactive Map & Search View (The "Home" Screen):

* Goal: Create an immersive, map-first discovery experience.
* Layout: The background should be a full-screen, interactive Google Map. UI elements float on top of it.
* Elements:
    * Top: A floating search bar with a soft shadow. It should contain a "Search" icon and placeholder text like "Search restaurants, bars, coffee...".
    * Next to the Search Bar: A "Filter" icon/button.
    * Map Content: When a search is active, the map is populated with custom-designed pins. Selected or hovered pins should be larger or a different color.
    * Bottom Results: After a search, a horizontally scrolling carousel of compact POI Summary Cards appears at the bottom. Each card shows a primary photo, the POI name, its category    
      (e.g., "Italian Restaurant"), and star rating. Tapping a card opens the full POI Detail View.
    * Bottom Navigation Bar: A clean, floating navigation bar with three distinct icons:
        * Search/Map (active): To represent the current view.
        * Saved Lists: To navigate to the user's personal collections.
        * Profile: For user settings.

3. Advanced Search Filters Interface:

* Goal: Showcase the app's powerful, fine-grained filtering capabilities in an intuitive way.
* Layout: This should be a bottom sheet modal that slides up to cover ~80% of the screen when the "Filter" button is tapped, keeping the map context visible behind it.
* Elements (organized into sections):
    * Price Range: A segmented control or pill-shaped buttons: $ $$ $$$ $$$$.
    * Rating: A selection for star ratings, e.g., 4.0+ ★, 4.5+ ★.
    * "Vibes" & Features (Multi-select): A collection of pill-shaped, selectable tags like: Good for Groups, Outdoor Seating, Live Music, Cozy, Romantic, Dog Friendly, Late Night.
    * Cuisine (if applicable): Another set of selectable tags: Italian, Mexican, Sushi, Vegan, etc.
    * Controls: A "Clear All" button and a prominent "Apply Filters" button at the bottom of the sheet.

4. POI Detail View:

* Goal: Present POI information beautifully and make saving easy.
* Layout: A bottom sheet that slides up when a map pin or summary card is tapped. It can be dragged to full-screen.
* Elements:
    * Header: A high-quality image gallery of the location.
    * Primary Info: Below the gallery, the POI name in a large, bold font. Underneath, its category and star rating.
    * Action Buttons: A prominent row of key actions: "Directions", "Call", "Website".
    * The "Save" Button: A highly visible, pill-shaped floating action button (FAB) with a "Bookmark" or "Heart" icon, allowing users to save the POI to a list. Tapping it could trigger a
      delightful animation and open a small modal to select which list to save to.
    * Detailed Info: A scrollable section with address, opening hours, user reviews, and other relevant details.

5. Saved Places & Lists Screen:

* Goal: Give the user a beautiful, personal space to organize their favorite spots.
* Layout: A clean screen with a clear heading like "My Lists". The body is a grid of List Cards.
* Elements:
    * List Card: Each card represents a user-created list (e.g., "Date Night Spots," "Favorite Coffee Shops"). The card should display the list title and could have a unique cover image  
      or a collage of POI photos from that list. A subtle icon could show the number of places in the list.
    * Create New List FAB: A floating action button with a + icon at the bottom right to allow users to create a new list. Tapping it opens a simple modal asking for a List Name and an   
      optional Icon/Color to personalize it.
    * Tapping a List: Navigates to a new screen showing all the POIs saved within that list, displayed as a vertical list or on a map.
