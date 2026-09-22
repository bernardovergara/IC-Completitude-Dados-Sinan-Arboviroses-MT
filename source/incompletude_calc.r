library(tidyverse, warn.conflicts = FALSE)

calc_incomp <- function(subconjunto, total) {
  (nrow(subconjunto) / total) * 100
}

calcular_incompletude <- function(dados, filtro_dict) {
  # Definição dos filtros de incompletude
  total <- nrow(dados)

  # IDADE (obrigatória)
  nu_idade_n_incomp <- dados |>
    dplyr::filter(is.na(NU_IDADE_N)) # nolint

  # SEXO (obrigatória)
  cs_sexo_incomp <- dados |>
    dplyr::filter(is.na(CS_SEXO) | CS_SEXO == "Ignorado") # nolint

  # GESTANT (obrigatória)
  cs_gestant_incomp <- dados |>
    dplyr::filter(CS_SEXO == "Feminino") |> # nolint
    dplyr::filter(
      is.na(CS_GESTANT) | # nolint
        CS_GESTANT == "Não se aplica" |
        CS_GESTANT == "Ignorado"
    )

  # RAÇA (essencial)
  cs_raca_incomp <- dados |>
    dplyr::filter(is.na(CS_RACA) | CS_RACA == "Ignorado") # nolint

  # ESCOLARIDADE (essencial)
  cs_escol_n_incomp <- dados |>
    dplyr::filter(
      is.na(CS_ESCOL_N) | # nolint
        CS_ESCOL_N == "Não se aplica" |
        CS_ESCOL_N == "09"
    )

  tibble::tibble(
    variavel = filtro_dict,
    perc_incomp = c(
      calc_incomp(nu_idade_n_incomp, total),
      calc_incomp(cs_sexo_incomp, total),
      calc_incomp(cs_gestant_incomp, total),
      calc_incomp(cs_raca_incomp, total),
      calc_incomp(cs_escol_n_incomp, total)
    )
  )
}