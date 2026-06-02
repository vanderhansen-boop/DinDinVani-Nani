# Supabase - DinDinVani&Nani

Estrutura local do Supabase para o projeto.

## Comandos uteis

- supabase login         (primeira vez)
- supabase link --project-ref REF
- supabase db push       (aplica migrations no Cloud)
- supabase status        (status do projeto)

## Workflow

1. Scripts 12-16 vao gerar SQL em migrations/
2. Crie projeto gratuito em https://supabase.com
3. Rode supabase link e supabase db push

Usamos apenas Supabase Cloud (gratuito). Sem Docker local.
