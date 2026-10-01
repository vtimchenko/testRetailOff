/// A store row from the shared `shops` spreadsheet.
class Shop {
  const Shop({required this.id, required this.name});

  final String id;
  final String name;

  @override
  bool operator ==(Object other) {
    return other is Shop && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}
