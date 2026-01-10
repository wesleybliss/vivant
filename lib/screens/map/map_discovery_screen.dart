import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:vivant/screens/map/place_search_screen.dart';
import 'package:vivant/services/places_service.dart';
import 'package:vivant/utils/logger.dart';

class MapDiscoveryScreen extends StatefulWidget {
  const MapDiscoveryScreen({super.key});

  @override
  State<MapDiscoveryScreen> createState() => _MapDiscoveryScreenState();
}

class _MapDiscoveryScreenState extends State<MapDiscoveryScreen> {
  final Logger _logger = Logger('MapDiscoveryScreen');
  GoogleMapController? _mapController;
  final PlacesService _placesService = PlacesService();
  
  String _selectedCategory = '';
  String _searchQuery = ''; // Store the search query
  bool _isSearching = false; // Track searching state
  final List<String> _categories = ['Restaurants', 'Coffee', 'Hotels', 'Gas', 'Groceries', 'Parks'];
  List<PlaceDetails> _searchResults = []; // Store search results for the bottom sheet
  
  // Stub location - NYC
  static const LatLng _center = LatLng(40.7580, -73.9855);
  Set<Marker> _markers = {
    Marker(
      markerId: const MarkerId('luna_rooftop'),
      position: const LatLng(40.7589, -73.9851),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ),
  };

