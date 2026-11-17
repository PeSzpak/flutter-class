import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'aluno_repositorio.dart';
import 'cadastro_tela.dart';

// Vêm de supabase.json: flutter run --dart-define-from-file=supabase.json
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseChave = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

// Passo 4: inicializar o Supabase antes do runApp().
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_supabaseUrl.isEmpty || _supabaseChave.isEmpty) {
    throw StateError(
      'Faltam as chaves do Supabase. Copie supabase.example.json para '
      'supabase.json e rode com --dart-define-from-file=supabase.json',
    );
  }
  await Supabase.initialize(url: _supabaseUrl, publishableKey: _supabaseChave);
  runApp(CadastroAlunosApp(repositorio: SupabaseAlunoRepositorio(Supabase.instance.client)));
}

class CadastroAlunosApp extends StatelessWidget {
  const CadastroAlunosApp({super.key, required this.repositorio});

  final AlunoRepositorio repositorio;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Alunos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF3ECF8E), useMaterial3: true),
      home: CadastroTela(repositorio: repositorio),
    );
  }
}
