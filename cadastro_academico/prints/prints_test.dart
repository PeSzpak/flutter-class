// Gera os prints da entrega: flutter test prints --update-goldens
import 'package:cadastro_academico/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fontes.dart';

Future<void> preencher(WidgetTester tester, String matricula) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Nome completo'), 'Ana Silva');
  await tester.enterText(find.byKey(const Key('campoMatricula')), matricula);
  await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'ana@exemplo.com');
  await tester.enterText(find.widgetWithText(TextFormField, 'Curso'), 'Análise e Desenvolvimento de Sistemas');
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
  setUpAll(carregarFontes);

  testWidgets('print: matrícula inválida', (tester) async {
    tamanhoCelular(tester);
    await tester.pumpWidget(const CadastroAcademicoApp());
    await preencher(tester, 'A12');
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 1000));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('01_matricula_invalida.png'));
  });

  testWidgets('print: cadastro válido', (tester) async {
    tamanhoCelular(tester);
    await tester.pumpWidget(const CadastroAcademicoApp());
    await preencher(tester, '2026ADS01');
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('02_cadastro_confirmado.png'));
  });
}
