import 'package:flutter/material.dart';

import 'atividade.dart';

// Tela de cadastro - devolve a nova Atividade pelo Navigator.pop
class CadastroTela extends StatefulWidget {
  const CadastroTela({super.key, required this.id});

  // Id recebido da tela principal para a nova atividade.
  final int id;

  @override
  State<CadastroTela> createState() => _CadastroTelaState();
}

class _CadastroTelaState extends State<CadastroTela> {
  final TextEditingController _disciplina = TextEditingController();
  final TextEditingController _nome = TextEditingController();
  final TextEditingController _data = TextEditingController();

  DateTime? _dataEntrega;
  Prioridade _prioridade = Prioridade.media;
  bool _importante = false;
  bool _tentouSalvar = false;

  @override
  void dispose() {
    _disciplina.dispose();
    _nome.dispose();
    _data.dispose();
    super.dispose();
  }

  String? _erroTexto(TextEditingController campo) =>
      _tentouSalvar && campo.text.trim().isEmpty ? 'Campo obrigatório' : null;

  Future<void> _escolherData() async {
    final hoje = DateUtils.dateOnly(DateTime.now());
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _dataEntrega ?? hoje,
      firstDate: DateTime(hoje.year - 1),
      lastDate: DateTime(hoje.year + 5),
      helpText: 'Data de entrega',
    );
    if (escolhida == null) return;
    setState(() {
      _dataEntrega = escolhida;
      _data.text = formatarData(escolhida);
    });
  }

  void _salvar() {
    setState(() => _tentouSalvar = true);

    final disciplina = _disciplina.text.trim();
    final nome = _nome.text.trim();
    final data = _dataEntrega;
    if (disciplina.isEmpty || nome.isEmpty || data == null) return;

    final atividade = Atividade(
      id: widget.id,
      disciplina: disciplina,
      nome: nome,
      dataEntrega: data,
      prioridade: _prioridade,
      importante: _importante,
    );
    Navigator.pop(context, atividade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova atividade')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _disciplina,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Disciplina',
                hintText: 'Ex.: Programação Mobile',
                prefixIcon: const Icon(Icons.menu_book_outlined),
                errorText: _erroTexto(_disciplina),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nome,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Nome da atividade',
                hintText: 'Ex.: Trabalho de Flutter',
                prefixIcon: const Icon(Icons.edit_note),
                errorText: _erroTexto(_nome),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _data,
              readOnly: true,
              onTap: _escolherData,
              decoration: InputDecoration(
                labelText: 'Data de entrega',
                hintText: 'Toque para escolher',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                errorText: _tentouSalvar && _dataEntrega == null
                    ? 'Escolha a data de entrega'
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Prioridade',
                prefixIcon: Icon(Icons.flag_outlined),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Prioridade>(
                  value: _prioridade,
                  isExpanded: true,
                  items: [
                    for (final p in Prioridade.values)
                      DropdownMenuItem(
                        value: p,
                        child: Text('${p.emoji}  ${p.rotulo}'),
                      ),
                  ],
                  onChanged: (p) {
                    if (p != null) setState(() => _prioridade = p);
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _importante,
              onChanged: (v) => setState(() => _importante = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text('Atividade importante'),
              subtitle: const Text('Destaca a atividade com uma ⭐ na lista'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.check),
              label: const Text('Cadastrar atividade'),
            ),
          ],
        ),
      ),
    );
  }
}
