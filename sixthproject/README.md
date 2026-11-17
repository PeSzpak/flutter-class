# sixthproject

Continuação do `fifthproject` (consulta de CEP e CNPJ e cadastro de clientes).
Agora os clientes ficam salvos numa tabela do Supabase, em vez de sumirem ao
fechar o app.

## Como rodar

1. No SQL Editor do Supabase, rode `supabase/clientes.sql`. Ele cria a tabela
   `clientes` e as permissões.
2. Copie `supabase.example.json` para `supabase.json` e preencha com a URL do
   projeto e a chave publicável (Project Settings → API Keys). O
   `supabase.json` fica fora do git.
3. Rode:

```bash
flutter run --dart-define-from-file=supabase.json
```

## Testes

```bash
flutter test
```

Os testes trocam o Supabase por um repositório em memória
(`ClienteRepositorio`), então rodam sem internet e sem chave.
