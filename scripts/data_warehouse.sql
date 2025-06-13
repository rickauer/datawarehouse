CREATE SCHEMA dwh;

-- Tabela de Dimensão de Tempo (deve ser pré-populada com vários anos)
CREATE TABLE dwh.Dim_Tempo (
    sk_tempo SERIAL PRIMARY KEY,
    data DATE NOT NULL UNIQUE,
    dia INT NOT NULL,
    mes INT NOT NULL,
    ano INT NOT NULL,
    trimestre INT NOT NULL,
    nome_mes VARCHAR(20) NOT NULL,
    dia_da_semana VARCHAR(20) NOT NULL
);

-- Tabela de Dimensão de Clientes
CREATE TABLE dwh.Dim_Cliente (
    sk_cliente SERIAL PRIMARY KEY,
    cliente_id_origem VARCHAR(100) NOT NULL, -- Para rastreabilidade
    fonte_dados VARCHAR(20) NOT NULL,       -- Para rastreabilidade
    nome_cliente VARCHAR(255) NOT NULL,
    documento VARCHAR(20) NOT NULL UNIQUE, -- CPF ou CNPJ padronizado
    tipo_pessoa CHAR(1) NOT NULL,          -- 'F' ou 'J'
    cidade_cliente VARCHAR(100),
    estado_cliente VARCHAR(50)
);

-- Tabela de Dimensão de Pátios
CREATE TABLE dwh.Dim_Patio (
    sk_patio SERIAL PRIMARY KEY,
    patio_id_origem VARCHAR(100) NOT NULL, -- Para rastreabilidade
    fonte_dados VARCHAR(20) NOT NULL,
    nome_patio VARCHAR(255) NOT NULL,
    localizacao_completa VARCHAR(500)
);

-- Tabela de Dimensão de Grupos de Veículos
CREATE TABLE dwh.Dim_GrupoVeiculo (
    sk_grupo SERIAL PRIMARY KEY,
    nome_grupo VARCHAR(100) NOT NULL UNIQUE
);

-- Tabela de Dimensão de Veículos
CREATE TABLE dwh.Dim_Veiculo (
    sk_veiculo SERIAL PRIMARY KEY,
    placa VARCHAR(12) NOT NULL UNIQUE,
    chassi VARCHAR(50) NOT NULL UNIQUE,
    marca VARCHAR(100) NOT NULL,
    modelo VARCHAR(100),
    ano_fabricacao INT,
    cor VARCHAR(50),
    tipo_cambio VARCHAR(20) NOT NULL -- Campo padronizado ('Manual', 'Automático')
);

-- Tabela Fato Principal: Locações
CREATE TABLE dwh.Fato_Locacao (
    sk_locacao SERIAL PRIMARY KEY,
    locacao_id_origem VARCHAR(100) NOT NULL, -- Degenerate Dimension
    fonte_dados VARCHAR(20) NOT NULL,      -- Degenerate Dimension

    -- Chaves estrangeiras para as dimensões
    sk_cliente INT NOT NULL REFERENCES dwh.Dim_Cliente(sk_cliente),
    sk_veiculo INT NOT NULL REFERENCES dwh.Dim_Veiculo(sk_veiculo),
    sk_grupo_veiculo INT NOT NULL REFERENCES dwh.Dim_GrupoVeiculo(sk_grupo),
    sk_patio_retirada INT NOT NULL REFERENCES dwh.Dim_Patio(sk_patio),
    sk_patio_devolucao INT REFERENCES dwh.Dim_Patio(sk_patio),
    sk_data_retirada INT NOT NULL REFERENCES dwh.Dim_Tempo(sk_tempo),
    sk_data_devolucao INT REFERENCES dwh.Dim_Tempo(sk_tempo),

    -- Métricas (os fatos numéricos)
    valor_total_pago NUMERIC(12, 2) NOT NULL,
    duracao_locacao_dias INT,
    quilometragem_rodada NUMERIC(10, 2)
);

-- Adicionando um índice para a chave de negócio para buscas mais rápidas durante a carga
CREATE UNIQUE INDEX idx_fato_locacao_origem ON dwh.Fato_Locacao(locacao_id_origem, fonte_dados);
