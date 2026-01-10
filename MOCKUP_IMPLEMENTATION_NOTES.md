# Mockup Implementation Notes

This document tracks the implementation status of features from the design mockups, including stubbed functionality and omitted features.

## Implemented Features ✅

### Welcome Screen (vivant_welcome_screen.png)
- ✅ Hero images at top (gradient placeholders with icons)
- ✅ "Vivant" branding with blue dot
- ✅ "Discover your city's pulse." tagline
- ✅ "Continue with Google" button with Material 3 styling
- ✅ Terms of Service & Privacy Policy text
- ✅ Light blue-gray background

### Map Discovery View (map_discovery_view.png)
- ✅ Google Maps integration
- ✅ Search bar with filter icon
- ✅ Category chips (All Places, Restaurants, Bars, Cafes)
- ✅ Floating action buttons (layers, my location)
- ✅ Category indicator FAB (coffee icon)
- ✅ Draggable bottom sheet with place cards
- ✅ Place cards with image placeholder, name, rating, category, distance
- ✅ "Open Now" status with closing time

### Place Details View (place_details_view.png)
- ✅ Hero image carousel with page indicators (1/5)
- ✅ Place name, cuisine type, price level
- ✅ Star rating with review count
- ✅ Action buttons (Directions, Call, Website, Share)
- ✅ Description text
- ✅ Address with location icon
- ✅ Mini map showing place location
- ✅ Save/bookmark button (floating)

### Search Filters (search_filters.png)
- ✅ Bottom sheet modal
- ✅ Close button and Reset button
- ✅ Price Range ($, $$, $$$, $$$$) toggle chips
- ✅ Minimum Rating slider (0-5 stars)
- ✅ Distance slider (0.5-25 mi)
- ✅ Place Features section (Outdoor Seating toggle)
- ✅ "Show X Places" apply button

### Saved Lists Screen (saved_lists_screen.png)
- ✅ List cards with emoji circles
- ✅ List name and place count
- ✅ Material 3 rounded cards with gradient backgrounds
- ✅ Navigation to list details

## Stubbed Features 🚧

These features are implemented with UI but without full backend integration:

### Map Discovery Screen
- **Search functionality**: Search bar is present but doesn't perform actual search
- **Category filtering**: Category chips change selection state but don't filter results
- **Real place data**: Using hardcoded stub data instead of API calls
- **Marker interaction**: Map markers are static, tapping doesn't show details
- **Layers button**: Button present but doesn't change map style
- **Real-time updates**: Place cards show static data, not live from location

### Place Details Screen
- **Image carousel**: Uses icon placeholders instead of actual place photos from Google Places API
- **Save to list**: Shows snackbar but doesn't actually save to backend
- **Share functionality**: Shows snackbar stub message
- **Real place data**: Uses passed-in data, not fetching from API

### Search Filters
- **Apply filters**: Closes modal but doesn't actually filter map results
- **Additional features**: Only "Outdoor Seating" is shown; mockup implies more features could be added

### Lists Screen
- **Create new list**: "+" button shows snackbar, doesn't open create dialog
- **List deletion/editing**: No UI for managing lists

### Profile Screen
- **Entire screen**: Stub placeholder with icon and text
- **User info**: No display of user name, email, or photo
- **Settings**: No settings or preferences
- **Sign out**: Available from Lists screen, not Profile

## Omitted Features ⏭️

These features from mockups were not implemented:

### Real Images
- Welcome screen hero images use gradient placeholders instead of actual photos
- Place cards use icon placeholders instead of venue photos
- Place details hero carousel uses icons instead of real photos

### Advanced Map Features
- Custom map markers with category icons
- Clustering of nearby places
- Route visualization for directions
- Street view integration

### Search Enhancements
- Search history/suggestions
- Voice search
- Nearby quick search buttons
- Search result list view

### Place Details Enhancements
- Hours of operation detailed schedule
- Menu/photos tabs
- User reviews display
- Related places recommendations
- Reservation/booking integration

### Lists Enhancements
- Create/edit/delete lists UI
- Reorder places within lists
- Share lists with others
- Collaborative lists
- List templates

### Profile Features
- User statistics (places saved, lists created, etc.)
- Settings and preferences
- Notification settings
- Privacy controls
- Account management

### Additional Filters
- Cuisine type filter
- Amenities checkboxes (parking, wifi, wheelchair accessible, etc.)
- Opening hours filter
- Rating distribution
- Sort options (distance, rating, price)

## Technical Notes

### Dependencies Added
- `google_maps_flutter: ^2.10.0` - Map integration
- `url_launcher: ^6.3.1` - Opening maps/phone/web

### Material 3 Implementation
- Using Material 3 design system (`useMaterial3: true`)
- Color scheme based on cornflower blue (#6495ED)
- Rounded corners on cards (20px) and buttons (30px)
- Proper use of color roles (primaryContainer, onSurface, etc.)

### Navigation Structure
- Bottom navigation bar with 3 tabs: Discover, Lists, Profile
- Uses IndexedStack to preserve screen state
- Map screen is default view after login

### Data Flow
- Authentication handled by existing AuthProvider
- Lists data managed by existing ListsProvider
- No API integration for place search/details (would require Google Places API key)
- Stub data used for demonstration purposes

## Recommendations for Full Implementation

1. **Google Places API Integration**
   - Add API key to environment variables
   - Implement place search service
   - Fetch place details, photos, and reviews
   - Handle API quotas and rate limiting

2. **Backend Integration**
   - Connect search filters to actual query parameters
   - Implement save/unsave places functionality
   - Add list creation/editing/deletion
   - Sync data with Convex backend

3. **Real Image Loading**
   - Integrate with Google Places Photo API
   - Implement image caching
   - Add loading states and error handling
   - Optimize image sizes for performance

4. **Enhanced UX**
   - Add loading skeletons
   - Implement pull-to-refresh on all lists
   - Add empty states with helpful CTAs
   - Show network error states with retry

5. **Profile Implementation**
   - Display user information from auth
   - Add settings (notifications, units, theme)
   - Implement account management
   - Add about/help/feedback sections

## Testing Checklist

Before testing, ensure:
- [ ] Google Maps API key is configured for Android/iOS
- [ ] Location permissions are granted
- [ ] Firebase authentication is properly configured
- [ ] Internet connection is available
- [ ] Convex backend is running (for lists functionality)

## Known Limitations

1. Map requires Google Maps API key to function properly
2. Location services must be enabled for "My Location" button
3. Some Material 3 features may not work on older Android versions
4. Bottom sheet gesture may conflict with map gestures
5. No offline support for place data
