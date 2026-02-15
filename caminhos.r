# definir caminhos para os dados

dados_brutos <- c(
  path = "data/raw",
  pattern = "\\.csv$",
)

dados_filtrados <- c(
  path = "data/processed",
  pattern = "\\.csv$",
  prefix = "filtrado_"
)