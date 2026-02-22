library(tidyverse)
library(microdatasus)

source("packages/system_process_mapping.r")
source("config.r")

# Criar diretório se não existir
dir.create("data/filtered", showWarnings = FALSE, recursive = TRUE)

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
      message("Sem dados para ", sis, " - ", uf_, " - ", ano)
      next
    }

    dados <- process_by_system(dados, sis)

    caminho_arquivo <- path_dados_filtrados_f(sis, uf_, ano)

    write_csv(dados, caminho_arquivo)
    message("✓ Arquivo salvo: ", caminho_arquivo)

  }, error = function(e) {
    message("✗ Erro em ", sis, " - ", uf_, " - ", ano, ": ", e$message)
  })
}

message("\n=== IMPORTAÇÃO FINALIZADA ===")