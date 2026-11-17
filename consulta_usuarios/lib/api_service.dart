import 'dart:convert';

import 'package:http/http.dart' as http;

import 'usuario.dart';

/// Consulta os usuários da JSONPlaceholder.
class ApiService {
  ApiService({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  static const baseUrl = 'https://jsonplaceholder.typicode.com';

  final http.Client _cliente;

  Future<List<Usuario>> buscarUsuarios() async {
    final resposta = await _cliente
        .get(Uri.parse('$baseUrl/users'))
        .timeout(const Duration(seconds: 15));

    if (resposta.statusCode != 200) {
      throw Exception('O servidor respondeu com o código ${resposta.statusCode}.');
    }

    final dados = jsonDecode(resposta.body);
    if (dados is! List) {
      throw const FormatException('A resposta não veio no formato esperado.');
    }
    return dados.whereType<Map<String, dynamic>>().map(Usuario.fromJson).toList();
  }
}
