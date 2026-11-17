import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cep_tela.dart';
import 'cliente_repositorio.dart';
import 'clientes_tela.dart';
import 'cnpj_tela.dart';
import 'consulta_service.dart';

// Vêm de supabase.json: flutter run --dart-define-from-file=supabase.json
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseChave = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

Future<void> main() async {
  if (_supabaseUrl.isEmpty || _supabaseChave.isEmpty) {
    throw StateError(
      'Faltam as chaves do Supabase. Copie supabase.example.json para '
      'supabase.json e rode com --dart-define-from-file=supabase.json',
    );
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: _supabaseUrl, publishableKey: _supabaseChave);
  runApp(
    MyApp(
      servico: ConsultaService(),
      repositorio: SupabaseClienteRepositorio(Supabase.instance.client),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.servico, required this.repositorio});

  final ConsultaService servico;
  final ClienteRepositorio repositorio;

  ThemeData _montarTema(Brightness brilho) {
    final esquema = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: brilho,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      appBarTheme: const AppBarTheme(centerTitle: true),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta Fácil',
      debugShowCheckedModeBanner: false,
      theme: _montarTema(Brightness.light),
      darkTheme: _montarTema(Brightness.dark),
      home: InicioTela(servico: servico, repositorio: repositorio),
    );
  }
}

class InicioTela extends StatefulWidget {
  const InicioTela({
    super.key,
    required this.servico,
    required this.repositorio,
  });

  final ConsultaService servico;
  final ClienteRepositorio repositorio;

  @override
  State<InicioTela> createState() => _InicioTelaState();
}

class _InicioTelaState extends State<InicioTela> {
  int _aba = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack mantém o estado de cada aba ao trocar.
      body: IndexedStack(
        index: _aba,
        children: [
          CepTela(servico: widget.servico),
          CnpjTela(servico: widget.servico),
          ClientesTela(
            servico: widget.servico,
            repositorio: widget.repositorio,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (i) => setState(() => _aba = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'CEP',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
            label: 'CNPJ',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Clientes',
          ),
        ],
      ),
    );
  }
}
