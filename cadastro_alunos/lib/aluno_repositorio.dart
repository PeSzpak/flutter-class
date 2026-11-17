import 'package:supabase_flutter/supabase_flutter.dart';

import 'aluno.dart';

class AlunoException implements Exception {
  const AlunoException(this.mensagem);
  final String mensagem;
}

// A tela só conhece esta interface; nos testes entra uma versão em memória.
abstract class AlunoRepositorio {
  Future<void> cadastrar(Aluno aluno);
  Future<List<Aluno>> listar();
}

class SupabaseAlunoRepositorio implements AlunoRepositorio {
  SupabaseAlunoRepositorio(this._db);

  final SupabaseClient _db;

  // Passo 6: insert envia um mapa de campos para a tabela.
  @override
  Future<void> cadastrar(Aluno aluno) => _tentar(() => _db.from('alunos').insert(aluno.toMap()));

  // Extensão 1: SELECT
  @override
  Future<List<Aluno>> listar() => _tentar(() async {
        final linhas = await _db.from('alunos').select().order('criado_em', ascending: false);
        return linhas.map(Aluno.fromMap).toList();
      });

  // Erros comuns do slide 13, traduzidos para o usuário.
  Future<T> _tentar<T>(Future<T> Function() acao) async {
    try {
      return await acao();
    } on PostgrestException catch (e) {
      switch (e.code) {
        case '23505':
          throw const AlunoException('Este e-mail já está cadastrado.');
        case '42501':
          throw const AlunoException('O banco recusou os dados (permissão ou política RLS).');
        case '42P01':
          throw const AlunoException('Tabela alunos não encontrada no Supabase.');
        case '22P02':
          throw const AlunoException('Algum campo foi enviado com o tipo errado.');
      }
      throw AlunoException('Erro no banco: ${e.message}');
    } on AlunoException {
      rethrow;
    } catch (_) {
      throw const AlunoException('Sem conexão com o servidor. Verifique a internet e tente de novo.');
    }
  }
}
