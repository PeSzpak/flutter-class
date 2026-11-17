import 'package:supabase_flutter/supabase_flutter.dart';

import 'cliente.dart';

class ClienteException implements Exception {
  const ClienteException(this.mensagem);
  final String mensagem;
}

// A tela só conhece esta interface; nos testes entra uma versão em memória.
abstract class ClienteRepositorio {
  Future<List<Cliente>> listar();
  Future<Cliente> inserir(Cliente cliente);
  Future<void> remover(int id);
}

class SupabaseClienteRepositorio implements ClienteRepositorio {
  SupabaseClienteRepositorio(this._db);

  final SupabaseClient _db;

  SupabaseQueryBuilder get _tabela => _db.from('clientes');

  @override
  Future<List<Cliente>> listar() => _tentar(() async {
    final linhas = await _tabela.select().order('created_at');
    return linhas.map(Cliente.fromMap).toList();
  });

  @override
  Future<Cliente> inserir(Cliente cliente) => _tentar(() async {
    final linha = await _tabela.insert(cliente.toMap()).select().single();
    return Cliente.fromMap(linha);
  });

  @override
  Future<void> remover(int id) => _tentar(() => _tabela.delete().eq('id', id));

  Future<T> _tentar<T>(Future<T> Function() acao) async {
    try {
      return await acao();
    } on PostgrestException catch (e) {
      // 23505 = violação de unique (CPF repetido)
      if (e.code == '23505') throw const ClienteException('CPF já cadastrado');
      throw ClienteException('Erro no banco: ${e.message}');
    } catch (_) {
      throw const ClienteException(
        'Sem conexão com o servidor. Tente de novo.',
      );
    }
  }
}
