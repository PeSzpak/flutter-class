import 'package:flutter_class/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mostra a lista de personagens do Cocoricó', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Cocoricó'), findsWidgets);
    expect(find.text('Júlio'), findsOneWidget);
  });
}
