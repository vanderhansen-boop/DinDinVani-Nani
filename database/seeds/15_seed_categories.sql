-- ============================================================
-- Script 15: Seed de Categorias Padrao
-- Cria funcao que popula categorias para uma family_id
-- + trigger que dispara automaticamente ao criar familia
-- ============================================================

-- ------------------------------------------------------------
-- FUNCAO: fn_seed_default_categories(p_family_id UUID)
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_seed_default_categories(p_family_id UUID)
RETURNS VOID AS $$

BEGIN
  -- =========================================
  -- CATEGORIAS DE RECEITA (income)
  -- =========================================
  INSERT INTO categories (family_id, name, type, icon, color, is_default) VALUES
    (p_family_id, 'Salario',          'income', 'wallet',        '#4CAF50', TRUE),
    (p_family_id, 'Freelance',        'income', 'laptop',        '#66BB6A', TRUE),
    (p_family_id, 'Investimentos',    'income', 'trending_up',   '#43A047', TRUE),
    (p_family_id, '13o Salario',      'income', 'card_giftcard', '#388E3C', TRUE),
    (p_family_id, 'Ferias',           'income', 'beach_access',  '#2E7D32', TRUE),
    (p_family_id, 'Reembolso',        'income', 'replay',        '#1B5E20', TRUE),
    (p_family_id, 'Presente',         'income', 'redeem',        '#81C784', TRUE),
    (p_family_id, 'Outras Receitas',  'income', 'attach_money',  '#A5D6A7', TRUE);

  -- =========================================
  -- CATEGORIAS DE DESPESA (expense)
  -- =========================================
  INSERT INTO categories (family_id, name, type, icon, color, is_default) VALUES
    -- Moradia
    (p_family_id, 'Aluguel',          'expense', 'home',            '#E53935', TRUE),
    (p_family_id, 'Condominio',       'expense', 'apartment',       '#D32F2F', TRUE),
    (p_family_id, 'Energia Eletrica', 'expense', 'bolt',            '#FBC02D', TRUE),
    (p_family_id, 'Agua',             'expense', 'water_drop',      '#1E88E5', TRUE),
    (p_family_id, 'Gas',              'expense', 'local_fire_department', '#FB8C00', TRUE),
    (p_family_id, 'Internet',         'expense', 'wifi',            '#5E35B1', TRUE),
    (p_family_id, 'IPTU',             'expense', 'receipt_long',    '#C62828', TRUE),

    -- Alimentacao
    (p_family_id, 'Supermercado',     'expense', 'shopping_cart',   '#FB8C00', TRUE),
    (p_family_id, 'Restaurante',      'expense', 'restaurant',      '#F4511E', TRUE),
    (p_family_id, 'Delivery',         'expense', 'delivery_dining', '#E64A19', TRUE),
    (p_family_id, 'Padaria',          'expense', 'bakery_dining',   '#D84315', TRUE),
    (p_family_id, 'Cafeteria',        'expense', 'local_cafe',      '#6D4C41', TRUE),

    -- Transporte
    (p_family_id, 'Combustivel',      'expense', 'local_gas_station', '#F57C00', TRUE),
    (p_family_id, 'Estacionamento',   'expense', 'local_parking',   '#FF8F00', TRUE),
    (p_family_id, 'Pedagio',          'expense', 'toll',            '#FFA000', TRUE),
    (p_family_id, 'Uber/Taxi',        'expense', 'local_taxi',      '#FFB300', TRUE),
    (p_family_id, 'Transporte Publico', 'expense', 'directions_bus', '#FFC107', TRUE),
    (p_family_id, 'Manutencao Veiculo', 'expense', 'build',         '#FF6F00', TRUE),
    (p_family_id, 'IPVA/Licenciamento', 'expense', 'description',   '#E65100', TRUE),

    -- Saude
    (p_family_id, 'Plano de Saude',   'expense', 'health_and_safety', '#26A69A', TRUE),
    (p_family_id, 'Medico',           'expense', 'medical_services',  '#00897B', TRUE),
    (p_family_id, 'Farmacia',         'expense', 'medication',      '#00796B', TRUE),
    (p_family_id, 'Dentista',         'expense', 'dentistry',       '#00695C', TRUE),
    (p_family_id, 'Academia',         'expense', 'fitness_center',  '#004D40', TRUE),

    -- Lazer
    (p_family_id, 'Streaming',        'expense', 'play_circle',     '#8E24AA', TRUE),
    (p_family_id, 'Cinema/Teatro',    'expense', 'theaters',        '#7B1FA2', TRUE),
    (p_family_id, 'Viagem',           'expense', 'flight',          '#6A1B9A', TRUE),
    (p_family_id, 'Hobbies',          'expense', 'palette',         '#4A148C', TRUE),
    (p_family_id, 'Bar/Balada',       'expense', 'local_bar',       '#AB47BC', TRUE),

    -- Educacao
    (p_family_id, 'Cursos',           'expense', 'school',          '#3949AB', TRUE),
    (p_family_id, 'Livros',           'expense', 'menu_book',       '#303F9F', TRUE),
    (p_family_id, 'Mensalidade Escolar', 'expense', 'cast_for_education', '#283593', TRUE),

    -- Vestuario e Cuidados Pessoais
    (p_family_id, 'Roupas',           'expense', 'checkroom',       '#EC407A', TRUE),
    (p_family_id, 'Calcados',         'expense', 'ice_skating',     '#D81B60', TRUE),
    (p_family_id, 'Salao de Beleza',  'expense', 'content_cut',     '#AD1457', TRUE),
    (p_family_id, 'Cosmeticos',       'expense', 'face',            '#880E4F', TRUE),

    -- Pets
    (p_family_id, 'Pet - Racao',      'expense', 'pets',            '#795548', TRUE),
    (p_family_id, 'Pet - Veterinario', 'expense', 'healing',        '#6D4C41', TRUE),

    -- Financeiro
    (p_family_id, 'Tarifas Bancarias', 'expense', 'account_balance', '#37474F', TRUE),
    (p_family_id, 'Juros e Multas',   'expense', 'warning',         '#263238', TRUE),
    (p_family_id, 'Emprestimos',      'expense', 'paid',            '#455A64', TRUE),
    (p_family_id, 'Impostos',         'expense', 'gavel',           '#546E7A', TRUE),

    -- Doacoes e Diversos
    (p_family_id, 'Doacoes',          'expense', 'volunteer_activism', '#EF5350', TRUE),
    (p_family_id, 'Presentes',        'expense', 'card_giftcard',   '#E57373', TRUE),
    (p_family_id, 'Assinaturas',      'expense', 'subscriptions',   '#9575CD', TRUE),
    (p_family_id, 'Outras Despesas',  'expense', 'more_horiz',      '#90A4AE', TRUE);

  -- =========================================
  -- CATEGORIAS DE TRANSFERENCIA (transfer)
  -- =========================================
  INSERT INTO categories (family_id, name, type, icon, color, is_default) VALUES
    (p_family_id, 'Transferencia entre Contas', 'transfer', 'swap_horiz', '#607D8B', TRUE),
    (p_family_id, 'Aporte em Caixinha',         'transfer', 'savings',    '#78909C', TRUE),
    (p_family_id, 'Pagamento de Fatura',        'transfer', 'credit_card','#546E7A', TRUE);

END;

$$ LANGUAGE plpgsql;

-- ------------------------------------------------------------
-- TRIGGER: ao criar uma family, popula categorias automaticamente
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_trigger_seed_categories()
RETURNS TRIGGER AS $$

BEGIN
  PERFORM fn_seed_default_categories(NEW.id);
  RETURN NEW;
END;

$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_seed_categories_on_family ON families;

CREATE TRIGGER trg_seed_categories_on_family
AFTER INSERT ON families
FOR EACH ROW
EXECUTE FUNCTION fn_trigger_seed_categories();
