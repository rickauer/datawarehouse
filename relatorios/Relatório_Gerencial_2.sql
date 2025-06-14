SELECT
    dg.nome_grupo AS grupo_do_veiculo,
    COUNT(fl.sk_locacao) AS total_de_locacoes,
    AVG(fl.duracao_locacao_dias)::numeric(10,1) AS duracao_media_dias,
    MIN(fl.duracao_locacao_dias) AS duracao_minima_dias,
    MAX(fl.duracao_locacao_dias) AS duracao_maxima_dias,
    SUM(fl.valor_total_pago)::numeric(12,2) AS faturamento_total_do_grupo
FROM
    dwh.Fato_Locacao fl
JOIN
    dwh.Dim_GrupoVeiculo dg ON fl.sk_grupo_veiculo = dg.sk_grupo
WHERE
    fl.duracao_locacao_dias IS NOT NULL
GROUP BY
    dg.nome_grupo
ORDER BY
    total_de_locacoes DESC;
