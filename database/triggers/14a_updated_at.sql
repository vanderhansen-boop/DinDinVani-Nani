-- =====================================================
-- BLOCO 1: updated_at automático
-- =====================================================

CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

-- Aplica em todas as tabelas que têm updated_at
DO $$
DECLARE t TEXT; tables TEXT[] := ARRAY[ 'families','users','accounts','credit_cards','invoices', 'transactions','recurring_transactions','piggy_banks', 'budgets','monthly_budgets','family_goals','categories', 'family_settings' ]; BEGIN FOREACH t IN ARRAY tables LOOP EXECUTE format('DROP TRIGGER IF EXISTS trg_%I_updated_at ON %I;', t, t); EXECUTE format('CREATE TRIGGER trg_%I_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();', t, t); END LOOP; END;
$$;
