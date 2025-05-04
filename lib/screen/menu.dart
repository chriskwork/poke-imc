import 'dart:io';
import 'package:pokeimc/model/database.dart';
import 'package:pokeimc/model/session.dart';
import 'package:pokeimc/model/user.dart';

class Menu {
  final db = Database();

  void greetings() async {
    print('');
    print('#===============#');
    print('🎉 Bienvenidos');
    print('#===============#');
    print('');

    await db.connect();
    showInitMenu(db);
  }

  void showInitMenu(Database db) {
    String? option;
    final session = UserSessionHandler(db);

    do {
      stdout.write('** Elige una opción **');
      print('\n');
      print('-> 1. Iniciar sessión');
      print('-> 2. Registrar');
      print('-> 3. Salir');
      print('');

      option = stdin.readLineSync() ?? '';

      switch (option) {
        case '1':
          // login
          session.login();
          break;
        case '2':
          // sign up
          session.signUp();
          break;
        case '3':
          // logout()
          session.logout();
          exit(0);
        default:
          print('Por favor, elige una opción.\n');
          continue;
      }
    } while (option == '');
  }

  void showMainMenu(int userId) async {
    String selectedOption = '';
    final session = UserSessionHandler(db);

    do {
      print('===== OPCIONES 👇 =====');
      print('1. Ver mi Pokémon');
      print('2. Ver mi IMC');
      print('3. Salir');

      stdout.write('\nElige una optión => ');
      selectedOption = stdin.readLineSync() ?? '';

      if (selectedOption == '1') {
        print('Ver mi pokemon');
      } else if (selectedOption == '2') {
        await User(db).showMyImc(userId);
      } else if (selectedOption == '3') {
        session.logout();
        exit(0);
      }
    } while (selectedOption.isEmpty);
  }
}
