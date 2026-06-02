class FamilyModel {
  final String id;
  final String name;
  final DateTime createdAt;

  const FamilyModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> j) => FamilyModel(
        id: j['id'] as String,
        name: j['name'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'created_at': createdAt.toIso8601String(),
      };
}
