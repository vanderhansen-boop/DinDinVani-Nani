// lib/data/models/category_model.dart
import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.familyId,
    required super.name,
    required super.icon,
    required super.color,
    required super.type,
    required super.isDefault,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> j) => CategoryModel(
    id:        j['id']         as String,
    familyId:  j['family_id']  as String,
    name:      j['name']       as String,
    icon:      j['icon']       as String? ?? 'category',
    color:     j['color']      as String? ?? '#607D8B',
    type:      j['type']       as String? ?? 'both',
    isDefault: j['is_default'] as bool?   ?? false,
  );
}