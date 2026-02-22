library(tidyverse)

source("config.r")

entrada <- map_df(seq_len(nrow(combinacoes)), ~ {
  uf_ <- combinacoes$uf[.x]
  sis <- combinacoes$sis[.x]
  ano <- combinacoes$ano[.x]

  caminho <- path_dados_processados_f(sis, uf_, ano)

  tibble(
    caminho = caminho,
    existe = file.exists(caminho)
  )
}) |>
  filter(existe) |>
  pull(caminho)

# Lê todos os arquivos disponíveis
df <- map_dfr(entrada, ~ read_csv(.x, show_col_types = FALSE))

# Criar um plot para cada sistema
sistemas_unicos <- unique(df$sis)

for (sistema in sistemas_unicos) {
  df_sis <- df |> filter(sis == sistema)

  plot <- ggplot(df_sis, aes(x = ano, y = perc_incomp, color = variavel, group = variavel)) + # nolint
    geom_line(linewidth = 1) +
    geom_point(size = 2) +
    scale_x_continuous(breaks = seq(min(df_sis$ano), max(df_sis$ano), by = 2)) +
    scale_y_continuous(labels = scales::percent_format(scale = 1)) +
    labs(
      title = paste("Evolução da Incompletude por Variável -", sistema),
      x = "Ano",
      y = "% Incompletude",
      color = "Variável"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

  caminho_saida <- path_plots_por_ano_f(sistema)
  ggsave(caminho_saida, plot, width = 10, height = 6)
  message("Plot salvo: ", caminho_saida)
}