import 'package:pokeimc/model/database.dart';

class Pokemon {
  final Database db;

  Pokemon(this.db);

  Future<void> pokemonDetail(int userId) async {
    var checkConnection = await db.ensureConnected();

    if (checkConnection) {
      var result = await db.conn.query(
        'SELECT p.id, p.name, p.height, p.weight, p.imc, p.imc_status, tp.obtained_at FROM trainer_pokemon tp JOIN pokemon p ON tp.pokemon_id = p.id WHERE tp.trainer_id = ?',
        [userId],
      );

      print('\n====[ Detalle de tu pokemon ]====\n');
      print('Nombre: ${result.first["name"]}');
      print('Altura: ${result.first["height"]}');
      print('Peso: ${result.first["weight"]}');
      print(
        'IMC: ${result.first["imc"]} / Estado: ${result.first["imc_status"]}\n',
      );
    } else {
      print('pokemonDetail connection problem');
    }
  }
}
