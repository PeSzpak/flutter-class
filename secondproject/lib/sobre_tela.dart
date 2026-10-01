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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagem (foto do aluno, logo, etc.).
              // Placeholder: enquanto não existir assets/images/perfil.jpg,
              // o errorBuilder mostra um ícone circular no lugar da imagem.
              ClipOval(
                child: Image.asset(
                  'assets/images/perfil.jpg',
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 140,
                      height: 140,
                      color: Colors.indigo.shade100,
                      child: Icon(
                        Icons.person,
                        size: 72,
                        color: Colors.indigo.shade400,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                nomeAluno,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Curso: $curso',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 4),

              const Text(
                'Disciplina: $disciplina',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
