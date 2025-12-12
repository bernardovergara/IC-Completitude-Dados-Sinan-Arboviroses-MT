##############################################
# BOLETIM EPIDEMIOLÓGICO – DENGUE – SINAN
# Versão para múltiplos anos (2010-2025)
##############################################

# Limpar ambiente
rm(list = ls())
gc()

# Carregar pacotes necessários
suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
  library(lubridate)
  library(ggplot2)
  library(stringr)
})

cat("\n===========================================\n")
cat("  PIPELINE DENGUE SINAN - MÚLTIPLOS ANOS\n")
cat("===========================================\n\n")

#--------------------------------------------------
# 1. CONFIGURAÇÕES
#--------------------------------------------------

# Ajuste estes caminhos conforme necessário
DIR_DADOS <- "data/raw/"
PADRAO_ARQUIVOS <- "dados_SINAN-DENGUE_\\d{4}\\.csv"  # Padrão regex para encontrar arquivos
DIR_OUTPUT <- "output"

# Criar diretório de saída
dir.create(DIR_OUTPUT, recursive = TRUE, showWarnings = FALSE)

cat("Configurações:\n")
cat("  Diretório de dados:", DIR_DADOS, "\n")
cat("  Padrão de arquivos:", PADRAO_ARQUIVOS, "\n")
cat("  Diretório de saída:", DIR_OUTPUT, "\n\n")

#--------------------------------------------------
# 2. LISTAR ARQUIVOS
#--------------------------------------------------

cat("ETAPA 1: Identificando arquivos\n")
cat("----------------------------\n")

# Listar todos os arquivos que correspondem ao padrão
arquivos <- list.files(
  path = DIR_DADOS,
  pattern = PADRAO_ARQUIVOS,
  full.names = TRUE
)

if (length(arquivos) == 0) {
  cat("ERRO: Nenhum arquivo encontrado!\n")
  cat("\nArquivos disponíveis em", DIR_DADOS, ":\n")
  print(list.files(DIR_DADOS))
  stop("Nenhum arquivo CSV de dengue encontrado")
}

cat("Arquivos encontrados:", length(arquivos), "\n\n")
for (i in seq_along(arquivos)) {
  tamanho_mb <- round(file.size(arquivos[i]) / 1024^2, 2)
  cat(sprintf("  %2d. %s (%s MB)\n", i, basename(arquivos[i]), tamanho_mb))
}

#--------------------------------------------------
# 3. FUNÇÃO DE LIMPEZA DE ARQUIVO
#--------------------------------------------------

limpar_arquivo_csv <- function(arquivo_entrada) {
  
  cat("\n  Limpando:", basename(arquivo_entrada), "\n")
  
  # Criar arquivo temporário
  arquivo_saida <- tempfile(fileext = ".csv")
  
  # Ler arquivo como bytes brutos
  con_in <- file(arquivo_entrada, "rb")
  bytes <- readBin(con_in, "raw", file.size(arquivo_entrada))
  close(con_in)
  
  # Remover bytes nulos (0x00)
  bytes_limpos <- bytes[bytes != as.raw(0)]
  
  # Escrever arquivo limpo
  con_out <- file(arquivo_saida, "wb")
  writeBin(bytes_limpos, con_out)
  close(con_out)
  
  cat("    ✓ Arquivo limpo (", 
      round(file.size(arquivo_entrada)/1024^2, 2), "MB ->",
      round(file.size(arquivo_saida)/1024^2, 2), "MB)\n")
  
  return(arquivo_saida)
}

#--------------------------------------------------
# 4. FUNÇÃO DE LEITURA DE UM ARQUIVO
#--------------------------------------------------

