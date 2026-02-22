library(tidyverse)

source("config.r")

entrada <- map_df(seq_len(nrow(combinacoes)), ~ {
  uf_ <- combinacoes$uf[.x]
  sis <- combinacoes$sis[.x]
  ano <- combinacoes$ano[.x]

  caminho <- path_dados_processados

  tibble(
    caminho = caminho,
    sis = sis,
    uf = uf_,
    ano = ano,
    existe = file.exists(caminho)
  )
}) |>
  filter(existe) |>
  pull(caminho)

# Lê todos os arquivos disponíveis
df <- map_dfr(entrada, ~ {
  read_csv(.x, show_col_types = FALSE) |>
    mutate(
      sis = str_extract(basename(.x), "(?<=incompletude_).*?(?=_[A-Z]{2}_)"),
      uf = str_extract(basename(.x), "(?<=_)[A-Z]{2}(?=_\\d{4})"),
      ano = as.numeric(str_extract(basename(.x), "\\d{4}(?=\\.csv)"))
    )
})

# Criar um plot para cada sistema
sistemas_unicos <- unique(df$sis)

for (sis in sistemas_unicos) {
  df_sis <- df |> filter(sis == sis)

  # Gráfico de linhas para cada sistema
  plot <- ggplot(df_sis, aes(x = ano, y = perc_incomp, color = variavel, group = variavel)) + # nolint
    geom_line(linewidth = 1) +
    geom_point(size = 2) +
    scale_x_continuous(breaks = seq(min(df_sis$ano), max(df_sis$ano), by = 2)) +
    scale_y_continuous(labels = scales::percent_format(scale = 1)) +
    labs(
      title = paste("Evolução da Incompletude por Variável -", sis),
      x = "Ano",
      y = "% Incompletude",
      color = "Variável"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

  # Salvar plot
  caminho_saida <- path_plots_por_ano
  ggsave(caminho_saida, plot, width = 10, height = 6)
  message("Plot salvo: ", caminho_saida)
}