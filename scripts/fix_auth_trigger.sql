-- ============================================================
-- TRIGGER: on_auth_user_created
-- Quando usuario se registra no Supabase Auth (auth.users),
-- cria automaticamente:
--   1. Uma familia para o primeiro usuario
--   2. O registro em public.users vinculado a familia
-- ============================================================

-- Tabela auxiliar para convites de familia
CREATE TABLE IF NOT EXISTS family_invites (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id   UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    code        TEXT UNIQUE NOT NULL DEFAULT upper(substring(md5(random()::text), 1, 8)),
    used_by     UUID REFERENCES users(id),
    used_at     TIMESTAMPTZ,
    expires_at  TIMESTAMPTZ DEFAULT NOW() + INTERVAL '7 days',
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Coluna invite_code em families (codigo para o parceiro entrar)
ALTER TABLE families ADD COLUMN IF NOT EXISTS invite_code TEXT UNIQUE 
    DEFAULT upper(substring(md5(random()::text), 1, 8));

-- ── FUNCAO PRINCIPAL ─────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_on_auth_user_created()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS \$\$
DECLARE
    v_family_id   UUID;
    v_family_name TEXT;
    v_user_name   TEXT;
    v_invite_code TEXT;
    v_role        TEXT;
BEGIN
    -- Nome vem do metadata do signUp (data->>'name')
    v_user_name := COALESCE(
        NEW.raw_user_meta_data->>'name',
        split_part(NEW.email, '@', 1)
    );

    -- Verifica se veio invite_code no metadata
    v_invite_code := NEW.raw_user_meta_data->>'invite_code';

    IF v_invite_code IS NOT NULL THEN
        -- ── CAMINHO 2: Entra em familia existente via convite ──
        SELECT family_id INTO v_family_id
        FROM family_invites
        WHERE code = v_invite_code
          AND used_by IS NULL
          AND expires_at > NOW();

        IF v_family_id IS NULL THEN
            -- Convite invalido ou expirado → cria familia nova mesmo
            v_invite_code := NULL;
        END IF;
    END IF;

    IF v_invite_code IS NULL THEN
        -- ── CAMINHO 1: Primeiro usuario → cria familia nova ───
        v_family_name := v_user_name || '''s Family';
        v_role := 'admin';

        INSERT INTO families (name)
        VALUES (v_family_name)
        RETURNING id INTO v_family_id;
    ELSE
        v_role := 'member';
    END IF;

    -- ── Cria registro em public.users ─────────────────────
    INSERT INTO public.users (
        id,
        family_id,
        auth_id,
        email,
        name,
        role,
        is_active,
        created_at,
        updated_at
    ) VALUES (
        NEW.id,          -- mesmo UUID do auth.users
        v_family_id,
        NEW.id,
        NEW.email,
        v_user_name,
        v_role,
        TRUE,
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        email      = EXCLUDED.email,
        name       = EXCLUDED.name,
        updated_at = NOW();

    -- ── Marca convite como usado ───────────────────────────
    IF v_invite_code IS NOT NULL THEN
        UPDATE family_invites
        SET used_by  = NEW.id,
            used_at  = NOW()
        WHERE code   = v_invite_code;
    END IF;

    RETURN NEW;

EXCEPTION WHEN OTHERS THEN
    -- Nunca bloqueia o cadastro por erro no trigger
    RAISE WARNING 'fn_on_auth_user_created error: % %', SQLERRM, SQLSTATE;
    RETURN NEW;
END;
\$\$;

-- ── CRIA O TRIGGER ────────────────────────────────────────
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION fn_on_auth_user_created();

-- ── CORRIGE USUARIOS JA CADASTRADOS (orphans) ────────────
-- Usuarios que estao em auth.users mas nao em public.users
DO \$\$
DECLARE
    r             RECORD;
    v_family_id   UUID;
    v_user_name   TEXT;
    v_count       INT := 0;
BEGIN
    FOR r IN
        SELECT au.id, au.email, au.raw_user_meta_data, au.created_at
        FROM auth.users au
        LEFT JOIN public.users pu ON pu.id = au.id
        WHERE pu.id IS NULL
        ORDER BY au.created_at
    LOOP
        v_user_name := COALESCE(
            r.raw_user_meta_data->>'name',
            split_part(r.email, '@', 1)
        );

        -- Cria familia para cada usuario orfao
        INSERT INTO families (name)
        VALUES (v_user_name || '''s Family')
        RETURNING id INTO v_family_id;

        -- Cria o registro em public.users
        INSERT INTO public.users (
            id, family_id, auth_id, email, name,
            role, is_active, created_at, updated_at
        ) VALUES (
            r.id, v_family_id, r.id, r.email, v_user_name,
            'admin', TRUE, r.created_at, NOW()
        )
        ON CONFLICT (id) DO NOTHING;

        v_count := v_count + 1;
        RAISE NOTICE 'Corrigido usuario orfao: % (%)', r.email, r.id;
    END LOOP;

    RAISE NOTICE '✅ Total de usuarios corrigidos: %', v_count;
END;
\$\$;

-- ── VERIFICA RESULTADO ────────────────────────────────────
SELECT
    au.email,
    au.created_at AS auth_created,
    pu.id         AS public_user_id,
    pu.family_id,
    pu.role,
    f.name        AS family_name
FROM auth.users au
LEFT JOIN public.users pu ON pu.id = au.id
LEFT JOIN families f      ON f.id = pu.family_id
ORDER BY au.created_at;
