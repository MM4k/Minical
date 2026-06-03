import 'package:flutter/foundation.dart' hide Category;

import '../data/category_repository.dart';
import '../models/category.dart';

/// Exposes the list of categories and CRUD operations to the views.
class CategoryController extends ChangeNotifier {
  CategoryController(this._repo);

  final CategoryRepository _repo;
  List<Category> _categories = [];

  List<Category> get categories => List.unmodifiable(_categories);

  Future<void> load() async {
    _categories = await _repo.getAll();
    notifyListeners();
  }

  Category? byId(int? id) {
    if (id == null) return null;
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> add(Category category) async {
    await _repo.insert(category);
    await load();
  }

  Future<void> update(Category category) async {
    await _repo.update(category);
    await load();
  }

  Future<void> remove(int id) async {
    await _repo.delete(id);
    await load();
  }
}
