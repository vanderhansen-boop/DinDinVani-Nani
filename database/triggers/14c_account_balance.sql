-- =====================================================
-- BLOCO 3: Atualização automática de saldo de conta
-- =====================================================

CREATE OR REPLACE FUNCTION fn_update_account_balance()
RETURNS TRIGGER AS $$
BEGIN IF TG_OP = 'INSERT' AND NEW.account_id IS NOT NULL THEN IF NEW.type = 'income' THEN UPDATE accounts SET balance = balance + NEW.amount WHERE id = NEW.account_id; ELSIF NEW.type = 'expense' THEN UPDATE accounts SET balance = balance - NEW.amount WHERE id = NEW.account_id; END IF; ELSIF TG_OP = 'DELETE' AND OLD.account_id IS NOT NULL THEN IF OLD.type = 'income' THEN UPDATE accounts SET balance = balance - OLD.amount WHERE id = OLD.account_id; ELSIF OLD.type = 'expense' THEN UPDATE accounts SET balance = balance + OLD.amount WHERE id = OLD.account_id; END IF; END IF; RETURN COALESCE(NEW, OLD); END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_account_balance ON transactions;
CREATE TRIGGER trg_update_account_balance
AFTER INSERT OR DELETE ON transactions
FOR EACH ROW EXECUTE FUNCTION fn_update_account_balance();
