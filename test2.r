library(microdatasus)
library(tidyverse)
library(readr)

setwd("/home/bernardo-vergara/Documentos/IC - Completitude Dados Sinan Arboviroses MT/") # nolint

anos <- 2010:2011

uf_ <- "MT"
sis <- "SINAN-DENGUE"

baixar_dados <- FALSE

# Dados Filtrados
# TALVEZ ADICIONAR
# ID_OCUPA_N - Ocupação
# DOENCA_TRA - Doença relacionada ao trabalho?
# EVOLUCAO - Evolução do caso
filtro <- c(
	NU_IDADE_N = "Idade",
	CS_SEXO = "Sexo",
	CS_GESTANT = "Gestante",
	CS_RACA = "Raça/Cor",
	CS_ESCOL_N = "Escolaridade"
)

importar_dados <- function(baixar_dados) {

	if (baixar_dados) {
		dados <- fetch_datasus(
		year_start = anos[1],
		year_end = anos[length(anos)],
		uf = uf_,
		information_system = sis
		)
		
		if (sis == "SINAN-DENGUE") {
			dados <- process_sinan_dengue(dados)
		}
		
		# write.csv(
		# 	dados,
		# 	paste0("data//raw//", sis, ".csv")
		# )

		return(dados)
	} else {
		dados <- tryCatch(
			read_csv(
				paste0("data//raw//", sis, ".csv"),
				progress = show_progress()
			),
			error = function(e) {
				message("Arquivo não encontrado ou corrompido: ", e$message)
				NULL
			}
		)
		return(dados)
	}
}

filtrar_dados <- function(dados, filtro, ano) {
	dados |>
		filter(grepl(as.character(ano), DT_NOTIFIC)) |>
		select(all_of(names(filtro)))
}

calc_incomp <- function(subconjunto, total) {
	(nrow(subconjunto) / total) * 100
}

calcular_incompletude <- function(dados) {
	# Definição dos filtros de incompletude
  	total <- nrow(df_ano)

	# IDADE (obrigatória)
	NU_IDADE_N_incomp <- dados |>
		filter(is.na(NU_IDADE_N))

	# SEXO (obrigatória)
	CS_SEXO_incomp <- dados |>
		filter(is.na(CS_SEXO) | CS_SEXO == "Ignorado")

	# GESTANT (obrigatória)
	CS_GESTANT_incomp <- dados |>
		filter(CS_SEXO == "Feminino") |>
		filter(
			is.na(CS_GESTANT) |
			CS_GESTANT == "Não se aplica" |
			CS_GESTANT == "Ignorado"
		)
	# Deve considerar "Não se aplica" como incompletude ???

	# RAÇA (essencial)
	CS_RACA_incomp <- dados |>
		filter(is.na(CS_RACA) | CS_RACA == "Ignorado")

	# ESCOLARIDADE (essencial)
	CS_ESCOL_N_incomp <- dados |>
		filter(
			is.na(CS_ESCOL_N) |
			CS_ESCOL_N == "Não se aplica" |
			CS_ESCOL_N == "09" # "Ignorado"
		)

	tibble::tibble(
		variavel = filtro,
		perc_incomp = c(
			calc_incomp(NU_IDADE_N_incomp, total),
			calc_incomp(CS_SEXO_incomp, total),
			calc_incomp(CS_GESTANT_incomp, total),
			calc_incomp(CS_RACA_incomp, total),
			calc_incomp(CS_ESCOL_N_incomp, total)
		)
	)
}


process_incompletude <- function(dados) {
	resultados_filtragem <- list()
	resultados_incompletude <- list()

	message("Iniciando filtragem...")

	for (ano in anos) {
		message(sprintf("Filtrando dados do ano: %s", ano))
		resultados_filtragem[[ano]] <-
			filtrar_dados(dados, filtro, ano)
	}

	message("Iniciando cálculo de incompletude...")

	for (ano in names(resultados_filtragem)) {
		message(sprintf("Calculando incompletude para o ano: %s", ano))
		resultados_incompletude[[ano]] <- 
			calcular_incompletude(resultados_filtragem[[ano]])
	}

	message("Processo concluído.")

	return(resultados_incompletude)
}


dados <- importar_dados(baixar_dados)
resultados <- process_incompletude(dados)


resumo_incompletude <- bind_rows(resultados, .id = "ano") %>%
	mutate(
		ano = as.integer(ano),
		perc_incomp = round(perc_incomp, 2)
	)
plot <- ggplot(resumo_incompletude, aes(x = ano, y = perc_incomp, color = variavel)) +
	geom_line(size = 1) +
	geom_point(size = 2) +
	geom_text(aes(label = sprintf("%.2f", perc_incomp)),
				vjust = -0.5, size = 3) +
	scale_x_continuous(breaks = anos) +
	scale_y_continuous(limits = c(0, 100)) +
	labs(
		title = "Evolução da Incompletude das Variáveis",
		x = "Ano",
		y = "Percentual (%)",
		color = "Variável"
	) +
	theme_minimal(base_size = 14)

print(plot)
# Próximos passos
# + criar gráfico de evolução
# + talvez add coisas sobre trabalho e evolução do caso
