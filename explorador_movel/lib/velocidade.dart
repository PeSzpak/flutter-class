import 'dart:math';

/// Uma leitura do GPS reduzida ao que o cálculo precisa.
class Leitura {
  const Leitura({
    required this.latitude,
    required this.longitude,
    required this.precisao,
    required this.horario,
  });

  final double latitude;
  final double longitude;
  final double precisao; // em metros
  final DateTime horario;
}

/// velocidade = distância ÷ tempo; km/h = m/s × 3,6.
/// Leituras imprecisas ou fora de ordem são descartadas (filtro de leituras ruins).
class CalculadoraVelocidade {
  CalculadoraVelocidade({this.precisaoMaxima = 25, this.velocidadeMaximaKmh = 250});

  final double precisaoMaxima;
  final double velocidadeMaximaKmh;
  Leitura? _anterior;
  double distanciaTotal = 0; // metros

  /// Recebe uma leitura e devolve a velocidade em km/h,
  /// ou null quando ainda não há base de comparação ou a leitura foi descartada.
  double? adicionar(Leitura atual) {
    if (atual.precisao > precisaoMaxima) return null;

    final anterior = _anterior;
    if (anterior == null) {
      _anterior = atual;
      return null;
    }

    final segundos = atual.horario.difference(anterior.horario).inMilliseconds / 1000;
    if (segundos <= 0) return null;

    final metros = distanciaEmMetros(anterior.latitude, anterior.longitude, atual.latitude, atual.longitude);
    final kmh = metros / segundos * 3.6;
    if (kmh > velocidadeMaximaKmh) return null; // salto de GPS, não movimento real

    _anterior = atual;
    distanciaTotal += metros;
    return kmh;
  }

  void zerar() {
    _anterior = null;
    distanciaTotal = 0;
  }
}

/// Fórmula de Haversine: distância em metros entre duas coordenadas.
double distanciaEmMetros(double lat1, double lon1, double lat2, double lon2) {
  const raioTerra = 6371000.0;
  double rad(double graus) => graus * pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLon = rad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) + cos(rad(lat1)) * cos(rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  return raioTerra * 2 * atan2(sqrt(a), sqrt(1 - a));
}
