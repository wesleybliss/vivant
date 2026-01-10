import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vivant/models/list_model.dart';
import 'package:vivant/models/saved_place.dart';
import 'package:vivant/utils/logger.dart';

class ConvexService {
  final String baseUrl;
  String? _authToken;

  ConvexService({required this.baseUrl});

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Query: Get user's lists
  Future<List<ListModel>> getUserLists() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/query'),
        headers: _headers,
        body: jsonEncode({
          'path': 'lists:getUserLists',
          'args': {},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['value'] == null) return [];
        final lists = (data['value'] as List)
            .map((json) => ListModel.fromJson(json))
            .toList();
        Logger.info('Loaded ${lists.length} lists');
        return lists;
      } else {
        Logger.error('Failed to load lists: ${response.statusCode}');
        Logger.error('Response: ${response.body}');
        throw Exception('Failed to load lists: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error loading lists: $e');
      rethrow;
    }
  }

  // Query: Get places in a list
  Future<List<SavedPlace>> getPlacesByList(String listId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/query'),
        headers: _headers,
        body: jsonEncode({
          'path': 'savedPlaces:getPlacesByList',
          'args': {'listId': listId},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['value'] == null) return [];
        final places = (data['value'] as List)
            .map((json) => SavedPlace.fromJson(json))
            .toList();
        Logger.info('Loaded ${places.length} places for list $listId');
        return places;
      } else {
        throw Exception('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error loading places: $e');
      rethrow;
    }
  }

  // Query: Get user's saved place IDs
  Future<List<String>> getUserSavedPlaceIds() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/query'),
        headers: _headers,
        body: jsonEncode({
          'path': 'savedPlaces:getUserSavedPlaceIds',
          'args': {},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['value'] == null) return [];
        return List<String>.from(data['value']);
      } else {
        throw Exception('Failed to load saved place IDs: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error loading saved place IDs: $e');
      rethrow;
    }
  }

  // Mutation: Ensure default lists exist
  Future<bool> ensureDefaultLists() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mutation'),
        headers: _headers,
        body: jsonEncode({
          'path': 'lists:ensureDefaultLists',
          'args': {},
        }),
      );

      if (response.statusCode == 200) {
        Logger.info('Default lists ensured');
        return true;
      } else {
        Logger.error('Failed to ensure default lists: ${response.statusCode}');
        throw Exception('Failed to ensure default lists: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error ensuring default lists: $e');
      rethrow;
    }
  }

  // Mutation: Create a new list
  Future<String> createList({
    required String name,
    required String emoji,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mutation'),
        headers: _headers,
        body: jsonEncode({
          'path': 'lists:createList',
          'args': {
            'name': name,
            'emoji': emoji,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Logger.info('Created list: $name');
        return data['value'] as String;
      } else {
        throw Exception('Failed to create list: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error creating list: $e');
      rethrow;
    }
  }

  // Mutation: Rename a list
  Future<void> renameList({
    required String listId,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mutation'),
        headers: _headers,
        body: jsonEncode({
          'path': 'lists:renameList',
          'args': {
            'listId': listId,
            'name': name,
          },
        }),
      );

      if (response.statusCode == 200) {
        Logger.info('Renamed list to: $name');
      } else {
        throw Exception('Failed to rename list: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error renaming list: $e');
      rethrow;
    }
  }

  // Mutation: Delete a list
  Future<void> deleteList(String listId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mutation'),
        headers: _headers,
        body: jsonEncode({
          'path': 'lists:deleteList',
          'args': {'listId': listId},
        }),
      );

      if (response.statusCode == 200) {
        Logger.info('Deleted list: $listId');
      } else {
        throw Exception('Failed to delete list: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error deleting list: $e');
      rethrow;
    }
  }

  // Mutation: Save a place to a list
  Future<String> savePlace({
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
      final response = await http.post(
        Uri.parse('$baseUrl/api/mutation'),
        headers: _headers,
        body: jsonEncode({
          'path': 'savedPlaces:savePlace',
          'args': {
            'listId': listId,
            'placeId': placeId,
            'name': name,
            'rating': rating,
            'reviewCount': reviewCount,
            if (priceLevel != null) 'priceLevel': priceLevel,
            if (cuisine != null) 'cuisine': cuisine,
            'address': address,
            if (photoUrl != null) 'photoUrl': photoUrl,
            if (lat != null) 'lat': lat,
            if (lng != null) 'lng': lng,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Logger.info('Saved place: $name');
        return data['value'] as String;
      } else {
        throw Exception('Failed to save place: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error saving place: $e');
      rethrow;
    }
  }

  // Mutation: Remove a place from a list
  Future<void> removePlace(String savedPlaceId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mutation'),
        headers: _headers,
        body: jsonEncode({
          'path': 'savedPlaces:removePlace',
          'args': {'savedPlaceId': savedPlaceId},
        }),
      );

      if (response.statusCode == 200) {
        Logger.info('Removed place: $savedPlaceId');
      } else {
        throw Exception('Failed to remove place: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error removing place: $e');
      rethrow;
    }
  }
}
