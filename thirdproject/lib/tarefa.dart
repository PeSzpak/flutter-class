import 'package:flutter/material.dart';

enum Prioridade {
  baixa('Baixa', Colors.green),
  media('Média', Colors.orange),
  alta('Alta', Colors.red);

  const Prioridade(this.rotulo, this.cor);
  final String rotulo;
  final Color cor;
}

class Tarefa {
  Tarefa({
    required this.id,
    required this.titulo,
    this.prioridade = Prioridade.media,
    this.concluida = false,
  });

  final int id;
  String titulo;
  Prioridade prioridade;
  bool concluida;
}

// Guarda as tarefas fora das telas: assim a lista não se perde ao voltar
// para o início, e o início também pode mostrar o resumo.
class TarefasController extends ChangeNotifier {
  final List<Tarefa> _tarefas = [];
  int _proximoId = 0;

  List<Tarefa> get tarefas => List.unmodifiable(_tarefas);
  int get total => _tarefas.length;
  int get concluidas => _tarefas.where((t) => t.concluida).length;
  int get pendentes => total - concluidas;

  void adicionar(String titulo, Prioridade prioridade) {
    _tarefas.insert(
      0,
      Tarefa(id: _proximoId++, titulo: titulo, prioridade: prioridade),
    );
    notifyListeners();
  }

  void alternar(Tarefa tarefa) {
    tarefa.concluida = !tarefa.concluida;
    notifyListeners();
  }

  void editar(Tarefa tarefa, String titulo, Prioridade prioridade) {
    tarefa.titulo = titulo;
    tarefa.prioridade = prioridade;
    notifyListeners();
  }

  // Devolve a posição para permitir desfazer a remoção.
  int remover(Tarefa tarefa) {
    final indice = _tarefas.indexOf(tarefa);
    _tarefas.remove(tarefa);
    notifyListeners();
    return indice;
  }

  void restaurar(int indice, Tarefa tarefa) {
    _tarefas.insert(indice.clamp(0, _tarefas.length), tarefa);
    notifyListeners();
  }

  void limparConcluidas() {
    _tarefas.removeWhere((t) => t.concluida);
    notifyListeners();
  }
}
