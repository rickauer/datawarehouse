/**************************************************************
 * SCRIPT DE EXTRAÇÃO DE DADOS (DML) - CORRIGIDO
 **************************************************************/

-- (Boa prática) Limpa os dados de uma execução anterior sem apagar a estrutura das tabelas.
TRUNCATE TABLE staging.stg_clientes, staging.stg_veiculos, staging.stg_locacoes, staging.stg_patios, staging.stg_cobrancas;


----------------------------------------------------------------------------------
-- extracao_fernanda.sql (correto, permanece como está)
----------------------------------------------------------------------------------
-- (código da extração de Fernanda aqui... sem alterações)
INSERT INTO staging.stg_clientes (id_origem, nome, cpf, cnpj, tipo_pessoa, cidade, email, fonte_dados)
SELECT "id"::text, "nome_razao", CASE WHEN "tipo" = 'PF' THEN "cpf_cnpj" END, CASE WHEN "tipo" = 'PJ' THEN "cpf_cnpj" END, "tipo", "endereco", "email", 'FERNANDA' FROM fernanda."Cliente";
INSERT INTO staging.stg_veiculos (id_origem, placa, chassi, marca, modelo, ano, cor, mecanizacao_varchar, grupo_nome, fonte_dados)
SELECT v."id"::text, v."placa", v."chassi", v."marca", v."modelo", v."ano", v."cor", v."transmissao"::varchar, gv."codigo_grupo", 'FERNANDA' FROM fernanda."Veiculo" v JOIN fernanda."GrupoVeiculo" gv ON v."grupo_id" = gv."id";
INSERT INTO staging.stg_patios(id_origem, nome, endereco, fonte_dados)
SELECT "id"::text, "nome", "endereco", 'FERNANDA' FROM fernanda."Patio";
INSERT INTO staging.stg_locacoes (id_origem, id_cliente_origem, id_veiculo_origem, id_patio_retirada_origem, id_patio_devolucao_origem, data_retirada, data_devolucao, km_retirada, km_devolucao, valor_final, fonte_dados)
SELECT l."id"::text, r."cliente_id"::text, l."veiculo_id"::text, l."patio_saida_id"::text, l."patio_chegada_id"::text, l."data_retirada", l."data_real_devolucao", l."km_saida", l."km_chegada", c."valor_final", 'FERNANDA' FROM fernanda."Locacao" l LEFT JOIN fernanda."Cobranca" c ON l."id" = c."locacao_id" LEFT JOIN fernanda."Reserva" r ON l."reserva_id" = r."id" WHERE r."status" = 'Concluida';


----------------------------------------------------------------------------------
-- extracao_rickauer.sql (correto, permanece como está)
----------------------------------------------------------------------------------
-- (código da extração de Rickauer aqui... sem alterações)
INSERT INTO staging.stg_clientes (id_origem, nome, cpf, tipo_pessoa, fonte_dados) SELECT c.id_cliente, pf.nome_completo, pf.cpf, 'F', 'RICKAUER' FROM rickauer.cliente c JOIN rickauer.pessoa_fisica pf ON c.id_cliente = pf.id_cliente;
INSERT INTO staging.stg_clientes (id_origem, nome, cnpj, tipo_pessoa, fonte_dados) SELECT c.id_cliente, pj.nome_empresa, pj.cnpj, 'J', 'RICKAUER' FROM rickauer.cliente c JOIN rickauer.pessoa_juridica pj ON c.id_cliente = pj.id_cliente;
INSERT INTO staging.stg_veiculos (id_origem, placa, chassi, marca, cor, mecanizacao_bool, grupo_nome, fonte_dados) SELECT v.id_veiculo, v.placa, v.chassi, v.marca, v.cor, v.mecanizacao, gv.nome_grupo, 'RICKAUER' FROM rickauer.veiculo v JOIN rickauer.grupo_veiculo gv ON v.id_grupo_veiculo = gv.id_grupo_veiculo;
INSERT INTO staging.stg_locacoes (id_origem, id_cliente_origem, id_veiculo_origem, id_patio_retirada_origem, id_patio_devolucao_origem, data_retirada, fonte_dados) SELECT id_contrato, id_cliente, id_veiculo, id_patio_retirada, id_patio_devolucao_efetiva, data_hora_contrato, 'RICKAUER' FROM rickauer.contrato;
INSERT INTO staging.stg_cobrancas (id_locacao_origem, valor_total, fonte_dados) SELECT id_contrato, valor, 'RICKAUER' FROM rickauer.cobranca;