ler_arquivo_dengue <- function(caminho_arquivo) {
  
  nome_arquivo <- basename(caminho_arquivo)
  
  cat("\n--- Processando:", nome_arquivo, "---\n")
  
  # Extrair ano do nome do arquivo
  ano <- str_extract(nome_arquivo, "\\d{4}") %>% as.integer()
  cat("  Ano detectado:", ano, "\n")
  
  # Limpar arquivo
  arquivo_limpo <- limpar_arquivo_csv(caminho_arquivo)
  
  # Ler dados
  cat("  Lendo CSV...\n")
  dados <- fread(
    arquivo_limpo,
    encoding = "UTF-8",
    na.strings = c("", "NA", "NULL", " "),
    fill = TRUE,
    strip.white = TRUE,
    blank.lines.skip = TRUE,
    showProgress = FALSE
  )
  
  cat("    ✓", format(nrow(dados), big.mark = "."), "linhas lidas\n")
  
  # Limpar arquivo temporário
  unlink(arquivo_limpo)
  
  # Converter para tibble e limpar nomes
  dados <- dados %>%
    as_tibble() %>%
    janitor::clean_names()
  
  # IMPORTANTE: Converter todas as colunas para character antes de combinar
  # Isso evita conflitos de tipo entre arquivos diferentes
  dados <- dados %>%
    mutate(across(everything(), as.character))
  
  # Adicionar coluna de ano
  dados$ano_arquivo <- as.character(ano)
  
  return(dados)
}

#--------------------------------------------------
# 5. IMPORTAR TODOS OS ARQUIVOS
#--------------------------------------------------

cat("\n\nETAPA 2: Importando todos os arquivos\n")
cat("----------------------------\n")

# Ler todos os arquivos e combinar
lista_dados <- lapply(arquivos, function(arq) {
  tryCatch({
    ler_arquivo_dengue(arq)
  }, error = function(e) {
    cat("\n  ✗ ERRO ao processar", basename(arq), "\n")
    cat("    Mensagem:", e$message, "\n")
    return(NULL)
  })
})

# Remover arquivos que falharam
lista_dados <- lista_dados[!sapply(lista_dados, is.null)]

if (length(lista_dados) == 0) {
  stop("ERRO: Nenhum arquivo foi importado com sucesso!")
}

cat("\n\nCombinando dados de", length(lista_dados), "arquivo(s)...\n")

# Combinar todos os dados (já estão como character)
dados <- bind_rows(lista_dados)

cat("  ✓ Dados combinados!\n")
cat("  - Total de linhas:", format(nrow(dados), big.mark = "."), "\n")
cat("  - Total de colunas:", ncol(dados), "\n")

# Converter ano_arquivo para numérico
dados$ano_arquivo <- as.integer(dados$ano_arquivo)

cat("  - Anos presentes:", paste(sort(unique(dados$ano_arquivo)), collapse = ", "), "\n\n")

# Salvar dados brutos
saveRDS(dados, file.path(DIR_OUTPUT, "01_dados_brutos_completo.rds"))
cat("  ✓ Dados brutos salvos\n")

#--------------------------------------------------
# 6. PROCESSAMENTO DE DATAS E TIPOS
#--------------------------------------------------

cat("\n\nETAPA 3: Processamento de dados\n")
cat("----------------------------\n")

# Converter colunas numéricas
cat("Convertendo colunas numéricas...\n")
colunas_numericas <- c("idade", "nu_notific", "id_agravo")
for (col in colunas_numericas) {
  if (col %in% names(dados)) {
    dados[[col]] <- as.numeric(dados[[col]])
    cat("  ✓", col, "\n")
  }
}

# Converter datas
cat("\nConvertendo datas...\n")
colunas_data <- grep("^dt_", names(dados), value = TRUE)
cat("Colunas de data encontradas:", length(colunas_data), "\n")

for (col in colunas_data) {
  cat("  Processando:", col, "...")
  
  dados[[col]] <- tryCatch({
    temp <- ymd(dados[[col]])
    temp[year(temp) < 1900 | year(temp) > 2030] <- NA
    validas <- sum(!is.na(temp))
    cat(" ✓", format(validas, big.mark = "."), "datas válidas\n")
    temp
  }, error = function(e) {
    cat(" ✗ erro\n")
    dados[[col]]
  })
}

#--------------------------------------------------
# 7. CRIAR VARIÁVEIS DERIVADAS
#--------------------------------------------------

cat("\n\nETAPA 4: Criando variáveis derivadas\n")
cat("----------------------------\n")

