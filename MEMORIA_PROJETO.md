# MEMORIA_PROJETO.md
# DinDinVani&Nani — Controle de Progresso
# Atualizado automaticamente pelo script de sessao

## STATUS GERAL
Progresso: 91% (29/32 scripts concluidos)
Ultima atualizacao: 2026-06-02 16:24:31
Diretorio base: Z:\AppFinancas
Diretorio app:  Z:\AppFinancas\app

## FASE 0 — Setup [CONCLUIDA]
[x] 01 - check_deps          OK - Git, Flutter, Node, npm, Dart verificados
[x] 02 - install_scoop       OK - Scoop instalado
[x] 03 - install_flutter     OK - Flutter SDK 3.x instalado
[x] 04 - install_node        OK - Node.js LTS instalado
[x] 05 - install_supabase    OK - Supabase CLI instalado
[x] 06 - install_git         OK - Git verificado/instalado
[x] 07 - create_cursorrules  OK - Arquivos de configuracao criados

## FASE 1 — Flutter + Supabase [CONCLUIDA]
[x] 08 - create_flutter_project   OK - Projeto Flutter criado em Z:\AppFinancas\app
[x] 09 - setup_pubspec            OK - Dependencias configuradas
[x] 10 - init_supabase_local      OK - Supabase local inicializado
[x] 11 - create_project_structure OK - Clean Architecture estruturada

## FASE 2 — Banco de Dados [CONCLUIDA]
[x] 12 - create_schema       OK - Schema PostgreSQL completo (19 tabelas)
[x] 13 - apply_rls           OK - RLS em todas as tabelas
[x] 14 - create_triggers     OK - Triggers CF e CPI automaticos
[x] 15 - seed_categories     OK - Categorias padrao inseridas
[x] 16 - create_edge_functions OK - Edge functions criadas

## FASE 3 — Flutter Core [CONCLUIDA]
[x] 17 - create_core_layer   OK - constants, extensions, errors
[x] 18 - create_data_layer   OK - models, datasources, repositories
[x] 19 - create_domain_layer OK - entities, use_cases
[x] 20 - create_auth_feature OK - Autenticacao completa

## FASE 4 — Telas [CONCLUIDA]
[x] 21 - dashboard           OK - Saldo, Score Paz Financeira, alertas
[x] 22 - transactions        OK - Lancamentos, filtros, recorrencias
[x] 23 - piggy_banks         OK - Caixinhas CF, CPI, CP, CM, CE
[x] 24 - planning            OK - Metas, alocacao 50/30/20, regras
[x] 25 - credit_cards        OK - Cartoes, faturas, cobertura CF
[x] 26 - reports             OK - Relatorios, projecoes, PDF/CSV
[x] 27 - profile             OK - Perfil do casal, tema, backup

## FASE 5 — Deploy [EM ANDAMENTO]
[x] 28 - setup_firebase      OK - FCM + flutter_local_notifications
                                   notification_service.dart criado
                                   firebase_options.dart placeholder criado
                                   main.dart atualizado
                                   main_layout.dart criado
                                   google-services.json placeholder criado
[x] 29 - setup_github_actions OK - CI/CD + keep-alive Supabase
                                   ci.yml (analyze + test)
                                   cd.yml (build web + deploy Vercel)
                                   keep-alive.yml (ping a cada 3 dias)
                                   build-android.yml (APK manual/tag)
                                   .gitignore completo
                                   README.md criado
[ ] 30 - build_android        PENDENTE
[ ] 31 - build_web            PENDENTE
[ ] 32 - deploy_vercel        PENDENTE

## ARQUIVOS CRIADOS — FASE 5 (parcial)
Z:\AppFinancas\app\lib\core\services\notification_service.dart
Z:\AppFinancas\app\lib\firebase_options.dart
Z:\AppFinancas\app\lib\main.dart (atualizado)
Z:\AppFinancas\app\lib\presentation\router\app_router.dart
Z:\AppFinancas\app\lib\presentation\shared\layouts\main_layout.dart
Z:\AppFinancas\app\android\app\google-services.json (placeholder)
Z:\AppFinancas\.github\workflows\ci.yml
Z:\AppFinancas\.github\workflows\cd.yml
Z:\AppFinancas\.github\workflows\keep-alive.yml
Z:\AppFinancas\.github\workflows\build-android.yml
Z:\AppFinancas\.gitignore
Z:\AppFinancas\README.md
Z:\AppFinancas\app\.env.example

