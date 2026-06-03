# MEMORIA_PROJETO.md — DinDinVani&Nani

> Ultima atualizacao: 02/06/2026 20:41
> Diretorio do projeto: **Z:\AppFinancas** (migrado de C:\ em 02/06/2026)
> Raiz Flutter: **Z:\AppFinancas\app**
> STATUS: ** PROJETO 100% CONCLUIDO - APP NO AR! **

## URL DE PRODUCAO
- App online: https://web-beta-eight-50.vercel.app
- Deploy alt: https://web-h2hwhdmp9-vanderhansen-boops-projects.vercel.app
- Conta Vercel: vanderhansen-boop

## STACK
Flutter 3.44.0 | Dart | Riverpod 2.x | go_router | fl_chart
Supabase | Firebase FCM | Vercel | GitHub Actions

## PROGRESSO DOS 32 SCRIPTS — TODOS CONCLUIDOS

### FASE 0 — Setup
- [x] 01 check_deps
- [x] 02 install_scoop
- [x] 03 install_flutter
- [x] 04 install_node
- [x] 05 install_supabase
- [x] 06 install_git
- [x] 07 create_cursorrules

### FASE 1 — Flutter + Supabase
- [x] 08 create_flutter_project
- [x] 09 setup_pubspec
- [x] 10 init_supabase_local
- [x] 11 create_project_structure

### FASE 2 — Banco de Dados
- [x] 12 create_schema
- [x] 13 apply_rls
- [x] 14 create_triggers
- [x] 15 seed_categories
- [x] 16 create_edge_functions

### FASE 3 — Flutter Core
- [x] 17 create_core_layer
- [x] 18 create_data_layer
- [x] 19 create_domain_layer
- [x] 20 create_auth_feature

### FASE 4 — Telas
- [x] 21 dashboard
- [x] 22 transactions
- [x] 23 piggy_banks
- [x] 24 planning
- [x] 25 credit_cards
- [x] 26 reports
- [x] 27 profile

### FASE 5 — Deploy
- [x] 28 setup_firebase
- [x] 29 setup_github_actions
- [x] 30 build_android
- [x] 31 build_web
- [x] 32 deploy_vercel        <-- CONCLUIDO EM 02/06/2026 20:41

## ESTADO ATUAL
- PROJETO FINALIZADO! Todos os 32 scripts executados com sucesso.
- App PWA publicado e acessivel via internet.
- APK Android gerado (Script 30).
- Build Web (PWA) no ar via Vercel.

## OBSERVACOES TECNICAS
- vercel.json deve ser gravado SEM BOM (usar [System.IO.File]::WriteAllText com UTF8 false)
- Avisos de Wasm sao inofensivos - build JS OK
- 61 pacotes com versoes mais novas disponiveis - atualizar com cuidado em manutencoes futuras
- Para renomear URL: Vercel > projeto 'web' > Settings > Project Name > 'dindinvani-nani'

## PROXIMOS PASSOS (MANUTENCAO / MELHORIAS FUTURAS)
- [ ] Renomear projeto na Vercel para URL mais bonita
- [ ] Configurar dominio proprio (opcional)
- [ ] Testar fluxo completo OD / CF / CPI em producao com dados reais
- [ ] Distribuir APK Android para Vani e Nani
- [ ] Verificar keep-alive do Supabase (GitHub Actions - Script 29)
