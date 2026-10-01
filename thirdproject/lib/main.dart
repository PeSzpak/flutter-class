import 'package:flutter/material.dart';

import 'sobre_tela.dart';
import 'tarefa.dart';
import 'tarefas_tela.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TarefasController _controller = TarefasController();
  ThemeMode _tema = ThemeMode.system;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

  void _alternarTema(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    setState(() => _tema = escuro ? ThemeMode.light : ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: _montarTema(Brightness.light),
      darkTheme: _montarTema(Brightness.dark),
      themeMode: _tema,
      home: InicioTela(
        controller: _controller,
        aoAlternarTema: _alternarTema,
      ),
    );
  }
}

// Tela 1 - Início
class InicioTela extends StatelessWidget {
  const InicioTela({
    super.key,
    required this.controller,
    required this.aoAlternarTema,
  });

  final TarefasController controller;
  final void Function(BuildContext) aoAlternarTema;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final escuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: escuro ? 'Tema claro' : 'Tema escuro',
            icon: Icon(escuro ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => aoAlternarTema(context),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagem de fundo; se faltar, cai para um degradê.
          Image.asset(
            'assets/images/fundo.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [esquema.primary, esquema.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Camada escura para garantir contraste do texto.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.checklist_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'App de Tarefas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Organize seu dia, uma tarefa por vez.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      ListenableBuilder(
                        listenable: controller,
                        builder: (context, _) => _ResumoCard(controller),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        icon: const Icon(Icons.list_alt),
                        label: const Text('Minhas tarefas'),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TarefasTela(controller: controller),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Sobre'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white70),
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SobreTela()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  const _ResumoCard(this.controller);

  final TarefasController controller;

  @override
  Widget build(BuildContext context) {
    final progresso =
        controller.total == 0 ? 0.0 : controller.concluidas / controller.total;

    return Card(
      color: Colors.white.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Numero(valor: controller.pendentes, rotulo: 'Pendentes'),
                _Numero(valor: controller.concluidas, rotulo: 'Concluídas'),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progresso,
                minHeight: 8,
                backgroundColor: Colors.white24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero({required this.valor, required this.rotulo});

  final int valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$valor',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(rotulo, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
