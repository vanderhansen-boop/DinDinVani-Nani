-- =====================================================
-- DINDINVANI&NANI - TRIGGERS AUTOMÁTICOS
-- Script 14 - CF, CPI, Auditoria e Proteções
-- =====================================================

-- =====================================================
-- 1. FUNÇÃO: updated_at automático
-- =====================================================
CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

-- Aplica em todas as tabelas que têm updated_at
DO $$
DECLARE t TEXT; tables TEXT[] := ARRAY[ 'families','users','accounts','credit_cards','invoices', 'transactions','recurring_transactions','piggy_banks', 'budgets','monthly_budgets','family_goals','categories', 'family_settings' ]; BEGIN FOREACH t IN ARRAY tables LOOP EXECUTE format('DROP TRIGGER IF EXISTS trg_%I_updated_at ON %I;', t, t); EXECUTE format('CREATE TRIGGER trg_%I_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();', t, t); END LOOP; END
$$;

-- =====================================================
-- 2. TRIGGER CF: Reserva automática em compra no cartão
-- =====================================================
-- Toda transação com credit_card_id gera reserva na CF (invoice_reserves)
CREATE OR REPLACE FUNCTION fn_cf_auto_reserve()
RETURNS TRIGGER AS $$
DECLARE v_invoice_id UUID; v_due_date DATE; v_closing_day INT; v_due_day INT; v_purchase_date DATE; BEGIN -- Só age se a transação tem cartão de crédito IF NEW.credit_card_id IS NULL THEN RETURN NEW; END IF; v_purchase_date := COALESCE(NEW.transaction_date, CURRENT_DATE); -- Busca dias de fechamento e vencimento do cartão SELECT closing_day, due_day INTO v_closing_day, v_due_day FROM credit_cards WHERE id = NEW.credit_card_id; -- Calcula data de vencimento da fatura desta compra IF EXTRACT(DAY FROM v_purchase_date)::INT <= v_closing_day THEN v_due_date := DATE_TRUNC('month', v_purchase_date)::DATE + (v_due_day - 1) * INTERVAL '1 day'; ELSE v_due_date := (DATE_TRUNC('month', v_purchase_date) + INTERVAL '1 month')::DATE + (v_due_day - 1) * INTERVAL '1 day'; END IF; -- Busca ou cria a fatura (invoice) correspondente SELECT id INTO v_invoice_id FROM invoices WHERE credit_card_id = NEW.credit_card_id AND due_date = v_due_date; IF v_invoice_id IS NULL THEN INSERT INTO invoices (family_id, credit_card_id, due_date, total_amount, status) VALUES (NEW.family_id, NEW.credit_card_id, v_due_date, 0, 'open') RETURNING id INTO v_invoice_id; END IF; -- Atualiza total da fatura UPDATE invoices SET total_amount = total_amount + NEW.amount WHERE id = v_invoice_id; -- Cria reserva na CF (invoice_reserves) INSERT INTO invoice_reserves ( family_id, invoice_id, transaction_id, amount, reserved_at ) VALUES ( NEW.family_id, v_invoice_id, NEW.id, NEW.amount, NOW() ); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_cf_auto_reserve ON transactions;
CREATE TRIGGER trg_cf_auto_reserve
    AFTER INSERT ON transactions
    FOR EACH ROW
    WHEN (NEW.credit_card_id IS NOT NULL)
    EXECUTE FUNCTION fn_cf_auto_reserve();

-- =====================================================
-- 3. TRIGGER CPI: Compra parcelada guarda valor TOTAL
-- =====================================================
-- Quando transação tem installments > 1, cria registros em cpi_installment_payments
CREATE OR REPLACE FUNCTION fn_cpi_auto_setup()
RETURNS TRIGGER AS $$
DECLARE i INT; v_installment_amount NUMERIC(15,2); v_due_date DATE; v_closing_day INT; v_due_day INT; v_base_date DATE; BEGIN -- Só age se parcelado E no cartão IF NEW.installments IS NULL OR NEW.installments <= 1 THEN RETURN NEW; END IF; IF NEW.credit_card_id IS NULL THEN RETURN NEW; END IF; v_installment_amount := ROUND(NEW.amount / NEW.installments, 2); v_base_date := COALESCE(NEW.transaction_date, CURRENT_DATE); SELECT closing_day, due_day INTO v_closing_day, v_due_day FROM credit_cards WHERE id = NEW.credit_card_id; -- Cria registro para cada parcela FOR i IN 1..NEW.installments LOOP IF EXTRACT(DAY FROM v_base_date)::INT <= v_closing_day THEN v_due_date := (DATE_TRUNC('month', v_base_date) + ((i-1) * INTERVAL '1 month'))::DATE + (v_due_day - 1) * INTERVAL '1 day'; ELSE v_due_date := (DATE_TRUNC('month', v_base_date) + (i * INTERVAL '1 month'))::DATE + (v_due_day - 1) * INTERVAL '1 day'; END IF; INSERT INTO cpi_installment_payments ( family_id, transaction_id, installment_number, total_installments, amount, due_date, status ) VALUES ( NEW.family_id, NEW.id, i, NEW.installments, v_installment_amount, v_due_date, 'pending' ); END LOOP; RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_cpi_auto_setup ON transactions;
CREATE TRIGGER trg_cpi_auto_setup
    AFTER INSERT ON transactions
    FOR EACH ROW
    WHEN (NEW.installments > 1 AND NEW.credit_card_id IS NOT NULL)
    EXECUTE FUNCTION fn_cpi_auto_setup();

