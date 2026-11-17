import 'package:flutter/material.dart';

import 'aluno.dart';
import 'aluno_repositorio.dart';

/// Extensão 1: lista os alunos gravados (SELECT).
class AlunosTela extends StatefulWidget {
  const AlunosTela({super.key, required this.repositorio});

  final AlunoRepositorio repositorio;

  @override
  State<AlunosTela> createState() => _AlunosTelaState();
}

class _AlunosTelaState extends State<AlunosTela> {
  late Future<List<Aluno>> _alunos = widget.repositorio.listar();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alunos cadastrados')),
      body: FutureBuilder<List<Aluno>>(
        future: _alunos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final erro = snapshot.error;
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(erro is AlunoException ? erro.mensagem : 'Não foi possível carregar os alunos.'),
                TextButton(
                  onPressed: () => setState(() => _alunos = widget.repositorio.listar()),
                  child: const Text('Tentar de novo'),
                ),
              ]),
            );
          }
          final alunos = snapshot.data!;
          if (alunos.isEmpty) return const Center(child: Text('Nenhum aluno cadastrado ainda.'));
          return ListView.separated(
            itemCount: alunos.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final a = alunos[i];
              return ListTile(
                leading: CircleAvatar(child: Text('${a.semestre}º')),
                title: Text(a.nome),
                subtitle: Text('${a.email}\n${a.curso}'),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
