class Contact {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final bool isFavorite;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    this.isFavorite = false,
  });

  /// Convert a Contact object into a Map for SQLite operations.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'address': address.trim(),
      'is_favorite': isFavorite ? 1 : 0,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Create a Contact object from a database Map.
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      name: (map['name'] as String?)?.trim() ?? '',
      phone: (map['phone'] as String?)?.trim() ?? '',
      email: (map['email'] as String?)?.trim() ?? '',
      address: (map['address'] as String?)?.trim() ?? '',
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
    );
  }

  /// Create a copy of the Contact with updated fields.
  Contact copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    bool? isFavorite,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contact &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phone == other.phone &&
          email == other.email &&
          address == other.address &&
          isFavorite == other.isFavorite;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      address.hashCode ^
      isFavorite.hashCode;

  @override
  String toString() {
    return 'Contact(id: $id, name: $name, phone: $phone, email: $email, address: $address, isFavorite: $isFavorite)';
  }
}
