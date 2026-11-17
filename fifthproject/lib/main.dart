import 'package:flutter/material.dart';

import 'cep_tela.dart';
import 'clientes_tela.dart';
import 'cnpj_tela.dart';
import 'consulta_service.dart';

void main() {
  runApp(MyApp(servico: ConsultaService()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.servico});

  final ConsultaService servico;

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
      home: InicioTela(servico: servico),
    );
  }
}

class InicioTela extends StatefulWidget {
  const InicioTela({super.key, required this.servico});

  final ConsultaService servico;

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
          ClientesTela(servico: widget.servico),
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
