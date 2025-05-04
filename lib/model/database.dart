import 'dart:convert';
import 'package:mysql1/mysql1.dart';
import 'package:http/http.dart' as http;
import 'package:pokeimc/model/imc_calculator.dart';

class Database {
  late MySqlConnection conn;
  bool isConnected = false;

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
    if (isConnected) return;

    // Esta App es para 'single user' en su dispositivo local
    // por eso, he decidido que se estará conectado al servidor
    // hasta que provoke UserSessionHandler().logout()
    try {
      conn = await MySqlConnection.connect(settings);
      isConnected = true;
    } catch (e) {
      final tempConn = await MySqlConnection.connect(tempSettings);

      // Crear base de datos
      await tempConn.query('CREATE DATABASE IF NOT EXISTS pokeimc');
      await tempConn.close();

      conn = await MySqlConnection.connect(settings);
      isConnected = true;

      // Crear las tablas
      print(
        'Es tu primera visita! Déjame preparar los datos un momento por favor.',
      );
      await _crearTablas();
      await initPokemonData();

      print('🙌 Ya está!\n');
    }
  }

  // Las tablas
  Future<void> _crearTablas() async {
    print('\n🔄 Creando Los Base de Datos..\n');

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
        id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
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

  // Llamar los datos desde el pokeAPI y gardar en el base de dato
  // usaré solo 100 pokemones.
  Future<void> initPokemonData() async {
    const String pokeAPI = 'https://pokeapi.co/api/v2/pokemon';

    print('🔄 Inicializando datos de Pokémon...');

    try {
      for (int i = 1; i <= 100; i++) {
        final res = await http.get(Uri.parse('$pokeAPI/$i'));

        if (res.statusCode == 200) {
          final data = json.decode(res.body);

          // Obtener IMC de Pokemon
          double pokemonHeight = data['height'] / 10;
          double pokemonWeight = data['weight'] / 10;
          double pokemonImc = imcCalculator(pokemonWeight, pokemonHeight);
          String pokemonImcStatus = imcStatusLogic(pokemonImc);

          await conn.query(
            'INSERT INTO pokemon (id, name, height, weight, imc, imc_status) VALUES (?, ?, ?, ?, ?, ?)',
            [
              data['id'],
              data['name'],
              pokemonHeight,
              pokemonWeight,
              pokemonImc,
              pokemonImcStatus,
            ],
          );

          if (i % 10 == 0) {
            print('🔄 Cargando $i%...');
          }
        }
      }

      print('\n');
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> ensuerConnected() async {
    if (!isConnected) {
      try {
        await connect();
        return true;
      } catch (e) {
        print('❌ Error de conexión: $e');
        return false;
      }
    }
    return true;
  }

  Future<void> close() async {
    if (isConnected) {
      await conn.close();
      isConnected = false;
    }
  }
}
