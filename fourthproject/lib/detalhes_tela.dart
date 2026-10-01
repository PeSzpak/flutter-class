import 'package:flutter/material.dart';

import 'atividade.dart';

// Ação escolhida na tela de detalhes, devolvida para a tela principal.
enum AcaoDetalhe { alternarConclusao, excluir }

// Tela de detalhes - recebe a atividade selecionada pelo construtor
class DetalhesTela extends StatelessWidget {
  const DetalhesTela({super.key, required this.atividade});

  final Atividade atividade;

  Future<void> _confirmarExclusao(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir atividade?'),
        content: Text('"${atividade.nome}" será removida da lista.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar == true && context.mounted) {
      Navigator.pop(context, AcaoDetalhe.excluir);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final a = atividade;

    final (corStatus, iconeStatus, textoStatus) = a.concluida
        ? (Colors.green, Icons.check_circle, 'Concluída')
        : a.atrasada
        ? (esquema.error, Icons.warning_amber_rounded, 'Pendente · atrasada')
        : (esquema.primary, Icons.schedule, 'Pendente');

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              a.nome,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(iconeStatus, color: corStatus, size: 18),
                  label: Text(textoStatus),
                ),
                if (a.importante)
                  const Chip(
                    avatar: Icon(Icons.star, color: Colors.amber, size: 18),
                    label: Text('Importante'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: esquema.surfaceContainerHighest,
              child: Column(
                children: [
                  _Linha(
                    icone: Icons.menu_book_outlined,
                    rotulo: 'Disciplina',
                    valor: a.disciplina,
                  ),
                  _Linha(
                    icone: Icons.calendar_today_outlined,
                    rotulo: 'Data de entrega',
                    valor: formatarData(a.dataEntrega),
                  ),
                  _Linha(
                    icone: Icons.flag_outlined,
                    rotulo: 'Prioridade',
                    valor: '${a.prioridade.emoji}  ${a.prioridade.rotulo}',
                  ),
                  _Linha(
                    icone: Icons.star_outline,
                    rotulo: 'Importante',
                    valor: a.importante ? 'Sim' : 'Não',
                  ),
                  _Linha(
                    icone: Icons.task_alt,
                    rotulo: 'Status',
                    valor: a.status,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.pop(context, AcaoDetalhe.alternarConclusao),
              icon: Icon(a.concluida ? Icons.undo : Icons.check),
              label: Text(
                a.concluida ? 'Marcar como pendente' : 'Marcar como concluída',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 52),
                foregroundColor: esquema.error,
                side: BorderSide(color: esquema.error),
              ),
              onPressed: () => _confirmarExclusao(context),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Excluir atividade'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({
    required this.icone,
    required this.rotulo,
    required this.valor,
  });

  final IconData icone;
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icone),
      title: Text(rotulo),
      trailing: Text(
        valor,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
