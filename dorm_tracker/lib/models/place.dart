class Place {
  final int id;
  final int dormId;
  final String name;

  Place({required this.id, required this.dormId, required this.name});

  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'] as int,
      dormId: map['dorm_id'] as int,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dorm_id': dormId,
      'name': name,
    };
  }
}
