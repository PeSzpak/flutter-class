import 'package:flutter/material.dart';

import 'aluno.dart';
import 'aluno_repositorio.dart';
import 'alunos_tela.dart';
import 'validacao.dart';

class CadastroTela extends StatefulWidget {
  const CadastroTela({super.key, required this.repositorio});

  final AlunoRepositorio repositorio;

  @override
  State<CadastroTela> createState() => _CadastroTelaState();
}

class _CadastroTelaState extends State<CadastroTela> {
  // Passo 5: formulário com TextEditingController
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cursoController = TextEditingController();
  final _semestreController = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cursoController.dispose();
    _semestreController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviando = true);
    final mensageiro = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    // Passo 7: tratar sucesso e erro
    try {
      await widget.repositorio.cadastrar(Aluno(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        curso: _cursoController.text.trim(),
        semestre: int.parse(_semestreController.text.trim()),
      ));
      if (!mounted) return;
      mensageiro.showSnackBar(const SnackBar(content: Text('Aluno cadastrado com sucesso!')));
      _formKey.currentState!.reset();
      for (final c in [_nomeController, _emailController, _cursoController, _semestreController]) {
        c.clear();
      }
    } on AlunoException catch (e) {
      mensageiro.showSnackBar(SnackBar(
        content: Text(e.mensagem),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de alunos'),
        actions: [
          IconButton(
            tooltip: 'Alunos cadastrados',
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AlunosTela(repositorio: widget.repositorio)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _campo(_nomeController, 'Nome', Icons.person_outline, validarNome,
                    capitalizacao: TextCapitalization.words),
                _campo(_emailController, 'E-mail', Icons.email_outlined, validarEmail,
                    teclado: TextInputType.emailAddress),
                _campo(_cursoController, 'Curso', Icons.menu_book_outlined, validarCurso),
                _campo(_semestreController, 'Semestre (1 a 12)', Icons.timeline, validarSemestre,
                    teclado: TextInputType.number),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _enviando ? null : _cadastrar,
                  icon: _enviando
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(_enviando ? 'Enviando...' : 'Cadastrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(
    TextEditingController controller,
    String rotulo,
    IconData icone,
    String? Function(String?) validador, {
    TextInputType? teclado,
    TextCapitalization capitalizacao = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: teclado,
        textCapitalization: capitalizacao,
        decoration: InputDecoration(labelText: rotulo, prefixIcon: Icon(icone), border: const OutlineInputBorder()),
        validator: validador,
      ),
    );
  }
}
