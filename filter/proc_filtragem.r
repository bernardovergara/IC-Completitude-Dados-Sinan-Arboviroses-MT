source("lerdados.r")
source("filter/filtragem.r")

dados <- ler_dados(entrada)
dados_filtrados <- filtrar_dados(dados, filtro)

exportar_dados(dados_filtrados)