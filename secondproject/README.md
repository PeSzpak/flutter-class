# App de Tarefas

Três telas ligadas com `Navigator.push`:

- **Início** (`main.dart`): imagem de fundo (`assets/images/fundo.png`), saudação com o nome do usuário e botões para as outras telas.
- **Tarefas** (`tarefas_tela.dart`): campo de texto, botão Adicionar e contador de tarefas.
- **Sobre** (`sobre_tela.dart`): nome, curso, disciplina e imagem.

As tarefas ficam só em memória. A versão com editar, concluir e filtros está em [`thirdproject/`](../thirdproject).

```bash
flutter pub get
flutter test
flutter run   # ou: flutter run -d chrome
```
