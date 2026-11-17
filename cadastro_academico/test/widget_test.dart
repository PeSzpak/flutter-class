import 'package:cadastro_academico/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> preencher(WidgetTester tester, {required String matricula}) async {
  await tester.pumpWidget(const CadastroAcademicoApp());
  await tester.enterText(find.widgetWithText(TextFormField, 'Nome completo'), 'Ana Silva');
  await tester.enterText(find.byKey(const Key('campoMatricula')), matricula);
  await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'ana@exemplo.com');
  await tester.enterText(find.widgetWithText(TextFormField, 'Curso'), 'ADS');
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Noturno').last);
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byType(CheckboxListTile));
  await tester.tap(find.byType(CheckboxListTile));
  await tester.pump();
  await tester.ensureVisible(find.text('Validar e cadastrar'));
  await tester.tap(find.text('Validar e cadastrar'));
  await tester.pumpAndSettle();
}

void main() {
  group('validarMatricula', () {
    test('vazia', () => expect(validarMatricula(''), 'Informe a matrícula.'));
    test('só espaços', () => expect(validarMatricula('    '), 'Informe a matrícula.'));
    test('curta', () => expect(validarMatricula('1234'), 'A matrícula deve ter pelo menos 5 caracteres.'));
    test('cinco caracteres', () => expect(validarMatricula('12345'), isNull));
  });

  testWidgets('caso inválido 1: matrícula vazia impede o envio', (tester) async {
    await preencher(tester, matricula: '');
    expect(find.text('Informe a matrícula.'), findsOneWidget);
    expect(find.text('Cadastro realizado!'), findsNothing);
  });

  testWidgets('caso inválido 2: matrícula com 4 caracteres', (tester) async {
    await preencher(tester, matricula: 'A123');
    expect(find.text('A matrícula deve ter pelo menos 5 caracteres.'), findsOneWidget);
    expect(find.text('Cadastro realizado!'), findsNothing);
  });

  testWidgets('caso inválido 3: espaços em volta não contam', (tester) async {
    await preencher(tester, matricula: '  12  ');
    expect(find.text('A matrícula deve ter pelo menos 5 caracteres.'), findsOneWidget);
    expect(find.text('Cadastro realizado!'), findsNothing);
  });

  testWidgets('caso válido: matrícula aparece na confirmação', (tester) async {
    await preencher(tester, matricula: '2026ADS01');
    expect(find.text('Cadastro realizado!'), findsOneWidget);
    expect(find.textContaining('Matrícula: 2026ADS01'), findsOneWidget);
  });
}
