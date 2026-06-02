-- =====================================================
-- BLOCO 4: Auditoria em tabelas críticas
-- =====================================================

CREATE OR REPLACE FUNCTION fn_audit_log()
RETURNS TRIGGER AS $$
BEGIN INSERT INTO audit_log ( table_name, operation, record_id, old_data, new_data, changed_at ) VALUES ( TG_TABLE_NAME, TG_OP, COALESCE(NEW.id, OLD.id), CASE WHEN TG_OP IN ('UPDATE','DELETE') THEN to_jsonb(OLD) ELSE NULL END, CASE WHEN TG_OP IN ('INSERT','UPDATE') THEN to_jsonb(NEW) ELSE NULL END, NOW() ); RETURN COALESCE(NEW, OLD); END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE t TEXT; audit_tables TEXT[] := ARRAY['transactions','piggy_banks','accounts','credit_cards','invoices']; BEGIN FOREACH t IN ARRAY audit_tables LOOP EXECUTE format('DROP TRIGGER IF EXISTS trg_audit_%I ON %I;', t, t); EXECUTE format('CREATE TRIGGER trg_audit_%I AFTER INSERT OR UPDATE OR DELETE ON %I FOR EACH ROW EXECUTE FUNCTION fn_audit_log();', t, t); END LOOP; END;
$$;
