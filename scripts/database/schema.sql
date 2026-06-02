-- ============================================================================
-- DINDINVANI&NANI - SCHEMA COMPLETO
-- Filosofia: OD (Orçamento Defasado M+2) + CF + CPI + CPA com Endowment
-- ============================================================================

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- ENUMS (Tipos customizados)
-- ============================================================================

-- Estágios financeiros (transição)
CREATE TYPE financial_stage AS ENUM (
    'SURVIVAL',       -- 🔴 Estágio 1: M+0 (sobrevivência)
    'TRANSITION_1',   -- 🟡 Estágio 2: M+0.5 (transição inicial)
    'TRANSITION_2',   -- 🟢 Estágio 3: M+1 (transição avançada)
    'PERFECT'         -- 💎 Estágio 4: M+2 (plano perfeito)
);

-- Tipos de conta
CREATE TYPE account_type AS ENUM (
    'CHECKING',       -- Conta corrente
    'SAVINGS',        -- Poupança
    'WALLET',         -- Carteira (dinheiro físico)
    'DIGITAL_BANK',   -- Banco digital (Nubank, Inter, etc)
    'INVESTMENT'      -- Conta de investimento
);

-- Tipos de transação
CREATE TYPE transaction_type AS ENUM (
    'INCOME',         -- Receita
    'EXPENSE',        -- Despesa
    'TRANSFER',       -- Transferência entre contas
    'INVESTMENT',     -- Investimento
    'REFUND'          -- Estorno
);

-- Status de transação
CREATE TYPE transaction_status AS ENUM (
    'PENDING',        -- Pendente
    'COMPLETED',      -- Concluída
    'CANCELLED',      -- Cancelada
    'SCHEDULED'       -- Agendada
);

-- Tipos de caixinha
CREATE TYPE piggy_bank_type AS ENUM (
    'CF',             -- Caixinha de Fatura (cartão)
    'CPI',            -- Caixinha de Parcela Integral
    'CP',             -- Caixinha Programada (meta)
    'CM',             -- Caixinha Mensal (despesa recorrente)
    'CE',             -- Caixinha de Emergência
    'CPA',            -- Caixinha Patrimonial Auto-sustentável (Endowment)
    'CS'              -- Caixinha de Sonhos (longo prazo)
);

-- Recorrência
CREATE TYPE recurrence_type AS ENUM (
    'DAILY',
    'WEEKLY',
    'BIWEEKLY',
    'MONTHLY',
    'BIMONTHLY',
    'QUARTERLY',
    'SEMIANNUAL',
    'ANNUAL'
);

-- Classes de ativos (investimentos)
CREATE TYPE asset_class AS ENUM (
    'STOCKS_BR',      -- Ações Brasil (B3)
    'STOCKS_US',      -- Ações EUA
    'FIIS',           -- Fundos Imobiliários
    'ETFS',           -- ETFs
    'FIXED_INCOME',   -- Renda Fixa
    'CRYPTO',         -- Criptomoedas
    'FUNDS',          -- Fundos de investimento
    'OTHER'           -- Outros
);

-- Tipos de operação (investimentos)
CREATE TYPE operation_type AS ENUM (
    'BUY',
    'SELL',
    'DIVIDEND',
    'JCP',
    'BONUS',
    'SPLIT',
    'REVERSE_SPLIT',
    'TRANSFER_IN',
    'TRANSFER_OUT'
);

-- Modo de juros CPA
CREATE TYPE cpa_yield_mode AS ENUM (
    'SIMULATED',      -- Simulado (não credita real)
    'REAL',           -- Real (credita no saldo)
    'HYBRID'          -- Ambos (simula + ajusta com real)
);

