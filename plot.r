library(tidyverse)

entrada <- list.files(
  path = "data/processed/",
  full.names = TRUE
)

anos <- 2010:2024

# Lê todos os arquivos e empilha com o ano correspondente
df <- map2_dfr(entrada, anos, ~ read_csv(.x) |> mutate(ano = .y))

# Gráfico de linhas
plot <- ggplot(df, aes(x = ano, y = perc_incomp, color = variavel, group = variavel)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_x_continuous(breaks = anos) +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  labs(
    title = "Evolução da Incompletude por Variável (2010–2024)",
    x = "Ano",
    y = "% Incompletude",
    color = "Variável"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))