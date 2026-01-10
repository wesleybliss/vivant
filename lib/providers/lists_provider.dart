import 'package:flutter/foundation.dart';
import 'package:vivant/models/list_model.dart';
import 'package:vivant/models/saved_place.dart';
import 'package:vivant/services/convex_service.dart';
import 'package:vivant/utils/logger.dart';

class ListsProvider with ChangeNotifier {
  final ConvexService convexService;

  List<ListModel> _lists = [];
  Map<String, List<SavedPlace>> _placesByList = {};
  bool _isLoading = false;
  String? _error;

  ListsProvider({required this.convexService});

  List<ListModel> get lists => _lists;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get places for a specific list
  List<SavedPlace> getPlacesForList(String listId) {
    return _placesByList[listId] ?? [];
  }

  // Load user's lists
  Future<void> loadLists({bool ensureDefaults = true}) async {
    _setLoading(true);

    try {
      _lists = await convexService.getUserLists();
      _error = null;
      Logger.info('Loaded ${_lists.length} lists');

      // Ensure default lists exist if no lists are found
      if (_lists.isEmpty && ensureDefaults) {
        Logger.info('No lists found, ensuring default lists...');
        try {
          await convexService.ensureDefaultLists();
          // Reload lists after creating defaults
          _lists = await convexService.getUserLists();
          Logger.info('Default lists created, now have ${_lists.length} lists');
        } catch (e) {
          Logger.warning('Failed to ensure default lists: $e');
        }
      }
    } catch (e) {
      _error = 'Failed to load lists: $e';
      Logger.error(_error!);
    } finally {
      _setLoading(false);
    }
  }

  // Load places for a specific list
  Future<void> loadPlacesForList(String listId) async {
    try {
      final places = await convexService.getPlacesByList(listId);
      _placesByList[listId] = places;
      _error = null;
      Logger.info('Loaded ${places.length} places for list $listId');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load places: $e';
      Logger.error(_error!);
      notifyListeners();
    }
  }

  // Create a new list
  Future<bool> createList({
    required String name,
    required String emoji,
  }) async {
    try {
      final listId = await convexService.createList(
        name: name,
        emoji: emoji,
      );
      Logger.info('Created list: $listId');

      // Reload lists to get the updated list
      await loadLists();
      return true;
    } catch (e) {
      _error = 'Failed to create list: $e';
      Logger.error(_error!);
      notifyListeners();
      return false;
    }
  }

  // Rename a list
  Future<bool> renameList({
    required String listId,
    required String name,
  }) async {
    try {
      await convexService.renameList(listId: listId, name: name);
      Logger.info('Renamed list: $listId');

      // Update local list
      final index = _lists.indexWhere((l) => l.id == listId);
      if (index != -1) {
        _lists[index] = _lists[index].copyWith(
          name: name,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to rename list: $e';
      Logger.error(_error!);
      notifyListeners();
      return false;
    }
  }

  // Delete a list
  Future<bool> deleteList(String listId) async {
    try {
      await convexService.deleteList(listId);
      Logger.info('Deleted list: $listId');

      // Remove from local lists
      _lists.removeWhere((l) => l.id == listId);
      _placesByList.remove(listId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete list: $e';
      Logger.error(_error!);
      notifyListeners();
      return false;
    }
  }

  // Save a place to a list
  Future<bool> savePlace({
    required String listId,
    required String placeId,
    required String name,
    required double rating,
    required int reviewCount,
    int? priceLevel,
    String? cuisine,
    required String address,
    String? photoUrl,
    double? lat,
    double? lng,
  }) async {
    try {
      await convexService.savePlace(
        listId: listId,
        placeId: placeId,
        name: name,
        rating: rating,
        reviewCount: reviewCount,
        priceLevel: priceLevel,
        cuisine: cuisine,
        address: address,
        photoUrl: photoUrl,
        lat: lat,
        lng: lng,
      );
      Logger.info('Saved place: $placeId to list: $listId');

      // Reload places for this list
      await loadPlacesForList(listId);

      // Update place count for the list
      final index = _lists.indexWhere((l) => l.id == listId);
      if (index != -1) {
        final currentCount = _lists[index].placeCount ?? 0;
        _lists[index] = _lists[index].copyWith(
          placeCount: currentCount + 1,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to save place: $e';
      Logger.error(_error!);
      notifyListeners();
      return false;
    }
  }

  // Remove a place from a list
  Future<bool> removePlace(String savedPlaceId, String listId) async {
    try {
      await convexService.removePlace(savedPlaceId);
      Logger.info('Removed place: $savedPlaceId');

      // Remove from local cache
      if (_placesByList.containsKey(listId)) {
        _placesByList[listId]!.removeWhere((p) => p.id == savedPlaceId);
      }

      // Update place count for the list
      final index = _lists.indexWhere((l) => l.id == listId);
      if (index != -1) {
        final currentCount = _lists[index].placeCount ?? 0;
        _lists[index] = _lists[index].copyWith(
          placeCount: currentCount > 0 ? currentCount - 1 : 0,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to remove place: $e';
      Logger.error(_error!);
      notifyListeners();
      return false;
    }
  }

  // Clear all data (useful on sign out)
  void clear() {
    _lists = [];
    _placesByList = {};
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