-- ============================================================================
-- TABELA 1: FAMILIES (Famílias)
-- ============================================================================
CREATE TABLE families (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
COMMENT ON TABLE families IS 'Famílias (casais). Cada família é um grupo isolado por RLS.';

-- ============================================================================
-- TABELA 2: USERS (Usuários)
-- ============================================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    auth_id UUID UNIQUE,                    -- Link com auth.users do Supabase
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    nickname TEXT,                          -- "Vani" ou "Nani"
    avatar_url TEXT,
    role TEXT DEFAULT 'member',             -- 'admin' ou 'member'
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_users_family ON users(family_id);
CREATE INDEX idx_users_auth ON users(auth_id);
COMMENT ON TABLE users IS 'Usuários do app. Vinculados a uma família e ao auth do Supabase.';

-- ============================================================================
-- TABELA 3: ACCOUNTS (Contas bancárias)
-- ============================================================================
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    name TEXT NOT NULL,                     -- "Nubank Vani", "Itaú Nani"
    type account_type NOT NULL,
    bank TEXT,                              -- "Nubank", "Itaú", "Inter"
    balance NUMERIC(15,2) DEFAULT 0,
    initial_balance NUMERIC(15,2) DEFAULT 0,
    color TEXT DEFAULT '#6366f1',           -- Cor para UI
    icon TEXT DEFAULT '🏦',
    is_shared BOOLEAN DEFAULT FALSE,        -- Conta conjunta?
    owner_id UUID REFERENCES users(id),     -- Dono principal (se não compartilhada)
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_accounts_family ON accounts(family_id);
CREATE INDEX idx_accounts_owner ON accounts(owner_id);
COMMENT ON TABLE accounts IS 'Contas bancárias e carteiras da família.';

-- ============================================================================
-- TABELA 4: CATEGORIES (Categorias)
-- ============================================================================
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID REFERENCES families(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    type transaction_type NOT NULL,
    parent_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    icon TEXT DEFAULT '📁',
    color TEXT DEFAULT '#6366f1',
    is_essential BOOLEAN DEFAULT FALSE,     -- Essencial (50%) ou supérflua (30%)?
    is_system BOOLEAN DEFAULT FALSE,        -- Categoria padrão do sistema?
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_categories_family ON categories(family_id);
CREATE INDEX idx_categories_parent ON categories(parent_id);
COMMENT ON TABLE categories IS 'Categorias de receitas e despesas. Permite hierarquia (subcategoria).';

-- ============================================================================
-- TABELA 5: CREDIT_CARDS (Cartões de crédito)
-- ============================================================================
CREATE TABLE credit_cards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    name TEXT NOT NULL,                     -- "Nubank Vani", "Itaú Black Nani"
    bank TEXT,
    last_digits TEXT,                       -- Últimos 4 dígitos
    credit_limit NUMERIC(15,2) NOT NULL,
    closing_day INT NOT NULL CHECK (closing_day BETWEEN 1 AND 31),
    due_day INT NOT NULL CHECK (due_day BETWEEN 1 AND 31),
    color TEXT DEFAULT '#1f2937',
    owner_id UUID REFERENCES users(id),
    payment_account_id UUID REFERENCES accounts(id), -- Conta que paga a fatura
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_cards_family ON credit_cards(family_id);
COMMENT ON TABLE credit_cards IS 'Cartões de crédito da família.';

-- ============================================================================
-- TABELA 6: INVOICES (Faturas)
-- ============================================================================
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    card_id UUID NOT NULL REFERENCES credit_cards(id) ON DELETE CASCADE,
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    reference_month DATE NOT NULL,          -- Mês de referência (ex: 2026-05-01)
    closing_date DATE NOT NULL,
    due_date DATE NOT NULL,
    total_amount NUMERIC(15,2) DEFAULT 0,
    reserved_amount NUMERIC(15,2) DEFAULT 0, -- Quanto já está na CF
    paid_amount NUMERIC(15,2) DEFAULT 0,
    is_paid BOOLEAN DEFAULT FALSE,
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(card_id, reference_month)
);
CREATE INDEX idx_invoices_card ON invoices(card_id);
CREATE INDEX idx_invoices_family ON invoices(family_id);
CREATE INDEX idx_invoices_month ON invoices(reference_month);
COMMENT ON TABLE invoices IS 'Faturas mensais dos cartões de crédito.';

-- ============================================================================
-- TABELA 7: TRANSACTIONS (Transações)
-- ============================================================================
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    account_id UUID REFERENCES accounts(id),
    category_id UUID REFERENCES categories(id),
    card_id UUID REFERENCES credit_cards(id),
    invoice_id UUID REFERENCES invoices(id),
    type transaction_type NOT NULL,
    status transaction_status DEFAULT 'COMPLETED',
    amount NUMERIC(15,2) NOT NULL,
    description TEXT NOT NULL,
    transaction_date DATE NOT NULL,
    -- Parcelamento
    is_installment BOOLEAN DEFAULT FALSE,
    installment_number INT,                 -- 1, 2, 3...
    installment_total INT,                  -- de 1, 2, 3 de N
    installment_group_id UUID,              -- Agrupa parcelas da mesma compra
    -- Recorrência
    recurring_transaction_id UUID,
    -- Outros
    notes TEXT,
    tags TEXT[],
    location TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_transactions_family ON transactions(family_id);
CREATE INDEX idx_transactions_account ON transactions(account_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_card ON transactions(card_id);
CREATE INDEX idx_transactions_invoice ON transactions(invoice_id);
CREATE INDEX idx_transactions_group ON transactions(installment_group_id);
COMMENT ON TABLE transactions IS 'Todas as transações financeiras (receitas, despesas, transferências).';

-- ============================================================================
-- TABELA 8: RECURRING_TRANSACTIONS (Transações recorrentes)
-- ============================================================================
CREATE TABLE recurring_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    account_id UUID REFERENCES accounts(id),
    category_id UUID REFERENCES categories(id),
    type transaction_type NOT NULL,
    amount NUMERIC(15,2) NOT NULL,
    description TEXT NOT NULL,
    recurrence recurrence_type NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,                          -- NULL = sem fim
    next_occurrence DATE NOT NULL,
    occurrences_count INT DEFAULT 0,        -- Quantas já foram geradas
    max_occurrences INT,                    -- Limite (NULL = ilimitado)
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_recurring_family ON recurring_transactions(family_id);
CREATE INDEX idx_recurring_next ON recurring_transactions(next_occurrence) WHERE is_active = TRUE;
COMMENT ON TABLE recurring_transactions IS 'Transações que se repetem (salário, aluguel, assinaturas).';

-- ============================================================================
-- TABELA 9: PIGGY_BANKS (Caixinhas)
-- ============================================================================
CREATE TABLE piggy_banks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    name TEXT NOT NULL,                     -- "CF Nubank", "Viagem Europa"
    type piggy_bank_type NOT NULL,
    description TEXT,
    target_amount NUMERIC(15,2),            -- Meta (NULL para CF/CM)
    current_amount NUMERIC(15,2) DEFAULT 0,
    target_date DATE,
    icon TEXT DEFAULT '🐷',
    color TEXT DEFAULT '#10b981',
    -- Vinculações
    linked_card_id UUID REFERENCES credit_cards(id), -- Para CF
    linked_category_id UUID REFERENCES categories(id), -- Para CM
    linked_account_id UUID REFERENCES accounts(id), -- Onde fica o dinheiro
    -- CPA específico (Endowment)
    is_cpa BOOLEAN DEFAULT FALSE,
    cpa_monthly_yield_rate NUMERIC(7,4),    -- Taxa mensal (ex: 0.0100 = 1%)
    cpa_yield_mode cpa_yield_mode DEFAULT 'HYBRID',
    cpa_yield_day INT DEFAULT 1 CHECK (cpa_yield_day BETWEEN 1 AND 28),
    cpa_total_yield_earned NUMERIC(15,2) DEFAULT 0, -- Total já rendido
    cpa_uses_global_rate BOOLEAN DEFAULT TRUE,      -- Usa taxa global ou própria?
    cpa_self_sustainable BOOLEAN DEFAULT FALSE,     -- Já se auto-sustenta?
    -- Metadados
    priority INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_piggy_family ON piggy_banks(family_id);
CREATE INDEX idx_piggy_type ON piggy_banks(type);
CREATE INDEX idx_piggy_card ON piggy_banks(linked_card_id);
COMMENT ON TABLE piggy_banks IS 'Caixinhas (CF, CPI, CP, CM, CE, CPA, CS). Coração do app!';

-- ============================================================================
-- TABELA 10: PIGGY_BANK_CONTRIBUTIONS (Aportes)
-- ============================================================================
CREATE TABLE piggy_bank_contributions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    piggy_bank_id UUID NOT NULL REFERENCES piggy_banks(id) ON DELETE CASCADE,
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    amount NUMERIC(15,2) NOT NULL,
    contribution_date DATE NOT NULL,
    contribution_type TEXT DEFAULT 'MANUAL', -- 'MANUAL', 'AUTOMATIC', 'YIELD'
    transaction_id UUID REFERENCES transactions(id),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_contributions_piggy ON piggy_bank_contributions(piggy_bank_id);
CREATE INDEX idx_contributions_family ON piggy_bank_contributions(family_id);
COMMENT ON TABLE piggy_bank_contributions IS 'Histórico de aportes em cada caixinha.';

-- ============================================================================
-- TABELA 11: PIGGY_BANK_RESERVATIONS (Reservas da CF)
-- ============================================================================
CREATE TABLE piggy_bank_reservations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    piggy_bank_id UUID NOT NULL REFERENCES piggy_banks(id) ON DELETE CASCADE,
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    transaction_id UUID REFERENCES transactions(id) ON DELETE CASCADE,
    invoice_id UUID REFERENCES invoices(id),
    amount NUMERIC(15,2) NOT NULL,
    reservation_date DATE NOT NULL,
    is_consumed BOOLEAN DEFAULT FALSE,      -- Foi usada para pagar fatura?
    consumed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_reservations_piggy ON piggy_bank_reservations(piggy_bank_id);
CREATE INDEX idx_reservations_invoice ON piggy_bank_reservations(invoice_id);
COMMENT ON TABLE piggy_bank_reservations IS 'Reservas automáticas na CF a cada compra no cartão.';

-- ============================================================================
-- TABELA 12: CPI_INSTALLMENT_PAYMENTS (Pagamentos de parcelas CPI)
-- ============================================================================
CREATE TABLE cpi_installment_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    piggy_bank_id UUID NOT NULL REFERENCES piggy_banks(id) ON DELETE CASCADE,
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    installment_group_id UUID NOT NULL,
    installment_number INT NOT NULL,
    total_installments INT NOT NULL,
    amount NUMERIC(15,2) NOT NULL,
    payment_date DATE NOT NULL,
    cf_piggy_bank_id UUID REFERENCES piggy_banks(id), -- CF que recebeu
    is_paid BOOLEAN DEFAULT FALSE,
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_cpi_piggy ON cpi_installment_payments(piggy_bank_id);
CREATE INDEX idx_cpi_group ON cpi_installment_payments(installment_group_id);
COMMENT ON TABLE cpi_installment_payments IS 'Pagamentos mensais da CPI para a CF.';

-- ============================================================================
-- TABELA 13: PIGGY_BANK_YIELD_HISTORY (Histórico de juros CPA)
-- ============================================================================
CREATE TABLE piggy_bank_yield_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    piggy_bank_id UUID NOT NULL REFERENCES piggy_banks(id) ON DELETE CASCADE,
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    yield_date DATE NOT NULL,
    base_amount NUMERIC(15,2) NOT NULL,     -- Saldo base do rendimento
    rate_applied NUMERIC(7,4) NOT NULL,     -- Taxa aplicada
    yield_amount NUMERIC(15,2) NOT NULL,    -- Valor rendido
    mode cpa_yield_mode NOT NULL,
    is_credited BOOLEAN DEFAULT FALSE,      -- Foi creditado no saldo real?
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(piggy_bank_id, yield_date)
);
CREATE INDEX idx_yield_piggy ON piggy_bank_yield_history(piggy_bank_id);
CREATE INDEX idx_yield_date ON piggy_bank_yield_history(yield_date);
COMMENT ON TABLE piggy_bank_yield_history IS 'Histórico mensal de rendimento das CPAs (Endowment).';

-- ============================================================================
-- TABELA 14: INVOICE_RESERVES (Resumo de reservas por fatura)
-- ============================================================================
CREATE TABLE invoice_reserves (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    cf_piggy_bank_id UUID REFERENCES piggy_banks(id),
    total_reserved NUMERIC(15,2) DEFAULT 0,
    total_needed NUMERIC(15,2) DEFAULT 0,
    coverage_pct NUMERIC(5,2) DEFAULT 0,    -- % de cobertura
    is_fully_covered BOOLEAN DEFAULT FALSE,
    last_calculation TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_invoice_reserves_invoice ON invoice_reserves(invoice_id);
COMMENT ON TABLE invoice_reserves IS 'Resumo da cobertura CF para cada fatura.';

-- ============================================================================
-- TABELA 15: BUDGETS (Orçamentos)
-- ============================================================================
CREATE TABLE budgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id),
    name TEXT NOT NULL,
    amount NUMERIC(15,2) NOT NULL,
    period TEXT DEFAULT 'MONTHLY',          -- 'MONTHLY', 'ANNUAL'
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_budgets_family ON budgets(family_id);
COMMENT ON TABLE budgets IS 'Orçamentos por categoria (template).';

-- ============================================================================
-- TABELA 16: MONTHLY_BUDGETS (Orçamentos mensais - OD M+2)
-- ============================================================================
CREATE TABLE monthly_budgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    reference_month DATE NOT NULL,          -- Mês orçado (M+2)
    source_month DATE NOT NULL,             -- Mês de origem da renda (M)
    total_income NUMERIC(15,2) DEFAULT 0,   -- Renda do mês origem
    total_budget NUMERIC(15,2) DEFAULT 0,   -- Total orçado
    total_spent NUMERIC(15,2) DEFAULT 0,    -- Total gasto
    -- Alocação 50/30/20 (configurável)
    essential_pct NUMERIC(5,2) DEFAULT 50,
    lifestyle_pct NUMERIC(5,2) DEFAULT 30,
    savings_pct NUMERIC(5,2) DEFAULT 20,
    -- Distribuição
    essential_budget NUMERIC(15,2) DEFAULT 0,
    lifestyle_budget NUMERIC(15,2) DEFAULT 0,
    savings_budget NUMERIC(15,2) DEFAULT 0,
    is_closed BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(family_id, reference_month)
);
CREATE INDEX idx_monthly_budgets_family ON monthly_budgets(family_id);
CREATE INDEX idx_monthly_budgets_month ON monthly_budgets(reference_month);
COMMENT ON TABLE monthly_budgets IS 'Orçamentos mensais (OD M+2). Renda do mês M vira orçamento de M+2.';

