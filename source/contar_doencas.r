library(tidyverse, warn.conflicts = FALSE)

source("scripts/config.r")

dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)

contagem_por_ano <- purrr::map_dfr(seq_len(nrow(combinacoes)), ~ {
  uf_ <- combinacoes$uf[.x]
  sis <- combinacoes$sis[.x]
  ano <- combinacoes$ano[.x]

  caminho <- path_dados_filtrados_f(sis, uf_, ano)

  if (!file.exists(caminho)) {
    return(tibble::tibble(
      doenca = dplyr::case_when(
        sis == "SINAN-DENGUE" ~ "Dengue",
        sis == "SINAN-CHIKUNGUNYA" ~ "Chikungunya",
        sis == "SINAN-ZIKA" ~ "Zika",
        TRUE ~ sis
      ),
      sis = sis,
      uf = uf_,
      ano = ano,
      n_registros = NA_integer_
    ))
  }

  dados <- read_csv(caminho, show_col_types = FALSE)

  tibble::tibble(
    doenca = dplyr::case_when(
      sis == "SINAN-DENGUE" ~ "Dengue",
      sis == "SINAN-CHIKUNGUNYA" ~ "Chikungunya",
      sis == "SINAN-ZIKA" ~ "Zika",
      TRUE ~ sis
    ),
    sis = sis,
    uf = uf_,
    ano = ano,
    n_registros = nrow(dados)
  )
})

contagem_total <- contagem_por_ano |>
  dplyr::filter(!is.na(n_registros)) |>
  dplyr::group_by(doenca) |>
  dplyr::summarise(total_registros = sum(n_registros, na.rm = TRUE), .groups = "drop")

caminho_contagem_ano <- file.path("data/processed", "contagem_doencas_por_ano.csv")
caminho_contagem_total <- file.path("data/processed", "contagem_doencas_total.csv")

write_csv(contagem_por_ano, caminho_contagem_ano)
write_csv(contagem_total, caminho_contagem_total)

message("Resumo de quantidade por doença salvo em:")
message("- ", caminho_contagem_ano)
message("- ", caminho_contagem_total)
message("\nTotal por doença:")
print(contagem_total)
