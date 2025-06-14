SELECT
    dg.nome_grupo AS grupo_do_veiculo,
    dc.cidade_cliente,
    COUNT(fl.sk_locacao) AS quantidade_de_locacoes
FROM
    dwh.Fato_Locacao fl
JOIN
    dwh.Dim_GrupoVeiculo dg ON fl.sk_grupo_veiculo = dg.sk_grupo
JOIN
    dwh.Dim_Cliente dc ON fl.sk_cliente = dc.sk_cliente
WHERE
    dc.cidade_cliente IS NOT NULL
GROUP BY
    dg.nome_grupo,
    dc.cidade_cliente
ORDER BY
    quantidade_de_locacoes DESC,
    dg.nome_grupo;

