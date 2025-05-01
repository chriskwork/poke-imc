import 'dart:io';
import 'package:pokeimc/model/database.dart';

class Menu {
  void greetings() async {
    print('');
    print('#===============#');
    print('🎉 Bienvenidos');
    print('#===============#');
    print('');

    Database db = Database();
    await db.connect();
    showInitMenu();
  }

  void showInitMenu() {
    String? option;

    do {
      stdout.write('** Elige una opción **');
      print('');
      print('-> 1. Registrar');
      print('-> 2. Iniciar sessión');
      print('-> 3. Salir');
      print('');

      option = stdin.readLineSync() ?? '';

      switch (option) {
        case '1':
          print('menu 1 selected');
          break;
        case '2':
          print('menu 2 selected');
          break;
        case '3':
          // logout()
          print('');
          exit(0);
        default:
          print('Por favor, elige una opción.\n');
          continue;
      }
    } while (option == '');
  }
}
