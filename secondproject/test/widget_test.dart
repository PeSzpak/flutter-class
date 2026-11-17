import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secondproject/main.dart';

void main() {
  testWidgets('cadastra tarefa e atualiza o contador', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('App de Tarefas'), findsOneWidget);

    await tester.tap(find.text('Minhas tarefas'));
    await tester.pumpAndSettle();
    expect(find.text('Total de tarefas: 0'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Nova tarefa'), 'Estudar Flutter');
    await tester.tap(find.text('Adicionar'));
    await tester.pump();
    expect(find.text('Estudar Flutter'), findsOneWidget);
    expect(find.text('Total de tarefas: 1'), findsOneWidget);
  });
}
