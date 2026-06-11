import 'package:calculadora_imc/controllers/peso_controller.dart';
import 'package:intl/intl.dart';
import 'package:calculadora_imc/models/perfil.dart';
import 'package:calculadora_imc/models/peso.dart';
import 'package:calculadora_imc/views/detalhes_perfil.dart';
import 'package:flutter/material.dart';

class RegistroPeso extends StatefulWidget {
  final Perfil perfil;

  const RegistroPeso({super.key, required this.perfil});

  @override
  State<RegistroPeso> createState() => _RegistroPesoState();
}

class _RegistroPesoState extends State<RegistroPeso> {
  final _formKey = GlobalKey<FormState>();
  final _pesoController = PesoController();

  late double _valor;
  DateTime _selectedDate = DateTime.now();

  void _dataSelecionada(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _medirPeso() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final DateTime dataFinal = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );

      final novoPeso = Peso(
        perfilId: widget.perfil.id!,
        valor: _valor,
        dataMedicao: dataFinal.toIso8601String(),
      );

      try {
        await _pesoController.registrarPeso(novoPeso);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Peso registrado com sucesso!")));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalhesPerfil(perfil: widget.perfil),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Exception: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat _dataFormatada = DateFormat("dd/MM/yyyy");
    return Scaffold(
      appBar: AppBar(title: Text("Medição de Peso")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Peso (em kg)"),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Campo deve ser preenchido";
                  }

                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
                    return "Digite um número válido";
                  }

                  return null;
                },
                onSaved: (value) {
                  _valor = double.parse(value!.replaceAll(',', '.'));
                },
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Data: ${_dataFormatada.format(_selectedDate)}",
                    ),
                  ),
                  TextButton(
                    onPressed: () => _dataSelecionada(context),
                    child: Text("Selecionar Data"),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _medirPeso,
                child: Text("Registrar Peso"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
