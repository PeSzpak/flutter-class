import 'package:flutter/material.dart';

import 'cliente.dart';
import 'cliente_cadastro_tela.dart';
import 'cliente_repositorio.dart';
import 'consulta_service.dart';

class ClientesTela extends StatefulWidget {
  const ClientesTela({
    super.key,
    required this.servico,
    required this.repositorio,
  });

  final ConsultaService servico;
  final ClienteRepositorio repositorio;

  @override
  State<ClientesTela> createState() => _ClientesTelaState();
}

class _ClientesTelaState extends State<ClientesTela> {
  List<Cliente> _clientes = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final clientes = await widget.repositorio.listar();
      if (mounted) setState(() => _clientes = clientes);
    } on ClienteException catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _avisar(String texto) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _novoCliente() async {
    final cliente = await Navigator.push<Cliente>(
      context,
      MaterialPageRoute(
        builder: (_) => ClienteCadastroTela(servico: widget.servico),
      ),
    );
    if (cliente == null || !mounted) return;
    try {
      final salvo = await widget.repositorio.inserir(cliente);
      if (!mounted) return;
      setState(() => _clientes = [..._clientes, salvo]);
      _avisar('${salvo.nome} cadastrado!');
    } on ClienteException catch (e) {
      if (mounted) _avisar(e.mensagem);
    }
  }

  Future<void> _remover(Cliente cliente) async {
    try {
      await widget.repositorio.remover(cliente.id!);
      if (!mounted) return;
      setState(
        () => _clientes = _clientes.where((c) => c.id != cliente.id).toList(),
      );
      _avisar('${cliente.nome} removido');
    } on ClienteException catch (e) {
      if (mounted) _avisar(e.mensagem);
    }
  }

  Widget _corpo() {
    if (_carregando) return const Center(child: CircularProgressIndicator());
    final erro = _erro;
    if (erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(erro, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: _carregar,
              child: const Text('Tentar de novo'),
            ),
          ],
        ),
      );
    }
    if (_clientes.isEmpty) {
      return const Center(child: Text('Nenhum cliente cadastrado ainda.'));
    }
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: _clientes.length,
        itemBuilder: (context, i) {
          final c = _clientes[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(c.nome[0].toUpperCase())),
              title: Text(c.nome),
              subtitle: Text(
                '${c.email}\n${c.logradouro}, ${c.numero} - '
                '${c.cidade}/${c.uf}',
              ),
              isThreeLine: true,
              trailing: IconButton(
                tooltip: 'Remover',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _remover(c),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novoCliente,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Novo cliente'),
      ),
      body: _corpo(),
    );
  }
}
