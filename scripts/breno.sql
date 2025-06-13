-- Passo 1: Limpar o ambiente específico (segurança para re-execução)
DROP SCHEMA IF EXISTS breno CASCADE;

-- Passo 2: Criar o schema novamente
CREATE SCHEMA breno;

-- Passo 3: DEFINIR O CONTEXTO DE EXECUÇÃO
-- Todos os comandos abaixo serão executados dentro do schema 'rickauer'
SET search_path TO breno;


/*
Grupo: Breno Valente Manhães - 122038517; João Pedro Moretti Fontes Ferreira - 122081366; Murilo Jorge de Figueiredo - 122079597
*/


CREATE TABLE CLIENTE (
  cliente_id     SERIAL PRIMARY KEY,
  tipo           CHAR(1)       NOT NULL CHECK (tipo IN ('F','J')),
  nome_razao     VARCHAR(100)  NOT NULL,
  cpf_cnpj       CHAR(14)      NOT NULL UNIQUE,
  telefone       VARCHAR(20),
  email          VARCHAR(100)
);

CREATE TABLE CONDUTOR (
  condutor_id    SERIAL PRIMARY KEY,
  cliente_id     INT           NOT NULL,
  nome           VARCHAR(100)  NOT NULL,
  cnh_numero     VARCHAR(20)   NOT NULL UNIQUE,
  cnh_categoria  VARCHAR(2)    NOT NULL,
  cnh_validade   DATE          NOT NULL,
  FOREIGN KEY (cliente_id) REFERENCES CLIENTE(cliente_id)
);

CREATE TABLE GRUPO_VEICULO (
  grupo_id       SERIAL PRIMARY KEY,
  nome           VARCHAR(50)   NOT NULL UNIQUE,
  tarifa_diaria  DECIMAL(10,2) NOT NULL
);

CREATE TABLE VEICULO (
  veiculo_id     SERIAL PRIMARY KEY,
  grupo_id       INT           NOT NULL,
  placa          CHAR(7)       NOT NULL UNIQUE,
  chassis        VARCHAR(17)   NOT NULL UNIQUE,
  marca          VARCHAR(50)   NOT NULL,
  modelo         VARCHAR(50)   NOT NULL,
  cor            VARCHAR(30),
  mecanizacao    VARCHAR(10)   NOT NULL CHECK (mecanizacao IN ('Manual','Auto')),
  ar_condicionado BOOLEAN       NOT NULL,
  cadeirinha     BOOLEAN       NOT NULL,
  FOREIGN KEY (grupo_id) REFERENCES GRUPO_VEICULO(grupo_id)
);

CREATE TABLE PRONTUARIO (
  prontuario_id  SERIAL PRIMARY KEY,
  veiculo_id     INT           NOT NULL,
  data_registro  TIMESTAMP     NOT NULL,
  descricao      TEXT,
  FOREIGN KEY (veiculo_id) REFERENCES VEICULO(veiculo_id)
);

CREATE TABLE FOTO_VEICULO (
  foto_id        SERIAL PRIMARY KEY,
  veiculo_id     INT           NOT NULL,
  url            VARCHAR(255)  NOT NULL,
  tipo           VARCHAR(20)   NOT NULL,
  FOREIGN KEY (veiculo_id) REFERENCES VEICULO(veiculo_id)
);

CREATE TABLE PATIO (
  patio_id       SERIAL PRIMARY KEY,
  nome           VARCHAR(100)  NOT NULL UNIQUE,
  localizacao    VARCHAR(150)
);

CREATE TABLE VAGA (
  vaga_id        SERIAL PRIMARY KEY,
  patio_id       INT           NOT NULL,
  codigo         VARCHAR(10)   NOT NULL,
  FOREIGN KEY (patio_id) REFERENCES PATIO(patio_id)
);

CREATE TABLE RESERVA (
  reserva_id           SERIAL PRIMARY KEY,
  cliente_id           INT           NOT NULL,
  grupo_id             INT           NOT NULL,
  data_inicio          DATE          NOT NULL,
  data_fim_previsto    DATE          NOT NULL,
  patio_retirada_id    INT           NOT NULL,
  status               VARCHAR(20)   NOT NULL CHECK (status IN ('Ativa','Cancelada','Concluída')),
  FOREIGN KEY (cliente_id)        REFERENCES CLIENTE(cliente_id),
  FOREIGN KEY (grupo_id)          REFERENCES GRUPO_VEICULO(grupo_id),
  FOREIGN KEY (patio_retirada_id) REFERENCES PATIO(patio_id)
);

CREATE TABLE LOCACAO (
  locacao_id            SERIAL PRIMARY KEY,
  reserva_id            INT,
  condutor_id           INT           NOT NULL,
  veiculo_id            INT           NOT NULL,
  data_retirada         TIMESTAMP     NOT NULL,
  patio_saida_id        INT           NOT NULL,
  data_devolucao_prevista TIMESTAMP   NOT NULL,
  data_devolucao_real   TIMESTAMP,
  patio_chegada_id      INT,
  estado_entrega        TEXT,
  estado_devolucao      TEXT,
  FOREIGN KEY (reserva_id)       REFERENCES RESERVA(reserva_id),
  FOREIGN KEY (condutor_id)      REFERENCES CONDUTOR(condutor_id),
  FOREIGN KEY (veiculo_id)       REFERENCES VEICULO(veiculo_id),
  FOREIGN KEY (patio_saida_id)   REFERENCES PATIO(patio_id),
  FOREIGN KEY (patio_chegada_id) REFERENCES PATIO(patio_id)
);

CREATE TABLE PROTECAO_ADICIONAL (
  protecao_id    SERIAL PRIMARY KEY,
  descricao      VARCHAR(100)  NOT NULL
);

CREATE TABLE LOCACAO_PROTECAO (
  locacao_id     INT           NOT NULL,
  protecao_id    INT           NOT NULL,
  PRIMARY KEY (locacao_id, protecao_id),
  FOREIGN KEY (locacao_id)  REFERENCES LOCACAO(locacao_id),
  FOREIGN KEY (protecao_id) REFERENCES PROTECAO_ADICIONAL(protecao_id)
);

CREATE TABLE COBRANCA (
  cobranca_id      SERIAL PRIMARY KEY,
  locacao_id       INT           NOT NULL,
  data_cobranca    TIMESTAMP     NOT NULL,
  valor_base       DECIMAL(12,2) NOT NULL,
  valor_final      DECIMAL(12,2),
  status_pagamento VARCHAR(20)   NOT NULL CHECK (status_pagamento IN ('Pendente','Pago','Cancelado')),
  FOREIGN KEY (locacao_id) REFERENCES LOCACAO(locacao_id)
);
