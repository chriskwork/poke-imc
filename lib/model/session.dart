import 'dart:io';

import 'package:pokeimc/model/database.dart';

class UserSessionHandler {
  final Database db;
  UserSessionHandler(this.db);

  static int? trainerID;

  String inputUsername = '';
  String _inputPassword = '';
  String trainerName = '';
  late Map<String, dynamic> user;

  // Login
  Future<void> login() async {
    try {
      do {
        stdout.write('👤 Nombre de Trainer: ');
        inputUsername = stdin.readLineSync() ?? '';
      } while (inputUsername.isEmpty);

      do {
        stdout.write('🔒 Contraseña: ');
        _inputPassword = stdin.readLineSync() ?? '';
      } while (_inputPassword.isEmpty);
    } catch (e) {
      throw Exception(e);
    }

    var result = await db.conn.query(
      'SELECT * FROM trainer WHERE name = ?, password = ?',
      [inputUsername, _inputPassword],
    );

    if (result.isNotEmpty) {
      final row = result.first;
      trainerID = row['id'];
      trainerName = row['name'];

      print('\n✔ Bienvenid@, $trainerName \n');
    } else {
      print('⚠ Login Error!');
    }
  }

  //================= Sign up ===========================
  Future<void> signUp() async {
    final Map<String, dynamic> user = await newUserInputData();

    // Insertar el nombre y password de user en base de dato
    var result = await db.conn.query(
      'INSERT INTO trainer (name, password) VALUES (?, ?)',
      [user["name"], user["password"]],
    );

    // Obtener user id
    trainerID = result.insertId;

    // Calcular IMC
    double userImcResult = user["weight"] / (user["height"] * user["height"]);
    String userImcStatus = imcStatusLogic(userImcResult);

    // Insertar la altura, el peso de user en base de dato
    await db.conn.query(
      'INSERT INTO trainer_imc (trainer_id, height, weight, imc, imc_status) VALUES (?, ?, ?, ?, ?)',
      [trainerID, user["height"], user["weight"], userImcResult, userImcStatus],
    );
  }

  Future<Map<String, dynamic>> newUserInputData() async {
    print('Registrar como Trainer\n');

    String inputName;
    String inputPassword;
    double? userHeight;
    double? userWeight;

    // Username
    do {
      stdout.write('(1/4) Crear el nombre de Trainer: ');
      inputName = stdin.readLineSync() ?? '';
      bool checkUserName = await isNameExist(inputName);
      if (!checkUserName) {
        print('❌ El nombre ya extiste. Elige otro nombre.');
        continue;
      }
    } while (inputName.isEmpty);

    // Password
    do {
      stdout.write('(2/4) Crear la contraseña: ');
      inputPassword = stdin.readLineSync() ?? '';
    } while (inputPassword.isEmpty);

    // Altura
    do {
      stdout.write('(3/4) Introduce tu altura(*metro): ');
      String inputHeight = stdin.readLineSync() ?? '';

      if (inputHeight.isEmpty) {
        print('El valor no está validad');
        continue;
      }

      userHeight = double.tryParse(inputHeight.trim().replaceAll(',', '.'));

      if (userHeight == null || userHeight <= 0) {
        print('Por favor, introduce una altura válida mayor que 0.');
        userHeight = null;
      }
    } while (userHeight == null || userHeight <= 0);

    // Peso
    do {
      stdout.write('(4/4) Introduce tu peso(*kg): ');
      String inputWeight = stdin.readLineSync() ?? '';

      if (inputWeight.isEmpty) {
        print('El valor no está validad');
        continue;
      }

      userWeight = double.tryParse(inputWeight.trim().replaceAll(',', '.'));

      if (userWeight == null || userWeight <= 0) {
        print('Por favor, introduce el peso válida mayor que 0.');
        userWeight = null;
      }
    } while (userWeight == null || userWeight <= 0);

    return user = {
      "name": inputName,
      "password": inputPassword,
      "height": userHeight,
      "weight": userWeight,
    };
  }

  // Check si el username ya existe.
  Future<bool> isNameExist(String name) async {
    try {
      var result = await db.conn.query(
        'SELECT name FROM trainer WHERE name = ?',
        [name],
      );

      if (result.first['name'] == name) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  String imcStatusLogic(double imc) {
    var imcStatus = '';

    // Clasificar estado del IMC
    if (imc < 18.5) {
      imcStatus = 'Bajo Peso';
    } else if (imc < 22.9) {
      imcStatus = 'Normal';
    } else if (imc < 24.9) {
      imcStatus = 'Sobrepeso';
    } else {
      imcStatus = 'Obesidad';
    }

    return imcStatus;
  }
  //==================================================

  // logout
  Future<void> logout() async {
    try {
      // Cerrar la conexión, Iniciar trainerID, Salir al prompt
      await db.conn.close();
      trainerID = null;
      exit(0);
    } catch (e) {
      throw Exception(e);
    }
  }

  // get trainer.id, use it for getting info.
}
