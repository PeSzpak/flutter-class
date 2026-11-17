// Validação no app: o usuário vê o erro antes de gastar uma requisição.
// O banco valida de novo (política RLS e índice único), porque o app pode ser burlado.

String? validarNome(String? v) {
  final nome = v?.trim() ?? '';
  if (nome.isEmpty) return 'Informe o nome.';
  if (nome.length < 3) return 'Digite pelo menos 3 caracteres.';
  return null;
}

String? validarEmail(String? v) {
  final email = v?.trim() ?? '';
  if (email.isEmpty) return 'Informe o e-mail.';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) return 'Informe um e-mail válido.';
  return null;
}

String? validarCurso(String? v) => (v?.trim() ?? '').isEmpty ? 'Informe o curso.' : null;

String? validarSemestre(String? v) {
  final texto = v?.trim() ?? '';
  if (texto.isEmpty) return 'Informe o semestre.';
  final semestre = int.tryParse(texto);
  if (semestre == null) return 'O semestre deve ser um número.';
  if (semestre < 1 || semestre > 12) return 'O semestre deve estar entre 1 e 12.';
  return null;
}
