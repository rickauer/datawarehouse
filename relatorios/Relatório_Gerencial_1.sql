SELECT
    dp.nome_patio AS patio_de_retirada,
    dg.nome_grupo AS grupo_do_veiculo,
    dv.marca,
    dv.tipo_cambio,
    COUNT(fl.sk_locacao) AS quantidade_de_locacoes
FROM
    dwh.Fato_Locacao fl
JOIN
    dwh.Dim_Patio dp ON fl.sk_patio_retirada = dp.sk_patio
JOIN
    dwh.Dim_Veiculo dv ON fl.sk_veiculo = dv.sk_veiculo
JOIN
    dwh.Dim_GrupoVeiculo dg ON fl.sk_grupo_veiculo = dg.sk_grupo
GROUP BY
    dp.nome_patio,
    dg.nome_grupo,
    dv.marca,
    dv.tipo_cambio
ORDER BY
    quantidade_de_locacoes DESC;