-- ============================================================================
-- TABELA 17: FAMILY_GOALS (Metas da família)
-- ============================================================================
CREATE TABLE family_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    name TEXT NOT NULL,                     -- "Casa própria", "Viagem Europa"
    description TEXT,
    target_amount NUMERIC(15,2) NOT NULL,
    current_amount NUMERIC(15,2) DEFAULT 0,
    target_date DATE,
    linked_piggy_bank_id UUID REFERENCES piggy_banks(id),
    icon TEXT DEFAULT '🎯',
    color TEXT DEFAULT '#8b5cf6',
    priority INT DEFAULT 0,
    is_achieved BOOLEAN DEFAULT FALSE,
    achieved_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_goals_family ON family_goals(family_id);
COMMENT ON TABLE family_goals IS 'Metas/sonhos da família.';

-- ============================================================================
-- TABELA 18: FAMILY_SETTINGS (Configurações da família)
-- ============================================================================
CREATE TABLE family_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID UNIQUE NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    -- Estágio financeiro
    current_stage financial_stage DEFAULT 'SURVIVAL',
    target_lag_months INT DEFAULT 2,        -- Meta de defasagem (padrão M+2)
    current_lag_months NUMERIC(3,1) DEFAULT 0,
    transition_started_at DATE,
    target_perfect_date DATE,
    -- CPA Global
    cpa_global_yield_rate NUMERIC(7,4) DEFAULT 0.0100, -- 1% ao mês
    cpa_global_yield_mode cpa_yield_mode DEFAULT 'HYBRID',
    cpa_global_yield_day INT DEFAULT 1,
    -- Alocação estratégica
    allocation_transition_pct NUMERIC(5,2) DEFAULT 55,
    allocation_emergency_pct NUMERIC(5,2) DEFAULT 25,
    allocation_investment_pct NUMERIC(5,2) DEFAULT 15,
    allocation_leisure_pct NUMERIC(5,2) DEFAULT 5,
    -- Comportamento do app
    compassionate_mode BOOLEAN DEFAULT FALSE, -- Modo Compassivo
    allow_stage_skip BOOLEAN DEFAULT TRUE,    -- Permite pular estágios?
    notify_violations BOOLEAN DEFAULT TRUE,
    -- Tema
    theme TEXT DEFAULT 'system',            -- 'light', 'dark', 'system'
    primary_color TEXT DEFAULT '#6366f1',
    currency TEXT DEFAULT 'BRL',
    locale TEXT DEFAULT 'pt-BR',
    -- Notificações
    notify_card_closing INT DEFAULT 3,      -- Dias antes do fechamento
    notify_card_due INT DEFAULT 5,          -- Dias antes do vencimento
    notify_budget_threshold NUMERIC(5,2) DEFAULT 80, -- % do orçamento p/ alertar
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
COMMENT ON TABLE family_settings IS 'Configurações gerais da família (1 registro por família).';

