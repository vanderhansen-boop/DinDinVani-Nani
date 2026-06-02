-- ============================================================
-- Trigger 14f: Atualizacao automatica do saldo das caixinhas
-- Mantem piggy_banks.current_balance sincronizado com
-- piggy_bank_contributions (deposito, saque, ajuste)
-- ============================================================

CREATE OR REPLACE FUNCTION fn_update_piggy_bank_balance()
RETURNS TRIGGER AS $$

DECLARE
  v_delta NUMERIC(14,2);
BEGIN
  -- INSERT: aplica contribuicao no saldo
  IF TG_OP = 'INSERT' THEN
    IF NEW.type = 'deposit' THEN
      v_delta := NEW.amount;
    ELSIF NEW.type = 'withdraw' THEN
      v_delta := -NEW.amount;
    ELSIF NEW.type = 'adjustment' THEN
      v_delta := NEW.amount;
    ELSE
      v_delta := 0;
    END IF;

    UPDATE piggy_banks
       SET current_balance = current_balance + v_delta,
           updated_at = NOW()
     WHERE id = NEW.piggy_bank_id;

    RETURN NEW;
  END IF;

  -- UPDATE: reverte valor antigo e aplica o novo
  IF TG_OP = 'UPDATE' THEN
    -- Reverte OLD
    IF OLD.type = 'deposit' THEN
      v_delta := -OLD.amount;
    ELSIF OLD.type = 'withdraw' THEN
      v_delta := OLD.amount;
    ELSIF OLD.type = 'adjustment' THEN
      v_delta := -OLD.amount;
    ELSE
      v_delta := 0;
    END IF;

    UPDATE piggy_banks
       SET current_balance = current_balance + v_delta,
           updated_at = NOW()
     WHERE id = OLD.piggy_bank_id;

    -- Aplica NEW
    IF NEW.type = 'deposit' THEN
      v_delta := NEW.amount;
    ELSIF NEW.type = 'withdraw' THEN
      v_delta := -NEW.amount;
    ELSIF NEW.type = 'adjustment' THEN
      v_delta := NEW.amount;
    ELSE
      v_delta := 0;
    END IF;

    UPDATE piggy_banks
       SET current_balance = current_balance + v_delta,
           updated_at = NOW()
     WHERE id = NEW.piggy_bank_id;

    RETURN NEW;
  END IF;

  -- DELETE: reverte a contribuicao
  IF TG_OP = 'DELETE' THEN
    IF OLD.type = 'deposit' THEN
      v_delta := -OLD.amount;
    ELSIF OLD.type = 'withdraw' THEN
      v_delta := OLD.amount;
    ELSIF OLD.type = 'adjustment' THEN
      v_delta := -OLD.amount;
    ELSE
      v_delta := 0;
    END IF;

    UPDATE piggy_banks
       SET current_balance = current_balance + v_delta,
           updated_at = NOW()
     WHERE id = OLD.piggy_bank_id;

    RETURN OLD;
  END IF;

  RETURN NULL;
END;

$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_piggy_bank_balance ON piggy_bank_contributions;

CREATE TRIGGER trg_update_piggy_bank_balance
AFTER INSERT OR UPDATE OR DELETE ON piggy_bank_contributions
FOR EACH ROW
EXECUTE FUNCTION fn_update_piggy_bank_balance();
