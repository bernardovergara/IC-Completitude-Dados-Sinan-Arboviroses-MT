library(tidyverse)

calc_incomp <- function(subconjunto, total) {
  (nrow(subconjunto) / total) * 100
}

calcular_incompletude <- function(dados) {
  # Definição dos filtros de incompletude
  total <- nrow(dados)

  # IDADE (obrigatória)
  nu_idade_n_incomp <- dados |>
    dplyr::filter(is.na(NU_IDADE_N))

  # SEXO (obrigatória)
  cs_sexo_incomp <- dados |>
    dplyr::filter(is.na(CS_SEXO) | CS_SEXO == "Ignorado")

  # GESTANT (obrigatória)
  cs_gestant_incomp <- dados |>
    dplyr::filter(CS_SEXO == "Feminino") |>
    dplyr::filter(
      is.na(CS_GESTANT) |
        CS_GESTANT == "Não se aplica" |
        CS_GESTANT == "Ignorado"
    )

  # RAÇA (essencial)
  cs_raca_incomp <- dados |>
    dplyr::filter(is.na(CS_RACA) | CS_RACA == "Ignorado")

  # ESCOLARIDADE (essencial)
  cs_escol_n_incomp <- dados |>
    dplyr::filter(
      is.na(CS_ESCOL_N) |
        CS_ESCOL_N == "Não se aplica" |
        CS_ESCOL_N == "09"
    )

  tibble::tibble(
    variavel = filtro,
    perc_incomp = c(
      calc_incomp(nu_idade_n_incomp, total),
      calc_incomp(cs_sexo_incomp, total),
      calc_incomp(cs_gestant_incomp, total),
      calc_incomp(cs_raca_incomp, total),
      calc_incomp(cs_escol_n_incomp, total)
    )
  )
}