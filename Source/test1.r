# (MS, Dados para Vigilância, 2024, p.55)
# VARIÁVEIS DE NOTIFICAÇÃO INDIVIDUAL
# Nome, data de nascimento, idade, sexo, raça/cor, escolaridade,
# número do cartão SUS, nome da mãe e se gestante.

library(tidyverse)
library(readr)

# nolint start: indentation_linter

importar_dados <- FALSEr <- process_incompletu

if (importar_dados) {
	setwd("/home/bernardo-vergara/Documentos/IC - Completitude Dados Sinan Arboviroses MT/") # nolint

	dados_dengue_mt <- read_csv("data/raw/dengue_mt.csv",
      							progress = show_progress())
# colocar aqui um try

# Dados Filtrados
vars_interesse <- c(
    "NU_IDADE_N",   # Idade
    "CS_SEXO",      # Sexo
    "CS_GESTANT",   # Gestante
    "CS_RACA",      # Raça/Cor
    "CS_ESCOL_N"    # Escolaridade
)

# TALVEZ ADD
# ID_OCUPA_N - Ocupação
# DOENCA_TRA - Doença relacionada ao trabalho?
# EVOLUCAO - Evolução do caso

dados_dengue_mt_filtrados <- dados_dengue_mt |>
  	select(all_of(vars_interesse))

write.csv( dados_dengue_mt_filtrados,
        "data//raw//dengue_mt_filtrados.csv")
}

dados <- read.csv("data//raw//dengue_mt_filtrados.csv")


# IDADE (obrigatória)

NU_IDADE_N_incomp <- dados |>
	filter(NU_IDADE_N == NA)


# SEXO (obrigatória) (Masculino, Feminino, Ignorado)

CS_SEXO_incomp <- dados |>
	filter(is.na(CS_SEXO) | CS_SEXO == "Ignorado")


# GESTANT ? (obrigatória)

# (1 Tri, 2 Tri, 3 Tri, Idade gestacional ignorada)
# (Não, Não se aplica, Ignorado)

# Deve considerar "Não se aplica" como incompletude ???

CS_GESTANT_incomp <- dados |>
	filter(CS_SEXO == "Feminino") |>
	filter(
		is.na(CS_GESTANT) |
		CS_GESTANT == "Não se aplica" |
		CS_GESTANT == "Ignorado"
		)


# RAÇA (essencial)

# (Branca, Preta, Amarela, Parda, Indígena, Ignorado)

CS_RACA_incomp <- dados |>
	filter(is.na(CS_RACA) | CS_RACA == "Ignorado")


# ESCOLARIDADE (essencial)

# (Ign/Branco, Analfabeto, 1 a 4 série incompleta do EF, 
# 1 a 4 série completa do EF, 5 a 8 série incompleta do EF, 
# Ensino fundamental completo, Ensino médio incompleto, 
# Ensino médio completo, Educação superior incompleta, 
# Educação superior completa, Não se aplica)

CS_ESCOL_N_incomp <- dados |>
	filter(
		is.na(CS_ESCOL_N) |
		CS_ESCOL_N == "Não se aplica" |
		CS_ESCOL_N == "09" # Corresponde ao Ignorado
		)

# CALC PERC
calc_incomp <- function(incomp, total) {
  (nrow(incomp) / nrow(total)) * 100
}

NU_IDADE_N_incomp_perc   <- calc_incomp(NU_IDADE_N_incomp, dados)
CS_SEXO_incomp_perc      <- calc_incomp(CS_SEXO_incomp, dados)
CS_GESTANT_incomp_perc   <- calc_incomp(CS_GESTANT_incomp, dados)
CS_RACA_incomp_perc      <- calc_incomp(CS_RACA_incomp, dados)
CS_ESCOL_N_incomp_perc   <- calc_incomp(CS_ESCOL_N_incomp, dados)

# PLOT TEMPORÁRIO
df_incomp <- tibble::tibble(
	variavel = c("Idade", "Sexo", "Gestante", "Raça/Cor", "Escolaridade"),
	perc_incomp = c(
		NU_IDADE_N_incomp_perc,
		CS_SEXO_incomp_perc,
		CS_GESTANT_incomp_perc,
		CS_RACA_incomp_perc,
		CS_ESCOL_N_incomp_perc
	)
)
temp_plot <- ggplot(df_incomp, aes(x = reorder(variavel, perc_incomp), 
                      y = perc_incomp)) +
    geom_col(fill = "steelblue") +
    geom_text(aes(label = sprintf("%.2f", perc_incomp)),
              vjust = -0.5, size = 4) +
    scale_y_continuous(limits = c(0, 100)) +
    labs(
        title = "Percentual de Incompletude por Variável",
        x = "Variável",
        y = "Incompletude (%)"
    ) +
    theme_minimal(base_size = 14)

print(temp_plot)

# nolint end

# Próximos passos
# + tabela com as datas (ANOS/ DT_NOTIFIC), para descrever evolução
# + criar gráfico de evolução
# + talvez add coisas sobre trabalho e evolução do caso