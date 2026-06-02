// lib/domain/entities/category.dart

class Category {
  final String  id;
  final String  familyId;
  final String  name;
  final String  icon;
  final String  color;
  final String  type; // income | expense | both
  final bool    isDefault;

  const Category({
    required this.id,
    required this.familyId,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.isDefault,
  });
}