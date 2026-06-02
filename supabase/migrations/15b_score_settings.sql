-- ============================================================
-- SCORE SETTINGS - DinDinVani&Nani - Script 15b (corrigido)
-- ============================================================

CREATE TABLE IF NOT EXISTS score_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id UUID NOT NULL UNIQUE REFERENCES families(id) ON DELETE CASCADE,
  peso_cf NUMERIC(5,2) NOT NULL DEFAULT 30.00,
  peso_ce NUMERIC(5,2) NOT NULL DEFAULT 25.00,
  peso_od NUMERIC(5,2) NOT NULL DEFAULT 20.00,
  peso_503020 NUMERIC(5,2) NOT NULL DEFAULT 15.00,
  peso_metas NUMERIC(5,2) NOT NULL DEFAULT 10.00,
  meses_reserva_emergencia INT NOT NULL DEFAULT 6,
  percentual_necessidades NUMERIC(5,2) NOT NULL DEFAULT 50.00,
  percentual_desejos NUMERIC(5,2) NOT NULL DEFAULT 30.00,
  percentual_poupanca NUMERIC(5,2) NOT NULL DEFAULT 20.00,
  faixa_verde_escuro INT NOT NULL DEFAULT 85,
  faixa_verde_claro INT NOT NULL DEFAULT 70,
  faixa_amarelo INT NOT NULL DEFAULT 50,
  faixa_laranja INT NOT NULL DEFAULT 30,
  alerta_queda_brusca BOOLEAN NOT NULL DEFAULT TRUE,
  alerta_cf_baixa BOOLEAN NOT NULL DEFAULT TRUE,
  alerta_ce_critica BOOLEAN NOT NULL DEFAULT TRUE,
  alerta_estouro_od BOOLEAN NOT NULL DEFAULT TRUE,
  alerta_meta_atrasada BOOLEAN NOT NULL DEFAULT TRUE,
  alerta_conquistas BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_by UUID REFERENCES users(id)
);

ALTER TABLE score_settings DROP CONSTRAINT IF EXISTS chk_pesos_soma;
ALTER TABLE score_settings ADD CONSTRAINT chk_pesos_soma CHECK (
  peso_cf + peso_ce + peso_od + peso_503020 + peso_metas = 100
);

ALTER TABLE score_settings DROP CONSTRAINT IF EXISTS chk_503020_soma;
ALTER TABLE score_settings ADD CONSTRAINT chk_503020_soma CHECK (
  percentual_necessidades + percentual_desejos + percentual_poupanca = 100
);

ALTER TABLE score_settings DROP CONSTRAINT IF EXISTS chk_faixas_ordem;
ALTER TABLE score_settings ADD CONSTRAINT chk_faixas_ordem CHECK (
  faixa_verde_escuro > faixa_verde_claro AND
  faixa_verde_claro > faixa_amarelo AND
  faixa_amarelo > faixa_laranja AND
  faixa_laranja > 0 AND
  faixa_verde_escuro <= 100
);

ALTER TABLE score_settings DROP CONSTRAINT IF EXISTS chk_meses_reserva;
ALTER TABLE score_settings ADD CONSTRAINT chk_meses_reserva CHECK (
  meses_reserva_emergencia BETWEEN 1 AND 24
);

CREATE INDEX IF NOT EXISTS idx_score_settings_family ON score_settings(family_id);

ALTER TABLE score_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS score_settings_select ON score_settings;
CREATE POLICY score_settings_select ON score_settings
  FOR SELECT USING (
    family_id IN (SELECT family_id FROM users WHERE id = auth.uid())
  );

DROP POLICY IF EXISTS score_settings_update ON score_settings;
CREATE POLICY score_settings_update ON score_settings
  FOR UPDATE USING (
    family_id IN (SELECT family_id FROM users WHERE id = auth.uid())
  );

DROP POLICY IF EXISTS score_settings_insert ON score_settings;
CREATE POLICY score_settings_insert ON score_settings
  FOR INSERT WITH CHECK (
    family_id IN (SELECT family_id FROM users WHERE id = auth.uid())
  );

CREATE OR REPLACE FUNCTION fn_score_settings_updated_at()
RETURNS TRIGGER AS $body$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$body$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_score_settings_updated_at ON score_settings;
CREATE TRIGGER trg_score_settings_updated_at
  BEFORE UPDATE ON score_settings
  FOR EACH ROW
  EXECUTE FUNCTION fn_score_settings_updated_at();

CREATE OR REPLACE FUNCTION fn_create_default_score_settings()
RETURNS TRIGGER AS $body$
BEGIN
  INSERT INTO score_settings (family_id)
  VALUES (NEW.id)
  ON CONFLICT (family_id) DO NOTHING;
  RETURN NEW;
END;
$body$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_create_default_score_settings ON families;
CREATE TRIGGER trg_create_default_score_settings
  AFTER INSERT ON families
  FOR EACH ROW
  EXECUTE FUNCTION fn_create_default_score_settings();

CREATE OR REPLACE FUNCTION fn_audit_score_settings()
RETURNS TRIGGER AS $body$
BEGIN
  INSERT INTO audit_log (
    family_id, user_id, table_name, record_id,
    action, old_data, new_data, created_at
  ) VALUES (
    NEW.family_id,
    NEW.updated_by,
    'score_settings',
    NEW.id,
    'UPDATE',
    to_jsonb(OLD),
    to_jsonb(NEW),
    NOW()
  );
  RETURN NEW;
END;
$body$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_audit_score_settings ON score_settings;
CREATE TRIGGER trg_audit_score_settings
  AFTER UPDATE ON score_settings
  FOR EACH ROW
  WHEN (OLD.* IS DISTINCT FROM NEW.*)
  EXECUTE FUNCTION fn_audit_score_settings();

SELECT 'score_settings criada' AS status, COUNT(*) AS total FROM score_settings;

SELECT 'Constraints aplicadas' AS status, COUNT(*) AS total
  FROM information_schema.table_constraints
  WHERE table_name = 'score_settings' AND constraint_type = 'CHECK';

SELECT 'Triggers criados' AS status, COUNT(*) AS total
  FROM information_schema.triggers
  WHERE event_object_table IN ('score_settings', 'families')
    AND trigger_name LIKE '%score%';
