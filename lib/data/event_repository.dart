import '../models/event.dart';
import 'app_database.dart';

/// Data-access for [Event] rows.
class EventRepository {
  Future<List<Event>> getAll() async {
    final db = await AppDatabase.instance();
    final rows = await db.query('events', orderBy: 'start');
    return rows.map(Event.fromMap).toList();
  }

  Future<Event> insert(Event event) async {
    final db = await AppDatabase.instance();
    final id = await db.insert('events', event.toMap());
    return event.copyWith(id: id);
  }

  Future<void> update(Event event) async {
    final db = await AppDatabase.instance();
    await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance();
    await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }
}
