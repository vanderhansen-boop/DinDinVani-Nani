CREATE OR REPLACE FUNCTION fn_process_cpi_installment_payment()
RETURNS TRIGGER AS $$
DECLARE v_cpi RECORD; v_installment_amount NUMERIC(14,2); v_cf_id UUID; BEGIN IF NEW.status = 'paid' AND (OLD.status IS NULL OR OLD.status <> 'paid') THEN SELECT id INTO v_cf_id FROM piggy_banks WHERE credit_card_id = NEW.credit_card_id AND type = 'CF' LIMIT 1; IF v_cf_id IS NULL THEN RETURN NEW; END IF; FOR v_cpi IN SELECT * FROM piggy_banks WHERE credit_card_id = NEW.credit_card_id AND type = 'CPI' AND installments_paid < installments_total AND current_amount > 0 LOOP v_installment_amount := ROUND(v_cpi.target_amount / v_cpi.installments_total, 2); IF v_installment_amount > v_cpi.current_amount THEN v_installment_amount := v_cpi.current_amount; END IF; UPDATE piggy_banks SET current_amount = current_amount - v_installment_amount, installments_paid = installments_paid + 1, updated_at = NOW() WHERE id = v_cpi.id; UPDATE piggy_banks SET current_amount = current_amount + v_installment_amount, updated_at = NOW() WHERE id = v_cf_id; INSERT INTO cpi_installment_payments ( cpi_piggy_bank_id, cf_piggy_bank_id, invoice_id, installment_number, amount, payment_date, created_at ) VALUES ( v_cpi.id, v_cf_id, NEW.id, v_cpi.installments_paid + 1, v_installment_amount, CURRENT_DATE, NOW() ); END LOOP; END IF; RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_process_cpi_installment_payment ON invoices;

CREATE TRIGGER trg_process_cpi_installment_payment
AFTER UPDATE ON invoices
FOR EACH ROW
EXECUTE FUNCTION fn_process_cpi_installment_payment();
