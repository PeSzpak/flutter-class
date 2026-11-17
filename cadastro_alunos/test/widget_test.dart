import 'package:cadastro_alunos/aluno.dart';
import 'package:cadastro_alunos/aluno_repositorio.dart';
import 'package:cadastro_alunos/main.dart';
import 'package:cadastro_alunos/validacao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repositório em memória que imita o banco (inclusive o e-mail único).
class RepositorioFalso implements AlunoRepositorio {
  final alunos = <Aluno>[];
  bool semConexao = false;

  @override
  Future<void> cadastrar(Aluno aluno) async {
    if (semConexao) throw const AlunoException('Sem conexão com o servidor. Verifique a internet e tente de novo.');
    if (alunos.any((a) => a.email == aluno.email)) throw const AlunoException('Este e-mail já está cadastrado.');
    alunos.add(aluno);
  }

  @override
  Future<List<Aluno>> listar() async => alunos.reversed.toList();
}

Future<void> preencher(WidgetTester tester, {String nome = 'Ana Silva', String email = 'ana@exemplo.com', String curso = 'ADS', String semestre = '4'}) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), nome);
  await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), email);
  await tester.enterText(find.widgetWithText(TextFormField, 'Curso'), curso);
  await tester.enterText(find.widgetWithText(TextFormField, 'Semestre (1 a 12)'), semestre);
  await tester.tap(find.text('Cadastrar'));
  await tester.pumpAndSettle();
}

void main() {
  group('validação', () {
    test('semestre', () {
      expect(validarSemestre(''), 'Informe o semestre.');
      expect(validarSemestre('dois'), 'O semestre deve ser um número.');
      expect(validarSemestre('0'), 'O semestre deve estar entre 1 e 12.');
      expect(validarSemestre('13'), 'O semestre deve estar entre 1 e 12.');
      expect(validarSemestre('12'), isNull);
    });
    test('e-mail', () {
      expect(validarEmail('ana'), 'Informe um e-mail válido.');
      expect(validarEmail('ana@exemplo.com'), isNull);
    });
  });

  testWidgets('campos vazios não enviam nada', (tester) async {
    final repo = RepositorioFalso();
    await tester.pumpWidget(CadastroAlunosApp(repositorio: repo));
    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe o nome.'), findsOneWidget);
    expect(find.text('Informe o semestre.'), findsOneWidget);
    expect(repo.alunos, isEmpty);
  });

  testWidgets('e-mail inválido não envia', (tester) async {
    final repo = RepositorioFalso();
    await tester.pumpWidget(CadastroAlunosApp(repositorio: repo));
    await preencher(tester, email: 'ana.exemplo.com');
    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
    expect(repo.alunos, isEmpty);
  });

  testWidgets('semestre fora do intervalo não envia', (tester) async {
    final repo = RepositorioFalso();
    await tester.pumpWidget(CadastroAlunosApp(repositorio: repo));
    await preencher(tester, semestre: '15');
    expect(find.text('O semestre deve estar entre 1 e 12.'), findsOneWidget);
    expect(repo.alunos, isEmpty);
  });

  testWidgets('cadastro válido grava e mostra sucesso', (tester) async {
    final repo = RepositorioFalso();
    await tester.pumpWidget(CadastroAlunosApp(repositorio: repo));
    await preencher(tester, email: 'Ana@Exemplo.com');
    expect(find.text('Aluno cadastrado com sucesso!'), findsOneWidget);
    expect(repo.alunos.single.email, 'ana@exemplo.com');
    expect(repo.alunos.single.semestre, 4);
  });

  testWidgets('e-mail repetido mostra o erro do banco', (tester) async {
    final repo = RepositorioFalso();
    await tester.pumpWidget(CadastroAlunosApp(repositorio: repo));
    await preencher(tester);
    await preencher(tester);
    expect(find.text('Este e-mail já está cadastrado.'), findsOneWidget);
    expect(repo.alunos, hasLength(1));
  });

  testWidgets('sem internet mostra mensagem de erro', (tester) async {
    final repo = RepositorioFalso()..semConexao = true;
    await tester.pumpWidget(CadastroAlunosApp(repositorio: repo));
    await preencher(tester);
    expect(find.textContaining('Sem conexão'), findsOneWidget);
  });

  testWidgets('lista os alunos cadastrados', (tester) async {
    final repo = RepositorioFalso();
    await tester.pumpWidget(CadastroAlunosApp(repositorio: repo));
    await preencher(tester);
    await tester.tap(find.byTooltip('Alunos cadastrados'));
    await tester.pumpAndSettle();
    expect(find.text('Ana Silva'), findsOneWidget);
  });
}
