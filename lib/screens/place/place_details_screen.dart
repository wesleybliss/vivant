import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final String placeId;
  final String name;
  final String? cuisine;
  final int? priceLevel;
  final double rating;
  final int reviewCount;
  final String address;
  final String? description;
  final String? phone;
  final String? website;
  final double? lat;
  final double? lng;
  
  const PlaceDetailsScreen({
    super.key,
    required this.placeId,
    required this.name,
    this.cuisine,
    this.priceLevel,
    required this.rating,
    required this.reviewCount,
    required this.address,
    this.description,
    this.phone,
    this.website,
    this.lat,
    this.lng,
  });

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  int _currentImageIndex = 0;
  bool _isSaved = false;
  
  // Stub images - in real app would be from API
  final List<IconData> _imageIcons = [
    Icons.restaurant,
    Icons.fastfood,
    Icons.local_bar,
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero image carousel
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image carousel placeholder
                  PageView.builder(
                    itemCount: _imageIcons.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primaryContainer,
                              colorScheme.secondaryContainer,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          _imageIcons[index],
                          size: 80,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      );
                    },
                  ),
                  
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Image indicators
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1}/${_imageIcons.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and rating
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Cuisine, price, rating
                      Row(
                        children: [
                          if (widget.cuisine != null) ...[
                            Text(
                              widget.cuisine!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '•',
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                            ),
                          ],
                          if (widget.priceLevel != null) ...[
                            Text(
                              '\$' * widget.priceLevel!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '•',
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                            ),
                          ],
                          Icon(
                            Icons.star,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.rating}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                          Text(
                            ' (${widget.reviewCount})',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(
                            icon: Icons.directions,
                            label: 'Directions',
                            onTap: () => _launchMaps(),
                          ),
                          if (widget.phone != null)
                            _buildActionButton(
                              icon: Icons.phone,
                              label: 'Call',
                              onTap: () => _launchPhone(),
                            ),
                          if (widget.website != null)
                            _buildActionButton(
                              icon: Icons.language,
                              label: 'Website',
                              onTap: () => _launchWebsite(),
                            ),
                          _buildActionButton(
                            icon: Icons.share,
                            label: 'Share',
                            onTap: () => _share(),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Description
                      if (widget.description != null) ...[
                        Text(
                          widget.description!,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                      
                      // Address section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 24,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.address,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Mini map
                      if (widget.lat != null && widget.lng != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 200,
                            child: AbsorbPointer(
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(widget.lat!, widget.lng!),
                                  zoom: 15,
                                ),
                                markers: {
                                  Marker(
                                    markerId: MarkerId(widget.placeId),
                                    position: LatLng(widget.lat!, widget.lng!),
                                  ),
                                },
                                zoomControlsEnabled: false,
                                scrollGesturesEnabled: false,
                                zoomGesturesEnabled: false,
                                tiltGesturesEnabled: false,
                                rotateGesturesEnabled: false,
                              ),
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Save button (floating)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _isSaved = !_isSaved;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isSaved ? 'Saved to list' : 'Removed from list'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
        label: Text(_isSaved ? 'Saved' : 'Save'),
        backgroundColor: _isSaved ? colorScheme.primary : colorScheme.primaryContainer,
        foregroundColor: _isSaved ? colorScheme.onPrimary : colorScheme.onPrimaryContainer,
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _launchMaps() async {
    if (widget.lat != null && widget.lng != null) {
      final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${widget.lat},${widget.lng}',
      );
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }
  
  Future<void> _launchPhone() async {
    if (widget.phone != null) {
      final url = Uri.parse('tel:${widget.phone}');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }
  
  Future<void> _launchWebsite() async {
    if (widget.website != null) {
      final url = Uri.parse(widget.website!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }
  
  void _share() {
    // Stub - would use share package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality - stub')),
    );
  }
}
