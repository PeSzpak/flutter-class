import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fourthproject/main.dart';

void main() {
  testWidgets('Cadastrar, consultar, concluir e excluir uma atividade', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.textContaining('Nenhuma atividade'), findsOneWidget);

    // Cadastrar
    await tester.tap(find.text('Nova atividade'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Mobile');
    await tester.enterText(find.byType(TextField).at(1), 'Trabalho Flutter');
    await tester.tap(find.byType(TextField).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('🟡  Média'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('🔴  Alta').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Atividade importante'));
    await tester.ensureVisible(find.text('Cadastrar atividade'));
    await tester.tap(find.text('Cadastrar atividade'));
    await tester.pumpAndSettle();

    // Visualizar
    expect(find.text('Trabalho Flutter'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);

    // Consultar + concluir
    await tester.tap(find.text('Trabalho Flutter'));
    await tester.pumpAndSettle();
    expect(find.text('Detalhes'), findsOneWidget);
    expect(find.text('🔴  Alta'), findsOneWidget);
    await tester.ensureVisible(find.text('Marcar como concluída'));
    await tester.tap(find.text('Marcar como concluída'));
    await tester.pumpAndSettle();
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isTrue);

    // Excluir (espera o SnackBar de conclusão sumir)
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trabalho Flutter'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Excluir atividade'));
    await tester.tap(find.text('Excluir atividade'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
    await tester.pumpAndSettle();
    expect(find.text('Trabalho Flutter'), findsNothing);
  });
}
