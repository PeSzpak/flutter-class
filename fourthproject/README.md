# StudyFlow

Organizador de atividades de estudo.

<img src="../docs/media/studyflow-cadastro.webp" width="240" alt="Formulário de nova atividade com disciplina, nome, data, prioridade e checkbox de importante">

- **Lista** (`atividades_tela.dart`): resumo com total, pendentes e concluídas; concluir e excluir (com desfazer no SnackBar).
- **Cadastro** (`cadastro_tela.dart`): disciplina, nome, data de entrega (`showDatePicker`), prioridade (`DropdownButton`) e "importante" (`CheckboxListTile`).
- **Detalhes** (`detalhes_tela.dart`): todos os campos da atividade, aberta pelo `Navigator`.
- Modelo em `lib/atividade.dart`; os dados ficam em memória.

```bash
flutter pub get
flutter test
flutter run   # ou: flutter run -d chrome
```
