import 'package:flutter/material.dart';

import 'cliente_cadastro_tela.dart';
import 'consulta_service.dart';

class Cliente {
  const Cliente({
    required this.nome,
    required this.cpf,
    required this.email,
    required this.telefone,
    required this.cep,
    required this.logradouro,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.uf,
  });

  final String nome;
  final String cpf;
  final String email;
  final String telefone;
  final String cep;
  final String logradouro;
  final String numero;
  final String bairro;
  final String cidade;
  final String uf;
}

class ClientesTela extends StatefulWidget {
  const ClientesTela({super.key, required this.servico});

  final ConsultaService servico;

  @override
  State<ClientesTela> createState() => _ClientesTelaState();
}

class _ClientesTelaState extends State<ClientesTela> {
  final List<Cliente> _clientes = [];

  Future<void> _novoCliente() async {
    final cliente = await Navigator.push<Cliente>(
      context,
      MaterialPageRoute(
        builder: (_) => ClienteCadastroTela(servico: widget.servico),
      ),
    );
    if (cliente == null || !mounted) return;
    setState(() => _clientes.add(cliente));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${cliente.nome} cadastrado!')));
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
      body: _clientes.isEmpty
          ? const Center(child: Text('Nenhum cliente cadastrado ainda.'))
          : ListView.builder(
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
                      onPressed: () => setState(() => _clientes.removeAt(i)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
