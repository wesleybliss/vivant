import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vivant/services/places_service.dart';

class PlaceSearchScreen extends StatefulWidget {
  const PlaceSearchScreen({super.key});

  @override
  State<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final PlacesService _placesService = PlacesService();
  
  List<PlacePrediction> _predictions = [];
  Timer? _debounce;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _predictions = [];
        _isLoading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _isLoading = true);
      final results = await _placesService.getAutocomplete(query);
      if (mounted) {
        setState(() {
          _predictions = results;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: _onSearchChanged,
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            Navigator.pop(context, value);
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search here',
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  if (_isLoading)
                     const Padding(
                       padding: EdgeInsets.symmetric(horizontal: 8.0),
                       child: SizedBox(
                         width: 20,
                         height: 20,
                         child: CircularProgressIndicator(strokeWidth: 2),
                       ),
                     )
                  else
                    IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: () {},
                    ),
                ],
              ),
            ),
            
            // Recent Searches / Suggestions / Predictions
            Expanded(
              child: _predictions.isNotEmpty
                  ? ListView.builder(
                      itemCount: _predictions.length,
                      itemBuilder: (context, index) {
                        final prediction = _predictions[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on_outlined, color: Colors.black54),
                          title: Text(
                            prediction.mainText,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(prediction.secondaryText),
                          onTap: () {
                            Navigator.pop(context, prediction);
                          },
                        );
                      },
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        if (_searchController.text.isEmpty) ...[
                          _buildSectionHeader('Recent'),
                          _buildRecentItem('Luna Rooftop', 'Cocktail Bar • 0.2 mi'),
                          _buildRecentItem('The Glass House', 'Modern European • 0.5 mi'),
                          const Divider(),
                          _buildSectionHeader('Try searching for'),
                          _buildSuggestionItem(Icons.restaurant, 'Restaurants'),
                          _buildSuggestionItem(Icons.local_cafe, 'Coffee'),
                          _buildSuggestionItem(Icons.hotel, 'Hotels'),
                          _buildSuggestionItem(Icons.local_gas_station, 'Gas'),
                        ]
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildRecentItem(String title, String subtitle) {
    return ListTile(
      leading: const Icon(Icons.history, color: Colors.grey),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        // TODO: Handle mock recent items properly
        Navigator.pop(context, PlacePrediction(
          description: title,
          placeId: 'mock_id',
          mainText: title,
          secondaryText: subtitle
        ));
      },
    );
  }

  Widget _buildSuggestionItem(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(text),
      onTap: () {
         // TODO: Handle category search
         Navigator.pop(context, text); 
      },
    );
  }
}
