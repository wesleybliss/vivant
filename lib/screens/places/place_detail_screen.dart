import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> place;

  const PlaceDetailScreen({
    super.key,
    required this.place,
  });

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<String> images = [
      'https://picsum.photos/seed/${widget.place['name']}/800/600',
      'https://picsum.photos/seed/${widget.place['name']}_2/800/600',
      'https://picsum.photos/seed/${widget.place['name']}_3/800/600',
    ];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement save to list
        },
        label: Text('Save', style: GoogleFonts.poppins()),
        icon: const Icon(Icons.bookmark_border),
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: theme.colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: PageView.builder(
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    images[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
              stretchModes: const [StretchMode.zoomBackground],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.place['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          widget.place['category'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          widget.place['rating'].toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton(context, 'Directions', FontAwesomeIcons.directions, () {}),
                        _buildActionButton(context, 'Call', FontAwesomeIcons.phone, () {}),
                        _buildActionButton(context, 'Website', FontAwesomeIcons.globe, () {}),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'About',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                      style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(widget.place['lat'], widget.place['lng']),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId(widget.place['name']),
                              position: LatLng(widget.place['lat'], widget.place['lng']),
                            )
                          },
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 80), // For FAB
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return Column(
      children: [
        FloatingActionButton(
          onPressed: onPressed,
          heroTag: title,
          child: FaIcon(icon),
          mini: true,
        ),
        const SizedBox(height: 8),
        Text(title, style: GoogleFonts.poppins(fontSize: 12)),
      ],
    );
  }
}
