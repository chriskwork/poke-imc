import 'package:mysql1/mysql1.dart';

class Database {
  late MySqlConnection conn;
  bool isDB = false;

  // Primera conexion: sin BD
  final tempSettings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
  );

  // Root
  final settings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
    db: 'pokeimc',
  );

  Future<void> connect() async {
    try {
      conn = await MySqlConnection.connect(settings);
    } catch (e) {
      final tempConn = await MySqlConnection.connect(tempSettings);

      print('\n🔄 Creando Base de Datos..\n');

      // Crear base de datos
      await tempConn.query('CREATE DATABASE IF NOT EXISTS pokeimc');
      await tempConn.close();

      conn = await MySqlConnection.connect(settings);
      // Crear las tablas
      await _crearTablas();

      print('🙌 Ya está!\n');
    }
  }

  // Las tablas
  Future<void> _crearTablas() async {
    await conn.query('''
        CREATE TABLE IF NOT EXISTS trainer (
        id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
        name varchar(50) NOT NULL,
        password varchar(50) NOT NULL,
        created_at timestamp DEFAULT CURRENT_TIMESTAMP
    )''');
    await conn.query('''
        CREATE TABLE IF NOT EXISTS trainer_imc (
        id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
        trainer_id int NOT NULL,
        height decimal(5,2) NOT NULL,
        weight decimal(5,2) NOT NULL,
        imc decimal(5,2) NOT NULL,
        imc_status varchar(15) NOT NULL,
        recorded_at timestamp DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (trainer_id) REFERENCES trainer(id)
    )''');
    await conn.query('''
        CREATE TABLE IF NOT EXISTS pokemon (
        id int NOT NULL PRIMARY KEY,
        name varchar(50) NOT NULL,
        height decimal(5,2) NOT NULL,
        weight decimal(5,2) NOT NULL,
        imc decimal(5,2) NOT NULL,
        imc_status varchar(15) NOT NULL
    )''');
    await conn.query('''
        CREATE TABLE IF NOT EXISTS trainer_pokemon (
        id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
        trainer_id int NOT NULL,
        pokemon_id int NOT NULL,
        pokemon_name varchar(50) NOT NULL,
        obtained_at timestamp DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (trainer_id) REFERENCES trainer(id),
        FOREIGN KEY (pokemon_id) REFERENCES pokemon(id)
    )''');
  }
}
