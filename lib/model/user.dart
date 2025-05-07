import 'package:pokeimc/model/database.dart';

class User {
  final Database db;

  User(this.db);

  // Ver mi Imc
  Future<void> showMyImc(int userId) async {
    var checkConnection = await db.ensureConnected();

    if (checkConnection) {
      try {
        var trainerImc = await db.conn.query(
          'SELECT imc, imc_status FROM trainer_imc WHERE trainer_id = ?',
          [userId],
        );

        var trainerPokemonName = await getTrainerPokemonName(userId);

        // Resultado
        print('\n====[ VER IMC ]====\n');
        print(
          'Tu IMC es ${trainerImc.first["imc"]} (${trainerImc.first["imc_status"]})',
        );
        print('Tu pokemon es $trainerPokemonName! \n');
        print(
          '(Depende de tu IMC, podrás obtener mejor(o peor) pokemon luego. 😁)\n',
        );
      } catch (e) {
        throw Exception('Error showMyImc(), $e');
      }
    } else {
      print('showMyImc connection problem');
    }
  }

  Future<String> getTrainerPokemonName(int userId) async {
    var result = await db.conn.query(
      'SELECT * FROM trainer_pokemon WHERE trainer_id = ?',
      [userId],
    );

    return result.first.isNotEmpty ? result.first['pokemon_name'] : '';
  }

  // Buscar y coincidir un pokemon que tiene el mismo tipo de IMC con user.
  Future<void> matchMyPokemon(int userId) async {
    // String getUserPokemonName = await hasPokemon(userId);

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
  }

  // Check si user tiene su pokemon o no
  // (No se necesita ahora: matching pokemon solo se eje una vez en Signup)

  // Future<String> hasPokemon(int userId) async {
  //   try {
  //     var result = await db.conn.query(
  //       'SELECT * FROM trainer_pokemon WHERE trainer_id = ?',
  //       [userId],
  //     );

  //     String trainerPokemonName = result.first['pokemon_name'];

  //     return trainerPokemonName.isEmpty
  //         ? trainerPokemonName = ''
  //         : trainerPokemonName;
  //   } catch (e) {
  //     throw Exception('hasPokemon() error, $e');
  //   }
  // }
}
