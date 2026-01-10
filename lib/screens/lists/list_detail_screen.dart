import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivant/models/list_model.dart';
import 'package:vivant/providers/lists_provider.dart';

class ListDetailScreen extends StatefulWidget {
  final ListModel list;

  const ListDetailScreen({super.key, required this.list});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load places for this list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListsProvider>(
        context,
        listen: false,
      ).loadPlacesForList(widget.list.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final listsProvider = Provider.of<ListsProvider>(context);
    final places = listsProvider.getPlacesForList(widget.list.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        title: Text('${widget.list.emoji}  ${widget.list.name}'),
        backgroundColor: const Color(0xFFF8F7F5),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(child: _buildBody(places)),
    );
  }

  Widget _buildBody(List places) {
    if (places.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.place_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No places yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add places to this list from search',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            place.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Address
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        place.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Review count and price level
                Row(
                  children: [
                    Text(
                      '${place.reviewCount} reviews',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (place.priceLevel != null) ...[
                      Text(
                        ' • ',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text(
                        '\$' * place.priceLevel!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    if (place.cuisine != null) ...[
                      Text(
                        ' • ',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text(
                        place.cuisine!,
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
        );
      },
    );
  }
}
