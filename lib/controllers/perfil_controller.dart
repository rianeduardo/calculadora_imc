import 'package:calculadora_imc/database/database_helper.dart';
import 'package:calculadora_imc/models/perfil.dart';

class PerfilController {
  final _db = DatabaseHelper();

  Future<int> criarPerfil(Perfil perfil) async => _db.criarPerfil(perfil);

  Future<int> deletarPerfil(int id) async => _db.deletarPerfil(id);

  Future<List<Perfil>> listarPerfis() async => _db.getPerfis();
}
