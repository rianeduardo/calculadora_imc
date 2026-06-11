class Perfil {
  int? id;
  String nome;
  double altura;
  String? sexo;
  String? dataNascimento;

  Perfil({
    this.id,
    required this.nome,
    required this.altura,
    required this.sexo,
    required this.dataNascimento,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nome": nome,
      "altura": altura,
      "sexo": sexo,
      "dataNascimento": dataNascimento,
    };
  }

  factory Perfil.fromMap(Map<String, dynamic> map) {
    return Perfil(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      altura: map['altura'] as double,
      sexo: map['sexo'] as String?,
      dataNascimento: map['dataNascimento'] as String?,
    );
  }
}
