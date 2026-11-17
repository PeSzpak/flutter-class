import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Carrega a Roboto e os ícones do próprio SDK do Flutter, para o print sair
/// com texto de verdade (nos testes, o padrão é uma fonte de caixinhas).
Future<void> carregarFontes() async {
  final raiz = Platform.environment['FLUTTER_ROOT'] ?? '/opt/homebrew/share/flutter';
  final pasta = '$raiz/bin/cache/artifacts/material_fonts';
  Future<ByteData> ler(String arquivo) async =>
      ByteData.sublistView(File('$pasta/$arquivo').readAsBytesSync());

  final roboto = FontLoader('Roboto');
  for (final peso in ['Regular', 'Medium', 'Bold']) {
    roboto.addFont(ler('Roboto-$peso.ttf'));
  }
  await roboto.load();
  await (FontLoader('MaterialIcons')..addFont(ler('MaterialIcons-Regular.otf'))).load();
}

/// Tela de celular: 412 x 915 pontos.
void tamanhoCelular(WidgetTester tester) {
  tester.view.physicalSize = const Size(1236, 2745);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}