-- ============================================================================
-- TABELA 19: TRANSITION_PLAN (Plano de transição)
-- ============================================================================
CREATE TABLE transition_plan (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    target_lag_months INT NOT NULL DEFAULT 2,
    starting_balance NUMERIC(15,2) NOT NULL,
    target_balance NUMERIC(15,2) NOT NULL,
    monthly_contribution NUMERIC(15,2) NOT NULL,
    estimated_months INT NOT NULL,
    started_at DATE NOT NULL,
    expected_completion DATE,
    actual_completion DATE,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_transition_family ON transition_plan(family_id);
COMMENT ON TABLE transition_plan IS 'Plano de transição até atingir M+2 (Estágio 4).';

-- ============================================================================
-- TABELA 20: TRANSITION_MILESTONES (Marcos da transição)
-- ============================================================================
CREATE TABLE transition_milestones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    milestone_type TEXT NOT NULL,           -- '1_WEEK', '2_WEEKS', '1_MONTH', '6_WEEKS', '2_MONTHS'
    target_amount NUMERIC(15,2) NOT NULL,
    achieved_at TIMESTAMPTZ,
    is_achieved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_milestones_family ON transition_milestones(family_id);
COMMENT ON TABLE transition_milestones IS 'Marcos conquistados durante a transição.';

-- ============================================================================
-- TABELA 21: ALLOCATION_STRATEGY (Estratégias de alocação por estágio)
-- ============================================================================
CREATE TABLE allocation_strategy (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    stage financial_stage NOT NULL,
    transition_pct NUMERIC(5,2) NOT NULL,
    emergency_pct NUMERIC(5,2) NOT NULL,
    investment_pct NUMERIC(5,2) NOT NULL,
    cpa_pct NUMERIC(5,2) DEFAULT 0,
    leisure_pct NUMERIC(5,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT FALSE,
    activated_at DATE,
    notes TEXT,
    CHECK (transition_pct + emergency_pct + investment_pct + cpa_pct + leisure_pct = 100),
    UNIQUE(family_id, stage)
);
CREATE INDEX idx_allocation_family ON allocation_strategy(family_id);
COMMENT ON TABLE allocation_strategy IS 'Estratégia de alocação % por estágio financeiro.';

-- ============================================================================
-- TABELA 22: INVESTMENT_PORTFOLIOS (Carteiras de investimento)
-- ============================================================================
CREATE TABLE investment_portfolios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    name TEXT NOT NULL DEFAULT 'Carteira Principal',
    description TEXT,
    total_invested NUMERIC(15,2) DEFAULT 0,
    current_value NUMERIC(15,2) DEFAULT 0,
    total_dividends NUMERIC(15,2) DEFAULT 0,
    profit_loss NUMERIC(15,2) DEFAULT 0,
    profit_loss_pct NUMERIC(7,2) DEFAULT 0,
    last_price_update TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_portfolios_family ON investment_portfolios(family_id);
COMMENT ON TABLE investment_portfolios IS 'Carteiras de investimento da família.';

-- ============================================================================
-- TABELA 23: INVESTMENT_ASSETS (Ativos individuais)
-- ============================================================================
CREATE TABLE investment_assets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    portfolio_id UUID NOT NULL REFERENCES investment_portfolios(id) ON DELETE CASCADE,
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    asset_class asset_class NOT NULL,
    ticker TEXT NOT NULL,                   -- "PETR4", "BTC", "CDB-XYZ"
    name TEXT NOT NULL,                     -- "Petrobras PN"
    quantity NUMERIC(20,8) DEFAULT 0,       -- 8 casas (cripto)
    avg_price NUMERIC(15,4) DEFAULT 0,
    current_price NUMERIC(15,4) DEFAULT 0,
    total_invested NUMERIC(15,2) DEFAULT 0,
    current_value NUMERIC(15,2) DEFAULT 0,
    profit_loss NUMERIC(15,2) DEFAULT 0,
    profit_loss_pct NUMERIC(7,2) DEFAULT 0,
    is_emergency_eligible BOOLEAN DEFAULT FALSE,
    custody_broker TEXT,                    -- "XP", "Clear", "Binance"
    maturity_date DATE,                     -- Para renda fixa
    yield_rate NUMERIC(7,4),                -- Taxa contratada (renda fixa)
    notes TEXT,
    last_price_update TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_assets_portfolio ON investment_assets(portfolio_id);
CREATE INDEX idx_assets_family ON investment_assets(family_id);
CREATE INDEX idx_assets_class ON investment_assets(asset_class);
CREATE INDEX idx_assets_ticker ON investment_assets(ticker);
COMMENT ON TABLE investment_assets IS 'Ativos individuais (ações, cripto, renda fixa, etc).';

-- ============================================================================
-- TABELA 24: INVESTMENT_OPERATIONS (Operações)
-- ============================================================================
CREATE TABLE investment_operations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    asset_id UUID NOT NULL REFERENCES investment_assets(id) ON DELETE CASCADE,
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    operation_date DATE NOT NULL,
    operation_type operation_type NOT NULL,
    quantity NUMERIC(20,8) NOT NULL,
    unit_price NUMERIC(15,4) NOT NULL,
    total_amount NUMERIC(15,2) NOT NULL,
    fees NUMERIC(15,2) DEFAULT 0,           -- Taxas
    taxes NUMERIC(15,2) DEFAULT 0,          -- IR
    net_amount NUMERIC(15,2) NOT NULL,      -- Líquido
    transaction_id UUID REFERENCES transactions(id), -- Vínculo com transação
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_operations_asset ON investment_operations(asset_id);
CREATE INDEX idx_operations_family ON investment_operations(family_id);
CREATE INDEX idx_operations_date ON investment_operations(operation_date);
COMMENT ON TABLE investment_operations IS 'Histórico de compras, vendas e proventos.';

-- ============================================================================
-- TABELA 25: INVESTMENT_PRICE_HISTORY (Histórico de preços)
-- ============================================================================
CREATE TABLE investment_price_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    asset_id UUID NOT NULL REFERENCES investment_assets(id) ON DELETE CASCADE,
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    snapshot_date DATE NOT NULL,
    price NUMERIC(15,4) NOT NULL,
    source TEXT DEFAULT 'MANUAL',           -- 'MANUAL', 'API_B3', 'API_BINANCE'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(asset_id, snapshot_date)
);
CREATE INDEX idx_price_history_asset ON investment_price_history(asset_id);
CREATE INDEX idx_price_history_date ON investment_price_history(snapshot_date);
COMMENT ON TABLE investment_price_history IS 'Histórico de preços dos ativos (snapshots diários/mensais).';

-- ============================================================================
-- TABELA 26: INVESTMENT_DIVIDENDS (Proventos detalhados)
-- ============================================================================
CREATE TABLE investment_dividends (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    asset_id UUID NOT NULL REFERENCES investment_assets(id) ON DELETE CASCADE,
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    payment_date DATE NOT NULL,
    ex_date DATE,
    dividend_type TEXT NOT NULL,            -- 'DIVIDEND', 'JCP', 'INTEREST'
    amount_per_share NUMERIC(15,4) NOT NULL,
    quantity_at_record NUMERIC(20,8) NOT NULL,
    total_amount NUMERIC(15,2) NOT NULL,
    tax_withheld NUMERIC(15,2) DEFAULT 0,
    net_amount NUMERIC(15,2) NOT NULL,
    transaction_id UUID REFERENCES transactions(id),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_dividends_asset ON investment_dividends(asset_id);
CREATE INDEX idx_dividends_family ON investment_dividends(family_id);
CREATE INDEX idx_dividends_date ON investment_dividends(payment_date);
COMMENT ON TABLE investment_dividends IS 'Dividendos, JCP e juros recebidos.';

-- ============================================================================
-- TABELA 27: INVESTMENT_TARGETS (Metas de alocação por classe)
-- ============================================================================
CREATE TABLE investment_targets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    portfolio_id UUID NOT NULL REFERENCES investment_portfolios(id) ON DELETE CASCADE,
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    asset_class asset_class NOT NULL,
    target_pct NUMERIC(5,2) NOT NULL,
    current_pct NUMERIC(5,2) DEFAULT 0,
    deviation_pct NUMERIC(7,2) DEFAULT 0,
    needs_rebalance BOOLEAN DEFAULT FALSE,
    rebalance_threshold NUMERIC(5,2) DEFAULT 5, -- Desvio que dispara alerta
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(portfolio_id, asset_class)
);
CREATE INDEX idx_targets_portfolio ON investment_targets(portfolio_id);
COMMENT ON TABLE investment_targets IS 'Metas de alocação % por classe de ativo (ex: 40% ações).';

-- ============================================================================
-- TABELA 28: AUDIT_LOG (Auditoria)
-- ============================================================================
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID REFERENCES families(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    action TEXT NOT NULL,                   -- 'CREATE', 'UPDATE', 'DELETE'
    entity_type TEXT NOT NULL,              -- 'transaction', 'piggy_bank', etc
    entity_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_audit_family ON audit_log(family_id);
CREATE INDEX idx_audit_user ON audit_log(user_id);
CREATE INDEX idx_audit_entity ON audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_date ON audit_log(created_at);
COMMENT ON TABLE audit_log IS 'Log de auditoria de todas as ações importantes.';

-- ============================================================================
-- TABELA 29: ATTACHMENTS (Anexos)
-- ============================================================================
CREATE TABLE attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    entity_type TEXT NOT NULL,              -- 'transaction', 'invoice', etc
    entity_id UUID NOT NULL,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,                -- Path no Supabase Storage
    file_size_bytes BIGINT,
    mime_type TEXT,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_attachments_family ON attachments(family_id);
CREATE INDEX idx_attachments_entity ON attachments(entity_type, entity_id);
COMMENT ON TABLE attachments IS 'Anexos (notas fiscais, comprovantes) vinculados a entidades.';

-- ============================================================================
-- FUNÇÃO: updated_at automático
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

-- Aplica trigger em todas as tabelas com updated_at
DO $$
DECLARE t TEXT; BEGIN FOR t IN SELECT table_name FROM information_schema.columns WHERE column_name = 'updated_at' AND table_schema = 'public' LOOP EXECUTE format(' CREATE TRIGGER trg_%I_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION update_updated_at_column(); ', t, t); END LOOP; END
$$;

-- ============================================================================
-- FIM DO SCHEMA
-- ============================================================================

SELECT '✅ Schema DinDinVani&Nani criado com sucesso! 29 tabelas.' AS resultado;
