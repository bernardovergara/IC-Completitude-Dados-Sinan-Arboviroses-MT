# definir caminhos para os dados

dados_brutos <- list(
  path = "data/raw",
  pattern = "\\.csv$"
)

dados_filtrados <- list(
  path = "data/processed",
  pattern = "\\.csv$",
  prefix = "filtrado_"
)