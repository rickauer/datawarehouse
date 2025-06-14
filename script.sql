-- Tabela: locadora

-- Guilherme Oliveira Rolim Silva - DRE: 122076696

-- Ricardo Lorente Kauer - DRE: 122100500

-- Vinícius Alcântara Gomes Reis de Souza - DRE: 122060831
CREATE TABLE locadora (
    id_locadora          SERIAL PRIMARY KEY,
    nome_locadora        VARCHAR(255) NOT NULL UNIQUE,
    cnpj                 VARCHAR(20)  NOT NULL UNIQUE
);

-- Tabela: patio
CREATE TABLE patio (
    id_patio             SERIAL PRIMARY KEY,
    id_locadora          INTEGER     NOT NULL
        REFERENCES locadora(id_locadora)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    nome_patio           VARCHAR(255) NOT NULL,
    endereco_patio       VARCHAR(500) NOT NULL
);

-- Tabela: vaga
CREATE TABLE vaga (
    id_vaga              SERIAL PRIMARY KEY,
    id_patio             INTEGER     NOT NULL
        REFERENCES patio(id_patio)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    status_vaga          VARCHAR(50)  NOT NULL
);

-- Tabela: grupo_veiculo
CREATE TABLE grupo_veiculo (
    id_grupo_veiculo     SERIAL PRIMARY KEY,
    nome_grupo           VARCHAR(100) NOT NULL UNIQUE,
    faixa_valor          NUMERIC(12,2) NOT NULL
);

-- Tabela: veiculo
CREATE TABLE veiculo (
    id_veiculo                   SERIAL PRIMARY KEY,
    id_grupo_veiculo             INTEGER     NOT NULL
        REFERENCES grupo_veiculo(id_grupo_veiculo)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    id_locadora_proprietaria     INTEGER     NOT NULL
        REFERENCES locadora(id_locadora)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    id_vaga_atual                INTEGER     NULL
        REFERENCES vaga(id_vaga)
        ON UPDATE CASCADE ON DELETE SET NULL,
    placa                        VARCHAR(12)  NOT NULL UNIQUE,
    chassi                       VARCHAR(50)  NOT NULL UNIQUE,
    cor                          VARCHAR(50)  NOT NULL,
    status_veiculo               VARCHAR(50)  NOT NULL,
    mecanizacao                  BOOLEAN     NOT NULL,
    ar_condicionado              BOOLEAN     NOT NULL,
    marca                        VARCHAR(100) NOT NULL
);

-- Tabela: prontuario (registros de manutenção)
CREATE TABLE prontuario (
    id_registro_manutencao       SERIAL PRIMARY KEY,
    id_veiculo                   INTEGER     NOT NULL
        REFERENCES veiculo(id_veiculo)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    data_ultima_manutencao       DATE        NOT NULL,
    estado_conservacao           VARCHAR(100) NOT NULL,
    caracteristica_rodagem       VARCHAR(100) NOT NULL,
    pressao_pneus                NUMERIC(6,2) NOT NULL,
    nivel_oleo                   NUMERIC(6,2) NOT NULL
);

-- Tabela: foto_veiculo
CREATE TABLE foto_veiculo (
    id_foto_veiculo              SERIAL PRIMARY KEY,
    id_veiculo                   INTEGER     NOT NULL
        REFERENCES veiculo(id_veiculo)
        ON UPDATE CASCADE ON DELETE CASCADE,
    tipo_foto                    VARCHAR(50)  NOT NULL,
    data_foto                    TIMESTAMP    NOT NULL
);

-- Tabela: veiculo_acessorio (associativa)
CREATE TABLE veiculo_acessorio (
    id_veiculo_acessorio         SERIAL PRIMARY KEY,
    id_veiculo                   INTEGER     NOT NULL
        REFERENCES veiculo(id_veiculo)
        ON UPDATE CASCADE ON DELETE CASCADE,
    nome                         VARCHAR(100) NOT NULL,
    valor                        NUMERIC(10,2) NOT NULL
);

-- Tabela: cliente (superclasse)
CREATE TABLE cliente (
    id_cliente                   SERIAL PRIMARY KEY,
    tipo_cliente                 VARCHAR(20)   NOT NULL,
    data_cadastro                TIMESTAMP     NOT NULL,
    email                        VARCHAR(255)  NOT NULL UNIQUE,
    telefone_principal           VARCHAR(20)   NOT NULL
);

