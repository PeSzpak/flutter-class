import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'consulta_service.dart';

class CepTela extends StatefulWidget {
  const CepTela({super.key, required this.servico});

  final ConsultaService servico;

  @override
  State<CepTela> createState() => _CepTelaState();
}

class _CepTelaState extends State<CepTela> {
  final TextEditingController _cep = TextEditingController();
  final TextEditingController _numero = TextEditingController();

  Endereco? _endereco;
  String _numeroBuscado = '';
  String? _erro;
  bool _carregando = false;

  @override
  void dispose() {
    _cep.dispose();
    _numero.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _carregando = true;
      _erro = null;
      _endereco = null;
    });
    try {
      final endereco = await widget.servico.buscarCep(_cep.text);
      setState(() {
        _endereco = endereco;
        _numeroBuscado = _numero.text.trim();
      });
    } on ConsultaException catch (e) {
      setState(() => _erro = e.mensagem);
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final endereco = _endereco;
    return Scaffold(
      appBar: AppBar(title: const Text('Consulta de CEP')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _cep,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              decoration: const InputDecoration(
                labelText: 'CEP',
                hintText: 'Ex.: 01001000',
                prefixIcon: Icon(Icons.pin_drop_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _numero,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _buscar(),
              decoration: const InputDecoration(
                labelText: 'Número da residência',
                hintText: 'Ex.: 123',
                prefixIcon: Icon(Icons.home_outlined),
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
              label: const Text('Buscar endereço'),
            ),
            const SizedBox(height: 24),
            if (_erro != null) MensagemErro(_erro!),
            if (endereco != null)
              EnderecoCard(endereco: endereco, numero: _numeroBuscado),
          ],
        ),
      ),
    );
  }
}

class EnderecoCard extends StatelessWidget {
  const EnderecoCard({super.key, required this.endereco, required this.numero});

  final Endereco endereco;
  final String numero;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final rua = endereco.logradouro.isEmpty
        ? 'Logradouro não informado'
        : '${endereco.logradouro}, ${numero.isEmpty ? 's/n' : numero}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Destaque: cidade e estado.
        Card(
          color: cores.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.location_city,
                  size: 40,
                  color: cores.onPrimaryContainer,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    endereco.cidade,
                    style: textos.headlineSmall?.copyWith(
                      color: cores.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cores.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    endereco.uf,
                    style: textos.titleLarge?.copyWith(
                      color: cores.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
              ListTile(
                leading: const Icon(Icons.signpost_outlined),
                title: Text(rua),
                subtitle: const Text('Endereço'),
              ),
              if (endereco.bairro.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.holiday_village_outlined),
                  title: Text(endereco.bairro),
                  subtitle: const Text('Bairro'),
                ),
              if (endereco.complemento.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.notes),
                  title: Text(endereco.complemento),
                  subtitle: const Text('Complemento'),
                ),
              ListTile(
                leading: const Icon(Icons.pin_drop_outlined),
                title: Text(endereco.cep),
                subtitle: const Text('CEP'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MensagemErro extends StatelessWidget {
  const MensagemErro(this.mensagem, {super.key});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Card(
      color: cores.errorContainer,
      child: ListTile(
        leading: Icon(Icons.error_outline, color: cores.onErrorContainer),
        title: Text(mensagem, style: TextStyle(color: cores.onErrorContainer)),
      ),
    );
  }
}
