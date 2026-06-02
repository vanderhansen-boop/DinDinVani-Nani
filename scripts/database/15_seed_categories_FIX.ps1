# ============================================================
# Script 15 (FIX) - Seed de Categorias Padrão
# Projeto: DinDinVani&Nani
# ============================================================

$ErrorActionPreference = "Stop"
$projectRoot = "C:\APP_Finanças"
$logDir      = "$projectRoot\logs"
$sqlDir      = "$projectRoot\supabase\seeds"
$logFile     = "$logDir\15_seed_categories.log"
$sqlFile     = "$sqlDir\15_seed_categories.sql"

New-Item -ItemType Directory -Force -Path $logDir | Out-Null
New-Item -ItemType Directory -Force -Path $sqlDir | Out-Null

function Write-Log {
    param([string]$msg, [string]$level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] [$level] $msg"
    Write-Host $line
    Add-Content -Path $logFile -Value $line
}

Write-Log "=== INICIANDO SEED DE CATEGORIAS (FIX PT-BR) ==="

$sql = @"
DELETE FROM categories WHERE is_padrao = TRUE AND family_id IS NULL;

-- RECEITAS
INSERT INTO categories (family_id, nome, icone, cor, tipo, grupo_50_30_20, is_padrao, ativa) VALUES
(NULL, 'Salário',          'work',           '#2E7D5B', 'receita', NULL, TRUE, TRUE),
(NULL, 'Freelance',         'laptop',         '#43A047', 'receita', NULL, TRUE, TRUE),
(NULL, 'Investimentos',     'trending_up',    '#1B5E20', 'receita', NULL, TRUE, TRUE),
(NULL, 'Reembolso',         'undo',           '#66BB6A', 'receita', NULL, TRUE, TRUE),
(NULL, 'Presente Recebido', 'card_giftcard',  '#81C784', 'receita', NULL, TRUE, TRUE),
(NULL, 'Outras Receitas',   'attach_money',   '#A5D6A7', 'receita', NULL, TRUE, TRUE);

-- NECESSIDADES (50%)
INSERT INTO categories (family_id, nome, icone, cor, tipo, grupo_50_30_20, is_padrao, ativa) VALUES
(NULL, 'Moradia',         'home',            '#C62828', 'despesa', 'necessidades', TRUE, TRUE),
(NULL, 'Aluguel',          'apartment',       '#D32F2F', 'despesa', 'necessidades', TRUE, TRUE),
(NULL, 'Condomínio',       'business',        '#E53935', 'despesa', 'necessidades', TRUE, TRUE),
(NULL, 'Energia',          'bolt',            '#F57C00', 'despesa', 'necessidades', TRUE, TRUE),
(NULL, 'Água',             'water_drop',      '#039BE5', 'despesa', 'necessidades', TRUE, TRUE),
(NULL, 'Internet',         'wifi',            '#1976D2', 'despesa', 'necessidades', TRUE, TRUE),
(NULL, 'Gás',              'local_fire_department','#EF6C00','despesa','necessidades', TRUE, TRUE),
(NULL, 'Mercado',          'shopping_cart',   '#6D4C41', 'despesa', 'necessidades', TRUE, TRUE),
(NULL, 'Transporte',       'directions_car',  '#455A64', 'despesa', 'necessidades', TRUE, TRUE),
(NULL, 'Combustível',      'local_gas_station','#37474F','despesa','necessidades', TRUE, TRUE),
(NULL, 'Saúde',            'favorite',        '#E91E63', 'despesa', 'necessidades', TRUE, TRUE),
(NULL, 'Farmácia',         'medication',      '#EC407A', 'despesa', 'necessidades', TRUE, TRUE),
(NULL, 'Plano de Saúde',   'medical_services','#AD1457', 'despesa', 'necessidades', TRUE, TRUE),
(NULL, 'Educação',         'school',          '#5E35B1', 'despesa', 'necessidades', TRUE, TRUE),
(NULL, 'Seguros',          'shield',          '#3949AB', 'despesa', 'necessidades', TRUE, TRUE);

