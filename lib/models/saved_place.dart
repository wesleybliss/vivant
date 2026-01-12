class SavedPlace {
  final String id;
  final String userId;
  final String listId;
  final String placeId; // Google Places ID
  final String name;
  final double rating;
  final int reviewCount;
  final int? priceLevel;
  final String? cuisine;
  final String address;
  final String? photoUrl;
  final double? lat;
  final double? lng;
  final int createdAt;
  final bool? importedFromGoogle;
  final String? googleMapsUrl;
  final String? countryCode;

  SavedPlace({
    required this.id,
    required this.userId,
    required this.listId,
    required this.placeId,
    required this.name,
    required this.rating,
    required this.reviewCount,
    this.priceLevel,
    this.cuisine,
    required this.address,
    this.photoUrl,
    this.lat,
    this.lng,
    required this.createdAt,
    this.importedFromGoogle,
    this.googleMapsUrl,
    this.countryCode,
  });

  factory SavedPlace.fromJson(Map<String, dynamic> json) {
    return SavedPlace(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      listId: json['listId'] as String,
      placeId: json['placeId'] as String,
      name: json['name'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      priceLevel: json['priceLevel'] as int?,
      cuisine: json['cuisine'] as String?,
      address: json['address'] as String,
      photoUrl: json['photoUrl'] as String?,
      lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      lng: json['lng'] != null ? (json['lng'] as num).toDouble() : null,
      createdAt: json['createdAt'] as int,
      importedFromGoogle: json['importedFromGoogle'] as bool?,
      googleMapsUrl: json['googleMapsUrl'] as String?,
      countryCode: json['countryCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'listId': listId,
      'placeId': placeId,
      'name': name,
      'rating': rating,
      'reviewCount': reviewCount,
      'priceLevel': priceLevel,
      'cuisine': cuisine,
      'address': address,
      'photoUrl': photoUrl,
      'lat': lat,
      'lng': lng,
      'createdAt': createdAt,
      'importedFromGoogle': importedFromGoogle,
      'googleMapsUrl': googleMapsUrl,
      'countryCode': countryCode,
    };
  }
}
