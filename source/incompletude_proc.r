library(tidyverse)

source("config.r")
source("source/incompletude_calc.r")

for (i in seq_len(nrow(combinacoes))) {

  uf_  <- combinacoes$uf[i]
  sis  <- combinacoes$sis[i]
  ano  <- combinacoes$ano[i]

  caminho_entrada <- path_dados_filtrados

  if (!file.exists(caminho_entrada)) {
    message("Arquivo não encontrado: ", caminho_entrada)
    next
  }

  tryCatch({
    dados <- read_csv(caminho_entrada, show_col_types = FALSE)

    if (nrow(dados) == 0) {
      message("Sem dados em: ", caminho_entrada)
      next
    }

    incompletude <- calcular_incompletude(dados, dict_filtro)

    caminho_saida <- path_dados_processados

    write_csv(incompletude, caminho_saida)
    message("Incompletude calculada e salva: ", caminho_saida)

  }, error = function(e) {
    message("Erro ao processar ", sis, " - ", uf_, " - ", ano, ": ", e$message)
  })
}
