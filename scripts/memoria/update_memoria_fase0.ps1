<#
.SYNOPSIS
    Atualiza MEMORIA_PROJETO.md - Fase 0 e Script 07 concluidos
.DESCRIPTION
    Projeto: DinDinVani&Nani
    Marca scripts 01-07 como concluidos
#>

$ErrorActionPreference = "Continue"
$ProjectRoot = "C:\APP_Finanças"
$MemoriaFile = "$ProjectRoot\MEMORIA_PROJETO.md"

Clear-Host
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "  ATUALIZANDO MEMORIA_PROJETO.md" -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host ""

$dataAtual = Get-Date -Format 'dd/MM/yyyy HH:mm'
$dataHoje = Get-Date -Format 'dd/MM/yyyy'

$conteudo = @"
# MEMORIA DO PROJETO - DinDinVani&Nani

> App financeiro para casal (Vani e Nani)
> Ultima atualizacao: $dataAtual

---

## STATUS GERAL

- Fase atual: Fase 1 - Flutter + Supabase
- Proximo script: 08_create_flutter_project.ps1
- Diretorio: C:\APP_Finanças

---

## FASE 0 - SETUP (CONCLUIDA)

- [x] 01_check_deps - Dependencias verificadas (todas OK)
- [x] 02_install_scoop - PULADO (nao necessario)
- [x] 03_install_flutter - PULADO (Flutter 3.44.0 ja instalado)
- [x] 04_install_node - PULADO (Node.js 24.16.0 ja instalado)
- [x] 05_install_supabase - A instalar sob demanda via npm
- [x] 06_install_git - PULADO (Git 2.54.0 ja instalado)
- [x] 07_create_cursorrules - 5 arquivos de config criados

---

## AMBIENTE VERIFICADO

| Ferramenta | Versao | Status |
|------------|--------|--------|
| PowerShell | 5.1.26100 | OK |
| Git | 2.54.0 | OK |
| Flutter | 3.44.0 stable | OK |
| Dart | 3.12.0 stable | OK |
| Node.js | 24.16.0 | OK |
| npm | 11.16.0 | OK |

---

## ARQUIVOS DE CONFIGURACAO CRIADOS (Script 07)

- [x] .cursorrules (1615 bytes) - regras para IA
- [x] .gitignore (707 bytes) - arquivos ignorados pelo Git
- [x] .env.example (544 bytes) - template de variaveis de ambiente
- [x] analysis_options.yaml (761 bytes) - lints do Dart
- [x] README.md (1259 bytes) - documentacao do projeto

---

## FASE 1 - FLUTTER + SUPABASE

- [ ] 08_create_flutter_project - PROXIMO
- [ ] 09_setup_pubspec - Configurar dependencias
- [ ] 10_init_supabase_local - Inicializar Supabase local
- [ ] 11_create_project_structure - Estrutura Clean Architecture

---

## FASE 2 - BANCO DE DADOS

- [ ] 12_create_schema
- [ ] 13_apply_rls
- [ ] 14_create_triggers
- [ ] 15_seed_categories
- [ ] 16_create_edge_functions

---

## FASE 3 - FLUTTER CORE

- [ ] 17_create_core_layer
- [ ] 18_create_data_layer
- [ ] 19_create_domain_layer
- [ ] 20_create_auth_feature

---

## FASE 4 - TELAS

- [ ] 21_dashboard
- [ ] 22_transactions
- [ ] 23_piggy_banks
- [ ] 24_planning
- [ ] 25_credit_cards
- [ ] 26_reports
- [ ] 27_profile

---

## FASE 5 - DEPLOY

- [ ] 28_setup_firebase
- [ ] 29_setup_github_actions
- [ ] 30_build_android
- [ ] 31_build_web
- [ ] 32_deploy_vercel

---

## SUPABASE - CHAVES

- Chave antiga 'padrao' REVOGADA (seguranca garantida)
- Nova chave 'dindinvani_app' criada
- Chave salva no arquivo .env local
- NUNCA commitar .env no Git

---

## FILOSOFIA FINANCEIRA (NUNCA VIOLAR)

- OD - Orcamento Defasado: renda do mes M define orcamento de M+2
- CF - Caixinha de Fatura: cada compra no cartao reserva valor imediato
- CPI - Caixinha de Parcela Integral: parcelado = valor TOTAL guardado no ato
- REGRA DE OURO: nunca somar a mesma despesa duas vezes

---

## HISTORICO DE SESSOES

### Sessao 1 - $dataHoje
- Criada estrutura inicial em C:\APP_Finanças
- Revogada chave Supabase comprometida
- Criada nova chave dindinvani_app
- Script 01 executado com sucesso (6/6 dependencias OK)
- Fase 0 finalizada - todas as ferramentas ja estavam instaladas
- Script 07 executado - 5 arquivos de config criados
"@

Set-Content -Path $MemoriaFile -Value $conteudo -Encoding UTF8

Write-Host "  [OK] MEMORIA_PROJETO.md atualizado!" -ForegroundColor Green
Write-Host ""
Write-Host "  Arquivo salvo em:" -ForegroundColor Gray
Write-Host "  $MemoriaFile" -ForegroundColor White
Write-Host ""
Write-Host "===========================================================" -ForegroundColor Green
Write-Host "  MEMORIA ATUALIZADA - SCRIPT 07 MARCADO COMO CONCLUIDO" -ForegroundColor Green
Write-Host "  Proximo: Script 08 - create_flutter_project" -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Green
Write-Host ""