# Faixa etária
if ("idade" %in% names(dados)) {
  cat("✓ Criando faixa_etaria\n")
  dados <- dados %>%
    mutate(
      faixa_etaria = case_when(
        is.na(idade) ~ "Desconhecido",
        idade < 1 ~ "<1 ano",
        idade < 10 ~ "1-9 anos",
        idade < 20 ~ "10-19 anos",
        idade < 30 ~ "20-29 anos",
        idade < 40 ~ "30-39 anos",
        idade < 50 ~ "40-49 anos",
        idade < 60 ~ "50-59 anos",
        idade < 70 ~ "60-69 anos",
        idade >= 70 ~ "70+ anos",
        TRUE ~ "Desconhecido"
      )
    )
}

# Ano de notificação
if ("dt_notific" %in% names(dados)) {
  cat("✓ Extraindo ano_notificacao\n")
  dados <- dados %>%
    mutate(ano_notificacao = year(dt_notific))
}

# Mês de notificação
if ("dt_notific" %in% names(dados)) {
  cat("✓ Extraindo mes_notificacao\n")
  dados <- dados %>%
    mutate(
      mes_notificacao = month(dt_notific),
      mes_nome = month(dt_notific, label = TRUE, abbr = FALSE, locale = "pt_BR.UTF-8")
    )
}

# Tempo até notificação
if (all(c("dt_notific", "dt_sin_pri") %in% names(dados))) {
  cat("✓ Calculando tempo_ate_notificacao\n")
  dados <- dados %>%
    mutate(
      tempo_ate_notificacao_dias = as.numeric(difftime(dt_notific, dt_sin_pri, units = "days"))
    )
}

# Salvar dados processados
saveRDS(dados, file.path(DIR_OUTPUT, "02_dados_processados_completo.rds"))
cat("\n✓ Dados processados salvos\n")

#--------------------------------------------------
# 8. ANÁLISES DESCRITIVAS
#--------------------------------------------------

cat("\n\nETAPA 5: Análises descritivas\n")
cat("----------------------------\n")

# 8.1 Resumo geral
cat("\n📊 RESUMO GERAL\n")
cat("  Total de registros:", format(nrow(dados), big.mark = "."), "\n")

if ("ano_notificacao" %in% names(dados)) {
  anos <- range(dados$ano_notificacao, na.rm = TRUE)
  cat("  Período:", anos[1], "a", anos[2], "\n")
}

# 8.2 Casos por ano
if ("ano_notificacao" %in% names(dados)) {
  cat("\n📅 Casos por ano:\n")
  tab_ano <- dados %>%
    filter(!is.na(ano_notificacao)) %>%
    count(ano_notificacao, name = "casos") %>%
    arrange(ano_notificacao)
  
  fwrite(tab_ano, file.path(DIR_OUTPUT, "tabela_casos_por_ano.csv"))
  print(tab_ano)
}

# 8.3 Casos por ano e UF
if (all(c("ano_notificacao", "uf_not") %in% names(dados))) {
  cat("\n📍 Casos por ano e UF:\n")
  tab_ano_uf <- dados %>%
    filter(!is.na(ano_notificacao), !is.na(uf_not)) %>%
    count(ano_notificacao, uf_not, name = "casos") %>%
    arrange(ano_notificacao, desc(casos))
  
  fwrite(tab_ano_uf, file.path(DIR_OUTPUT, "tabela_casos_por_ano_uf.csv"))
  cat("  ✓ Salva em tabela_casos_por_ano_uf.csv\n")
}

# 8.4 Casos por UF (total)
if ("uf_not" %in% names(dados)) {
  cat("\n🗺️  Top 10 UFs com mais casos:\n")
  tab_uf <- dados %>%
    filter(!is.na(uf_not)) %>%
    count(uf_not, name = "casos") %>%
    arrange(desc(casos))
  
  fwrite(tab_uf, file.path(DIR_OUTPUT, "tabela_casos_por_uf.csv"))
  print(head(tab_uf, 10))
}

# 8.5 Casos por sexo
if ("sexo" %in% names(dados)) {
  cat("\n👥 Casos por sexo:\n")
  tab_sexo <- dados %>%
    filter(!is.na(sexo)) %>%
    count(sexo, name = "casos") %>%
    mutate(percentual = round(casos / sum(casos) * 100, 1)) %>%
    arrange(desc(casos))
  
  fwrite(tab_sexo, file.path(DIR_OUTPUT, "tabela_casos_por_sexo.csv"))
  print(tab_sexo)
}