-- DESEJOS (30%)
INSERT INTO categories (family_id, nome, icone, cor, tipo, grupo_50_30_20, is_padrao, ativa) VALUES
(NULL, 'Lazer',            'sports_esports',  '#7B1FA2', 'despesa', 'desejos', TRUE, TRUE),
(NULL, 'Restaurantes',     'restaurant',      '#FB8C00', 'despesa', 'desejos', TRUE, TRUE),
(NULL, 'Delivery',         'delivery_dining', '#F4511E', 'despesa', 'desejos', TRUE, TRUE),
(NULL, 'Streaming',        'play_circle',     '#D81B60', 'despesa', 'desejos', TRUE, TRUE),
(NULL, 'Viagens',          'flight',          '#00897B', 'despesa', 'desejos', TRUE, TRUE),
(NULL, 'Compras',          'shopping_bag',    '#8E24AA', 'despesa', 'desejos', TRUE, TRUE),
(NULL, 'Vestuário',        'checkroom',       '#9C27B0', 'despesa', 'desejos', TRUE, TRUE),
(NULL, 'Beleza',           'face',            '#EC407A', 'despesa', 'desejos', TRUE, TRUE),
(NULL, 'Presentes',        'redeem',          '#F06292', 'despesa', 'desejos', TRUE, TRUE),
(NULL, 'Assinaturas',      'subscriptions',   '#5C6BC0', 'despesa', 'desejos', TRUE, TRUE),
(NULL, 'Pets',             'pets',            '#795548', 'despesa', 'desejos', TRUE, TRUE),
(NULL, 'Hobbies',          'palette',         '#AB47BC', 'despesa', 'desejos', TRUE, TRUE);

-- POUPANCA (20%)
INSERT INTO categories (family_id, nome, icone, cor, tipo, grupo_50_30_20, is_padrao, ativa) VALUES
(NULL, 'Reserva de Emergência','savings',      '#1B5E20', 'despesa', 'poupanca', TRUE, TRUE),
(NULL, 'Investimentos Aporte', 'show_chart',   '#2E7D32', 'despesa', 'poupanca', TRUE, TRUE),
(NULL, 'Aposentadoria',        'elderly',      '#388E3C', 'despesa', 'poupanca', TRUE, TRUE),
(NULL, 'Metas de Longo Prazo', 'flag',         '#43A047', 'despesa', 'poupanca', TRUE, TRUE),
(NULL, 'Caixinha CF',          'credit_card',  '#00695C', 'despesa', 'poupanca', TRUE, TRUE),
(NULL, 'Caixinha CPI',         'event_repeat', '#00796B', 'despesa', 'poupanca', TRUE, TRUE);

-- TRANSFERENCIAS
INSERT INTO categories (family_id, nome, icone, cor, tipo, grupo_50_30_20, is_padrao, ativa) VALUES
(NULL, 'Transferência entre Contas',   'swap_horiz',     '#607D8B', 'transferencia', NULL, TRUE, TRUE),
(NULL, 'Aporte em Caixinha',           'account_balance','#546E7A', 'transferencia', NULL, TRUE, TRUE),
(NULL, 'Resgate de Caixinha',          'savings',       '#78909C', 'transferencia', NULL, TRUE, TRUE),
(NULL, 'Pagamento de Fatura',          'payment',       '#455A64', 'transferencia', NULL, TRUE, TRUE);

SELECT tipo, grupo_50_30_20, COUNT(*) AS total
FROM categories
WHERE is_padrao = TRUE AND family_id IS NULL
GROUP BY tipo, grupo_50_30_20
ORDER BY tipo, grupo_50_30_20 NULLS LAST;
"@

Set-Content -Path $sqlFile -Value $sql -Encoding UTF8
Write-Log "SQL gerado em: $sqlFile"

Write-Log "Executando seed no banco local..."
Set-Location $projectRoot

try {
    $output = supabase db execute --file $sqlFile 2>&1 | Out-String
    Write-Log "Saida do Supabase:`n$output"
    Write-Log "=== SEED DE CATEGORIAS CONCLUIDO COM SUCESSO ===" "SUCCESS"
}
catch {
    Write-Log "ERRO ao executar seed: $_" "ERROR"
    Write-Log "Dica: rode manualmente no SQL Editor do Supabase Studio:" "INFO"
    Write-Log "  -> $sqlFile" "INFO"
    exit 1
}

Write-Host ""
Write-Host "Script 15 (FIX) finalizado!" -ForegroundColor Green
Write-Host "SQL:  $sqlFile" -ForegroundColor Cyan
Write-Host "Log:  $logFile" -ForegroundColor Cyan
