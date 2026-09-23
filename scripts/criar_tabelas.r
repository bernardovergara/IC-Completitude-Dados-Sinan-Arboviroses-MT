library(tidyverse)

# =====================================
# CONFIGURAÇÃO
# =====================================

dir_processados <- "data/processed"
dir_tabelas     <- "data/tables"
uf_padrao       <- "MT"

sistemas <- c(
  "SINAN-DENGUE",
  "SINAN-CHIKUNGUNYA",
  "SINAN-ZIKA"
)

nomes_sistemas <- c(
  "SINAN-DENGUE"      = "Dengue",
  "SINAN-CHIKUNGUNYA" = "Chikungunya",
  "SINAN-ZIKA"        = "Zika"
)

# ORDEM DEFINITIVA DAS VARIÁVEIS (de cima para baixo nas tabelas e no heatmap)
variaveis_interesse <- c(
  "Idade",
  "Sexo",
  "Gestante",
  "Raça/Cor",
  "Escolaridade"
)

# Rótulos usados somente na visualização, sem alterar os nomes dos dados.
rotulos_variaveis <- c(
  "Idade"        = "Idade",
  "Sexo"         = "Sexo",
  "Gestante"     = "Gestante",
  "Raça/Cor"     = "Raça/Cor da pele",
  "Escolaridade" = "Escolaridade"
)

# Nomes possíveis das colunas de contagem nos arquivos processados.
col_total_candidatos      <- c("n_total", "total", "n_notificacoes")
col_incompleto_candidatos <- c("n_incompleto", "n_incompletos", "incompletos")

# =====================================
# CLASSIFICAÇÃO DA INCOMPLETUDE
# (Romero & Cunha)
# =====================================

classificar_incompletude <- function(x) {
  case_when(
    x < 5  ~ "Excelente",
    x < 10 ~ "Boa",
    x < 20 ~ "Regular",
    x < 50 ~ "Ruim",
    TRUE   ~ "Muito ruim"
  )
}

cores_classificacao <- c(
  "Excelente"  = "#8ec07c",
  "Boa"        = "#c9e4a5",
  "Regular"    = "#fefae0",
  "Ruim"       = "#f4a261",
  "Muito ruim" = "#e76f51"
)

rotulos_classificacao <- c(
  "Excelente"  = "Excelente (< 5%)",
  "Boa"        = "Boa (5 a 10%)",
  "Regular"    = "Regular (10 a 20%)",
  "Ruim"       = "Ruim (20 a 50%)",
  "Muito ruim" = "Muito ruim (> 50%)"
)

# =====================================
# LEITURA
# =====================================

ler_dados_sistema <- function(sistema, uf = uf_padrao) {

  arquivos <- list.files(
    dir_processados,
    pattern = paste0("incompletude_", sistema, "_", uf),
    full.names = TRUE
  )

  if (length(arquivos) == 0) {
    warning("Nenhum arquivo encontrado para ", sistema)
    return(NULL)
  }

  map_dfr(arquivos, read_csv, show_col_types = FALSE) %>%
    mutate(sistema = sistema)
}

dados_brutos <- map_dfr(sistemas, ler_dados_sistema)

if (nrow(dados_brutos) == 0) {
  stop("Nenhum dado encontrado para nenhuma das arboviroses. Verifique dir_processados.")
}

dados_brutos <- dados_brutos %>%
  filter(variavel %in% variaveis_interesse) %>%
  mutate(
    perc_incomp = round(perc_incomp, 1),
    variavel = factor(variavel, levels = variaveis_interesse)
  )

col_total      <- intersect(col_total_candidatos, names(dados_brutos))[1]
col_incompleto <- intersect(col_incompleto_candidatos, names(dados_brutos))[1]
tem_contagens  <- !is.na(col_total) && !is.na(col_incompleto)

# =====================================
# FUNÇÃO: TABELA POR SISTEMA (individual)
# =====================================

