import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapDiscoveryScreen extends StatefulWidget {
  const MapDiscoveryScreen({super.key});

  @override
  State<MapDiscoveryScreen> createState() => _MapDiscoveryScreenState();
}

class _MapDiscoveryScreenState extends State<MapDiscoveryScreen> {
  GoogleMapController? _mapController;
  String _selectedCategory = 'All Places';
  final List<String> _categories = ['All Places', 'Restaurants', 'Bars', 'Cafes'];
  
  // Stub location - NYC
  static const LatLng _center = LatLng(40.7580, -73.9855);

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
            markers: {
              Marker(
                markerId: const MarkerId('luna_rooftop'),
                position: const LatLng(40.7589, -73.9851),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              ),
            },
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
                      elevation: 4,
                      borderRadius: BorderRadius.circular(30),
                      shadowColor: Colors.black26,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search places...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                          suffixIcon: Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.tune, size: 20),
                              onPressed: () {
                                _showFilters();
                              },
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Category chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((category) {
                          final isSelected = category == _selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                color: isSelected 
                                    ? colorScheme.onPrimaryContainer 
                                    : Colors.grey.shade700,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              elevation: 2,
                              shadowColor: Colors.black26,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Floating action buttons (right side)
          Positioned(
            right: 16,
            bottom: 200,
            child: Column(
              children: [
                // Layers button
                FloatingActionButton.small(
                  heroTag: 'layers',
                  onPressed: () {},
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.layers, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                // My location button
                FloatingActionButton.small(
                  heroTag: 'location',
                  onPressed: () {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLng(_center),
                    );
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Colors.black87),
                ),
              ],
            ),
          ),
          
          // Category indicator button (bottom right, coffee cup icon from mockup)
          Positioned(
            right: 16,
            bottom: 140,
            child: FloatingActionButton(
              heroTag: 'category',
              onPressed: () {},
              backgroundColor: colorScheme.primary,
              child: const Icon(Icons.coffee, color: Colors.white),
            ),
          ),
          
          // Bottom sheet with place cards
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.15,
            maxChildSize: 0.6,
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
                child: Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Places list
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        children: [
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
                        ],
                      ),
                    ),
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
    
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer,
                ],
              ),
            ),
            child: Icon(
              imageIcon,
              size: 40,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$category • $distance',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Open Now',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '• $closingTime',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
                divisions: 100,
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
