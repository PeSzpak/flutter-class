import 'package:flutter/material.dart';

import 'camera_tela.dart';
import 'localizacao_tela.dart';
import 'velocidade_tela.dart';

void main() {
  runApp(const ExploradorMovelApp());
}

class ExploradorMovelApp extends StatelessWidget {
  const ExploradorMovelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explorador Móvel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
      home: const InicioTela(),
    );
  }
}

class InicioTela extends StatefulWidget {
  const InicioTela({super.key});

  @override
  State<InicioTela> createState() => _InicioTelaState();
}

class _InicioTelaState extends State<InicioTela> {
  int _aba = 0;

  static const _titulos = ['Localização', 'Câmera', 'Velocidade'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titulos[_aba])),
      // Cada aba é criada só quando aberta: a câmera e o GPS liberam os recursos ao trocar de aba.
      body: switch (_aba) {
        0 => const LocalizacaoTela(),
        1 => const CameraTela(),
        _ => const VelocidadeTela(),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (i) => setState(() => _aba = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.place_outlined), label: 'Localização'),
          NavigationDestination(icon: Icon(Icons.photo_camera_outlined), label: 'Câmera'),
          NavigationDestination(icon: Icon(Icons.speed), label: 'Velocidade'),
        ],
      ),
    );
  }
}
