library(tidyverse)
library(microdatasus)

source("packages/system_process_mapping.r")
source("config.r")

for (i in seq_len(nrow(combinacoes))) {

  uf_  <- combinacoes$uf[i]
  sis  <- combinacoes$sis[i]
  ano  <- combinacoes$ano[i]

  tryCatch({
    dados <- fetch_datasus(
      year_start = ano,
      year_end = ano,
      uf = uf_,
      information_system = sis,
      vars = filtro
    )

    if (nrow(dados) == 0) {
      message("Sem dados para ", ano)
      next
    }

    dados <- process_by_system(dados, sis)

    caminho_arquivo <- file.path(
      path_dados_filtrados$path,
      paste0("dados_", sis, "_", uf_, "_", ano, ".csv")
    )

    write_csv(dados, caminho_arquivo)
    message("Arquivo salvo: ", caminho_arquivo)

  }, error = function(e) {
    message("Erro em ", uf_, " - ", sis, " - ", ano, ": ", e$message)
  })
}