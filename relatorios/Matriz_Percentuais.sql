-- Guilherme Oliveira Rolim Silva - DRE: 122076696

-- Ricardo Lorente Kauer - DRE: 122100500

-- Vinícius Alcântara Gomes Reis de Souza - DRE: 122060831

WITH Movimentacoes AS (
    -- Conta o número de viagens entre cada par de pátios
    SELECT
        p_retirada.nome_patio AS patio_retirada,
        p_devolucao.nome_patio AS patio_devolucao,
        COUNT(fl.sk_locacao) AS total_viagens
    FROM
        dwh.Fato_Locacao fl
    JOIN
        dwh.Dim_Patio p_retirada ON fl.sk_patio_retirada = p_retirada.sk_patio
    JOIN
        dwh.Dim_Patio p_devolucao ON fl.sk_patio_devolucao = p_devolucao.sk_patio
    WHERE
        fl.sk_patio_devolucao IS NOT NULL
    GROUP BY
        p_retirada.nome_patio,
        p_devolucao.nome_patio
)
-- Calcula o percentual de cada movimentação sobre o total de saídas do pátio de retirada
SELECT
    m.patio_retirada,
    m.patio_devolucao,
    m.total_viagens,
    (m.total_viagens * 100.0 / SUM(m.total_viagens) OVER (PARTITION BY m.patio_retirada))::numeric(5, 2) AS percentual_movimentacao
FROM
    Movimentacoes m
ORDER BY
    m.patio_retirada,
    percentual_movimentacao DESC;
