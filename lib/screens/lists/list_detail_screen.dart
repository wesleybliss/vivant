import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivant/models/list_model.dart';
import 'package:vivant/models/saved_place.dart';
import 'package:vivant/providers/lists_provider.dart';
import 'package:vivant/screens/places/place_detail_screen.dart';

class ListDetailScreen extends StatefulWidget {
  final ListModel list;

  const ListDetailScreen({
    super.key,
    required this.list,
  });

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load places for this list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListsProvider>(context, listen: false)
          .loadPlacesForList(widget.list.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final listsProvider = Provider.of<ListsProvider>(context);
    final places = listsProvider.getPlacesForList(widget.list.id);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.list.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(widget.list.name),
          ],
        ),
      ),
      body: SafeArea(
        child: _buildBody(context, places),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<SavedPlace> places) {
    final theme = Theme.of(context);

    if (places.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.place_outlined,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              Text(
                'No places yet',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'Add places to this list from the search screen.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaceDetailScreen(
                    place: {
                      'name': place.name,
                      'rating': place.rating,
                      'lat': place.lat,
                      'lng': place.lng,
                    },
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Place name and rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              place.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Address
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          place.address,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Review count and price level
                  Row(
                    children: [
                      Text(
                        '${place.reviewCount} reviews',
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (place.priceLevel != null) ...[
                        Text(
                          ' • ',
                          style: TextStyle(color: theme.textTheme.bodySmall?.color),
                        ),
                        Text(
                          '\$' * place.priceLevel!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      if (place.cuisine != null) ...[
                        Text(
                          ' • ',
                          style: TextStyle(color: theme.textTheme.bodySmall?.color),
                        ),
                        Text(
                          place.cuisine!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
