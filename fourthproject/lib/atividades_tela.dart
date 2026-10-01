import 'package:flutter/material.dart';

import 'atividade.dart';
import 'cadastro_tela.dart';
import 'detalhes_tela.dart';

// Tela principal - lista das atividades cadastradas
class AtividadesTela extends StatefulWidget {
  const AtividadesTela({super.key});

  @override
  State<AtividadesTela> createState() => _AtividadesTelaState();
}

class _AtividadesTelaState extends State<AtividadesTela> {
  final List<Atividade> _atividades = [];
  int _proximoId = 0;

  int get _pendentes => _atividades.where((a) => !a.concluida).length;

  // Pendentes primeiro, ordenadas pela data de entrega.
  List<Atividade> get _ordenadas => [..._atividades]
    ..sort((a, b) {
      if (a.concluida != b.concluida) return a.concluida ? 1 : -1;
      return a.dataEntrega.compareTo(b.dataEntrega);
    });

  Future<void> _abrirCadastro() async {
    // Navigator.push devolve o valor passado no Navigator.pop da outra tela.
    final nova = await Navigator.push<Atividade>(
      context,
      MaterialPageRoute(builder: (context) => CadastroTela(id: _proximoId)),
    );
    if (nova == null) return;

    setState(() {
      _atividades.add(nova);
      _proximoId++;
    });
    _avisar('Atividade "${nova.nome}" cadastrada');
  }

  Future<void> _abrirDetalhes(Atividade atividade) async {
    // Envia a atividade selecionada e recebe de volta a ação escolhida.
    final acao = await Navigator.push<AcaoDetalhe>(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesTela(atividade: atividade),
      ),
    );

    switch (acao) {
      case AcaoDetalhe.alternarConclusao:
        _alternar(atividade);
      case AcaoDetalhe.excluir:
        _excluir(atividade);
      case null:
        break;
    }
  }

  void _alternar(Atividade atividade) {
    setState(() => atividade.concluida = !atividade.concluida);
    _avisar(
      atividade.concluida
          ? '"${atividade.nome}" concluída ✅'
          : '"${atividade.nome}" voltou para pendente',
    );
  }

  void _excluir(Atividade atividade) {
    final indice = _atividades.indexOf(atividade);
    setState(() => _atividades.remove(atividade));
    _avisar(
      'Atividade "${atividade.nome}" excluída',
      acao: SnackBarAction(
        label: 'Desfazer',
        onPressed: () => setState(
          () => _atividades.insert(
            indice.clamp(0, _atividades.length),
            atividade,
          ),
        ),
      ),
    );
  }

  void _avisar(String mensagem, {SnackBarAction? acao}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(mensagem), action: acao));
  }

  @override
  Widget build(BuildContext context) {
    final lista = _ordenadas;

    return Scaffold(
      appBar: AppBar(title: const Text('📚 StudyFlow')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastro,
        icon: const Icon(Icons.add),
        label: const Text('Nova atividade'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Resumo(total: _atividades.length, pendentes: _pendentes),
            Expanded(
              child: lista.isEmpty
                  ? const _Vazio()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                      itemCount: lista.length,
                      itemBuilder: (context, index) {
                        final atividade = lista[index];
                        return _AtividadeItem(
                          key: ValueKey(atividade.id),
                          atividade: atividade,
                          aoTocar: () => _abrirDetalhes(atividade),
                          aoAlternar: () => _alternar(atividade),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  const _Resumo({required this.total, required this.pendentes});

  final int total;
  final int pendentes;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final concluidas = total - pendentes;

    return Card(
      margin: const EdgeInsets.all(16),
      color: esquema.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            _Numero(valor: total, rotulo: 'Total'),
            _Numero(valor: pendentes, rotulo: 'Pendentes'),
            _Numero(valor: concluidas, rotulo: 'Concluídas'),
          ],
        ),
      ),
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero({required this.valor, required this.rotulo});

  final int valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.onPrimaryContainer;
    return Expanded(
      child: Column(
        children: [
          Text(
            '$valor',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
          Text(rotulo, style: TextStyle(color: cor)),
        ],
      ),
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio();

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.outline;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 64, color: cor),
            const SizedBox(height: 8),
            Text(
              'Nenhuma atividade cadastrada.\n'
              'Toque em "Nova atividade" para começar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cor),
            ),
          ],
        ),
      ),
    );
  }
}

class _AtividadeItem extends StatelessWidget {
  const _AtividadeItem({
    super.key,
    required this.atividade,
    required this.aoTocar,
    required this.aoAlternar,
  });

  final Atividade atividade;
  final VoidCallback aoTocar;
  final VoidCallback aoAlternar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final a = atividade;

    return Card(
      color: esquema.surfaceContainerHighest,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: aoTocar,
        leading: Checkbox(value: a.concluida, onChanged: (_) => aoAlternar()),
        title: Text(
          a.nome,
          style: a.concluida
              ? TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: esquema.outline,
                )
              : null,
        ),
        subtitle: Text(
          '${a.disciplina} · 📅 ${formatarData(a.dataEntrega)}'
          '${a.atrasada ? ' · atrasada' : ''}',
          style: a.atrasada ? TextStyle(color: esquema.error) : null,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (a.importante)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.star, color: Colors.amber),
              ),
            Tooltip(
              message: 'Prioridade ${a.prioridade.rotulo.toLowerCase()}',
              child: Text(a.prioridade.emoji),
            ),
          ],
        ),
      ),
    );
  }
}
