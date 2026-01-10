import 'package:flutter/material.dart';

class PlaceSearchScreen extends StatefulWidget {
  const PlaceSearchScreen({super.key});

  @override
  State<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
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
                        decoration: const InputDecoration(
                          hintText: 'Search here',
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.grey),
                        ),
                        onSubmitted: (value) {
                          // TODO: Implement actual search
                          Navigator.pop(context, value);
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            // Recent Searches / Suggestions
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildSectionHeader('Recent'),
                  _buildRecentItem('Luna Rooftop', 'Cocktail Bar • 0.2 mi'),
                  _buildRecentItem('The Glass House', 'Modern European • 0.5 mi'),
                  const Divider(),
                  _buildSectionHeader('Try searching for'),
                  _buildSuggestionItem(Icons.restaurant, 'Restaurants'),
                  _buildSuggestionItem(Icons.local_cafe, 'Coffee'),
                  _buildSuggestionItem(Icons.hotel, 'Hotels'),
                  _buildSuggestionItem(Icons.local_gas_station, 'Gas'),
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
        Navigator.pop(context, title);
      },
    );
  }

  Widget _buildSuggestionItem(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(text),
      onTap: () {
        Navigator.pop(context, text);
      },
    );
  }
}
