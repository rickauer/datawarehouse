DROP SCHEMA IF EXISTS fernanda CASCADE;

CREATE SCHEMA fernanda;

SET search_path TO fernanda;

----------------------------------------------------------
-- Authors: 
-- Fernanda Franco Bottecchia - 121042199 
-- Jéssica Martins de Oliveira  - 116058842
-- Kaway Henrique da Rocha Marinho - 119056239
-- Rafael Cardim dos Santos - 120038511
-- Thiago Dias da Costa  - 119019790
----------------------------------------------------------
CREATE TYPE "transmissaotipo" AS ENUM (
  'automatico',
  'manual'
);

CREATE TABLE "Empresa" (
  "id" serial PRIMARY KEY,
  "nome_fantasia" varchar,
  "cnpj" char(14) UNIQUE
);

CREATE TABLE "Patio" (
  "id" serial PRIMARY KEY,
  "empresa_id" int,
  "nome" varchar,
  "endereco" varchar,
  "total_vagas" int
);

CREATE TABLE "GrupoVeiculo" (
  "id" serial PRIMARY KEY,
  "codigo_grupo" varchar,
  "descricao" varchar,
  "preco_diario" decimal
);

CREATE TABLE "Veiculo" (
  "id" serial PRIMARY KEY,
  "grupo_id" int,
  "placa" char(7) UNIQUE,
  "chassi" char(17) UNIQUE,
  "marca" varchar,
  "modelo" varchar,
  "cor" varchar,
  "transmissao" transmissaotipo,
  "ar_condicionado" boolean,
  "ano" smallint,
  "quilometragem" int
);

CREATE TABLE "AcessoriosVeiculo" (
  "veiculo_id" int PRIMARY KEY,
  "cadeira_de_crianca" boolean DEFAULT false,
  "bebe_conforto" boolean DEFAULT false
);

CREATE TABLE "FotoPropaganda" (
  "id" serial PRIMARY KEY,
  "veiculo_id" int,
  "url" text,
  "descricao" varchar
);

CREATE TABLE "Cliente" (
  "id" serial PRIMARY KEY,
  "tipo" varchar,
  "nome_razao" varchar,
  "cpf_cnpj" varchar UNIQUE,
  "email" varchar,
  "telefone1" varchar,
  "telefone2" varchar,
  "endereco" varchar
);

CREATE TABLE "Condutor" (
  "id" serial PRIMARY KEY,
  "cliente_id" int,
  "nome" varchar,
  "cnh" varchar,
  "categoria_cnh" varchar,
  "validade_cnh" date
);

CREATE TABLE "Reserva" (
  "id" serial PRIMARY KEY,
  "cliente_id" int,
  "grupo_id" int,
  "data_prev_retirada" timestamptz,
  "data_prev_devolucao" timestamptz,
  "patio_retirada_id" int,
  "patio_devolucao_id" int,
  "status" varchar
);

CREATE TABLE "Locacao" (
  "id" serial PRIMARY KEY,
  "reserva_id" int,
  "condutor_id" int,
  "veiculo_id" int,
  "data_retirada" timestamptz,
  "data_real_devolucao" timestamptz,
  "patio_saida_id" int,
  "patio_chegada_id" int,
  "km_saida" int,
  "km_chegada" int,
  "status" varchar
);

CREATE TABLE "FotoDevolucao" (
  "id" serial PRIMARY KEY,
  "locacao_id" int,
  "url" text,
  "observacoes" text
);

CREATE TABLE "ProtecaoAdicional" (
  "id" serial PRIMARY KEY,
  "nome" varchar,
  "descricao" varchar,
  "preco_dia" decimal
);

CREATE TABLE "LocacaoProtecao" (
  "locacao_id" int,
  "protecao_id" int,
  PRIMARY KEY ("locacao_id", "protecao_id")
);

CREATE TABLE "Cobranca" (
  "id" serial PRIMARY KEY,
  "locacao_id" int,
  "valor_previsto" decimal,
  "valor_final" decimal,
  "data_cobranca" timestamptz,
  "metodo_pagamento" varchar
);

CREATE TABLE "FilaEspera" (
  "id" serial PRIMARY KEY,
  "cliente_id" int NOT NULL,
  "grupo_id" int,
  "veiculo_id" int,
  "data_solicitacao" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "status" varchar DEFAULT 'ativo'
);

ALTER TABLE "Patio" ADD FOREIGN KEY ("empresa_id") REFERENCES "Empresa" ("id");

ALTER TABLE "Veiculo" ADD FOREIGN KEY ("grupo_id") REFERENCES "GrupoVeiculo" ("id");

ALTER TABLE "FotoPropaganda" ADD FOREIGN KEY ("veiculo_id") REFERENCES "Veiculo" ("id");

ALTER TABLE "Condutor" ADD FOREIGN KEY ("cliente_id") REFERENCES "Cliente" ("id");

ALTER TABLE "Reserva" ADD FOREIGN KEY ("cliente_id") REFERENCES "Cliente" ("id");

ALTER TABLE "Reserva" ADD FOREIGN KEY ("grupo_id") REFERENCES "GrupoVeiculo" ("id");

ALTER TABLE "Reserva" ADD FOREIGN KEY ("patio_retirada_id") REFERENCES "Patio" ("id");

ALTER TABLE "Reserva" ADD FOREIGN KEY ("patio_devolucao_id") REFERENCES "Patio" ("id");

ALTER TABLE "Locacao" ADD FOREIGN KEY ("reserva_id") REFERENCES "Reserva" ("id");

ALTER TABLE "Locacao" ADD FOREIGN KEY ("condutor_id") REFERENCES "Condutor" ("id");

ALTER TABLE "Locacao" ADD FOREIGN KEY ("veiculo_id") REFERENCES "Veiculo" ("id");

ALTER TABLE "Locacao" ADD FOREIGN KEY ("patio_saida_id") REFERENCES "Patio" ("id");

ALTER TABLE "Locacao" ADD FOREIGN KEY ("patio_chegada_id") REFERENCES "Patio" ("id");

ALTER TABLE "FotoDevolucao" ADD FOREIGN KEY ("locacao_id") REFERENCES "Locacao" ("id");

ALTER TABLE "LocacaoProtecao" ADD FOREIGN KEY ("locacao_id") REFERENCES "Locacao" ("id");

ALTER TABLE "LocacaoProtecao" ADD FOREIGN KEY ("protecao_id") REFERENCES "ProtecaoAdicional" ("id");

ALTER TABLE "Cobranca" ADD FOREIGN KEY ("locacao_id") REFERENCES "Locacao" ("id");

ALTER TABLE "AcessoriosVeiculo" ADD FOREIGN KEY ("veiculo_id") REFERENCES "Veiculo" ("id");

ALTER TABLE "FilaEspera" ADD FOREIGN KEY ("cliente_id") REFERENCES "Cliente" ("id");

ALTER TABLE "FilaEspera" ADD FOREIGN KEY ("grupo_id") REFERENCES "GrupoVeiculo" ("id");

ALTER TABLE "FilaEspera" ADD FOREIGN KEY ("veiculo_id") REFERENCES "Veiculo" ("id");
