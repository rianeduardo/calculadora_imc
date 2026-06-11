class Peso {
  int? id;
  int perfilId;
  double valor;
  String dataMedicao;

  Peso({
    this.id,
    required this.perfilId,
    required this.valor,
    required this.dataMedicao,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "perfilId": perfilId,
      "valor": valor,
      "dataMedicao": dataMedicao,
    };
  }

  factory Peso.fromMap(Map<String, dynamic> map) {
    return Peso(
      id: map['id'] as int?,
      perfilId: map['perfilId'] as int,
      valor: map['valor'] as double,
      dataMedicao: map['dataMedicao'] as String,
    );
  }
}
