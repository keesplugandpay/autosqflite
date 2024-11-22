import 'package:autosqflite/autosqflite.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AutoSqfLite db;

  setUpAll(() {
    ffi.sqfliteFfiInit();
    ffi.databaseFactory = ffi.databaseFactoryFfi;
  });

  setUp(() async {
    db = AutoSqfLite(databaseName: 'test_db');
  });

  tearDown(() async {
    final dbClient = await db.database;
    await dbClient.close();
    await ffi.deleteDatabase('test_db');
  });

  group('DateTime and Nested Objects Tests', () {
    test('should handle DateTime fields with nested objects', () async {
      // Arrange
      final now = DateTime.now();
      final testData = {
        'title': 'Main Item',
        'created': now,
        'address': {
          'street': '123 Main St',
          'created': now.add(Duration(hours: 1)),
        },
      };

      // Act
      final id = await db.insert('items', testData);
      final result = await db.get('items', id);

      // Assert
      expect(result!['title'], 'Main Item');
      expect(result['created'], isA<DateTime>());
      expect(result['created'], now);
      expect(result['address_id'], isA<int>());
    });

    test('should retrieve nested object with DateTime fields', () async {
      // Arrange
      final now = DateTime.now();
      final address = {
        'street': '123 Main St',
        'created': now,
      };

      // Act
      final addressId = await db.insert('addresses', address);
      final result = await db.get('addresses', addressId);

      // Assert
      expect(result!['street'], '123 Main St');
      expect(result['created'], isA<DateTime>());
      expect(result['created'], now);
    });

    test('should handle multiple DateTime fields in getAll with nested objects', () async {
      // Arrange
      final now = DateTime.now();
      final items = [
        {
          'title': 'Item 1',
          'created': now,
          'address': {
            'street': 'Street 1',
            'created': now,
          },
        },
        {
          'title': 'Item 2',
          'created': now.add(Duration(days: 1)),
          'address': {
            'street': 'Street 2',
            'created': now.add(Duration(days: 1)),
          },
        },
      ];

      // Act
      for (var item in items) {
        await db.insert('items', item);
      }
      final results = await db.getAll('items');

      // Assert
      expect(results.length, 2);
      for (var result in results) {
        expect(result['created'], isA<DateTime>());
        expect(result['address_id'], isA<int>());
      }
    });

    test('should update DateTime fields in nested objects', () async {
      // Arrange
      final now = DateTime.now();
      final testData = {
        'title': 'Test Item',
        'created': now,
        'address': {
          'street': '123 Main St',
          'created': now,
        },
      };

      // Act
      final id = await db.insert('items', testData);
      final newDate = now.add(Duration(days: 1));
      await db.update(
          'items',
          {
            'created': newDate,
          },
          id);
      final result = await db.get('items', id);

      // Assert
      expect(result!['created'], newDate);
      expect(result['address_id'], isA<int>());
    });

    test('should handle null DateTime fields in nested objects', () async {
      // Arrange
      final testData = {
        'title': 'Test Item',
        'created': null,
        'address': {
          'street': '123 Main St',
          'created': null,
        },
      };

      // Act
      final id = await db.insert('items', testData);
      final result = await db.get('items', id);

      // Assert
      expect(result!['created'], null);
      expect(result['address_id'], isA<int>());
    });
  });
}
