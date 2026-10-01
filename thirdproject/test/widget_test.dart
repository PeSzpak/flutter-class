import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thirdproject/main.dart';

void main() {
  testWidgets('Fluxo entre as telas do app', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tela 1 - Início.
    expect(find.text('App de Tarefas'), findsOneWidget);
    expect(find.text('Minhas tarefas'), findsOneWidget);
    expect(find.text('Sobre'), findsOneWidget);

    // Tela 2 - Tarefas: adiciona uma tarefa e confere o contador.
    await tester.tap(find.text('Minhas tarefas'));
    await tester.pumpAndSettle();
    expect(find.text('Total de tarefas: 0'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Estudar Flutter');
    await tester.tap(find.text('Adicionar'));
    await tester.pump();
    expect(find.text('Estudar Flutter'), findsOneWidget);
    expect(find.text('Total de tarefas: 1'), findsOneWidget);

    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();

    // Tela 3 - Sobre.
    await tester.tap(find.text('Sobre'));
    await tester.pumpAndSettle();
    expect(find.text('Pedro Szpak'), findsOneWidget);

    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('App de Tarefas'), findsOneWidget);
  });
}
