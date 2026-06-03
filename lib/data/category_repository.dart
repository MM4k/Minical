import '../models/category.dart';
import 'app_database.dart';

/// Data-access for [Category] rows.
class CategoryRepository {
  Future<List<Category>> getAll() async {
    final db = await AppDatabase.instance();
    final rows = await db.query('categories', orderBy: 'name COLLATE NOCASE');
    return rows.map(Category.fromMap).toList();
  }

  Future<Category> insert(Category category) async {
    final db = await AppDatabase.instance();
    final id = await db.insert('categories', category.toMap());
    return category.copyWith(id: id);
  }

  Future<void> update(Category category) async {
    final db = await AppDatabase.instance();
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance();
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
