import 'dart:convert';

import 'package:http/http.dart' as http;

// Erro com mensagem pronta para mostrar ao usuário.
class ConsultaException implements Exception {
  const ConsultaException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

class Endereco {
  const Endereco({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.uf,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) => Endereco(
    cep: json['cep'] ?? '',
    logradouro: json['logradouro'] ?? '',
    complemento: json['complemento'] ?? '',
    bairro: json['bairro'] ?? '',
    cidade: json['localidade'] ?? '',
    uf: json['uf'] ?? '',
  );

  final String cep;
  final String logradouro;
  final String complemento;
  final String bairro;
  final String cidade;
  final String uf;
}

class Empresa {
  const Empresa({
    required this.cnpj,
    required this.razaoSocial,
    required this.nomeFantasia,
    required this.situacao,
    required this.abertura,
    required this.atividade,
    required this.endereco,
    required this.cidade,
    required this.uf,
    required this.telefone,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    final partes = [
      json['descricao_tipo_de_logradouro'],
      json['logradouro'],
    ].where((p) => p != null && '$p'.isNotEmpty).join(' ');
    final numero = '${json['numero'] ?? ''}';
    final bairro = '${json['bairro'] ?? ''}';
    return Empresa(
      cnpj: '${json['cnpj'] ?? ''}',
      razaoSocial: '${json['razao_social'] ?? ''}',
      nomeFantasia: '${json['nome_fantasia'] ?? ''}',
      situacao: '${json['descricao_situacao_cadastral'] ?? ''}',
      abertura: '${json['data_inicio_atividade'] ?? ''}',
      atividade: '${json['cnae_fiscal_descricao'] ?? ''}',
      endereco: [
        if (partes.isNotEmpty) numero.isEmpty ? partes : '$partes, $numero',
        if (bairro.isNotEmpty) bairro,
      ].join(' - '),
      cidade: '${json['municipio'] ?? ''}',
      uf: '${json['uf'] ?? ''}',
      telefone: '${json['ddd_telefone_1'] ?? ''}',
    );
  }

  final String cnpj;
  final String razaoSocial;
  final String nomeFantasia;
  final String situacao;
  final String abertura;
  final String atividade;
  final String endereco;
  final String cidade;
  final String uf;
  final String telefone;
}

String somenteDigitos(String texto) => texto.replaceAll(RegExp(r'\D'), '');

// Valida os dois dígitos verificadores do CNPJ.
bool cnpjValido(String cnpj) {
  final d = somenteDigitos(cnpj);
  if (d.length != 14 || RegExp(r'^(\d)\1*$').hasMatch(d)) return false;
  final n = d.split('').map(int.parse).toList();
  int digito(int tamanho) {
    final pesos = tamanho == 12
        ? [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
        : [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    var soma = 0;
    for (var i = 0; i < tamanho; i++) {
      soma += n[i] * pesos[i];
    }
    final resto = soma % 11;
    return resto < 2 ? 0 : 11 - resto;
  }

  return digito(12) == n[12] && digito(13) == n[13];
}

class ConsultaService {
  ConsultaService({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  final http.Client _cliente;

  Future<Endereco> buscarCep(String texto) async {
    final cep = somenteDigitos(texto);
    if (cep.isEmpty) throw const ConsultaException('Informe o CEP');
    if (cep.length != 8) {
      throw const ConsultaException('O CEP deve ter 8 dígitos');
    }

    final json = await _get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
    // O ViaCEP responde 200 com {"erro": true} quando o CEP não existe.
    if (json['erro'] != null) {
      throw const ConsultaException('CEP não encontrado');
    }
    return Endereco.fromJson(json);
  }

  Future<Empresa> buscarCnpj(String texto) async {
    final cnpj = somenteDigitos(texto);
    if (cnpj.isEmpty) throw const ConsultaException('Informe o CNPJ');
    if (!cnpjValido(cnpj)) throw const ConsultaException('CNPJ inválido');

    final json = await _get(
      Uri.parse('https://brasilapi.com.br/api/cnpj/v1/$cnpj'),
      naoEncontrado: 'CNPJ não encontrado',
    );
    return Empresa.fromJson(json);
  }

  Future<Map<String, dynamic>> _get(Uri url, {String? naoEncontrado}) async {
    final http.Response resposta;
    try {
      resposta = await _cliente.get(url).timeout(const Duration(seconds: 10));
    } catch (_) {
      throw const ConsultaException(
        'Não foi possível conectar. Verifique sua internet.',
      );
    }
    if (resposta.statusCode == 404 && naoEncontrado != null) {
      throw ConsultaException(naoEncontrado);
    }
    if (resposta.statusCode != 200) {
      throw ConsultaException(
        'Erro no servidor (${resposta.statusCode}). Tente novamente.',
      );
    }
    return jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
  }
}
