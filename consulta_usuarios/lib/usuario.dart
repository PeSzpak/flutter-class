/// Um usuário da JSONPlaceholder, só com os campos que o app mostra.
class Usuario {
  const Usuario({required this.nome, required this.email, required this.telefone});

  final String nome;
  final String email;
  final String telefone;

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        nome: json['name'] as String? ?? 'Sem nome',
        email: json['email'] as String? ?? '-',
        telefone: json['phone'] as String? ?? '-',
      );
}
