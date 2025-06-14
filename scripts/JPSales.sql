DROP SCHEMA IF EXISTS jpsales CASCADE;

CREATE SCHEMA jpsales;

SET search_path TO jpsales;

-- Avaliação 02: Modelagem de Data Warehouse
-- Parte 1: Script DDL do Sistema Transacional
-- Grupo:
-- Augusto Fernandes Nodari 						DRE: 121131778 
-- Henrique Almico Dias da Silva  					DRE: 124238228
-- João Pedro de Faria Sales  						DRE: 121056457 
-- Vitor Rayol Taranto                              DRE: 121063585

-- Tabela para os Grupos (Categorias) de Veículos
CREATE TABLE grupos_veiculos (
    grupo_id SERIAL PRIMARY KEY,
    nome_grupo VARCHAR(50) NOT NULL UNIQUE,
    descricao TEXT,
    valor_diaria_base DECIMAL(10, 2) NOT NULL CHECK (valor_diaria_base > 0)
);

-- Tabela para os Pátios de estacionamento
CREATE TABLE patios (
    patio_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    endereco VARCHAR(255) NOT NULL,
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabela para as Vagas dentro de cada pátio
CREATE TABLE vagas (
    vaga_id SERIAL PRIMARY KEY,
    patio_id INT NOT NULL REFERENCES patios(patio_id),
    codigo_vaga VARCHAR(20) NOT NULL,
    ocupada BOOLEAN DEFAULT FALSE,
    UNIQUE(patio_id, codigo_vaga)
);

-- Tabela principal da frota de veículos
CREATE TABLE veiculos (
    veiculo_id SERIAL PRIMARY KEY,
    placa VARCHAR(10) NOT NULL UNIQUE,
    chassi VARCHAR(17) NOT NULL UNIQUE,
    grupo_id INT NOT NULL REFERENCES grupos_veiculos(grupo_id),
    vaga_atual_id INT REFERENCES vagas(vaga_id) UNIQUE, -- Um veículo só pode estar em uma vaga
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    cor VARCHAR(30) NOT NULL,
    ano_fabricacao INT NOT NULL,
    mecanizacao VARCHAR(20) NOT NULL CHECK (mecanizacao IN ('Manual', 'Automática')),
    ar_condicionado BOOLEAN NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Disponível' CHECK (status IN ('Disponível', 'Alugado', 'Manutenção'))
);

-- Tabela de Clientes (Pessoa Física ou Jurídica)
CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    nome_completo VARCHAR(255) NOT NULL,
    cpf_cnpj VARCHAR(18) NOT NULL UNIQUE,
    tipo_pessoa CHAR(1) NOT NULL CHECK (tipo_pessoa IN ('F', 'J')),
    email VARCHAR(100) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    endereco_cidade VARCHAR(100),
    endereco_estado VARCHAR(50),
    data_cadastro TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Motoristas (condutores autorizados)
CREATE TABLE motoristas (
    motorista_id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL REFERENCES clientes(cliente_id), -- Cliente responsável pelo motorista
    nome_completo VARCHAR(255) NOT NULL,
    cnh VARCHAR(11) NOT NULL UNIQUE,
    cnh_categoria VARCHAR(5) NOT NULL,
    cnh_validade DATE NOT NULL
);

-- Tabela de Reservas
CREATE TABLE reservas (
    reserva_id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL REFERENCES clientes(cliente_id),
    grupo_id INT NOT NULL REFERENCES grupos_veiculos(grupo_id),
    patio_retirada_id INT NOT NULL REFERENCES patios(patio_id),
    data_reserva TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    data_prevista_retirada TIMESTAMP WITH TIME ZONE NOT NULL,
    data_prevista_devolucao TIMESTAMP WITH TIME ZONE NOT NULL,
    status_reserva VARCHAR(20) DEFAULT 'Ativa' CHECK (status_reserva IN ('Ativa', 'Cancelada', 'Concluída')),
    CHECK (data_prevista_devolucao > data_prevista_retirada)
);

-- Tabela de Locações (Aluguéis)
CREATE TABLE locacoes (
    locacao_id SERIAL PRIMARY KEY,
    reserva_id INT UNIQUE REFERENCES reservas(reserva_id), -- Uma reserva gera uma locação
    cliente_id INT NOT NULL REFERENCES clientes(cliente_id),
    motorista_id INT NOT NULL REFERENCES motoristas(motorista_id),
    veiculo_id INT NOT NULL REFERENCES veiculos(veiculo_id),
    patio_retirada_id INT NOT NULL REFERENCES patios(patio_id),
    patio_devolucao_id INT REFERENCES patios(patio_id),
    data_retirada_real TIMESTAMP WITH TIME ZONE NOT NULL,
    data_devolucao_prevista TIMESTAMP WITH TIME ZONE NOT NULL,
    data_devolucao_real TIMESTAMP WITH TIME ZONE,
    valor_total_previsto DECIMAL(10, 2) NOT NULL,
    valor_total_final DECIMAL(10, 2),
    protecoes_adicionais TEXT,
    CHECK (data_devolucao_prevista > data_retirada_real),
    CHECK (data_devolucao_real IS NULL OR data_devolucao_real > data_retirada_real)
);

-- Tabela de Cobranças
CREATE TABLE cobrancas (
    cobranca_id SERIAL PRIMARY KEY,
    locacao_id INT NOT NULL REFERENCES locacoes(locacao_id),
    valor DECIMAL(10, 2) NOT NULL,
    data_emissao TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    data_vencimento DATE NOT NULL,
    data_pagamento DATE,
    status_pagamento VARCHAR(20) NOT NULL DEFAULT 'Pendente' CHECK (status_pagamento IN ('Pendente', 'Pago', 'Atrasado'))
);

-- Tabelas Auxiliares
CREATE TABLE acessorios (
    acessorio_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT
);

CREATE TABLE veiculos_acessorios (
    veiculo_id INT NOT NULL REFERENCES veiculos(veiculo_id),
    acessorio_id INT NOT NULL REFERENCES acessorios(acessorio_id),
    PRIMARY KEY (veiculo_id, acessorio_id)
);

CREATE TABLE prontuarios_veiculos (
    prontuario_id SERIAL PRIMARY KEY,
    veiculo_id INT NOT NULL REFERENCES veiculos(veiculo_id),
    data_ocorrencia DATE NOT NULL,
    tipo VARCHAR(50) NOT NULL CHECK (tipo IN ('Manutenção Preventiva', 'Manutenção Corretiva', 'Revisão', 'Avaria')),
    descricao TEXT NOT NULL,
    custo DECIMAL(10, 2)
);

CREATE TABLE fotos_veiculos (
    foto_id SERIAL PRIMARY KEY,
    veiculo_id INT NOT NULL REFERENCES veiculos(veiculo_id),
    url_foto VARCHAR(255) NOT NULL,
    tipo VARCHAR(50) CHECK (tipo IN ('Propaganda', 'Entrega', 'Devolução')),
    data_upload TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
