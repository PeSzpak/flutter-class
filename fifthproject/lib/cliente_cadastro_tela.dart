import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'clientes_tela.dart';
import 'consulta_service.dart';

// Formulário de cadastro - devolve o novo Cliente pelo Navigator.pop
class ClienteCadastroTela extends StatefulWidget {
  const ClienteCadastroTela({super.key, required this.servico});

  final ConsultaService servico;

  @override
  State<ClienteCadastroTela> createState() => _ClienteCadastroTelaState();
}

class _ClienteCadastroTelaState extends State<ClienteCadastroTela> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _cpf = TextEditingController();
  final _email = TextEditingController();
  final _telefone = TextEditingController();
  final _cep = TextEditingController();
  final _logradouro = TextEditingController();
  final _numero = TextEditingController();
  final _bairro = TextEditingController();
  final _cidade = TextEditingController();
  final _uf = TextEditingController();

  bool _buscandoCep = false;
  String? _erroCep;

  @override
  void dispose() {
    for (final c in [
      _nome,
      _cpf,
      _email,
      _telefone,
      _cep,
      _logradouro,
      _numero,
      _bairro,
      _cidade,
      _uf,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _obrigatorio(String? v) =>
      (v ?? '').trim().isEmpty ? 'Campo obrigatório' : null;

  Future<void> _buscarCep() async {
    setState(() {
      _buscandoCep = true;
      _erroCep = null;
    });
    try {
      final e = await widget.servico.buscarCep(_cep.text);
      _logradouro.text = e.logradouro;
      _bairro.text = e.bairro;
      _cidade.text = e.cidade;
      _uf.text = e.uf;
    } on ConsultaException catch (e) {
      _erroCep = e.mensagem;
    } finally {
      setState(() => _buscandoCep = false);
    }
  }

  void _salvar() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(
      context,
      Cliente(
        nome: _nome.text.trim(),
        cpf: _cpf.text,
        email: _email.text.trim(),
        telefone: _telefone.text,
        cep: _cep.text,
        logradouro: _logradouro.text.trim(),
        numero: _numero.text.trim(),
        bairro: _bairro.text.trim(),
        cidade: _cidade.text.trim(),
        uf: _uf.text.trim().toUpperCase(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const espaco = SizedBox(height: 16);
    return Scaffold(
      appBar: AppBar(title: const Text('Novo cliente')),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Dados pessoais',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              espaco,
              TextFormField(
                controller: _nome,
                textCapitalization: TextCapitalization.words,
                validator: _obrigatorio,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              espaco,
              TextFormField(
                controller: _cpf,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: (v) =>
                    (v ?? '').length != 11 ? 'O CPF deve ter 11 dígitos' : null,
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  hintText: 'Somente números',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              espaco,
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v ?? '')
                    ? null
                    : 'E-mail inválido',
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              espaco,
              TextFormField(
                controller: _telefone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: (v) =>
                    (v ?? '').length < 10 ? 'Informe DDD + número' : null,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  hintText: 'Ex.: 11987654321',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 24),
              Text('Endereço', style: Theme.of(context).textTheme.titleMedium),
              espaco,
              TextFormField(
                controller: _cep,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                onChanged: (v) {
                  if (v.length == 8) _buscarCep();
                },
                validator: (v) =>
                    (v ?? '').length != 8 ? 'O CEP deve ter 8 dígitos' : null,
                decoration: InputDecoration(
                  labelText: 'CEP',
                  helperText: 'O endereço é preenchido automaticamente',
                  errorText: _erroCep,
                  prefixIcon: const Icon(Icons.pin_drop_outlined),
                  suffixIcon: _buscandoCep
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          tooltip: 'Buscar CEP',
                          icon: const Icon(Icons.search),
                          onPressed: _buscarCep,
                        ),
                ),
              ),
              espaco,
              TextFormField(
                controller: _logradouro,
                validator: _obrigatorio,
                decoration: const InputDecoration(
                  labelText: 'Logradouro',
                  prefixIcon: Icon(Icons.signpost_outlined),
                ),
              ),
              espaco,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _numero,
                      keyboardType: TextInputType.number,
                      validator: _obrigatorio,
                      decoration: const InputDecoration(labelText: 'Número'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _bairro,
                      validator: _obrigatorio,
                      decoration: const InputDecoration(labelText: 'Bairro'),
                    ),
                  ),
                ],
              ),
              espaco,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _cidade,
                      validator: _obrigatorio,
                      decoration: const InputDecoration(labelText: 'Cidade'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _uf,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [LengthLimitingTextInputFormatter(2)],
                      validator: (v) =>
                          (v ?? '').trim().length != 2 ? 'UF' : null,
                      decoration: const InputDecoration(labelText: 'UF'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.check),
                label: const Text('Cadastrar cliente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
