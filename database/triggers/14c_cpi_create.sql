CREATE OR REPLACE FUNCTION fn_create_cpi_on_installment()
RETURNS TRIGGER AS $$
DECLARE v_cpi_id UUID; v_total_amount NUMERIC(14,2); v_family_id UUID; v_description TEXT; BEGIN IF NEW.installments IS NOT NULL AND NEW.installments > 1 AND NEW.credit_card_id IS NOT NULL AND NEW.type = 'expense' THEN v_total_amount := NEW.amount * NEW.installments; SELECT family_id INTO v_family_id FROM credit_cards WHERE id = NEW.credit_card_id; v_description := 'CPI - ' || COALESCE(NEW.description, 'Compra parcelada'); INSERT INTO piggy_banks ( family_id, name, type, target_amount, current_amount, credit_card_id, installments_total, installments_paid, created_at, updated_at ) VALUES ( v_family_id, v_description, 'CPI', v_total_amount, v_total_amount, NEW.credit_card_id, NEW.installments, 0, NOW(), NOW() ) RETURNING id INTO v_cpi_id; INSERT INTO piggy_bank_contributions ( piggy_bank_id, transaction_id, amount, contribution_date, created_at ) VALUES ( v_cpi_id, NEW.id, v_total_amount, CURRENT_DATE, NOW() ); END IF; RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_create_cpi_on_installment ON transactions;

CREATE TRIGGER trg_create_cpi_on_installment
AFTER INSERT ON transactions
FOR EACH ROW
EXECUTE FUNCTION fn_create_cpi_on_installment();
