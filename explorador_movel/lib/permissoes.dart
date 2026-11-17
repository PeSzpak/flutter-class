import 'package:geolocator/geolocator.dart';

/// Erro com uma mensagem pronta para mostrar ao usuário.
class ErroRecurso implements Exception {
  const ErroRecurso(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Passos 1 e 2 dos slides: serviço de localização ligado e permissão concedida.
Future<void> garantirLocalizacao() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw const ErroRecurso('A localização do aparelho está desligada. Ative o GPS e tente de novo.');
  }

  var permissao = await Geolocator.checkPermission();
  if (permissao == LocationPermission.denied) {
    permissao = await Geolocator.requestPermission();
  }
  if (permissao == LocationPermission.denied) {
    throw const ErroRecurso('Permissão de localização negada.');
  }
  if (permissao == LocationPermission.deniedForever) {
    throw const ErroRecurso(
        'Permissão de localização negada permanentemente. Libere nas configurações do aparelho.');
  }
}