gerar_tabela_sistema <- function(sistema) {

  dados_filtrados <- dados_brutos %>%
    filter(sistema == !!sistema)

  if (nrow(dados_filtrados) == 0) return(NULL)

  dados_filtrados %>%
    select(ano, variavel, perc_incomp) %>%
    pivot_wider(names_from = ano, values_from = perc_incomp) %>%
    arrange(variavel) %>%
    rowwise() %>%
    mutate(
      incompletude_acumulada = round(mean(c_across(where(is.numeric)), na.rm = TRUE), 1),
      classificacao = classificar_incompletude(incompletude_acumulada)
    ) %>%
    ungroup()
}

tabela_dengue      <- gerar_tabela_sistema("SINAN-DENGUE")
tabela_chikungunya <- gerar_tabela_sistema("SINAN-CHIKUNGUNYA")
tabela_zika        <- gerar_tabela_sistema("SINAN-ZIKA")

# =====================================
# TABELA CONSOLIDADA (uma linha por sistema)
# =====================================

tabela_consolidada <- bind_rows(
  tabela_dengue      %>% mutate(sistema = "Dengue"),
  tabela_chikungunya %>% mutate(sistema = "Chikungunya"),
  tabela_zika        %>% mutate(sistema = "Zika")
) %>%
  relocate(sistema, .before = variavel)

# =====================================
# TABELA AGREGADA (as 3 arboviroses juntas)
# =====================================

