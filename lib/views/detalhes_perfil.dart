import 'package:calculadora_imc/database/database_helper.dart';
import 'package:calculadora_imc/models/perfil.dart';
import 'package:calculadora_imc/models/peso.dart';
import 'package:calculadora_imc/views/registro_peso.dart';
import 'package:flutter/material.dart';

class DetalhesPerfil extends StatefulWidget {
  final Perfil perfil;

  const DetalhesPerfil({super.key, required this.perfil});

  @override
  State<DetalhesPerfil> createState() => _DetalhesPerfilState();
}

class _DetalhesPerfilState extends State<DetalhesPerfil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil: ${widget.perfil.nome} • ID: ${widget.perfil.id}"),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text("Nome: ${widget.perfil.nome}"),
            subtitle: Text(
              "Altura: ${widget.perfil.altura} • Sexo: ${widget.perfil.sexo}",
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              "Histórico de Pesos e IMC",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Peso>>(
              future: DatabaseHelper().getPesos(widget.perfil.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                final pesos = snapshot.data!;
                return ListView.builder(
                  itemCount: pesos.length,
                  itemBuilder: (context, i) => Card(
                    child: ListTile(
                      title: Text(pesos[i].valor.toString()),
                      subtitle: Text(
                        "IMC: ${(pesos[i].valor / (widget.perfil.altura * widget.perfil.altura)).toStringAsFixed(2)} • ${pesos[i].dataMedicao}",
                      ),
                      trailing: Icon(Icons.calendar_today),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Agendar"),
        icon: Icon(Icons.add_task),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => RegistroPeso(perfil: widget.perfil),
          ),
        ).then((value) => setState(() {})),
      ),
    );
  }
}
