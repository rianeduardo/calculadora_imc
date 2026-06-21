import 'package:calculadora_imc/database/database_helper.dart';
import 'package:calculadora_imc/models/perfil.dart';
import 'package:calculadora_imc/models/peso.dart';
import 'package:calculadora_imc/views/registro_peso.dart';
import 'package:calculadora_imc/views/registro_perfil.dart';
import 'package:calculadora_imc/controllers/peso_controller.dart';
import 'package:calculadora_imc/controllers/perfil_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetalhesPerfil extends StatefulWidget {
  final Perfil perfil;

  const DetalhesPerfil({super.key, required this.perfil});

  @override
  State<DetalhesPerfil> createState() => _DetalhesPerfilState();
}

class _DetalhesPerfilState extends State<DetalhesPerfil> {
  final DateFormat _dataFormatada = DateFormat('dd/MM/yyyy');
  final PesoController _pesoController = PesoController();
  final PerfilController _perfilController = PerfilController();
  late Perfil _perfil;

  @override
  void initState() {
    super.initState();
    _perfil = widget.perfil;
  }

  Map<String, dynamic> _classificarImc(double imc) {
    if (imc < 18.5) {
      return {'texto': 'Magreza', 'cor': Colors.blue};
    } else if (imc < 25) {
      return {'texto': 'Peso normal', 'cor': Colors.green};
    } else if (imc < 30) {
      return {'texto': 'Sobrepeso', 'cor': Colors.orange};
    } else if (imc < 35) {
      return {'texto': 'Obesidade grau 1', 'cor': Colors.red.shade700};
    } else if (imc < 40) {
      return {'texto': 'Obesidade grau 2', 'cor': Colors.red};
    } else {
      return {'texto': 'Obesidade grau 3 (GRAVE)', 'cor': Colors.red.shade900};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil: ${_perfil.nome} • ID: ${_perfil.id}"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => RegistroPerfil(perfil: _perfil)),
              );

              if (result == true) {
                final atualizado = await _perfilController.listarPerfis();
                // tentar localizar perfil atualizado na lista
                final encontrado = atualizado.firstWhere((p) => p.id == _perfil.id, orElse: () => _perfil);
                setState(() {
                  _perfil = encontrado;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Excluir perfil'),
                  content: Text('Deseja realmente excluir este perfil e todas as medições?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Excluir')),
                  ],
                ),
              );

              if (confirm == true) {
                await _perfilController.deletarPerfil(_perfil.id!);
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: Text(_perfil.nome.isNotEmpty ? _perfil.nome[0].toUpperCase() : '?'),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _perfil.nome,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text("Altura: ${_perfil.altura} m • Sexo: ${_perfil.sexo}"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "Histórico de Pesos e IMC",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Peso>>(
                future: DatabaseHelper().getPesos(_perfil.id!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  final pesos = snapshot.data!;

                  if (pesos.isEmpty) {
                    return Center(child: Text('Nenhum registro de peso.'));
                  }

                  // Encontrar a medição mais recente pela data
                  pesos.sort((a, b) => DateTime.parse(b.dataMedicao).compareTo(DateTime.parse(a.dataMedicao)));
                  final maisRecente = pesos.first;
                  final imcAtual = maisRecente.valor / (_perfil.altura * _perfil.altura);
                  final classificacao = _classificarImc(imcAtual);

                  return Column(
                    children: [
                      Card(
                        color: (classificacao['cor'] as Color).withOpacity(0.1),
                        child: ListTile(
                          title: Text(
                            'IMC atual: ${imcAtual.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Peso: ${maisRecente.valor} kg • Data: ${_dataFormatada.format(DateTime.parse(maisRecente.dataMedicao))}'),
                          trailing: Chip(
                            label: Text(classificacao['texto']),
                            backgroundColor: classificacao['cor'],
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: pesos.length,
                          itemBuilder: (context, i) {
                            final p = pesos[i];
                            final bmi = p.valor / (_perfil.altura * _perfil.altura);
                            final cls = _classificarImc(bmi);
                            return Dismissible(
                              key: ValueKey(p.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (dir) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text('Excluir medição'),
                                    content: Text('Deseja excluir a medição de ${p.valor} kg em ${_dataFormatada.format(DateTime.parse(p.dataMedicao))}?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancelar')),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Excluir')),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (dir) async {
                                await _pesoController.deletarPeso(p.id!);
                                setState(() {});
                              },
                              child: Card(
                                child: ListTile(
                                  leading: CircleAvatar(child: Text(p.valor.toStringAsFixed(0))),
                                  title: Text('${p.valor.toStringAsFixed(2)} kg'),
                                  subtitle: Text('${_dataFormatada.format(DateTime.parse(p.dataMedicao))} • IMC: ${bmi.toStringAsFixed(2)}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: (cls['cor'] as Color).withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          cls['texto'],
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline, color: Colors.grey[700]),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text('Excluir medição'),
                                              content: Text('Deseja excluir a medição de ${p.valor} kg em ${_dataFormatada.format(DateTime.parse(p.dataMedicao))}?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancelar')),
                                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Excluir')),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await _pesoController.deletarPeso(p.id!);
                                            setState(() {});
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tabela de Classificação do IMC', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Faixa IMC')),
                                    DataColumn(label: Text('Classificação')),
                                  ],
                                  rows: [
                                    DataRow(cells: [
                                      DataCell(Text('< 18,5')),
                                      DataCell(Container(padding: EdgeInsets.symmetric(horizontal:8, vertical:4), decoration: BoxDecoration(color: (_classificarImc(17)['cor'] as Color), borderRadius: BorderRadius.circular(12)), child: Text('Magreza', style: TextStyle(color: Colors.white)))),
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('18,5 - 24,9')),
                                      DataCell(Container(padding: EdgeInsets.symmetric(horizontal:8, vertical:4), decoration: BoxDecoration(color: (_classificarImc(22)['cor'] as Color), borderRadius: BorderRadius.circular(12)), child: Text('Peso normal', style: TextStyle(color: Colors.white)))),
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('25 - 29,9')),
                                      DataCell(Container(padding: EdgeInsets.symmetric(horizontal:8, vertical:4), decoration: BoxDecoration(color: (_classificarImc(27)['cor'] as Color), borderRadius: BorderRadius.circular(12)), child: Text('Sobrepeso', style: TextStyle(color: Colors.white)))),
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('30 - 34,9')),
                                      DataCell(Container(padding: EdgeInsets.symmetric(horizontal:8, vertical:4), decoration: BoxDecoration(color: (_classificarImc(32)['cor'] as Color), borderRadius: BorderRadius.circular(12)), child: Text('Obesidade grau 1', style: TextStyle(color: Colors.white)))),
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('35 - 39,9')),
                                      DataCell(Container(padding: EdgeInsets.symmetric(horizontal:8, vertical:4), decoration: BoxDecoration(color: (_classificarImc(37)['cor'] as Color), borderRadius: BorderRadius.circular(12)), child: Text('Obesidade grau 2', style: TextStyle(color: Colors.white)))),
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('>= 40')),
                                      DataCell(Container(padding: EdgeInsets.symmetric(horizontal:8, vertical:4), decoration: BoxDecoration(color: (_classificarImc(42)['cor'] as Color), borderRadius: BorderRadius.circular(12)), child: Text('Obesidade grau 3 (GRAVE)', style: TextStyle(color: Colors.white)))),
                                    ]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Agendar"),
        icon: Icon(Icons.add_task),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => RegistroPeso(perfil: _perfil),
          ),
        ).then((value) => setState(() {})),
      ),
    );
  }
}
