# Dados Analisados
anos <- 2010:2025
ufs  <- "MT"
siss <- c("SINAN-DENGUE", "SINAN-CHIKUNGUNYA", "SINAN-ZIKA")

combinacoes <- expand.grid(
  uf = ufs,
  sis = siss,
  ano = anos,
  stringsAsFactors = FALSE
)

# Caminhos
path_dados_filtrados <- file.path(
  "data/filtered",
  paste0("dados_", sis, "_", uf_, "_", ano, ".csv")
)
path_dados_processados <- file.path(
  "data/processed",
  paste0("incompletude_", sis, "_", uf_, "_", ano, ".csv")
)
path_plots_por_ano <- file.path(
  "plots",
  paste0("plot_incompletude_", sis, "por_ano", ".png")
)

# Variáveis Analisadas
# modificação requer atualizar incompletude.r
dict_filtro <- c(
  NU_IDADE_N = "Idade",
  CS_SEXO = "Sexo",
  CS_GESTANT = "Gestante",
  CS_RACA = "Raça/Cor",
  CS_ESCOL_N = "Escolaridade"
)
filtro <- names(dict_filtro)
