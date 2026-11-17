// Exercício 09/10: cadastro acadêmico com o campo Matrícula.
//
// ADO: as funções vistas nos slides estão marcadas no código com "ADO:".
//   runApp()                    inicia o aplicativo
//   build()                     desenha a interface do widget
//   createState() / State       tela com estado (StatefulWidget)
//   dispose()                   libera os controllers ao sair da tela
//   TextEditingController       lê o texto digitado
//   GlobalKey<FormState>        identifica o formulário
//   validator                   regra de validação de cada campo
//   validate()                  valida todos os campos de uma vez
//   reset()                     limpa as mensagens do formulário
//   setState()                  atualiza a tela quando o estado muda
//   trim()                      remove espaços antes e depois do texto
//   ScaffoldMessenger.of(context).showSnackBar()   mensagem rápida no rodapé
//   showDialog() / AlertDialog  janela de confirmação
//   Navigator.of(context).pop() fecha a janela
//   DropdownButtonFormField     lista de opções com validação
//   CheckboxListTile            caixa de confirmação

import 'package:flutter/material.dart';

void main() {
  // ADO: runApp()
  runApp(const CadastroAcademicoApp());
}

class CadastroAcademicoApp extends StatelessWidget {
  const CadastroAcademicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro Acadêmico',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CadastroAlunoPage(),
    );
  }
}

class CadastroAlunoPage extends StatefulWidget {
  const CadastroAlunoPage({super.key});

  @override
  // ADO: createState()
  State<CadastroAlunoPage> createState() => _CadastroAlunoPageState();
}

class _CadastroAlunoPageState extends State<CadastroAlunoPage> {
  // ADO: GlobalKey<FormState>. O Form usa esta chave para validar todos os campos.
  final _formKey = GlobalKey<FormState>();

  // ADO: TextEditingController. Controllers permitem ler os valores digitados.
  final _nomeController = TextEditingController();
  final _matriculaController = TextEditingController();
  final _emailController = TextEditingController();
  final _cursoController = TextEditingController();

  String? _periodoSelecionado;
  bool _aceitouTermos = false;

  final List<String> _periodos = [
    'Matutino',
    'Vespertino',
    'Noturno',
    'EAD',
  ];

  // ADO: dispose()
  @override
  void dispose() {
    // Boa prática: liberar os controllers quando a tela for descartada.
    _nomeController.dispose();
    _matriculaController.dispose();
    _emailController.dispose();
    _cursoController.dispose();
    super.dispose();
  }

  void _cadastrarAluno() {
    // ADO: validate(). Se algum campo for inválido, o Flutter mostra a mensagem
    // correspondente e o envio é impedido (inclusive matrícula vazia ou curta).
    if (!_formKey.currentState!.validate()) {
      // ADO: ScaffoldMessenger.of(context).showSnackBar()
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revise os campos destacados antes de continuar.'),
        ),
      );
      return;
    }

    if (_periodoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o período do curso.')),
      );
      return;
    }

    if (!_aceitouTermos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marque a confirmação para concluir o cadastro.'),
        ),
      );
      return;
    }

    // ADO: trim()
    final nome = _nomeController.text.trim();
    final matricula = _matriculaController.text.trim();
    final email = _emailController.text.trim();
    final curso = _cursoController.text.trim();
    final periodo = _periodoSelecionado!;

    // ADO: showDialog() / AlertDialog. Por enquanto, os dados são apenas exibidos.
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cadastro realizado!'),
        content: Text(
          'Nome: $nome\n'
          'Matrícula: $matricula\n'
          'E-mail: $email\n'
          'Curso: $curso\n'
          'Período: $periodo\n\n'
          'Na próxima etapa, vamos adicionar a listagem e o armazenamento.',
        ),
        actions: [
          TextButton(
            // ADO: Navigator.of(context).pop()
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _limparFormulario();
            },
            child: const Text('Novo cadastro'),
          ),
        ],
      ),
    );
  }

  void _limparFormulario() {
    // ADO: reset()
    _formKey.currentState?.reset();
    _nomeController.clear();
    _matriculaController.clear();
    _emailController.clear();
    _cursoController.clear();

    // ADO: setState()
    setState(() {
      _periodoSelecionado = null;
      _aceitouTermos = false;
    });
  }

  // ADO: build()
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de aluno'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // Mantém o formulário confortável no navegador e em telas maiores.
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.school, size: 56),
                    const SizedBox(height: 12),
                    Text(
                      'Cadastro acadêmico',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Preencha os dados abaixo. Os campos obrigatórios '
                      'serão validados antes da confirmação.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _nomeController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nome completo',
                        hintText: 'Ex.: Ana Silva',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o nome completo.';
                        }
                        if (value.trim().length < 3) {
                          return 'Digite pelo menos 3 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      key: const Key('campoMatricula'),
                      controller: _matriculaController,
                      decoration: const InputDecoration(
                        labelText: 'Matrícula',
                        hintText: 'Ex.: 2026ADS01',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                      // ADO: validator
                      validator: validarMatricula,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'aluno@exemplo.com',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return 'Informe o e-mail.';
                        }
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(email)) {
                          return 'Informe um e-mail válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _cursoController,
                      decoration: const InputDecoration(
                        labelText: 'Curso',
                        hintText: 'Ex.: Análise e Desenvolvimento de Sistemas',
                        prefixIcon: Icon(Icons.menu_book_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o curso.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ADO: DropdownButtonFormField
                    DropdownButtonFormField<String>(
                      value: _periodoSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Período',
                        prefixIcon: Icon(Icons.schedule),
                        border: OutlineInputBorder(),
                      ),
                      items: _periodos
                          .map(
                            (periodo) => DropdownMenuItem(
                              value: periodo,
                              child: Text(periodo),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _periodoSelecionado = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione um período.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // ADO: CheckboxListTile
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text(
                        'Confirmo que os dados informados estão corretos.',
                      ),
                      value: _aceitouTermos,
                      onChanged: (value) {
                        setState(() {
                          _aceitouTermos = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    FilledButton.icon(
                      onPressed: _cadastrarAluno,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Validar e cadastrar'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _limparFormulario,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Limpar formulário'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Matrícula obrigatória, com pelo menos 5 caracteres (espaços nas pontas não contam).
String? validarMatricula(String? value) {
  final matricula = value?.trim() ?? '';
  if (matricula.isEmpty) {
    return 'Informe a matrícula.';
  }
  if (matricula.length < 5) {
    return 'A matrícula deve ter pelo menos 5 caracteres.';
  }
  return null;
}
