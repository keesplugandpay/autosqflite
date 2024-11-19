# Changelog

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
