class Aluno {
  const Aluno({this.id, required this.nome, required this.email, required this.curso, required this.semestre, this.criadoEm});

  final int? id;
  final String nome;
  final String email;
  final String curso;
  final int semestre;
  final DateTime? criadoEm;

  Map<String, dynamic> toMap() => {'nome': nome, 'email': email, 'curso': curso, 'semestre': semestre};

  factory Aluno.fromMap(Map<String, dynamic> m) => Aluno(
        id: m['id'] as int?,
        nome: m['nome'] as String,
        email: m['email'] as String,
        curso: m['curso'] as String,
        semestre: m['semestre'] as int,
        criadoEm: m['criado_em'] == null ? null : DateTime.parse(m['criado_em'] as String),
      );
}
