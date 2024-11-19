import 'package:flutter_test/flutter_test.dart';
import 'package:autosqflite/autosqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize FFI for testing
  setUp(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AutoSqfLite Tests', () {
    late AutoSqfLite db;

    setUp(() {
      db = AutoSqfLite(databaseName: 'test_auto');
    });

    test('Database initialization and connection', () async {
      // Test constructor and database getter
      expect(db.databaseName, equals('test_auto'));
      final database = await db.database;
      expect(database, isNotNull);
      expect(database.isOpen, isTrue);

      // Test singleton behavior of database getter
      final database2 = await db.database;
      expect(identical(database, database2), isTrue);
    });

    group('Table Operations', () {
      test('Table creation with different data types', () async {
        final testData = {
          'int_field': 42,
          'double_field': 3.14,
          'text_field': 'Hello',
          'bool_field': true,
          'datetime_field': DateTime.now().millisecondsSinceEpoch,
          'null_field': null,
        };

        await db.insert('type_test', testData);

        final results = await db.getAll('type_test');
        expect(results.length, equals(1));

        final savedData = results.first;
        expect(savedData['int_field'], isA<int>());
        expect(savedData['double_field'], isA<num>());
        expect(savedData['text_field'], isA<String>());
        expect(savedData['bool_field'], equals(1));
        expect(savedData['datetime_field'], isA<int>());
      });

      test('Adding new columns to existing table', () async {
        // Create initial table
        final initialData = {'name': 'John'};
        await db.insert('users', initialData);

        // Add new column through new data
        final newData = {
          'name': 'Jane',
          'age': 25,
          'email': 'jane@example.com',
        };
        await db.insert('users', newData);

        // Verify both records and new columns
        final results = await db.getAll('users');
        expect(results.length, equals(2));

        final secondRecord = results.where((r) => r['name'] == 'Jane').first;
        expect(secondRecord['age'], equals(25));
        expect(secondRecord['email'], equals('jane@example.com'));
      });
    });

    group('CRUD Operations', () {
      test('Insert and GetAll', () async {
        final testData1 = {'name': 'John', 'age': 30};
        final testData2 = {'name': 'Jane', 'age': 25};

        await db.insert('users', testData1);
        await db.insert('users', testData2);

        final results = await db.getAll('users');
        expect(results.length, equals(2));
        expect(results.any((r) => r['name'] == 'John'), isTrue);
        expect(results.any((r) => r['name'] == 'Jane'), isTrue);
      });

      test('Get single record', () async {
        // Test get on empty table
        final emptyResult = await db.get('users', 1);
        expect(emptyResult, isNull);

        // Test get with existing record
        final testData = {'name': 'John', 'age': 30};
        await db.insert('users', testData);

        final results = await db.getAll('users');
        final id = results.first['id'] as int;

        final record = await db.get('users', id);
        expect(record, isNotNull);
        expect(record!['name'], equals('John'));
        expect(record['age'], equals(30));

        // Test get with non-existent id
        final nonExistent = await db.get('users', -1);
        expect(nonExistent, isNull);
      });

      test('Update record', () async {
        // Insert initial record
        final initialData = {'name': 'John', 'age': 30};
        await db.insert('users', initialData);

        final results = await db.getAll('users');
        final id = results.first['id'] as int;

        // Update with new data and new column
        final updateData = {
          'name': 'John Updated',
          'age': 31,
          'email': 'john@example.com',
        };

        final updateCount = await db.update('users', updateData, id);
        expect(updateCount, equals(1));

        // Verify update
        final updated = await db.get('users', id);
        expect(updated!['name'], equals('John Updated'));
        expect(updated['age'], equals(31));
        expect(updated['email'], equals('john@example.com'));

        // Test update on non-existent record
        final nonExistentUpdate = await db.update('users', updateData, -1);
        expect(nonExistentUpdate, equals(0));
      });

      test('Delete record', () async {
        // Test delete on empty table
        final emptyDelete = await db.delete('users', 1);
        expect(emptyDelete, equals(0));

        // Insert and delete record
        final testData = {'name': 'John', 'age': 30};
        await db.insert('users', testData);

        final results = await db.getAll('users');
        final id = results.first['id'] as int;

        final deleteCount = await db.delete('users', id);
        expect(deleteCount, equals(1));

        // Verify deletion
        final deleted = await db.get('users', id);
        expect(deleted, isNull);

        // Test delete on non-existent record
        final nonExistentDelete = await db.delete('users', -1);
        expect(nonExistentDelete, equals(0));
      });
    });

    tearDown(() async {
      final dbPath = await databaseFactory.getDatabasesPath();
      await deleteDatabase('$dbPath/test_auto.db');
    });
  });
}