## ACOES MANUAIS PENDENTES
[ ] Criar projeto no Firebase Console (dindinvani-app)
[ ] Baixar google-services.json real e substituir placeholder
[ ] Executar: flutterfire configure --project=dindinvani-app
[ ] Criar repositorio no GitHub (dindinvani-app)
[ ] Configurar Secrets: SUPABASE_URL, SUPABASE_ANON_KEY
[ ] Configurar Secrets Vercel (no script 32)

## STACK UTILIZADA
Flutter: 3.44.x (canal stable)
Dart: SDK incluso no Flutter
Supabase: free tier — projeto xzbfdklyvgqlyowrlhfb
Firebase: FCM gratuito — placeholder configurado
Vercel: gratuito — deploy no script 32
GitHub Actions: gratuito (2000 min/mes)

## PROXIMO PASSO
Script 30 - build_android
  - Configura android/build.gradle e app/build.gradle
  - Configura assinatura (keystore)
  - Executa flutter build apk --release
  - Gera APK em build/app/outputs/flutter-apk/
---
## 📝 LOG DE SESSÃO — 02/06/2026 17:27

### ✅ Tela 26 — Reports (Relatórios) FUNCIONANDO
- Entidade MonthlySummary + CategoryBreakdown finalizada
  - Getters: income, expense, balance, savingsRate, totalIncome,
    totalExpenses, topCategories, label, monthLabel, monthFull
  - Aliases em CategoryBreakdown: .key e .value (p/ CategoryPieChart)
- Widget MonthlyBarChart -> recebe data:
- Widget _SummaryTable -> recebe summaries:
- Widget CategoryPieChart -> usa .key / .value
- ✅ App COMPILA 100% sem erros
- ✅ App RODA no navegador (web-server :8080)

### 💡 Notas de ambiente
- Chrome auto-launch falha no Windows -> usar:
  lutter run -d web-server --web-port 8080 e abrir manualmente
---
## 📝 LOG DE SESSÃO — 02/06/2026 17:30

### ✅ Tela 27 — Profile CONCLUÍDA
- profile_page.dart completa (header casal, editar perfil, aparência,
  filosofia financeira, config do casal, backup, danger zone)
- Bottom sheets: editar perfil + editar nome do casal
- Widgets implementados:
  - couple_avatar_header (166 ln)
  - theme_selector (98 ln) -> troca tema/cor reativa via themeSettingsProvider
  - philosophy_toggles (97 ln) -> OD / CF / CPI
  - backup_card (123 ln) -> export backup
  - danger_zone (154 ln) -> logout / conta
- Providers: currentProfile, partnerProfile, familySettings,
  themeSettings/themeMode/light/dark, loading states
- ProfilePage plugada em main_layout.dart (navegação principal)
- ✅ Compila e roda

### 🎯 PROGRESSO FASE 4 — Telas
- [x] 21 dashboard
- [x] 22 transactions
- [x] 23 piggy_banks
- [x] 24 planning
- [x] 25 credit_cards
- [x] 26 reports
- [x] 27 profile  <-- CONCLUÍDA AGORA
- FASE 4 COMPLETA! ➡️ Próximo: FASE 5 (28 setup_firebase)

### Sessao 2026-06-02 18:26 — Script 28 (setup_firebase) CONCLUIDO
- firebase_options.dart regerado com projeto REAL: dindinvani-nani (sender 167234791330)
- google-services.json real gerado
- Apps registrados: android / ios / web
- Permissoes adicionadas no AndroidManifest: INTERNET + POST_NOTIFICATIONS
- Plugin google-services confirmado em build.gradle.kts e settings.gradle.kts (v4.3.15)
- iOS GoogleService-Info.plist: pendente (so no macOS — nao bloqueia)
- NOTA: raiz REAL do projeto = Z:\AppFinancas (nao C:\APP_Finanças)
- PROXIMO: Script 29 — GitHub Actions (CI/CD + keep-alive Supabase)