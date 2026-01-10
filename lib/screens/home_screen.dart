import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vivant/screens/places/place_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController _mapController;
  String? _mapStyle;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  int? _selectedPlaceIndex;

  // Dummy data for places
  final List<Map<String, dynamic>> _places = [
    {
      'name': 'The Golden Spoon',
      'category': 'Italian Restaurant',
      'rating': 4.8,
      'lat': 37.7749,
      'lng': -122.4194,
    },
    {
      'name': 'The Hidden Garden',
      'category': 'Vegan Cafe',
      'rating': 4.5,
      'lat': 37.7850,
      'lng': -122.4320,
    },
    {
      'name': 'The Salty Squid',
      'category': 'Seafood Shack',
      'rating': 4.2,
      'lat': 37.7900,
      'lng': -122.4050,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _getCurrentLocation();
  }

  Future<void> _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/map_style.json');
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController.setMapStyle(_mapStyle);
  }

  Future<void> _getCurrentLocation() async {
    // ... (location fetching logic remains the same)
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14.0,
      ),
    ));
    _addMarkers();
  }

  Future<BitmapDescriptor> _createMarkerBitmap(IconData icon, Color color) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = color;
    final double size = 60;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 35,
        fontFamily: icon.fontFamily,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
        canvas, Offset(size / 2 - textPainter.width / 2, size / 2 - textPainter.height / 2));

    final img = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  void _addMarkers() async {
    final Set<Marker> markers = {};

    // User's location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: await _createMarkerBitmap(FontAwesomeIcons.locationArrow, Colors.blue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // Places markers
    for (int i = 0; i < _places.length; i++) {
      final place = _places[i];
      final bool isSelected = _selectedPlaceIndex == i;
      markers.add(
        Marker(
          markerId: MarkerId(place['name']),
          position: LatLng(place['lat'], place['lng']),
          icon: await _createMarkerBitmap(
              FontAwesomeIcons.utensils, isSelected ? Colors.amber : Colors.red),
          onTap: () {
            setState(() {
              _selectedPlaceIndex = i;
            });
            _onPlaceSelected(i);
          },
        ),
      );
    }

    setState(() {
      _markers.clear();
      _markers.addAll(markers);
    });
  }

  void _onPlaceSelected(int index) {
    setState(() {
      _selectedPlaceIndex = index;
    });
    final place = _places[index];
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(place['lat'], place['lng']),
          zoom: 15.0,
        ),
      ),
    );
    _addMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.7749, -122.4194), // Default to SF
              zoom: 12.0,
            ),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: _markers,
          ),
          _buildSearchBar(),
          _buildPlacesCarousel(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  hintText: 'Search restaurants, bars, coffee...',
                  hintStyle: GoogleFonts.poppins(),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // TODO: Implement filter modal
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacesCarousel() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Container(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _places.length,
          itemBuilder: (context, index) {
            final place = _places[index];
            return _buildPlaceCard(place, index);
          },
        ),
      ),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place, int index) {
    return InkWell(
      onTap: () => _onPlaceSelected(index),
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Image.network(
                  'https://picsum.photos/seed/${place['name']}/400/200',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place['category'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          place['rating'].toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
