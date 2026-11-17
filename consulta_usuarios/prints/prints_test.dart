// Gera os prints: flutter test prints --update-goldens
// usuarios_reais.json é a resposta de https://jsonplaceholder.typicode.com/users
import 'dart:io';

import 'package:consulta_usuarios/api_service.dart';
import 'package:consulta_usuarios/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fontes.dart';

ApiService api(Future<http.Response> Function() resposta) =>
    ApiService(cliente: MockClient((_) => resposta()));

void main() {
  setUpAll(carregarFontes);

  testWidgets('print: lista de usuários', (tester) async {
    tamanhoCelular(tester);
    final corpo = File('prints/usuarios_reais.json').readAsBytesSync();
    await tester.pumpWidget(ConsultaUsuariosApp(
        api: api(() async => http.Response.bytes(corpo, 200, headers: {'content-type': 'application/json; charset=utf-8'}))));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('01_lista.png'));
  });

  testWidgets('print: erro de conexão', (tester) async {
    tamanhoCelular(tester);
    await tester.pumpWidget(ConsultaUsuariosApp(api: api(() async => throw http.ClientException('offline'))));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('02_erro.png'));
  });
}
