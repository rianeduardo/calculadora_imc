import 'package:flutter/material.dart';
import 'package:calculadora_imc/controllers/perfil_controller.dart';
import 'package:calculadora_imc/models/perfil.dart';

class RegistroPerfil extends StatefulWidget {
  const RegistroPerfil({super.key});

  @override
  State<RegistroPerfil> createState() => _RegistroPerfilState();
}

class _RegistroPerfilState extends State<RegistroPerfil> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  late double _altura;
  String? _sexo = "Masculino";
  String? _dataNascimento;

  final PerfilController _perfilController = PerfilController();
  final _dataController = TextEditingController();

  Future<void> _selecionarData() async {
    DateTime? data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (data != null) {
      String dataFormatada = data.toIso8601String();
      setState(() {
        _dataNascimento = dataFormatada;
        _dataController.text =
            "${data.day.toString().padLeft(2, '0')}/"
            "${data.month.toString().padLeft(2, '0')}/"
            "${data.year}";
      });
    }
  }

  // Função para processar o salvamento
  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final novoPerfil = Perfil(
        nome: _nomeController.text,
        altura: _altura,
        sexo: _sexo!,
        dataNascimento: _dataNascimento!,
      );

      bool sucesso = await _perfilController.criarPerfil(novoPerfil) > 0;

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Perfil cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar o perfil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastrar Novo Perfil")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo Nome do Pet
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: "Seu nome",
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Informe seu nome" : null,
              ),
              SizedBox(height: 16),

              // Campo Raça
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Altura (em metros)",
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Campo deve ser preenchido";
                  }

                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
                    return "Digite uma altura válida";
                  }

                  return null;
                },
                onSaved: (value) {
                  _altura = double.parse(value!.replaceAll(',', '.'));
                },
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Sexo",
                  border: OutlineInputBorder(),
                ),
                initialValue: _sexo,
                items: const [
                  DropdownMenuItem(
                    value: "Masculino",
                    child: Text("Masculino"),
                  ),
                  DropdownMenuItem(value: "Feminino", child: Text("Feminino")),
                ],
                onChanged: (value) {
                  setState(() {
                    _sexo = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return "Selecione um sexo";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _dataController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Data de nascimento",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _selecionarData,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Selecione uma data";
                  }
                  return null;
                },
              ),

              SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text("Salvar Cadastro"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
