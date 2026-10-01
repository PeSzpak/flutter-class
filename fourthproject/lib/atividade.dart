import 'package:flutter/material.dart';

enum Prioridade {
  alta('Alta', '🔴', Colors.red),
  media('Média', '🟡', Colors.amber),
  baixa('Baixa', '🟢', Colors.green);

  const Prioridade(this.rotulo, this.emoji, this.cor);
  final String rotulo;
  final String emoji;
  final Color cor;
}

// Representa uma atividade acadêmica cadastrada pelo usuário.
class Atividade {
  Atividade({
    required this.id,
    required this.disciplina,
    required this.nome,
    required this.dataEntrega,
    this.prioridade = Prioridade.media,
    this.importante = false,
    this.concluida = false,
  });

  final int id;
  final String disciplina;
  final String nome;
  final DateTime dataEntrega;
  final Prioridade prioridade;
  final bool importante;
  bool concluida;

  String get status => concluida ? 'Concluída' : 'Pendente';

  // Pendente e com a data de entrega já passada.
  bool get atrasada {
    final hoje = DateUtils.dateOnly(DateTime.now());
    return !concluida && dataEntrega.isBefore(hoje);
  }
}

String formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}
