class ListModel {
  final String id;
  final String userId;
  final String name;
  final String emoji;
  final bool isDefault;
  final int createdAt;
  final int updatedAt;
  final int? placeCount;

  ListModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.emoji,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    this.placeCount,
  });

  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      isDefault: json['isDefault'] as bool,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int,
      placeCount: json['placeCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'name': name,
      'emoji': emoji,
      'isDefault': isDefault,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (placeCount != null) 'placeCount': placeCount,
    };
  }

  ListModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? emoji,
    bool? isDefault,
    int? createdAt,
    int? updatedAt,
    int? placeCount,
  }) {
    return ListModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      placeCount: placeCount ?? this.placeCount,
    );
  }
}
