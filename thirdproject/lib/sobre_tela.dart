import 'package:flutter/material.dart';

// Tela 3 - Sobre
class SobreTela extends StatelessWidget {
  const SobreTela({super.key});

  // Dados do aluno exibidos nesta tela.
  static const String nomeAluno = 'Pedro Szpak';
  static const String curso = 'Análise e Desenvolvimento de Sistemas (ADS)';
  static const String disciplina = 'Tecnologias Móveis e Híbridas';

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Foto do aluno; sem assets/images/perfil.jpg, mostra um ícone.
                Center(
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: esquema.primaryContainer,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/perfil.jpg',
                        width: 112,
                        height: 112,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          size: 64,
                          color: esquema.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  nomeAluno,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                const Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.school_outlined),
                        title: Text('Curso'),
                        subtitle: Text(curso),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.menu_book_outlined),
                        title: Text('Disciplina'),
                        subtitle: Text(disciplina),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Voltar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
