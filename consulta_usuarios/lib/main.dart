import 'package:flutter/material.dart';

import 'api_service.dart';
import 'usuario.dart';

void main() {
  runApp(ConsultaUsuariosApp(api: ApiService()));
}

class ConsultaUsuariosApp extends StatelessWidget {
  const ConsultaUsuariosApp({super.key, required this.api});

  final ApiService api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta de Usuários',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: UsuariosTela(api: api),
    );
  }
}

class UsuariosTela extends StatefulWidget {
  const UsuariosTela({super.key, required this.api});

  final ApiService api;

  @override
  State<UsuariosTela> createState() => _UsuariosTelaState();
}

class _UsuariosTelaState extends State<UsuariosTela> {
  late Future<List<Usuario>> _usuarios;

  @override
  void initState() {
    super.initState();
    _usuarios = widget.api.buscarUsuarios();
  }

  void _recarregar() {
    setState(() {
      _usuarios = widget.api.buscarUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de Usuários'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _recarregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Usuario>>(
        future: _usuarios,
        builder: (context, snapshot) {
          // Carregando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Erro
          if (snapshot.hasError) {
            return _Aviso(
              icone: Icons.cloud_off,
              texto: 'Não foi possível consultar os usuários.\nVerifique sua conexão.',
              onTentar: _recarregar,
            );
          }

          // Resposta vazia
          final usuarios = snapshot.data ?? [];
          if (usuarios.isEmpty) {
            return _Aviso(
              icone: Icons.person_off_outlined,
              texto: 'Nenhum usuário encontrado.',
              onTentar: _recarregar,
            );
          }

          // Sucesso
          return RefreshIndicator(
            onRefresh: () async => _recarregar(),
            child: ListView.separated(
              itemCount: usuarios.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final u = usuarios[i];
                return ListTile(
                  leading: CircleAvatar(child: Text(u.nome[0])),
                  title: Text(u.nome),
                  subtitle: Text('${u.email}\n${u.telefone}'),
                  isThreeLine: true,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.icone, required this.texto, required this.onTentar});

  final IconData icone;
  final String texto;
  final VoidCallback onTentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 56),
            const SizedBox(height: 12),
            Text(texto, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onTentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar de novo'),
            ),
          ],
        ),
      ),
    );
  }
}
