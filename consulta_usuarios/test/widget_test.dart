import 'package:consulta_usuarios/api_service.dart';
import 'package:consulta_usuarios/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

ApiService apiQueResponde(String corpo, [int status = 200]) =>
    ApiService(cliente: MockClient((_) async => http.Response(corpo, status, headers: {'content-type': 'application/json; charset=utf-8'})));

const doisUsuarios = '[{"name":"Leanne Graham","email":"Sincere@april.biz","phone":"1-770-736-8031"},'
    '{"name":"Ervin Howell","email":"Shanna@melissa.tv","phone":"010-692-6593"}]';

void main() {
  testWidgets('mostra o carregamento e depois nome, e-mail e telefone', (tester) async {
    await tester.pumpWidget(ConsultaUsuariosApp(api: apiQueResponde(doisUsuarios)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Leanne Graham'), findsOneWidget);
    expect(find.text('Sincere@april.biz\n1-770-736-8031'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('erro do servidor mostra aviso e botão de tentar de novo', (tester) async {
    await tester.pumpWidget(ConsultaUsuariosApp(api: apiQueResponde('erro', 500)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Não foi possível consultar'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
  });

  testWidgets('falha de rede mostra o mesmo aviso', (tester) async {
    final api = ApiService(cliente: MockClient((_) async => throw http.ClientException('sem internet')));
    await tester.pumpWidget(ConsultaUsuariosApp(api: api));
    await tester.pumpAndSettle();
    expect(find.textContaining('Não foi possível consultar'), findsOneWidget);
  });

  testWidgets('lista vazia mostra aviso próprio', (tester) async {
    await tester.pumpWidget(ConsultaUsuariosApp(api: apiQueResponde('[]')));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum usuário encontrado.'), findsOneWidget);
  });

  testWidgets('JSON em formato errado é tratado como erro', (tester) async {
    await tester.pumpWidget(ConsultaUsuariosApp(api: apiQueResponde('{"name":"x"}')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Não foi possível consultar'), findsOneWidget);
  });

}
