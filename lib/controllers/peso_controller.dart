import 'package:calculadora_imc/database/database_helper.dart';
import 'package:calculadora_imc/models/peso.dart';

class PesoController {
  final _db = DatabaseHelper();

  Future<int> registrarPeso(Peso peso) async => _db.medirPeso(peso);

  Future<int> deletarPeso(int id) async => _db.deletarMedicao(id);

  Future<List<Peso>> listarPesos(int id) async => _db.getPesos(id);
}
