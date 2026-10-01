import 'package:flutter/material.dart';

import 'tarefa.dart';

enum _Filtro { todas, pendentes, concluidas }

// Tela 2 - Tarefas
class TarefasTela extends StatefulWidget {
  const TarefasTela({super.key, required this.controller});

  final TarefasController controller;

  @override
  State<TarefasTela> createState() => _TarefasTelaState();
}

class _TarefasTelaState extends State<TarefasTela> {
  final TextEditingController _texto = TextEditingController();
  Prioridade _prioridade = Prioridade.media;
  _Filtro _filtro = _Filtro.todas;

  TarefasController get _c => widget.controller;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void _adicionar() {
    final titulo = _texto.text.trim();
    if (titulo.isEmpty) return;
    _c.adicionar(titulo, _prioridade);
    _texto.clear();
  }

  void _remover(Tarefa tarefa) {
    final indice = _c.remover(tarefa);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('"${tarefa.titulo}" removida'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => _c.restaurar(indice, tarefa),
          ),
        ),
      );
  }

  Future<void> _editar(Tarefa tarefa) async {
    final campo = TextEditingController(text: tarefa.titulo);
    var prioridade = tarefa.prioridade;

    final salvar = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: const Text('Editar tarefa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: campo, autofocus: true),
              const SizedBox(height: 16),
              SegmentedButton<Prioridade>(
                showSelectedIcon: false,
                segments: [
                  for (final p in Prioridade.values)
                    ButtonSegment(value: p, label: Text(p.rotulo)),
                ],
                selected: {prioridade},
                onSelectionChanged: (s) => setDialog(() => prioridade = s.first),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    final novoTitulo = campo.text.trim();
    campo.dispose();
    if (salvar == true && novoTitulo.isNotEmpty) {
      _c.editar(tarefa, novoTitulo, prioridade);
    }
  }

  List<Tarefa> _visiveis() => _c.tarefas.where((t) {
        switch (_filtro) {
          case _Filtro.todas:
            return true;
          case _Filtro.pendentes:
            return !t.concluida;
          case _Filtro.concluidas:
            return t.concluida;
        }
      }).toList();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) {
        final visiveis = _visiveis();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Minhas Tarefas'),
            actions: [
              IconButton(
                tooltip: 'Limpar concluídas',
                icon: const Icon(Icons.cleaning_services_outlined),
                onPressed: _c.concluidas == 0 ? null : _c.limparConcluidas,
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _texto,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _adicionar(),
                  decoration: const InputDecoration(
                    labelText: 'Nova tarefa',
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<Prioridade>(
                        showSelectedIcon: false,
                        segments: [
                          for (final p in Prioridade.values)
                            ButtonSegment(value: p, label: Text(p.rotulo)),
                        ],
                        selected: {_prioridade},
                        onSelectionChanged: (s) =>
                            setState(() => _prioridade = s.first),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 40),
                      ),
                      onPressed: _adicionar,
                      child: const Text('Adicionar'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Total de tarefas: ${_c.total}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${_c.concluidas} concluída(s) · ${_c.pendentes} pendente(s)'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final f in _Filtro.values)
                      ChoiceChip(
                        label: Text(switch (f) {
                          _Filtro.todas => 'Todas',
                          _Filtro.pendentes => 'Pendentes',
                          _Filtro.concluidas => 'Concluídas',
                        }),
                        selected: _filtro == f,
                        onSelected: (_) => setState(() => _filtro = f),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: visiveis.isEmpty
                      ? const _Vazio()
                      : ListView.builder(
                          itemCount: visiveis.length,
                          itemBuilder: (context, index) {
                            final tarefa = visiveis[index];
                            return _TarefaItem(
                              key: ValueKey(tarefa.id),
                              tarefa: tarefa,
                              aoAlternar: () => _c.alternar(tarefa),
                              aoEditar: () => _editar(tarefa),
                              aoRemover: () => _remover(tarefa),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Voltar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio();

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.outline;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: cor),
          const SizedBox(height: 8),
          Text('Nenhuma tarefa por aqui.', style: TextStyle(color: cor)),
        ],
      ),
    );
  }
}

class _TarefaItem extends StatelessWidget {
  const _TarefaItem({
    super.key,
    required this.tarefa,
    required this.aoAlternar,
    required this.aoEditar,
    required this.aoRemover,
  });

  final Tarefa tarefa;
  final VoidCallback aoAlternar;
  final VoidCallback aoEditar;
  final VoidCallback aoRemover;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey('dismiss-${tarefa.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => aoRemover(),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: esquema.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: esquema.onErrorContainer),
      ),
      child: Card(
        color: esquema.surfaceContainerHighest,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          onTap: aoEditar,
          leading: Checkbox(
            value: tarefa.concluida,
            onChanged: (_) => aoAlternar(),
          ),
          title: Text(
            tarefa.titulo,
            style: tarefa.concluida
                ? TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: esquema.outline,
                  )
                : null,
          ),
          subtitle: Row(
            children: [
              Icon(Icons.flag, size: 14, color: tarefa.prioridade.cor),
              const SizedBox(width: 4),
              Text(
                'Prioridade ${tarefa.prioridade.rotulo.toLowerCase()}',
                style: TextStyle(color: tarefa.prioridade.cor),
              ),
            ],
          ),
          trailing: IconButton(
            tooltip: 'Remover',
            icon: const Icon(Icons.delete_outline),
            onPressed: aoRemover,
          ),
        ),
      ),
    );
  }
}
