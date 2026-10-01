import 'package:flutter/material.dart';

// Tela 2 - Tarefas
// Precisa ser StatefulWidget porque a lista de tarefas muda com o tempo
// (o usuário adiciona novas tarefas e a tela precisa se redesenhar).
class TarefasTela extends StatefulWidget {
  const TarefasTela({super.key});

  @override
  State<TarefasTela> createState() => _TarefasTelaState();
}

class _TarefasTelaState extends State<TarefasTela> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _tarefas = [];

  void _adicionarTarefa() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _tarefas.add(texto);
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo para cadastrar tarefa.
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Nova tarefa',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _adicionarTarefa(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _adicionarTarefa,
                  child: const Text('Adicionar'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Contador de tarefas.
            Text(
              'Total de tarefas: ${_tarefas.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Lista das tarefas cadastradas.
            Expanded(
              child: _tarefas.isEmpty
                  ? const Center(
                      child: Text('Nenhuma tarefa cadastrada ainda.'),
                    )
                  : ListView.builder(
                      itemCount: _tarefas.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.check_box_outline_blank),
                            title: Text(_tarefas[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                setState(() {
                                  _tarefas.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),

            // Botão Voltar.
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
