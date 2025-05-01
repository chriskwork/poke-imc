import 'package:mysql1/mysql1.dart';

class DatabaseConfig {
  static final settings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
    db: 'pokeimc',
  );
}