if (tem_contagens) {

  message(
    "Colunas de contagem encontradas (", col_total, ", ", col_incompleto,
    "). Agregando por soma de notificações e recalculando o percentual."
  )

  dados_agregados <- dados_brutos %>%
    rename(
      n_total_var      = all_of(col_total),
      n_incompleto_var = all_of(col_incompleto)
    ) %>%
    group_by(ano, variavel) %>%
    summarise(
      n_total_var      = sum(n_total_var, na.rm = TRUE),
      n_incompleto_var = sum(n_incompleto_var, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(perc_incomp = round(100 * n_incompleto_var / n_total_var, 1)) %>%
    select(ano, variavel, perc_incomp)

} else {

  message(
    "Colunas de contagem não encontradas. Agregando por média simples ",
    "do percentual de incompletude entre as três arboviroses (aproximação)."
  )

  dados_agregados <- dados_brutos %>%
    group_by(ano, variavel) %>%
    summarise(perc_incomp = round(mean(perc_incomp, na.rm = TRUE), 1), .groups = "drop")
}

tabela_arboviroses <- dados_agregados %>%
  pivot_wider(names_from = ano, values_from = perc_incomp) %>%
  arrange(variavel) %>%
  rowwise() %>%
  mutate(
    incompletude_acumulada = round(mean(c_across(where(is.numeric)), na.rm = TRUE), 1),
    classificacao = classificar_incompletude(incompletude_acumulada)
  ) %>%
  ungroup()

# =====================================
# EXPORTAR CSVs
# =====================================

dir.create(dir_tabelas, recursive = TRUE, showWarnings = FALSE)

write_csv(tabela_dengue,       file.path(dir_tabelas, "tabela_incompletude_dengue.csv"))
write_csv(tabela_chikungunya,  file.path(dir_tabelas, "tabela_incompletude_chikungunya.csv"))
write_csv(tabela_zika,         file.path(dir_tabelas, "tabela_incompletude_zika.csv"))
write_csv(tabela_consolidada,  file.path(dir_tabelas, "tabela_incompletude_consolidada.csv"))
write_csv(tabela_arboviroses,  file.path(dir_tabelas, "tabela_incompletude_arboviroses_agregado.csv"))

# =====================================
# DIMENSÕES DO HEATMAP (versão DOCX)
# Largura e altura têm multiplicadores independentes:
# mexa em largura_celula / altura_celula para ajustar o tamanho.
# Lembre-se: o Word limita a largura pela largura útil da página
# (~6.5" com margens padrão) e a altura pela altura útil de uma
# página (~9-9.5") — valores acima disso são reduzidos de volta
# pelo próprio Word ao inserir a imagem.
# =====================================

dim_heatmap_docx <- function(tabela) {
  n_anos      <- length(setdiff(
    names(tabela),
    c("sistema", "variavel", "incompletude_acumulada", "classificacao")
  ))
  n_variaveis <- length(variaveis_interesse)

  largura_celula <- 2   # <- ajuste aqui a largura de cada coluna (variável)
  altura_celula  <- 2 # <- ajuste aqui a altura de cada linha (ano)

  list(
    width  = 2 + n_variaveis * largura_celula,
    height = 2 + n_anos      * altura_celula
  )
}

# =====================================
# PLOT BASE
# =====================================

plotar_heatmap_docx <- function(tabela, titulo = NULL) {

  niveis_classe <- names(cores_classificacao)

  tabela_long <- tabela %>%
    mutate(variavel = factor(variavel, levels = variaveis_interesse)) %>%
    pivot_longer(
      -any_of(c("sistema", "variavel", "incompletude_acumulada", "classificacao")),
      names_to = "ano",
      values_to = "valor"
    ) %>%
    filter(ano != "incompletude_acumulada") %>%
    mutate(
      valor  = as.numeric(valor),
      classe = classificar_incompletude(valor),
      classe = factor(classe, levels = niveis_classe)
    )

  n_anos    <- n_distinct(tabela_long$ano)
  tam_texto <- pmax(2.6, 3.8 - 0.07 * n_anos)

  ggplot(tabela_long, aes(x = variavel, y = ano, fill = classe)) +
    geom_tile(
      width = 1,
      height = 1,
      color = "white",
      linewidth = 2,
      lineheight = 3,
      show.legend = TRUE
    ) +
    geom_text(
      aes(label = ifelse(is.na(valor), NA, sub("\\.", ",", sprintf("%.1f", valor)))),
      size = tam_texto, color = "grey15"
    ) +
    scale_x_discrete(
      position = "top",
      labels = function(x) str_wrap(rotulos_variaveis[x], width = 10)
    ) +
    scale_y_discrete(limits = rev(sort(unique(tabela_long$ano)))) +
    scale_fill_manual(
      values = cores_classificacao,
      labels = rotulos_classificacao,
      limits = niveis_classe,
      breaks = niveis_classe,
      name   = "Classificação",
      drop   = FALSE
    ) +
    guides(fill = guide_legend(override.aes = list(fill = cores_classificacao[niveis_classe]))) +
    labs(title = titulo, x = NULL, y = "Ano") +
    theme_minimal(base_size = 11) +
    theme(
  panel.grid          = element_blank(),
  plot.title          = element_text(face = "bold", size = 9, hjust = 0.5, margin = margin(b = 8)),
  plot.title.position = "plot",   # <- troque "panel" por "plot" (ou remova a linha inteira)
  axis.text           = element_text(color = "grey20"),
  axis.text.x         = element_text(size = 10, lineheight = 0.8),
  axis.text.y         = element_text(size = 10),
  axis.title.y        = element_text(size = 10, margin = margin(r = 6)),
  legend.position     = "right",
  legend.title        = element_text(face = "bold", size = 10),
  legend.text         = element_text(size = 10),
  plot.margin         = margin(t = 8, r = 10, b = 8, l = 10)
)
}

# =====================================
# GERAR OS HEATMAPS PARA O DOCX
# =====================================

heatmap_dengue_docx      <- plotar_heatmap_docx(tabela_dengue)
heatmap_chikungunya_docx <- plotar_heatmap_docx(tabela_chikungunya)
heatmap_zika_docx        <- plotar_heatmap_docx(tabela_zika)
heatmap_arboviroses_docx <- plotar_heatmap_docx(tabela_arboviroses)