import '../datasources/categories_remote_datasource.dart';
import '../models/category_model.dart';

class CategoriesRepositoryImpl {
  final CategoriesRemoteDataSource remote;
  CategoriesRepositoryImpl(this.remote);

  Future<List<CategoryModel>> list(String familyId) => remote.list(familyId);
}
