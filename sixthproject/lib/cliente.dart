class Cliente {
  const Cliente({
    this.id,
    required this.nome,
    required this.cpf,
    required this.email,
    required this.telefone,
    required this.cep,
    required this.logradouro,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.uf,
  });

  // Gerado pelo banco; nulo enquanto o cliente ainda não foi salvo.
  final int? id;
  final String nome;
  final String cpf;
  final String email;
  final String telefone;
  final String cep;
  final String logradouro;
  final String numero;
  final String bairro;
  final String cidade;
  final String uf;

  factory Cliente.fromMap(Map<String, dynamic> m) => Cliente(
    id: m['id'] as int,
    nome: m['nome'] as String,
    cpf: m['cpf'] as String,
    email: m['email'] as String,
    telefone: m['telefone'] as String,
    cep: m['cep'] as String,
    logradouro: m['logradouro'] as String,
    numero: m['numero'] as String,
    bairro: m['bairro'] as String,
    cidade: m['cidade'] as String,
    uf: m['uf'] as String,
  );

  Map<String, dynamic> toMap() => {
    'nome': nome,
    'cpf': cpf,
    'email': email,
    'telefone': telefone,
    'cep': cep,
    'logradouro': logradouro,
    'numero': numero,
    'bairro': bairro,
    'cidade': cidade,
    'uf': uf,
  };
}
