import 'package:explorador_movel/main.dart';
import 'package:explorador_movel/velocidade.dart';
import 'package:flutter_test/flutter_test.dart';

final t0 = DateTime(2026, 11, 16, 10);

Leitura leitura(double lat, double lon, {int segundos = 0, double precisao = 5}) =>
    Leitura(latitude: lat, longitude: lon, precisao: precisao, horario: t0.add(Duration(seconds: segundos)));

void main() {
  group('velocidade (exemplo do slide: 100 m em 20 s = 18 km/h)', () {
    // 0,0009 grau de latitude ≈ 100 m
    test('primeira leitura só serve de base', () {
      expect(CalculadoraVelocidade().adicionar(leitura(-25.0, -49.0)), isNull);
    });

    test('100 m em 20 s dá 18 km/h', () {
      final c = CalculadoraVelocidade();
      c.adicionar(leitura(-25.0, -49.0));
      final kmh = c.adicionar(leitura(-25.0 + 0.0008993, -49.0, segundos: 20))!;
      expect(kmh, closeTo(18, 0.1));
      expect(c.distanciaTotal, closeTo(100, 0.5));
    });

    test('leitura imprecisa é ignorada', () {
      final c = CalculadoraVelocidade();
      c.adicionar(leitura(-25.0, -49.0));
      expect(c.adicionar(leitura(-25.001, -49.0, segundos: 20, precisao: 80)), isNull);
    });

    test('leitura com o mesmo horário é ignorada', () {
      final c = CalculadoraVelocidade();
      c.adicionar(leitura(-25.0, -49.0));
      expect(c.adicionar(leitura(-25.001, -49.0)), isNull);
    });

    test('salto absurdo do GPS (1 km em 1 s) é ignorado', () {
      final c = CalculadoraVelocidade();
      c.adicionar(leitura(-25.0, -49.0));
      expect(c.adicionar(leitura(-25.009, -49.0, segundos: 1)), isNull);
      expect(c.distanciaTotal, 0);
    });
  });

  test('distância Curitiba → São Paulo fica perto de 340 km', () {
    expect(distanciaEmMetros(-25.4284, -49.2733, -23.5505, -46.6333) / 1000, closeTo(338, 10));
  });

  testWidgets('abre na aba Localização e troca para Velocidade', (tester) async {
    await tester.pumpWidget(const ExploradorMovelApp());
    expect(find.text('Toque no botão para obter a localização.'), findsOneWidget);
    await tester.tap(find.text('Velocidade').last);
    await tester.pumpAndSettle();
    expect(find.text('km/h'), findsOneWidget);
    expect(find.text('Iniciar'), findsOneWidget);
  });
}
