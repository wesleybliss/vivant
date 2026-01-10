import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivant/providers/auth_provider.dart';
import 'package:vivant/providers/lists_provider.dart';
import 'package:vivant/screens/lists/list_detail_screen.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListsProvider>(context, listen: false).loadLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final listsProvider = Provider.of<ListsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              listsProvider.clear();
            },
          ),
        ],
      ),
      body: SafeArea(child: _buildBody(listsProvider)),
    );
  }

  Widget _buildBody(ListsProvider listsProvider) {
    if (listsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (listsProvider.lists.isEmpty) {
      return const Center(child: Text('No saved lists yet'));
    }

    return RefreshIndicator(
      onRefresh: () => listsProvider.loadLists(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: listsProvider.lists.length,
        separatorBuilder: (_, __) => const Divider(height: 32),
        itemBuilder: (context, index) {
          final list = listsProvider.lists[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListDetailScreen(list: list),
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(list.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${list.placeCount ?? 0} places',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
          );
        },
      ),
    );
  }
}
