-- Rode uma vez no SQL Editor do Supabase (projeto de teste, dados fictícios).

-- Passo 1: a tabela do slide
create table if not exists public.alunos (
  id bigint generated always as identity primary key,
  nome text not null,
  email text not null,
  curso text not null,
  semestre integer not null,
  criado_em timestamptz not null default now()
);

-- Extensão 2: o banco recusa e-mail repetido, mesmo com maiúsculas diferentes
create unique index if not exists alunos_email_unico on public.alunos (lower(email));

-- Passo 2: segurança do laboratório (INSERT anônimo só com campos válidos)
alter table public.alunos enable row level security;
grant insert on public.alunos to anon;
create policy "Permitir cadastro para aula" on public.alunos
  for insert to anon
  with check (
    nome <> '' and email <> '' and curso <> ''
    and semestre between 1 and 12
  );

-- Extensão 1: listar alunos (SELECT). Só para a aula: em produção, ninguém
-- anônimo deveria ler e-mails de outras pessoas (ver README).
grant select on public.alunos to anon;
create policy "Permitir leitura para aula" on public.alunos
  for select to anon
  using (true);
