import 'package:flutter/material.dart';
import 'package:calculadora_imc/controllers/perfil_controller.dart';
import 'package:calculadora_imc/models/perfil.dart';
import 'package:calculadora_imc/views/detalhes_perfil.dart';
import 'package:calculadora_imc/views/registro_perfil.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PerfilController _controller = PerfilController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calculadora IMC - Meus Perfis")),
      body: FutureBuilder<List<Perfil>>(
        future: _controller.listarPerfis(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final perfis = snapshot.data!;
          return ListView.builder(
            itemCount: perfis.length,
            itemBuilder: (context, i) => ListTile(
              leading: Icon(Icons.people),
              title: Text(perfis[i].nome),
              subtitle: Text(
                perfis[i].altura.toString() + "•" + perfis[i].sexo.toString(),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => DetalhesPerfil(perfil: perfis[i]),
                ),
              ).then((value) => setState(() {})),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => RegistroPerfil()),
        ).then((value) => setState(() {})),
      ),
    );
  }
}
