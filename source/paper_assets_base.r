read_processed_data <- function(path = "data/processed") {
  files <- list.files(path, pattern = "^incompletude_.*\\.csv$", full.names = TRUE)
  if (length(files) == 0) {
    stop("Nenhum arquivo processado encontrado em ", path)
  }

  do.call(rbind, lapply(files, read.csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8"))
}

read_case_counts <- function(path = "data/filtered") {
  files <- list.files(path, pattern = "^dados_.*\\.csv$", full.names = TRUE)
  if (length(files) == 0) {
    stop("Nenhum arquivo filtrado encontrado em ", path)
  }

  rows <- lapply(files, function(file) {
    name <- basename(file)
    info <- sub("^dados_(.*)_([^_]+)_([0-9]{4})\\.csv$", "\\1|\\2|\\3", name)
    parts <- strsplit(info, "\\|")[[1]]
    data.frame(
      sis = parts[1],
      uf = parts[2],
      ano = as.integer(parts[3]),
      n = max(length(readLines(file, warn = FALSE, encoding = "UTF-8")) - 1, 0),
      stringsAsFactors = FALSE
    )
  })

  do.call(rbind, rows)
}

classificar_incompletude <- function(x) {
  cut(
    x,
    breaks = c(-Inf, 5, 10, 20, 50, Inf),
    labels = c("Excelente", "Bom", "Regular", "Ruim", "Muito ruim"),
    right = TRUE
  )
}

format_percent <- function(x, digits = 1) {
  gsub("\\.", ",", sprintf(paste0("%.", digits, "f%%"), x))
}

markdown_table <- function(df) {
  cols <- names(df)
  lines <- c(
    paste0("| ", paste(cols, collapse = " | "), " |"),
    paste0("| ", paste(rep("---", length(cols)), collapse = " | "), " |")
  )
  body <- apply(df, 1, function(row) {
    paste0("| ", paste(row, collapse = " | "), " |")
  })
  paste(c(lines, body), collapse = "\n")
}

make_table_cases <- function(counts) {
  by_sis <- aggregate(n ~ sis, counts, sum)
  years <- aggregate(ano ~ sis, counts, function(x) paste0(min(x), "-", max(x)))
  out <- merge(by_sis, years, by = "sis")
  out <- out[match(c("SINAN-DENGUE", "SINAN-CHIKUNGUNYA", "SINAN-ZIKA"), out$sis), ]
  total <- data.frame(
    sis = "Total",
    n = sum(out$n),
    ano = paste0(min(counts$ano), "-", max(counts$ano)),
    stringsAsFactors = FALSE
  )
  out <- rbind(out, total)
  names(out) <- c("Sistema", "Notificações", "Período")
  out$Notificações <- format(out$Notificações, big.mark = ".", decimal.mark = ",", scientific = FALSE)
  out
}

make_table_summary <- function(df) {
  combos <- unique(df[c("sis", "variavel")])
  rows <- lapply(seq_len(nrow(combos)), function(i) {
    item <- combos[i, ]
    subset <- df[df$sis == item$sis & df$variavel == item$variavel, ]
    data.frame(
      Sistema = item$sis,
      Variável = item$variavel,
      "Mínimo" = format_percent(min(subset$perc_incomp, na.rm = TRUE)),
      "Média" = format_percent(mean(subset$perc_incomp, na.rm = TRUE)),
      "Máximo" = format_percent(max(subset$perc_incomp, na.rm = TRUE)),
      "Pior escore" = as.character(classificar_incompletude(max(subset$perc_incomp, na.rm = TRUE))),
      check.names = FALSE,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  out[order(out$Sistema, out$Variável), ]
}

make_aggregate_plot <- function(df, output = "plots/plot_incompletude_SINAN_agregado_por_ano.png") {
  aggregate_df <- aggregate(perc_incomp ~ ano + variavel, df, mean, na.rm = TRUE)
  variables <- unique(aggregate_df$variavel)
  years <- sort(unique(aggregate_df$ano))
  colors <- c("#1b9e77", "#d95f02", "#7570b3", "#e7298a", "#66a61e")

  dir.create(dirname(output), showWarnings = FALSE, recursive = TRUE)

  # PNG para leitura no manuscrito; PDF vetorial para submissão (a RESS exige
  # PDF, SVG ou EPS para gráficos, em arquivos separados).
  output_pdf <- sub("\\.png$", ".pdf", output)
  devices <- list(
    function() png(output, width = 17, height = 10, units = "cm", res = 300, family = "serif"),
    function() pdf(output_pdf, width = 17 / 2.54, height = 10 / 2.54, family = "serif")
  )

  for (open_device in devices) {
    open_device()
    draw_aggregate_plot(aggregate_df, variables, years, colors)
    dev.off()
  }

  invisible(c(output, output_pdf))
}

# Sem título embutido: a legenda da figura no manuscrito cumpre esse papel,
# conforme as normas da RESS.
draw_aggregate_plot <- function(aggregate_df, variables, years, colors) {
  # Margem inferior ampliada para acomodar a legenda horizontal abaixo do eixo,
  # fora da área de plotagem, evitando sobreposição com as linhas.
  par(mar = c(7, 5, 2, 2), xpd = TRUE)
  plot(
    range(years),
    range(aggregate_df$perc_incomp, na.rm = TRUE),
    type = "n",
    xlab = "Ano",
    ylab = "% Incompletude",
    xaxt = "n"
  )
  axis(1, at = seq(min(years), max(years), by = 2))
  grid(col = "gray85")

  for (i in seq_along(variables)) {
    subset <- aggregate_df[aggregate_df$variavel == variables[i], ]
    subset <- subset[order(subset$ano), ]
    lines(subset$ano, subset$perc_incomp, col = colors[i], lwd = 2)
    points(subset$ano, subset$perc_incomp, col = colors[i], pch = 19)
  }

  legend(
    x = grconvertX(0.5, "ndc", "user"),
    y = grconvertY(0.06, "ndc", "user"),
    xjust = 0.5,
    yjust = 0.5,
    legend = variables,
    col = colors[seq_along(variables)],
    lwd = 2,
    pch = 19,
    bty = "n",
    horiz = TRUE,
    cex = 0.85,
    x.intersp = 0.6,
    text.width = NA
  )
  invisible(NULL)
}

write_paper_tables <- function(output = "paper_tables.md") {
  df <- read_processed_data()
  counts <- read_case_counts()
  make_aggregate_plot(df)

  content <- paste(
    "Tabela 1. Notificações analisadas por sistema de informação.",
    "",
    markdown_table(make_table_cases(counts)),
    "",
    "Tabela 2. Resumo da incompletude por sistema e variável.",
    "",
    markdown_table(make_table_summary(df)),
    sep = "\n"
  )
  writeLines(content, output, useBytes = TRUE)
  invisible(output)
}

if (identical(environment(), globalenv())) {
  write_paper_tables()
}
