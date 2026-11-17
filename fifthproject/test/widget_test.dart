import 'dart:convert';

import 'package:fifthproject/consulta_service.dart';
import 'package:fifthproject/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Simula o ViaCEP e a BrasilAPI sem acessar a internet.
final _api = MockClient((req) async {
  final url = req.url.toString();
  if (url.contains('viacep') && url.contains('01001000')) {
    return http.Response.bytes(
      utf8.encode(
        jsonEncode({
          'cep': '01001-000',
          'logradouro': 'Praça da Sé',
          'complemento': 'lado ímpar',
          'bairro': 'Sé',
          'localidade': 'São Paulo',
          'uf': 'SP',
        }),
      ),
      200,
    );
  }
  if (url.contains('viacep')) return http.Response('{"erro": "true"}', 200);
  if (url.contains('11222333000181')) {
    return http.Response(
      jsonEncode({
        'cnpj': '11222333000181',
        'razao_social': 'EMPRESA TESTE LTDA',
        'nome_fantasia': 'Teste',
        'descricao_situacao_cadastral': 'ATIVA',
        'municipio': 'CURITIBA',
        'uf': 'PR',
      }),
      200,
    );
  }
  return http.Response('{"message": "not found"}', 404);
});

Future<void> _abrirApp(WidgetTester tester) =>
    tester.pumpWidget(MyApp(servico: ConsultaService(cliente: _api)));

Future<void> _buscarCep(WidgetTester tester, String cep, String numero) async {
  await tester.enterText(find.widgetWithText(TextField, 'CEP'), cep);
  await tester.enterText(
    find.widgetWithText(TextField, 'Número da residência'),
    numero,
  );
  await tester.tap(find.text('Buscar endereço'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('CEP válido mostra endereço com número e cidade/UF', (
    tester,
  ) async {
    await _abrirApp(tester);
    await _buscarCep(tester, '01001000', '123');

    expect(find.text('Praça da Sé, 123'), findsOneWidget);
    expect(find.text('São Paulo'), findsOneWidget);
    expect(find.text('SP'), findsOneWidget);
    expect(find.text('Sé'), findsOneWidget);
  });

  testWidgets('CEP válido sem número mostra s/n', (tester) async {
    await _abrirApp(tester);
    await _buscarCep(tester, '01001000', '');
    expect(find.text('Praça da Sé, s/n'), findsOneWidget);
  });

  testWidgets('CEP inexistente mostra erro', (tester) async {
    await _abrirApp(tester);
    await _buscarCep(tester, '99999999', '10');
    expect(find.text('CEP não encontrado'), findsOneWidget);
  });

  testWidgets('Campo vazio pede o CEP', (tester) async {
    await _abrirApp(tester);
    await _buscarCep(tester, '', '');
    expect(find.text('Informe o CEP'), findsOneWidget);
  });

  testWidgets('CEP incompleto avisa os 8 dígitos', (tester) async {
    await _abrirApp(tester);
    await _buscarCep(tester, '0100', '');
    expect(find.text('O CEP deve ter 8 dígitos'), findsOneWidget);
  });

  testWidgets('Consulta de CNPJ: válido, inválido e inexistente', (
    tester,
  ) async {
    await _abrirApp(tester);
    await tester.tap(find.text('CNPJ').last);
    await tester.pumpAndSettle();

    final campo = find.widgetWithText(TextField, 'CNPJ');
    await tester.enterText(campo, '11222333000181');
    await tester.tap(find.text('Buscar empresa'));
    await tester.pumpAndSettle();
    expect(find.text('Teste'), findsOneWidget);
    expect(find.text('CURITIBA - PR'), findsOneWidget);
    expect(find.text('ATIVA'), findsOneWidget);

    await tester.enterText(campo, '11222333000100');
    await tester.tap(find.text('Buscar empresa'));
    await tester.pumpAndSettle();
    expect(find.text('CNPJ inválido'), findsOneWidget);

    await tester.enterText(campo, '11444777000161');
    await tester.tap(find.text('Buscar empresa'));
    await tester.pumpAndSettle();
    expect(find.text('CNPJ não encontrado'), findsOneWidget);
  });

  testWidgets('Cadastro de cliente preenche endereço pelo CEP', (tester) async {
    tester.view.physicalSize = const Size(1080, 4200);
    addTearDown(tester.view.reset);
    await _abrirApp(tester);
    await tester.tap(find.text('Clientes').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Novo cliente'));
    await tester.pumpAndSettle();

    // Salvar vazio mostra os erros de validação.
    await tester.ensureVisible(find.text('Cadastrar cliente'));
    await tester.tap(find.text('Cadastrar cliente'));
    await tester.pumpAndSettle();
    expect(find.text('Campo obrigatório'), findsWidgets);

    Finder campo(String rotulo) => find.widgetWithText(TextFormField, rotulo);
    await tester.enterText(campo('Nome completo'), 'Maria Silva');
    await tester.enterText(campo('CPF'), '12345678901');
    await tester.enterText(campo('E-mail'), 'maria@email.com');
    await tester.enterText(campo('Telefone'), '11987654321');
    await tester.enterText(campo('CEP'), '01001000');
    await tester.pumpAndSettle();
    expect(find.text('Praça da Sé'), findsOneWidget);
    await tester.enterText(campo('Número'), '50');

    await tester.ensureVisible(find.text('Cadastrar cliente'));
    await tester.tap(find.text('Cadastrar cliente'));
    await tester.pumpAndSettle();

    expect(find.text('Maria Silva'), findsOneWidget);
    expect(
      find.textContaining('Praça da Sé, 50 - São Paulo/SP'),
      findsOneWidget,
    );
  });
}
