import 'dart:io';
import 'package:pokeimc/model/database.dart';
import 'package:pokeimc/model/session.dart';

class Menu {
  final db = Database();

  void greetings() async {
    print('');
    print('#===============#');
    print('🎉 Bienvenidos');
    print('#===============#');
    print('');

    await db.connect();
    showInitMenu();
  }

  void showInitMenu() {
    String? option;
    final session = UserSessionHandler(db);

    do {
      stdout.write('** Elige una opción **');
      print('\n');
      print('-> 1. Registrar');
      print('-> 2. Iniciar sessión');
      print('-> 3. Salir');
      print('');

      option = stdin.readLineSync() ?? '';

      switch (option) {
        case '1':
          // sign up
          session.signUp();
          break;
        case '2':
          // login
          session.login();
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

  void showMeinMenu(int userId) async {
    String selectedOption = '';

    do {
      print('===== OPCIONES 👇 =====');
      print('1. Ver mi Pokémon');
      print('2. Ver mi IMC');
      print('3. Salir');

      stdout.write('Elige una optión => ');
      selectedOption = stdin.readLineSync() ?? '';

      if (selectedOption == '1') {
        print('menu option 1');
      } else if (selectedOption == '2') {
        print('menu option 2');
      } else if (selectedOption == '3') {
        UserSessionHandler().logout();
      }
    } while (selectedOption.isEmpty);
  }
}
