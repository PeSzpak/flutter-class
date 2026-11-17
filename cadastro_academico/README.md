# Exercício 09/10: Cadastro acadêmico com Matrícula

Parte do código fornecido em aula (`main.dart`) e acrescenta:

- campo **Matrícula** logo abaixo do nome;
- o envio é impedido se a matrícula estiver vazia;
- a matrícula precisa ter **pelo menos 5 caracteres** (espaços nas pontas não contam);
- a matrícula aparece na janela de confirmação.

**ADO (funções dos slides):** cada função vista em aula está marcada no código com um comentário `ADO:`, e a lista completa está no topo de `lib/main.dart`.

## Testes (3 inválidos e 1 válido)

| Caso | Matrícula | Resultado |
|---|---|---|
| Inválido 1 | vazia | "Informe a matrícula." e o cadastro não é enviado |
| Inválido 2 | `A123` (4 caracteres) | "A matrícula deve ter pelo menos 5 caracteres." |
| Inválido 3 | `  12  ` (espaços em volta) | "A matrícula deve ter pelo menos 5 caracteres." |
| Válido | `2026ADS01` | Confirmação com "Matrícula: 2026ADS01" |

```bash
flutter test            # roda os 4 casos acima e os testes da função de validação
flutter run             # Android, ou -d chrome
```

Capturas de tela em [`prints/`](prints). Para gerar de novo: `flutter test prints --update-goldens`.
