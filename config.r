# Dados Analisados
anos <- 2010:2010
ufs  <- "MT"
siss <- c("SINAN-DENGUE", "SINAN-CHIKUNGUNYA", "SINAN-ZIKA")

combinacoes <- expand.grid(
  uf = ufs,
  sis = siss,
  ano = anos,
  stringsAsFactors = FALSE
)

# Caminhos - Função auxiliar para construir dinâmicamente
path_dados_filtrados_f <- function(sis, uf_, ano) {
  file.path("data/filtered", paste0("dados_", sis, "_", uf_, "_", ano, ".csv"))
}

path_dados_processados_f <- function(sis, uf_, ano) {
  file.path("data/processed", paste0("incompletude_", sis, "_", uf_, "_", ano, ".csv"))
}

path_plots_por_ano_f <- function(sis) {
  file.path("plots", paste0("plot_incompletude_", sis, "_por_ano.png"))
}

# Variáveis Analisadas
dict_filtro <- c(
  NU_IDADE_N = "Idade",
  CS_SEXO = "Sexo",
  CS_GESTANT = "Gestante",
  CS_RACA = "Raça/Cor",
  CS_ESCOL_N = "Escolaridade"
)
filtro <- names(dict_filtro)