-- =====================================================
-- 4. TRIGGER: Atualiza saldo da conta automaticamente
-- =====================================================
CREATE OR REPLACE FUNCTION fn_update_account_balance()
RETURNS TRIGGER AS $$
BEGIN IF TG_OP = 'INSERT' THEN IF NEW.account_id IS NOT NULL AND NEW.credit_card_id IS NULL THEN IF NEW.type = 'income' THEN UPDATE accounts SET balance = balance + NEW.amount WHERE id = NEW.account_id; ELSIF NEW.type = 'expense' THEN UPDATE accounts SET balance = balance - NEW.amount WHERE id = NEW.account_id; END IF; END IF; ELSIF TG_OP = 'DELETE' THEN IF OLD.account_id IS NOT NULL AND OLD.credit_card_id IS NULL THEN IF OLD.type = 'income' THEN UPDATE accounts SET balance = balance - OLD.amount WHERE id = OLD.account_id; ELSIF OLD.type = 'expense' THEN UPDATE accounts SET balance = balance + OLD.amount WHERE id = OLD.account_id; END IF; END IF; END IF; RETURN COALESCE(NEW, OLD); END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_account_balance ON transactions;
CREATE TRIGGER trg_update_account_balance
    AFTER INSERT OR DELETE ON transactions
    FOR EACH ROW EXECUTE FUNCTION fn_update_account_balance();

-- =====================================================
-- 5. TRIGGER: Atualiza saldo da caixinha (piggy_bank)
-- =====================================================
CREATE OR REPLACE FUNCTION fn_update_piggy_balance()
RETURNS TRIGGER AS $$
BEGIN IF TG_OP = 'INSERT' THEN UPDATE piggy_banks SET current_amount = current_amount + NEW.amount WHERE id = NEW.piggy_bank_id; ELSIF TG_OP = 'DELETE' THEN UPDATE piggy_banks SET current_amount = current_amount - OLD.amount WHERE id = OLD.piggy_bank_id; END IF; RETURN COALESCE(NEW, OLD); END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_piggy_balance ON piggy_bank_contributions;
CREATE TRIGGER trg_update_piggy_balance
    AFTER INSERT OR DELETE ON piggy_bank_contributions
    FOR EACH ROW EXECUTE FUNCTION fn_update_piggy_balance();

-- =====================================================
-- 6. TRIGGER: Proteção contra duplicação (Regra de Ouro)
-- =====================================================
-- Impede transações idênticas (mesma família, valor, data, descrição) em < 60s
CREATE OR REPLACE FUNCTION fn_prevent_duplicate_transaction()
RETURNS TRIGGER AS $$
DECLARE v_count INT; BEGIN SELECT COUNT(*) INTO v_count FROM transactions WHERE family_id = NEW.family_id AND amount = NEW.amount AND transaction_date = NEW.transaction_date AND COALESCE(description,'') = COALESCE(NEW.description,'') AND type = NEW.type AND created_at > NOW() - INTERVAL '60 seconds'; IF v_count > 0 THEN RAISE EXCEPTION 'REGRA DE OURO: Transação duplicada detectada (mesmo valor, data e descrição em menos de 60s).'; END IF; RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_duplicate_transaction ON transactions;
CREATE TRIGGER trg_prevent_duplicate_transaction
    BEFORE INSERT ON transactions
    FOR EACH ROW EXECUTE FUNCTION fn_prevent_duplicate_transaction();

-- =====================================================
-- 7. TRIGGER: Audit log automático
-- =====================================================
CREATE OR REPLACE FUNCTION fn_audit_log()
RETURNS TRIGGER AS $$
DECLARE v_family_id UUID; v_user_id UUID; BEGIN v_user_id := auth.uid(); IF TG_OP = 'DELETE' THEN v_family_id := OLD.family_id; INSERT INTO audit_log (family_id, user_id, table_name, operation, record_id, old_data) VALUES (v_family_id, v_user_id, TG_TABLE_NAME, TG_OP, OLD.id, row_to_json(OLD)); RETURN OLD; ELSE v_family_id := NEW.family_id; INSERT INTO audit_log (family_id, user_id, table_name, operation, record_id, new_data) VALUES (v_family_id, v_user_id, TG_TABLE_NAME, TG_OP, NEW.id, row_to_json(NEW)); RETURN NEW; END IF; END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplica auditoria nas tabelas críticas
DO $$
DECLARE t TEXT; audit_tables TEXT[] := ARRAY[ 'transactions','piggy_banks','credit_cards', 'invoices','family_goals','budgets' ]; BEGIN FOREACH t IN ARRAY audit_tables LOOP EXECUTE format('DROP TRIGGER IF EXISTS trg_audit_%I ON %I;', t, t); EXECUTE format('CREATE TRIGGER trg_audit_%I AFTER INSERT OR UPDATE OR DELETE ON %I FOR EACH ROW EXECUTE FUNCTION fn_audit_log();', t, t); END LOOP; END
$$;

-- =====================================================
-- VALIDAÇÃO FINAL
-- =====================================================
SELECT 
    trigger_name AS "Trigger",
    event_object_table AS "Tabela",
    event_manipulation AS "Evento",
    action_timing AS "Quando"
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;