-- Tabela: pessoa_fisica (subclasse de cliente)
CREATE TABLE pessoa_fisica (
    id_cliente                   INTEGER     PRIMARY KEY
        REFERENCES cliente(id_cliente)
        ON UPDATE CASCADE ON DELETE CASCADE,
    nome_completo                VARCHAR(255) NOT NULL,
    cpf                          VARCHAR(14)  NOT NULL UNIQUE,
    data_nascimento              DATE         NOT NULL
);

-- Tabela: pessoa_juridica (subclasse de cliente)
CREATE TABLE pessoa_juridica (
    id_cliente                   INTEGER     PRIMARY KEY
        REFERENCES cliente(id_cliente)
        ON UPDATE CASCADE ON DELETE CASCADE,
    nome_empresa                 VARCHAR(255) NOT NULL UNIQUE,
    cnpj                         VARCHAR(20)  NOT NULL UNIQUE
);

-- Tabela: motorista
CREATE TABLE motorista (
    id_motorista                 SERIAL PRIMARY KEY,
    id_pessoa_fisica             INTEGER     NOT NULL UNIQUE
        REFERENCES pessoa_fisica(id_cliente)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Tabela: cnh
CREATE TABLE cnh (
    id_cnh                       SERIAL PRIMARY KEY,
    id_motorista                 INTEGER     NOT NULL UNIQUE
        REFERENCES motorista(id_motorista)
        ON UPDATE CASCADE ON DELETE CASCADE,
    numero_cnh                   VARCHAR(20)  NOT NULL UNIQUE,
    categoria_cnh                VARCHAR(5)   NOT NULL,
    data_validade               DATE         NOT NULL
);

-- Tabela: reserva
CREATE TABLE reserva (
    id_reserva                   SERIAL PRIMARY KEY,
    id_veiculo                   INTEGER     NOT NULL
        REFERENCES veiculo(id_veiculo)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    data_hora_reserva_inicio     TIMESTAMP    NOT NULL,
    data_hora_retirada_fim       TIMESTAMP    NOT NULL
);

-- Tabela: contrato (locação)
CREATE TABLE contrato (
    id_contrato                  SERIAL PRIMARY KEY,
    id_reserva                   INTEGER     NULL
        REFERENCES reserva(id_reserva)
        ON UPDATE CASCADE ON DELETE SET NULL,
    id_cliente                   INTEGER     NOT NULL
        REFERENCES cliente(id_cliente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    id_locadora                  INTEGER     NOT NULL
        REFERENCES locadora(id_locadora)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    id_motorista                 INTEGER     NOT NULL
        REFERENCES motorista(id_motorista)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    id_veiculo                   INTEGER     NOT NULL
        REFERENCES veiculo(id_veiculo)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    id_patio_retirada            INTEGER     NOT NULL
        REFERENCES patio(id_patio)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    id_patio_devolucao_efetiva   INTEGER     NULL
        REFERENCES patio(id_patio)
        ON UPDATE CASCADE ON DELETE SET NULL,
    data_hora_contrato           TIMESTAMP    NOT NULL,
    status_locacao               VARCHAR(50)  NOT NULL
);

-- Tabela: protecao_adicional (associativa Contrato ↔ Proteção Adicional)
CREATE TABLE protecao_adicional (
    id_protecao_adicional        SERIAL PRIMARY KEY,
    id_contrato                  INTEGER     NOT NULL
        REFERENCES contrato(id_contrato)
        ON UPDATE CASCADE ON DELETE CASCADE,
    nome_protecao                VARCHAR(100) NOT NULL,
    valor_cobrado                NUMERIC(10,2) NOT NULL
);

-- Tabela: cobranca (fatura)
CREATE TABLE cobranca (
    id_fatura                    SERIAL PRIMARY KEY,
    id_contrato                  INTEGER     NOT NULL
        REFERENCES contrato(id_contrato)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    numero_fatura                VARCHAR(50)  NOT NULL UNIQUE,
    data_emissao                 DATE         NOT NULL,
    valor                        NUMERIC(12,2) NOT NULL,
    status_fatura                VARCHAR(50)  NOT NULL
);
