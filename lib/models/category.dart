/// A user-defined event category with a solid color (stored as ARGB int).
class Category {
  final int? id;
  final String name;
  final int color;

  const Category({this.id, required this.name, required this.color});

  Category copyWith({int? id, String? name, int? color}) => Category(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'color': color,
      };

  factory Category.fromMap(Map<String, Object?> map) => Category(
        id: map['id'] as int?,
        name: map['name'] as String,
        color: map['color'] as int,
      );
}
