-- Tabela usada pelo app. Rode uma vez no SQL Editor do Supabase.
create table if not exists public.clientes (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  nome text not null,
  cpf text not null unique,
  email text not null,
  telefone text not null,
  cep text not null,
  logradouro text not null,
  numero text not null,
  bairro text not null,
  cidade text not null,
  uf char(2) not null
);

alter table public.clientes enable row level security;

-- Exercício sem login: qualquer um com a chave pública lê, cadastra e remove.
-- Num app real, troque por políticas ligadas a auth.uid().
create policy "anon lê clientes" on public.clientes for select to anon using (true);
create policy "anon cadastra clientes" on public.clientes for insert to anon with check (true);
create policy "anon remove clientes" on public.clientes for delete to anon using (true);
