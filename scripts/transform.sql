-- transformacao_unificada.sql

-- Adiciona colunas transformadas que vamos popular
ALTER TABLE staging.stg_clientes ADD COLUMN documento_unificado VARCHAR(20);
ALTER TABLE staging.stg_veiculos ADD COLUMN tipo_cambio_padronizado VARCHAR(20);
ALTER TABLE staging.stg_locacoes ADD COLUMN valor_total_calculado NUMERIC(12, 2);
ALTER TABLE staging.stg_locacoes ADD COLUMN duracao_dias INT;

-- T1: Unificar e limpar documentos dos clientes
UPDATE staging.stg_clientes
SET documento_unificado = REGEXP_REPLACE(COALESCE(cpf, cnpj), '[^0-9]', '', 'g');

-- T2: Padronizar tipo de câmbio dos veículos
UPDATE staging.stg_veiculos
SET tipo_cambio_padronizado = 'Automático'
WHERE
    (fonte_dados = 'RICKAUER' AND mecanizacao_bool = TRUE) OR
    (mecanizacao_varchar ILIKE 'Automatica') OR
    (mecanizacao_varchar ILIKE 'Automática') OR
    (mecanizacao_varchar ILIKE 'Auto');

UPDATE staging.stg_veiculos
SET tipo_cambio_padronizado = 'Manual'
WHERE tipo_cambio_padronizado IS NULL; -- O resto é manual

-- T3: Calcular métricas para a tabela de locações
-- Calcular duração em dias
UPDATE staging.stg_locacoes
SET duracao_dias = EXTRACT(DAY FROM (data_devolucao - data_retirada));

-- Calcular valor total (a parte mais complexa)
-- Primeiro, para as fontes que já têm, apenas copiamos
UPDATE staging.stg_locacoes
SET valor_total_calculado = valor_final
WHERE valor_final IS NOT NULL;

-- Para as fontes que precisam buscar da tabela de cobrança (Rickauer, Breno)
UPDATE staging.stg_locacoes l
SET valor_total_calculado = c.valor_total
FROM staging.stg_cobrancas c
WHERE l.id_origem = c.id_locacao_origem AND l.fonte_dados = c.fonte_dados
  AND l.valor_total_calculado IS NULL;

-- Define um valor padrão para locações que ficaram sem valor
UPDATE staging.stg_locacoes
SET valor_total_calculado = 0
WHERE valor_total_calculado IS NULL;
