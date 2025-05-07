import 'package:pokeimc/model/database.dart';
import 'package:mysql1/mysql1.dart';

class User {
  final Database db;

  User(this.db);

  // int? id;
  // String name;
  // String _password;
  // double height;
  // double weight;

  // User({
  //   this.id,
  //   required this.name,
  //   required String password,
  //   required this.height,
  //   required this.weight,
  // }) : _password = password;

  // String get password => _password;

  // set password(String password) {
  //   _password = password;
  // }

  // Ver mi Imc
  Future<void> showMyImc(int userId) async {
    var checkConnection = await db.ensureConnected();

    if (checkConnection) {
      try {
        var result = await db.conn.query(
          'SELECT imc, imc_status FROM trainer_imc WHERE trainer_id = ?',
          [userId],
        );

        String matchedPokemon = await findMyPokemon(userId);

        // Resultado
        print('====[ VER IMC ]====');
        print(
          'Tu IMC es ${result.first["imc"]} (${result.first["imc_status"]})\n',
        );
        print('Tu pokemon es $matchedPokemon!\n');
        print(
          'Depende de tu IMC, podrás obtener mejor(o peor) pokemon luego. 😁\n',
        );
      } catch (e) {
        throw Exception('Error showMyImc(), $e');
      }
    } else {
      print('showMyImc connection problem');
    }
  }

  // Buscar y coincidir un pokemon que tiene el mismo tipo de IMC con user.
  Future<String> findMyPokemon(int userId) async {
    print('🔍 Buscando tu pokemon..\n');

    // Se va a elegir un pokemon que tenga el mismo estado de IMC de user.
    var matchingPokemon = await db.conn.query(
      ''' 
      SELECT p.id, p.name
      FROM pokemon p
      JOIN (
          SELECT imc_status
          FROM trainer_imc
          WHERE trainer_id = ?
          ORDER BY id DESC
          LIMIT 1
      ) AS latest_imc ON p.imc_status = latest_imc.imc_status
      ORDER BY RAND()
      LIMIT 1;
      ''',
      [userId],
    );

    int matchedPokemonId = matchingPokemon.first['id'];
    String matchedPokemonName = matchingPokemon.first['name'];

    await db.conn.query(
      'INSERT INTO trainer_pokemon (trainer_id, pokemon_id, pokemon_name) VALUES (?, ?, ?)',
      [userId, matchedPokemonId, matchedPokemonName],
    );

    return matchedPokemonName;
  }

  // Check si user tiene su pokemon o no
  Future<bool> hasPokemon(int userId) async {}
}
