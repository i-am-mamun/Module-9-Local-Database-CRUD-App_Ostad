import 'package:flutter_test/flutter_test.dart';
import 'package:contact_app/models/contact.dart';

void main() {
  group('Contact Model Tests', () {
    test('toMap converts Contact instance into valid SQLite map', () {
      final contact = Contact(
        id: 1,
        name: 'John Doe',
        phone: '+1 234 567 8900',
        email: 'john@example.com',
        address: '123 Tech Street, Silicon Valley',
        isFavorite: true,
      );

      final map = contact.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'John Doe');
      expect(map['phone'], '+1 234 567 8900');
      expect(map['email'], 'john@example.com');
      expect(map['address'], '123 Tech Street, Silicon Valley');
      expect(map['is_favorite'], 1);
    });

    test('fromMap restores Contact instance correctly', () {
      final map = <String, dynamic>{
        'id': 42,
        'name': 'Jane Smith',
        'phone': '+880 1700 000000',
        'email': 'jane@example.com',
        'address': 'Dhaka, Bangladesh',
        'is_favorite': 1,
      };

      final contact = Contact.fromMap(map);

      expect(contact.id, 42);
      expect(contact.name, 'Jane Smith');
      expect(contact.phone, '+880 1700 000000');
      expect(contact.email, 'jane@example.com');
      expect(contact.address, 'Dhaka, Bangladesh');
      expect(contact.isFavorite, isTrue);
    });

    test('copyWith updates specified fields only', () {
      final original = Contact(
        id: 5,
        name: 'Alice',
        phone: '111',
        email: 'alice@example.com',
        address: 'Wonderland',
        isFavorite: false,
      );

      final updated = original.copyWith(
        name: 'Alice Cooper',
        isFavorite: true,
      );

      expect(updated.id, original.id);
      expect(updated.name, 'Alice Cooper');
      expect(updated.phone, original.phone);
      expect(updated.email, original.email);
      expect(updated.address, original.address);
      expect(updated.isFavorite, isTrue);
    });
  });
}