  Future<void> _handlePlaceSelection(dynamic result) async {
    if (result == null) {
      _logger.d('Place selection result is null');
      return;
    }

    _logger.i('Handling place selection: $result');
    setState(() {
      _isSearching = true;
    });

    try {
      if (result is PlacePrediction) {
        _logger.d('Prediction selected: ${result.description}');
        setState(() => _searchQuery = result.mainText);
        
        // Fetch details
        final details = await _placesService.getPlaceDetails(result.placeId);
        if (details != null) {
          _logger.d('Place details fetched: ${details.name}');
          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(details.location, 16.0),
            );
          }
          
          setState(() {
            _searchResults = [details];
            _markers = {
              Marker(
                markerId: MarkerId(details.placeId),
                position: details.location,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                infoWindow: InfoWindow(title: details.name, snippet: details.formattedAddress),
              ),
            };
          });
        } else {
          _logger.w('Failed to fetch place details for: ${result.placeId}');
        }
      } else if (result is String) {
        _logger.d('Text search submitted: $result');
        setState(() => _searchQuery = result);
        
        final results = await _placesService.searchPlaces(result);
        _logger.i('Search results found: ${results.length}');
        
        setState(() {
          _searchResults = results;
          if (results.isNotEmpty) {
            // Create markers from results
            final markers = results.map((place) => Marker(
              markerId: MarkerId(place.placeId),
              position: place.location,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              infoWindow: InfoWindow(title: place.name, snippet: place.formattedAddress),
            )).toSet();

            _markers = markers;

            // Zoom to fit all markers
            if (_mapController != null) {
              if (markers.length == 1) {
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(markers.first.position, 16.0),
                );
              } else {
                LatLngBounds bounds = _boundsFromLatLngList(markers.map((m) => m.position).toList());
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngBounds(bounds, 50),
                );
              }
            }
          } else {
            _logger.i('No results found for search query');
            _markers = {};
          }
        });
      }
    } catch (e, stack) {
      _logger.e('Error handling place selection', e, stack);
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }
  
  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
            },
            initialCameraPosition: const CameraPosition(
              target: _center,
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            // Stub markers - would be loaded from API
            markers: _markers,
          ),
          
          // Top search bar and filters
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search bar
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                      child: InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PlaceSearchScreen(),
                            ),
                          );
                          _handlePlaceSelection(result);
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.grey.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _searchQuery.isNotEmpty ? _searchQuery : 'Search here',
                                  style: TextStyle(
                                    color: _searchQuery.isNotEmpty ? Colors.black87 : Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(8),
                                )
                              else
                                IconButton(
                                  icon: const Icon(Icons.mic, color: Colors.black54),
                                  onPressed: () {},
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(8),
                                ),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: colorScheme.primaryContainer,
                                child: Text(
                                  'W',
                                  style: TextStyle(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Category chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12, right: 8),
                            child: ActionChip(
                              avatar: const Icon(Icons.tune, size: 18),
                              label: const Text('Filters'),
                              onPressed: _showFilters,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            ),
                          ),
                          ..._categories.map((category) {
                          final isSelected = category == _selectedCategory;
                          IconData? icon;
                          switch (category) {
                            case 'Restaurants': icon = Icons.restaurant; break;
                            case 'Coffee': icon = Icons.coffee; break;
                            case 'Hotels': icon = Icons.hotel; break;
                            case 'Gas': icon = Icons.local_gas_station; break;
                            case 'Groceries': icon = Icons.local_grocery_store; break;
                            case 'Parks': icon = Icons.park; break;
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              avatar: icon != null ? Icon(icon, size: 18, color: isSelected ? colorScheme.onPrimaryContainer : Colors.grey.shade700) : null,
                              label: Text(category),
                              selected: isSelected,
                              showCheckmark: false,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = selected ? category : '';
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                color: isSelected 
                                    ? colorScheme.onPrimaryContainer 
                                    : Colors.grey.shade700,
                                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              elevation: 2,
                              shadowColor: Colors.black12,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                            ),
                          );
                        }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Layers button (Top Right)
          Positioned(
            right: 16,
            top: 110, // Below search bar area
            child: FloatingActionButton.small(
              heroTag: 'layers',
              onPressed: () {},
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Square-ish
              ),
              child: const Icon(Icons.layers_outlined, color: Colors.black54),
            ),
          ),

          // Bottom Right buttons (Location & Directions)
          Positioned(
            right: 16,
            bottom: 140, // Above bottom sheet (approx)
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // My location button
                FloatingActionButton(
                  heroTag: 'location',
                  onPressed: () {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLng(_center),
                    );
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 16),
                // Directions button
                FloatingActionButton(
                  heroTag: 'directions',
                  onPressed: () {},
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.directions, color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Bottom sheet with place cards
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.15,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Text(
                        _isSearching
                            ? 'Searching...'
                            : _searchResults.isNotEmpty
                                ? 'Search results'
                                : _searchQuery.isNotEmpty
                                    ? 'No results found'
                                    : 'Explore nearby',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Places list items
                    if (_isSearching)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_searchResults.isNotEmpty)
                      ..._searchResults.map((place) => _buildPlaceCard(
                        name: place.name,
                        category: 'Place', 
                        distance: '', 
                        rating: place.rating ?? 0.0,
                        isOpen: place.openNow ?? true,
                        closingTime: '', 
                        imageIcon: Icons.location_on,
                      ))
                    else if (_searchQuery.isNotEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'No places found for "$_searchQuery"',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      _buildPlaceCard(
                        name: 'Luna Rooftop',
                        category: 'Cocktail Bar',
                        distance: '0.2 mi',
                        rating: 4.8,
                        isOpen: true,
                        closingTime: 'Closes 2 AM',
                        imageIcon: Icons.nightlife,
                      ),
                      _buildPlaceCard(
                        name: 'The Glass House',
                        category: 'Modern European',
                        distance: '0.5 mi',
                        rating: 4.7,
                        isOpen: true,
                        closingTime: 'Closes 11 PM',
                        imageIcon: Icons.restaurant,
                      ),
                      _buildPlaceCard(
                        name: 'Café Artisan',
                        category: 'Coffee Shop',
                        distance: '0.3 mi',
                        rating: 4.6,
                        isOpen: true,
                        closingTime: 'Closes 8 PM',
                        imageIcon: Icons.coffee,
                      ),
                      _buildPlaceCard(
                        name: 'Central Park North',
                        category: 'Park',
                        distance: '0.8 mi',
                        rating: 4.9,
                        isOpen: true,
                        closingTime: 'Open 24h',
                        imageIcon: Icons.park,
                      ),
                      _buildPlaceCard(
                        name: 'Joe\'s Pizza',
                        category: 'Pizza',
                        distance: '1.2 mi',
                        rating: 4.5,
                        isOpen: true,
                        closingTime: 'Closes 4 AM',
                        imageIcon: Icons.local_pizza,
                      ),
                      _buildPlaceCard(
                        name: 'Grand Hotel',
                        category: 'Hotel',
                        distance: '0.1 mi',
                        rating: 4.4,
                        isOpen: true,
                        closingTime: 'Open 24h',
                        imageIcon: Icons.hotel,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlaceCard({
    required String name,
    required String category,
    required String distance,
    required double rating,
    required bool isOpen,
    required String closingTime,
    required IconData imageIcon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: () {
        // TODO: Navigate to details
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Icon(
                imageIcon,
                size: 32,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                      const SizedBox(width: 2),
                      Text(
                        '(124)', // Placeholder review count
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.isNotEmpty ? category : "Place"}${distance.isNotEmpty ? " • $distance" : ""}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        isOpen ? 'Open' : 'Closed',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isOpen ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                      if (closingTime.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          '• $closingTime',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SearchFiltersSheet(),
    );
  }
}

// Placeholder for search filters - will be implemented next
class SearchFiltersSheet extends StatefulWidget {
  const SearchFiltersSheet({super.key});

  @override
  State<SearchFiltersSheet> createState() => _SearchFiltersSheetState();
}

class _SearchFiltersSheetState extends State<SearchFiltersSheet> {
  int _priceLevel = 2; // $ = 1, $$ = 2, $$$ = 3, $$$$ = 4
  double _minRating = 4.0;
  double _distance = 5.0; // miles
  bool _outdoorSeating = true;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Search Filters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _priceLevel = 2;
                        _minRating = 0;
                        _distance = 25;
                        _outdoorSeating = false;
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Price Range
              const Text(
                'Price Range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(4, (index) {
                  final level = index + 1;
                  final isSelected = _priceLevel == level;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
                      child: FilterChip(
                        label: Center(
                          child: Text('\$' * level),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _priceLevel = level;
                          });
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: Theme.of(context).colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                              ? Theme.of(context).colorScheme.onPrimaryContainer 
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 24),
              
              // Minimum Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Minimum Rating',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _minRating == 0 ? 'Any' : _minRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (_minRating > 0)
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                ],
              ),
              Slider(
                value: _minRating,
                min: 0,
                max: 5.0,
                divisions: 50,
                label: _minRating == 0 ? 'Any' : _minRating.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _minRating = value;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Distance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Distance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Within ${_distance.toInt()} mi',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _distance,
                min: 0.5,
                max: 25.0,
                divisions: 49,
                label: '${_distance.toStringAsFixed(1)} mi',
                onChanged: (value) {
                  setState(() {
                    _distance = value;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              const SizedBox(height: 24),
              
              // Apply button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Apply filters
                  },
                  child: const Text(
                    'Show 24 Places',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
