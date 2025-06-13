INSERT INTO dwh.Dim_Tempo (data, dia, mes, ano, trimestre, nome_mes, dia_da_semana)
SELECT datum,
       EXTRACT(DAY FROM datum),
       EXTRACT(MONTH FROM datum),
       EXTRACT(YEAR FROM datum),
       EXTRACT(QUARTER FROM datum),
       TO_CHAR(datum, 'TMMonth'),
       TO_CHAR(datum, 'TMDay')
FROM (SELECT '2020-01-01'::DATE + s.a AS datum FROM generate_series(0, 5000) AS s(a)) AS V
ON CONFLICT (data) DO NOTHING;


-- ====================================================================
-- L1: Carga das Dimensões (com deduplicação)
-- ====================================================================
-- As dimensões devem ser carregadas ANTES da tabela fato.

-- Carga da Dimensão Cliente, garantindo um registro único por documento.
INSERT INTO dwh.Dim_Cliente (cliente_id_origem, fonte_dados, nome_cliente, documento, tipo_pessoa, cidade_cliente)
SELECT DISTINCT ON (documento_unificado)
    id_origem, fonte_dados, nome, documento_unificado, UPPER(tipo_pessoa), cidade
FROM staging.stg_clientes
WHERE documento_unificado IS NOT NULL
ON CONFLICT (documento) DO NOTHING; -- Se um cliente com este documento já existe, não faz nada.

-- Carga da Dimensão Pátio.
INSERT INTO dwh.Dim_Patio (patio_id_origem, fonte_dados, nome_patio, localizacao_completa)
SELECT DISTINCT ON (id_origem, fonte_dados)
    id_origem, fonte_dados, nome, endereco
FROM staging.stg_patios
-- ON CONFLICT só funciona com uma constraint UNIQUE. Vamos assumir que a combinação de id e fonte é única.
ON CONFLICT DO NOTHING;

-- Carga da Dimensão GrupoVeiculo.
-- *** CORREÇÃO APLICADA AQUI ***
-- A coluna de origem na staging se chama 'grupo_nome'.
INSERT INTO dwh.Dim_GrupoVeiculo (nome_grupo)
SELECT DISTINCT grupo_nome FROM staging.stg_veiculos WHERE grupo_nome IS NOT NULL
ON CONFLICT (nome_grupo) DO NOTHING; -- Se um grupo com este nome já existe, não faz nada.

-- Carga da Dimensão Veículo, garantindo um registro único por placa.
INSERT INTO dwh.Dim_Veiculo (placa, chassi, marca, modelo, ano_fabricacao, cor, tipo_cambio)
SELECT DISTINCT ON (placa)
    placa, chassi, marca, modelo, ano, cor, tipo_cambio_padronizado
FROM staging.stg_veiculos
WHERE placa IS NOT NULL
ON CONFLICT (placa) DO NOTHING; -- Se um veículo com esta placa já existe, não faz nada.


-- ====================================================================
-- L2: Carga da Tabela Fato (a parte mais importante)
-- ====================================================================
-- Este passo busca as chaves substitutas (sk_) das dimensões já carregadas.

INSERT INTO dwh.Fato_Locacao (
    locacao_id_origem, fonte_dados,
    sk_cliente, sk_veiculo, sk_grupo_veiculo,
    sk_patio_retirada, sk_patio_devolucao,
    sk_data_retirada, sk_data_devolucao,
    valor_total_pago, duracao_locacao_dias, quilometragem_rodada
)
SELECT
    sl.id_origem,
    sl.fonte_dados,
    dc.sk_cliente,
    dv.sk_veiculo,
    dg.sk_grupo,
    dpr.sk_patio,
    dpd.sk_patio,
    dtr.sk_tempo,
    dtd.sk_tempo,
    sl.valor_total_calculado,
    sl.duracao_dias,
    sl.km_devolucao - sl.km_retirada
FROM
    staging.stg_locacoes sl
-- Joins para buscar as Surrogate Keys (sk_) das dimensões:
-- 1. Busca a chave do Cliente
JOIN staging.stg_clientes sc ON sl.id_cliente_origem = sc.id_origem AND sl.fonte_dados = sc.fonte_dados
JOIN dwh.Dim_Cliente dc ON sc.documento_unificado = dc.documento

-- 2. Busca a chave do Veículo e do Grupo
JOIN staging.stg_veiculos sv ON sl.id_veiculo_origem = sv.id_origem AND sl.fonte_dados = sv.fonte_dados
JOIN dwh.Dim_Veiculo dv ON sv.placa = dv.placa
JOIN dwh.Dim_GrupoVeiculo dg ON sv.grupo_nome = dg.nome_grupo -- Este JOIN agora funciona, pois a dimensão foi carregada corretamente.

-- 3. Busca as chaves dos Pátios
JOIN dwh.Dim_Patio dpr ON sl.id_patio_retirada_origem = dpr.patio_id_origem AND sl.fonte_dados = dpr.fonte_dados
LEFT JOIN dwh.Dim_Patio dpd ON sl.id_patio_devolucao_origem = dpd.patio_id_origem AND sl.fonte_dados = dpd.fonte_dados

-- 4. Busca as chaves de Tempo
JOIN dwh.Dim_Tempo dtr ON sl.data_retirada::date = dtr.data
LEFT JOIN dwh.Dim_Tempo dtd ON sl.data_devolucao::date = dtd.data

-- Garante a idempotência: se a locação já foi carregada, não faz nada.
ON CONFLICT (locacao_id_origem, fonte_dados) DO NOTHING;
