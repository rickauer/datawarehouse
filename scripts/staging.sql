CREATE SCHEMA staging;

CREATE TABLE staging.stg_clientes (
    id_origem VARCHAR(100),
    nome VARCHAR(255),
    cpf VARCHAR(20),
    cnpj VARCHAR(20),
    tipo_pessoa CHAR(2),
    cidade VARCHAR(100),
    estado VARCHAR(50),
    email VARCHAR(255),
    fonte_dados VARCHAR(20)
);

CREATE TABLE staging.stg_veiculos (
    id_origem VARCHAR(100),
    placa VARCHAR(12),
    chassi VARCHAR(50),
    marca VARCHAR(100),
    modelo VARCHAR(100),
    ano INT,
    cor VARCHAR(50),
    grupo_nome VARCHAR(100),
    mecanizacao_bool BOOLEAN,
    mecanizacao_varchar VARCHAR(20),
    fonte_dados VARCHAR(20)
);

CREATE TABLE staging.stg_locacoes (
    id_origem VARCHAR(100),
    id_cliente_origem VARCHAR(100),
    id_veiculo_origem VARCHAR(100),
    id_patio_retirada_origem VARCHAR(100),
    id_patio_devolucao_origem VARCHAR(100),
    data_retirada TIMESTAMP,
    data_devolucao TIMESTAMP,
    km_retirada NUMERIC(10, 2),
    km_devolucao NUMERIC(10, 2),
    valor_final NUMERIC(12, 2),
    fonte_dados VARCHAR(20)
);

CREATE TABLE staging.stg_patios (
    id_origem VARCHAR(100),
    nome VARCHAR(255),
    endereco VARCHAR(500),
    fonte_dados VARCHAR(20)
);

CREATE TABLE staging.stg_cobrancas (
    id_locacao_origem VARCHAR(100),
    valor_total NUMERIC(12, 2),
    fonte_dados VARCHAR(20)
);
