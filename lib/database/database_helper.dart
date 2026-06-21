import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:calculadora_imc/models/perfil.dart';
import 'package:calculadora_imc/models/peso.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Database? _banco;

  Future<Database> get database async {
    if (_banco != null) return _banco!;

    _banco = await _initDb();
    return _banco!;
  }

  Future<Database> _initDb() async {
    String caminho = join(await getDatabasesPath(), 'calculadora.db');

    return await openDatabase(
      caminho,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE perfis(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, altura REAL, sexo TEXT, dataNascimento TEXT)''',
        );
        await db.execute(
          '''CREATE TABLE pesos(id INTEGER PRIMARY KEY AUTOINCREMENT, perfilId INTEGER, valor REAL, dataMedicao TEXT, FOREIGN KEY(perfilId) REFERENCES perfis(id) ON DELETE CASCADE)''',
        );
      },
      onConfigure: (db) async =>
          await db.execute('''PRAGMA foreign_key = ON'''),
    );
  }

  Future<List<Perfil>> getPerfis() async {
    final List<Map<String, dynamic>> maps = await (await database).query(
      "perfis",
      orderBy: "nome ASC",
    );

    return List.generate(maps.length, (e) => Perfil.fromMap(maps[e]));
  }

  Future<int> criarPerfil(Perfil perfil) async =>
      (await database).insert("perfis", perfil.toMap());

    Future<int> atualizarPerfil(Perfil perfil) async =>
      (await database).update("perfis", perfil.toMap(), where: "id = ?", whereArgs: [perfil.id]);

  Future<int> deletarPerfil(int id) async =>
      (await database).delete("perfis", where: "id = ?", whereArgs: [id]);

  Future<List<Peso>> getPesos(int perfilId) async {
    final List<Map<String, dynamic>> maps = await (await database).query(
      "pesos",
      where: "perfilId = ?",
      whereArgs: [perfilId],
      orderBy: "valor ASC",
    );

    return List.generate(maps.length, (e) => Peso.fromMap(maps[e]));
  }

  Future<int> medirPeso(Peso peso) async =>
      (await database).insert("pesos", peso.toMap());

  Future<int> deletarMedicao(int id) async =>
      (await database).delete("pesos", where: "id = ?", whereArgs: [id]);
}
