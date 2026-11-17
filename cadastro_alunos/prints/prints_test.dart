// Gera os prints: flutter test prints --update-goldens
// Usa um repositório em memória no lugar do Supabase.
import 'package:cadastro_alunos/aluno.dart';
import 'package:cadastro_alunos/aluno_repositorio.dart';
import 'package:cadastro_alunos/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fontes.dart';

class Memoria implements AlunoRepositorio {
  final alunos = <Aluno>[
    const Aluno(nome: 'Bruno Costa', email: 'bruno@exemplo.com', curso: 'Engenharia de Software', semestre: 2),
  ];
  @override
  Future<void> cadastrar(Aluno aluno) async {
    if (alunos.any((a) => a.email == aluno.email)) throw const AlunoException('Este e-mail já está cadastrado.');
    alunos.add(aluno);
  }

  @override
  Future<List<Aluno>> listar() async => alunos.reversed.toList();
}

Future<void> preencher(WidgetTester tester, String email, String semestre) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Ana Silva');
  await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), email);
  await tester.enterText(find.widgetWithText(TextFormField, 'Curso'), 'Análise e Desenvolvimento de Sistemas');
  await tester.enterText(find.widgetWithText(TextFormField, 'Semestre (1 a 12)'), semestre);
  await tester.tap(find.text('Cadastrar'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(carregarFontes);

  testWidgets('print: validação', (tester) async {
    tamanhoCelular(tester);
    await tester.pumpWidget(CadastroAlunosApp(repositorio: Memoria()));
    await preencher(tester, 'ana.exemplo.com', '15');
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('01_validacao.png'));
  });

  testWidgets('print: cadastro e lista', (tester) async {
    tamanhoCelular(tester);
    await tester.pumpWidget(CadastroAlunosApp(repositorio: Memoria()));
    await preencher(tester, 'ana@exemplo.com', '4');
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('02_sucesso.png'));
    await tester.tap(find.byTooltip('Alunos cadastrados'));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('03_lista.png'));
  });
}
