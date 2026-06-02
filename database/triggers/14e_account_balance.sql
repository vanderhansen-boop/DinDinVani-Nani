CREATE OR REPLACE FUNCTION fn_update_account_balance()
RETURNS TRIGGER AS $$

DECLARE
  v_delta NUMERIC(14,2);
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.account_id IS NOT NULL AND NEW.credit_card_id IS NULL THEN
      IF NEW.type = 'income' THEN
        v_delta := NEW.amount;
      ELSIF NEW.type = 'expense' THEN
        v_delta := -NEW.amount;
      ELSE
        v_delta := 0;
      END IF;
      UPDATE accounts SET balance = balance + v_delta, updated_at = NOW() WHERE id = NEW.account_id;
    END IF;
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE' THEN
    IF OLD.account_id IS NOT NULL AND OLD.credit_card_id IS NULL THEN
      IF OLD.type = 'income' THEN
        v_delta := -OLD.amount;
      ELSIF OLD.type = 'expense' THEN
        v_delta := OLD.amount;
      ELSE
        v_delta := 0;
      END IF;
      UPDATE accounts SET balance = balance + v_delta, updated_at = NOW() WHERE id = OLD.account_id;
    END IF;
    IF NEW.account_id IS NOT NULL AND NEW.credit_card_id IS NULL THEN
      IF NEW.type = 'income' THEN
        v_delta := NEW.amount;
      ELSIF NEW.type = 'expense' THEN
        v_delta := -NEW.amount;
      ELSE
        v_delta := 0;
      END IF;
      UPDATE accounts SET balance = balance + v_delta, updated_at = NOW() WHERE id = NEW.account_id;
    END IF;
    RETURN NEW;
  END IF;

  IF TG_OP = 'DELETE' THEN
    IF OLD.account_id IS NOT NULL AND OLD.credit_card_id IS NULL THEN
      IF OLD.type = 'income' THEN
        v_delta := -OLD.amount;
      ELSIF OLD.type = 'expense' THEN
        v_delta := OLD.amount;
      ELSE
        v_delta := 0;
      END IF;
      UPDATE accounts SET balance = balance + v_delta, updated_at = NOW() WHERE id = OLD.account_id;
    END IF;
    RETURN OLD;
  END IF;

  RETURN NULL;
END;

$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_account_balance ON transactions;

CREATE TRIGGER trg_update_account_balance
AFTER INSERT OR UPDATE OR DELETE ON transactions
FOR EACH ROW
EXECUTE FUNCTION fn_update_account_balance();
