# Changelog

## 1.2.1 - 2024-11-22

### Added
- Added support for nested objects in database operations
  - Automatic creation of related tables
  - Foreign key relationships
  - Cascading DateTime handling in nested structures

## 1.1.2 - 2024-11-22

### Added
- Improved DateTime handling in database operations
  - DateTime fields are now stored with '_datetime' suffix
  - Automatic conversion of DateTime fields when retrieving data
  - More reliable DateTime serialization and deserialization

## 1.1.0 - 2024-11-19

### Added
- Database encryption support using SQLCipher
- Password protection for databases
- Documentation for encryption features

### Changed
- Switched from `sqflite` to `sqflite_sqlcipher` for encryption support

## 1.0.0 - 2024-11-19

Initial release of AutoSqfLite with the following features:

### Added
- Automatic table creation from Dart objects
- Dynamic schema updates for new fields
- Automatic type mapping between Dart and SQLite
- Basic CRUD operations (Create, Read, Update, Delete)
- Support for common data types:
  - Integer
  - Double
  - String
  - Boolean
  - DateTime
- Null-safe implementation
- Automatic table existence checking
- Automatic column addition for schema updates

### Supported Operations
- `insert`: Add new records
- `getAll`: Retrieve all records from a table
- `get`: Retrieve a single record by ID
- `update`: Update existing records
- `delete`: Remove records by ID

### Developer Notes
- First stable release
- Full test coverage
- Example Todo application included
- Documentation and README completed
