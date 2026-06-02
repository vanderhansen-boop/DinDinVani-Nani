CREATE OR REPLACE FUNCTION fn_reserve_invoice_cf()
RETURNS TRIGGER AS $$
DECLARE v_invoice_id UUID; v_cf_id UUID; BEGIN IF NEW.credit_card_id IS NOT NULL AND NEW.type = 'expense' THEN SELECT id INTO v_invoice_id FROM invoices WHERE credit_card_id = NEW.credit_card_id AND status = 'open' ORDER BY due_date ASC LIMIT 1; SELECT id INTO v_cf_id FROM piggy_banks WHERE credit_card_id = NEW.credit_card_id AND type = 'CF' LIMIT 1; IF v_invoice_id IS NOT NULL AND v_cf_id IS NOT NULL THEN INSERT INTO invoice_reserves ( invoice_id, transaction_id, piggy_bank_id, amount, created_at ) VALUES ( v_invoice_id, NEW.id, v_cf_id, NEW.amount, NOW() ); END IF; END IF; RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_reserve_invoice_cf ON transactions;

CREATE TRIGGER trg_reserve_invoice_cf
AFTER INSERT ON transactions
FOR EACH ROW
EXECUTE FUNCTION fn_reserve_invoice_cf();