----------------------------------------------------------------------------------
-- extracao_breno.sql (SEÇÃO CORRIGIDA)
----------------------------------------------------------------------------------
INSERT INTO staging.stg_clientes (id_origem, nome, cpf, cnpj, tipo_pessoa, fonte_dados)
SELECT cliente_id::text, nome_razao, CASE WHEN tipo = 'F' THEN cpf_cnpj END, CASE WHEN tipo = 'J' THEN cpf_cnpj END, tipo, 'BRENO' FROM breno.CLIENTE;

INSERT INTO staging.stg_veiculos (id_origem, placa, chassi, marca, modelo, cor, mecanizacao_varchar, grupo_nome, fonte_dados)
SELECT v.veiculo_id::text, v.placa, v.chassis, v.marca, v.modelo, v.cor, v.mecanizacao, gv.nome, 'BRENO'
FROM breno.VEICULO v JOIN breno.GRUPO_VEICULO gv ON v.grupo_id = gv.grupo_id;

-- Consulta de Locação corrigida
INSERT INTO staging.stg_locacoes (id_origem, id_cliente_origem, id_veiculo_origem, id_patio_retirada_origem, id_patio_devolucao_origem, data_retirada, data_devolucao, fonte_dados)
SELECT
    l.locacao_id::text,
    r.cliente_id::text,
    l.veiculo_id::text,
    l.patio_saida_id::text,
    l.patio_chegada_id::text,
    l.data_retirada,
    l.data_devolucao_real,
    'BRENO'
FROM breno.LOCACAO l
JOIN breno.RESERVA r ON l.reserva_id = r.reserva_id
WHERE r.status = 'Concluída'; -- << CORREÇÃO APLICADA AQUI

INSERT INTO staging.stg_cobrancas (id_locacao_origem, valor_total, fonte_dados)
SELECT locacao_id::text, valor_final, 'BRENO' FROM breno.COBRANCA;

----------------------------------------------------------------------------------
-- extracao_jpsales.sql (correto, permanece como está)
----------------------------------------------------------------------------------
-- (código da extração de JPSales aqui... sem alterações)
INSERT INTO staging.stg_clientes (id_origem, nome, cpf, cnpj, tipo_pessoa, cidade, estado, fonte_dados) SELECT cliente_id, nome_completo, CASE WHEN tipo_pessoa = 'F' THEN cpf_cnpj END, CASE WHEN tipo_pessoa = 'J' THEN cpf_cnpj END, tipo_pessoa, endereco_cidade, endereco_estado, 'JPSALES' FROM jpsales.clientes;
INSERT INTO staging.stg_veiculos (id_origem, placa, chassi, marca, modelo, ano, cor, mecanizacao_varchar, grupo_nome, fonte_dados) SELECT v.veiculo_id, v.placa, v.chassi, v.marca, v.modelo, v.ano_fabricacao, v.cor, v.mecanizacao, gv.nome_grupo, 'JPSALES' FROM jpsales.veiculos v JOIN jpsales.grupos_veiculos gv ON v.grupo_id = gv.grupo_id;
INSERT INTO staging.stg_locacoes (id_origem, id_cliente_origem, id_veiculo_origem, id_patio_retirada_origem, id_patio_devolucao_origem, data_retirada, data_devolucao, valor_final, fonte_dados) SELECT locacao_id, cliente_id, veiculo_id, patio_retirada_id, patio_devolucao_id, data_retirada_real, data_devolucao_real, valor_total_final, 'JPSALES' FROM jpsales.locacoes WHERE data_devolucao_real IS NOT NULL;
