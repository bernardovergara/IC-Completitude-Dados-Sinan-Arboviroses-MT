source("lerdados.r")
source("filtragem")

dados <- ler_dados(entrada)
dados_filtrados <- filtrar_dados(dados, filtro)

exportar_dados(dados_filtrados)