# 8.6 Casos por faixa etária
if ("faixa_etaria" %in% names(dados)) {
  cat("\n👶👴 Casos por faixa etária:\n")
  tab_faixa <- dados %>%
    count(faixa_etaria, name = "casos") %>%
    mutate(percentual = round(casos / sum(casos) * 100, 1)) %>%
    arrange(desc(casos))
  
  fwrite(tab_faixa, file.path(DIR_OUTPUT, "tabela_casos_por_faixa_etaria.csv"))
  print(tab_faixa)
}

# 8.7 Taxa de letalidade por ano
if (all(c("evolucao", "ano_notificacao") %in% names(dados))) {
  cat("\n💀 Taxa de letalidade por ano:\n")
  
  tab_letalidade <- dados %>%
    filter(!is.na(evolucao), !is.na(ano_notificacao)) %>%
    group_by(ano_notificacao) %>%
    summarise(
      total_casos = n(),
      obitos = sum(grepl("bito", evolucao, ignore.case = TRUE)),
      taxa_letalidade = round((obitos / total_casos) * 100, 2),
      .groups = "drop"
    ) %>%
    arrange(ano_notificacao)
  
  fwrite(tab_letalidade, file.path(DIR_OUTPUT, "tabela_letalidade_por_ano.csv"))
  print(tab_letalidade)
}

#--------------------------------------------------
# 9. GRÁFICOS
#--------------------------------------------------

cat("\n\nETAPA 6: Gerando gráficos\n")
cat("----------------------------\n")

# 9.1 Série temporal completa
if ("dt_notific" %in% names(dados)) {
  cat("📈 Gerando série temporal...\n")
  
  dados_temporal <- dados %>%
    filter(!is.na(dt_notific)) %>%
    mutate(ano_mes = floor_date(dt_notific, "month")) %>%
    count(ano_mes, name = "casos")
  
  p1 <- ggplot(dados_temporal, aes(x = ano_mes, y = casos)) +
    geom_line(color = "#2E86AB", size = 1.2) +
    geom_point(color = "#2E86AB", size = 2) +
    scale_y_continuous(labels = scales::comma) +
    theme_minimal(base_size = 14) +
    labs(
      title = "Série Temporal - Casos de Dengue",
      subtitle = paste("Notificações mensais de", min(year(dados_temporal$ano_mes)), 
                       "a", max(year(dados_temporal$ano_mes))),
      x = "Período",
      y = "Número de casos"
    ) +
    theme(
      plot.title = element_text(face = "bold", size = 18),
      plot.subtitle = element_text(size = 12),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
  ggsave(
    file.path(DIR_OUTPUT, "grafico_serie_temporal_completa.png"),
    p1, width = 14, height = 7, dpi = 300
  )
  cat("  ✓ grafico_serie_temporal_completa.png\n")
}

# 9.2 Casos por ano (barras)
if ("ano_notificacao" %in% names(dados)) {
  cat("📊 Gerando gráfico de casos por ano...\n")
  
  dados_anual <- dados %>%
    filter(!is.na(ano_notificacao)) %>%
    count(ano_notificacao, name = "casos")
  
  p2 <- ggplot(dados_anual, aes(x = ano_notificacao, y = casos)) +
    geom_col(fill = "#A23B72", alpha = 0.8) +
    geom_text(aes(label = scales::comma(casos)), vjust = -0.5, size = 3.5) +
    scale_y_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.1))) +
    scale_x_continuous(breaks = dados_anual$ano_notificacao) +
    theme_minimal(base_size = 14) +
    labs(
      title = "Casos de Dengue por Ano",
      subtitle = "Total de notificações anuais",
      x = "Ano",
      y = "Número de casos"
    ) +
    theme(
      plot.title = element_text(face = "bold", size = 18),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
  ggsave(
    file.path(DIR_OUTPUT, "grafico_casos_por_ano.png"),
    p2, width = 12, height = 7, dpi = 300
  )
  cat("  ✓ grafico_casos_por_ano.png\n")
}

