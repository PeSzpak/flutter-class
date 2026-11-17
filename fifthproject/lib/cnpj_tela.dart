import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cep_tela.dart';
import 'consulta_service.dart';

// Desafio extra: consulta de CNPJ pela BrasilAPI.
class CnpjTela extends StatefulWidget {
  const CnpjTela({super.key, required this.servico});

  final ConsultaService servico;

  @override
  State<CnpjTela> createState() => _CnpjTelaState();
}

class _CnpjTelaState extends State<CnpjTela> {
  final TextEditingController _cnpj = TextEditingController();

  Empresa? _empresa;
  String? _erro;
  bool _carregando = false;

  @override
  void dispose() {
    _cnpj.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _carregando = true;
      _erro = null;
      _empresa = null;
    });
    try {
      final empresa = await widget.servico.buscarCnpj(_cnpj.text);
      setState(() => _empresa = empresa);
    } on ConsultaException catch (e) {
      setState(() => _erro = e.mensagem);
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final empresa = _empresa;
    return Scaffold(
      appBar: AppBar(title: const Text('Consulta de CNPJ')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _cnpj,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _buscar(),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(14),
              ],
              decoration: const InputDecoration(
                labelText: 'CNPJ',
                hintText: 'Somente números',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _carregando ? null : _buscar,
              icon: _carregando
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: const Text('Buscar empresa'),
            ),
            const SizedBox(height: 24),
            if (_erro != null) MensagemErro(_erro!),
            if (empresa != null) _EmpresaCard(empresa),
          ],
        ),
      ),
    );
  }
}

class _EmpresaCard extends StatelessWidget {
  const _EmpresaCard(this.empresa);

  final Empresa empresa;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final ativa = empresa.situacao.toUpperCase() == 'ATIVA';

    Widget? linha(IconData icone, String rotulo, String valor) => valor.isEmpty
        ? null
        : ListTile(
            leading: Icon(icone),
            title: Text(valor),
            subtitle: Text(rotulo),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: cores.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  empresa.nomeFantasia.isEmpty
                      ? empresa.razaoSocial
                      : empresa.nomeFantasia,
                  style: textos.headlineSmall?.copyWith(
                    color: cores.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${empresa.cidade} - ${empresa.uf}',
                  style: textos.titleMedium?.copyWith(
                    color: cores.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Chip(
                  avatar: Icon(
                    ativa ? Icons.check_circle : Icons.cancel,
                    color: ativa ? Colors.green : cores.error,
                  ),
                  label: Text(empresa.situacao),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: cores.surfaceContainerHighest,
          child: Column(
            children: [
              ?linha(Icons.apartment, 'Razão social', empresa.razaoSocial),
              ?linha(Icons.badge_outlined, 'CNPJ', empresa.cnpj),
              ?linha(
                Icons.work_outline,
                'Atividade principal',
                empresa.atividade,
              ),
              ?linha(Icons.event_outlined, 'Abertura', empresa.abertura),
              ?linha(Icons.signpost_outlined, 'Endereço', empresa.endereco),
              ?linha(Icons.phone_outlined, 'Telefone', empresa.telefone),
            ],
          ),
        ),
      ],
    );
  }
}
