import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vivant/utils/logger.dart';

class PlacePrediction {
  final String description;
  final String placeId;
  final String mainText;
  final String secondaryText;

  PlacePrediction({
    required this.description,
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      description: json['description'] ?? '',
      placeId: json['place_id'] ?? '',
      mainText: json['structured_formatting']?['main_text'] ?? '',
      secondaryText: json['structured_formatting']?['secondary_text'] ?? '',
    );
  }

  @override
  String toString() => 'PlacePrediction($description)';
}

class PlaceDetails {
  final String placeId;
  final String name;
  final LatLng location;
  final String? formattedAddress;
  final double? rating;
  final int? userRatingsTotal;
  final bool? openNow;
  final List<String>? photoReferences;
  final int? priceLevel;
  final List<String>? types;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.location,
    this.formattedAddress,
    this.rating,
    this.userRatingsTotal,
    this.openNow,
    this.photoReferences,
    this.priceLevel,
    this.types,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    if (result == null) throw Exception('Result is null');
    final geometry = result['geometry'];
    final location = geometry['location'];
    
    bool? openNow;
    if (result['opening_hours'] != null) {
      openNow = result['opening_hours']['open_now'];
    }

    List<String>? photos;
    if (result['photos'] != null) {
      photos = (result['photos'] as List)
          .map((p) => p['photo_reference'] as String)
          .toList();
    }

    return PlaceDetails(
      placeId: result['place_id'],
      name: result['name'],
      location: LatLng(location['lat'], location['lng']),
      formattedAddress: result['formatted_address'],
      rating: result['rating']?.toDouble(),
      userRatingsTotal: result['user_ratings_total'],
      openNow: openNow,
      photoReferences: photos,
      priceLevel: result['price_level'],
      types: result['types'] != null ? List<String>.from(result['types']) : null,
    );
  }

  factory PlaceDetails.fromTextSearchJson(Map<String, dynamic> json) {
    final geometry = json['geometry'];
    final location = geometry['location'];
    
    bool? openNow;
    if (json['opening_hours'] != null) {
      openNow = json['opening_hours']['open_now'];
    }

    List<String>? photos;
    if (json['photos'] != null) {
      photos = (json['photos'] as List)
          .map((p) => p['photo_reference'] as String)
          .toList();
    }

    return PlaceDetails(
      placeId: json['place_id'],
      name: json['name'],
      location: LatLng(location['lat'], location['lng']),
      formattedAddress: json['formatted_address'],
      rating: json['rating']?.toDouble(),
      userRatingsTotal: json['user_ratings_total'],
      openNow: openNow,
      photoReferences: photos,
      priceLevel: json['price_level'],
      types: json['types'] != null ? List<String>.from(json['types']) : null,
    );
  }
}

class PlacesService {
  final Logger _logger = Logger('PlacesService');
  PackageInfo? _packageInfo;
  Map<String, String>? _cachedHeaders;

  String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'AIzaSyBs9FDiIQKQh9YVqI9cVgh4FWH9_AF-NUY';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  Map<String, String>? get cachedHeaders => _cachedHeaders;

  Future<Map<String, String>> _getHeaders() async {
    if (_cachedHeaders != null) return _cachedHeaders!;

    final headers = <String, String>{};
    
    if (Platform.isAndroid) {
      _packageInfo ??= await PackageInfo.fromPlatform();
      final package = _packageInfo!.packageName;
      final sha1 = dotenv.env['GOOGLE_MAPS_API_KEY_ANDROID_SHA1'];
      
      if (sha1 != null && sha1.isNotEmpty) {
        final formattedSha1 = sha1.replaceAll(':', '').toUpperCase();
        headers['X-Android-Package'] = package;
        headers['X-Android-Cert'] = formattedSha1;
        _logger.v('Adding Android restriction headers. Package: $package, SHA1 ends with: ${formattedSha1.substring(formattedSha1.length - 4)}');
      } else {
        _logger.w('Platform is Android but GOOGLE_MAPS_API_KEY_ANDROID_SHA1 not found in .env');
      }
    } else if (Platform.isIOS) {
      _packageInfo ??= await PackageInfo.fromPlatform();
      final bundleId = _packageInfo!.packageName;
      headers['X-Ios-Bundle-Identifier'] = bundleId;
    }
    
    _cachedHeaders = headers;
    return headers;
  }

  Future<List<PlaceDetails>> searchPlaces(String query) async {
    _logger.i('Searching places for query: $query');
    final url = Uri.parse(
        '$_baseUrl/textsearch/json?query=$query&key=$_apiKey');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      _logger.v('Search response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _logger.v('Search response status from body: ${data['status']}');
        if (data['status'] == 'OK') {
          final results = (data['results'] as List)
              .map((p) => PlaceDetails.fromTextSearchJson(p))
              .toList();
          _logger.i('Found ${results.length} places');
          return results;
        } else if (data['status'] == 'ZERO_RESULTS') {
          _logger.i('Zero results found for query');
          return [];
        } else {
          _logger.w('Search API returned non-OK status: ${data['status']} ${data['error_message'] ?? ''}');
        }
      } else {
        _logger.e('HTTP error searching places: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logger.e('Error searching places', e, stack);
    }
    return [];
  }

  Future<List<PlacePrediction>> getAutocomplete(String query) async {
    _logger.v('Getting autocomplete for query: $query');
    if (query.isEmpty) return [];

    final url = Uri.parse(
        '$_baseUrl/autocomplete/json?input=$query&key=$_apiKey');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return (data['predictions'] as List)
              .map((p) => PlacePrediction.fromJson(p))
              .toList();
        } else if (data['status'] == 'ZERO_RESULTS') {
          return [];
        } else {
          _logger.w('Autocomplete API returned non-OK status: ${data['status']}');
        }
      } else {
        _logger.e('HTTP error fetching autocomplete: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logger.e('Error fetching autocomplete', e, stack);
    }
    return [];
  }

  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    _logger.i('Getting place details for ID: $placeId');
    final url = Uri.parse(
        '$_baseUrl/details/json?place_id=$placeId&fields=name,geometry,formatted_address,rating,user_ratings_total,opening_hours,photos,price_level,types&key=$_apiKey');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return PlaceDetails.fromJson(data);
        } else {
          _logger.w('Details API returned non-OK status: ${data['status']}');
        }
      } else {
        _logger.e('HTTP error fetching place details: ${response.statusCode}');
      }
    } catch (e, stack) {
      _logger.e('Error fetching place details', e, stack);
    }
    return null;
  }
}