# 9.3 Sazonalidade (média de todos os anos)
if ("mes_nome" %in% names(dados)) {
  cat("🌡️  Gerando gráfico de sazonalidade...\n")
  
  dados_sazonal <- dados %>%
    filter(!is.na(mes_notificacao)) %>%
    count(mes_notificacao, name = "casos") %>%
    mutate(
      mes_nome = month(mes_notificacao, label = TRUE, abbr = FALSE, locale = "pt_BR.UTF-8")
    )
  
  p3 <- ggplot(dados_sazonal, aes(x = mes_notificacao, y = casos)) +
    geom_col(fill = "#F18F01", alpha = 0.8) +
    geom_line(color = "#C73E1D", size = 1.2, group = 1) +
    scale_x_continuous(
      breaks = 1:12,
      labels = month(1:12, label = TRUE, abbr = TRUE, locale = "pt_BR.UTF-8")
    ) +
    scale_y_continuous(labels = scales::comma) +
    theme_minimal(base_size = 14) +
    labs(
      title = "Sazonalidade - Casos de Dengue",
      subtitle = "Distribuição mensal (todos os anos agregados)",
      x = "Mês",
      y = "Número de casos"
    ) +
    theme(
      plot.title = element_text(face = "bold", size = 18),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
  ggsave(
    file.path(DIR_OUTPUT, "grafico_sazonalidade.png"),
    p3, width = 12, height = 7, dpi = 300
  )
  cat("  ✓ grafico_sazonalidade.png\n")
}

# 9.4 Top UFs
if ("uf_not" %in% names(dados)) {
  cat("🗺️  Gerando gráfico de UFs...\n")
  
  dados_uf <- dados %>%
    filter(!is.na(uf_not)) %>%
    count(uf_not, name = "casos") %>%
    arrange(desc(casos)) %>%
    head(15)
  
  p4 <- ggplot(dados_uf, aes(x = reorder(uf_not, casos), y = casos)) +
    geom_col(fill = "#06A77D", alpha = 0.8) +
    geom_text(aes(label = scales::comma(casos)), hjust = -0.2, size = 3.5) +
    coord_flip() +
    scale_y_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.1))) +
    theme_minimal(base_size = 14) +
    labs(
      title = "Top 15 UFs - Casos de Dengue",
      subtitle = "Total de notificações por unidade federativa",
      x = "UF",
      y = "Número de casos"
    ) +
    theme(plot.title = element_text(face = "bold", size = 18))
  
  ggsave(
    file.path(DIR_OUTPUT, "grafico_top_ufs.png"),
    p4, width = 10, height = 8, dpi = 300
  )
  cat("  ✓ grafico_top_ufs.png\n")
}

#--------------------------------------------------
# 10. RELATÓRIO FINAL
#--------------------------------------------------

cat("\n\n===========================================\n")
cat("  ✅ PIPELINE CONCLUÍDO COM SUCESSO!\n")
cat("===========================================\n\n")

cat("📁 Arquivos gerados em:", DIR_OUTPUT, "\n\n")

cat("📊 Dados RDS:\n")
for (arquivo in list.files(DIR_OUTPUT, pattern = "\\.rds$")) {
  tamanho <- round(file.size(file.path(DIR_OUTPUT, arquivo)) / 1024^2, 2)
  cat(sprintf("  ✓ %s (%s MB)\n", arquivo, tamanho))
}

cat("\n📋 Tabelas CSV:\n")
for (arquivo in list.files(DIR_OUTPUT, pattern = "^tabela_.*\\.csv$")) {
  cat("  ✓", arquivo, "\n")
}

cat("\n📈 Gráficos PNG:\n")
for (arquivo in list.files(DIR_OUTPUT, pattern = "^grafico_.*\\.png$")) {
  cat("  ✓", arquivo, "\n")
}

cat("\n🎉 Análise de múltiplos anos completa!\n")
cat("📊 Total de anos processados:", length(unique(dados$ano_arquivo)), "\n")
cat("📝 Total de registros:", format(nrow(dados), big.mark = "."), "\n\n")