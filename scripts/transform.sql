-- Guilherme Oliveira Rolim Silva - DRE: 122076696

-- Ricardo Lorente Kauer - DRE: 122100500

-- Vinícius Alcântara Gomes Reis de Souza - DRE: 122060831

ALTER TABLE staging.stg_clientes ADD COLUMN documento_unificado VARCHAR(20);
ALTER TABLE staging.stg_veiculos ADD COLUMN tipo_cambio_padronizado VARCHAR(20);
ALTER TABLE staging.stg_locacoes ADD COLUMN valor_total_calculado NUMERIC(12, 2);
ALTER TABLE staging.stg_locacoes ADD COLUMN duracao_dias INT;

UPDATE staging.stg_clientes
SET documento_unificado = REGEXP_REPLACE(COALESCE(cpf, cnpj), '[^0-9]', '', 'g');

UPDATE staging.stg_veiculos
SET tipo_cambio_padronizado = 'Automático'
WHERE
    (fonte_dados = 'RICKAUER' AND mecanizacao_bool = TRUE) OR
    (mecanizacao_varchar ILIKE 'Automatica') OR
    (mecanizacao_varchar ILIKE 'Automática') OR
    (mecanizacao_varchar ILIKE 'Auto');

UPDATE staging.stg_veiculos
SET tipo_cambio_padronizado = 'Manual'
WHERE tipo_cambio_padronizado IS NULL;

UPDATE staging.stg_locacoes
SET duracao_dias = EXTRACT(DAY FROM (data_devolucao - data_retirada));

UPDATE staging.stg_locacoes
SET valor_total_calculado = valor_final
WHERE valor_final IS NOT NULL;

UPDATE staging.stg_locacoes l
SET valor_total_calculado = c.valor_total
FROM staging.stg_cobrancas c
WHERE l.id_origem = c.id_locacao_origem AND l.fonte_dados = c.fonte_dados
  AND l.valor_total_calculado IS NULL;

UPDATE staging.stg_locacoes
SET valor_total_calculado = 0
WHERE valor_total_calculado IS NULL;
