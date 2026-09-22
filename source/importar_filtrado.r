library(tidyverse, warn.conflicts = FALSE)
library(microdatasus)

source("packages/system_process_mapping.r")
source("scripts/config.r")

# Criar diretório se não existir
dir.create("data/filtered", showWarnings = FALSE, recursive = TRUE)

codigo_uf <- NULL
if (!is.null(ufs)) {
  if (!("SG_UF_NOT" %in% filtro)) {
    filtro <- c(filtro, "SG_UF_NOT")
  }

  codigo_uf <- read_csv("data/utils/uf_ibge_cods.csv")
}

filtrar_estados <- function(dados, ufs) {
  if (is.null(ufs)) {
    print("Nenhum filtro de estado aplicado. Retornando todos os dados.")
    return(dados)
  }
  ufs_cods <- codigo_uf$codigo[which(codigo_uf$estado %in% ufs)]
  filter(dados, SG_UF_NOT %in% ufs_cods) # nolint
}

for (i in seq_len(nrow(combinacoes))) {

  uf_  <- combinacoes$uf[i]
  sis  <- combinacoes$sis[i]
  ano  <- combinacoes$ano[i]

  tryCatch({
    dados <- fetch_datasus(
      year_start = ano,
      year_end = ano,
      information_system = sis,
      vars = filtro
    )

    if (nrow(dados) == 0) {
      message("Sem dados para ", sis, " - ", ano)
      next
    }

    dados <- filtrar_estados(dados, ufs)

    dados <- process_by_system(dados, sis)

    caminho_arquivo <- path_dados_filtrados_f(sis, uf_, ano)

    write_csv(dados, caminho_arquivo)
    message("✓ Arquivo salvo: ", caminho_arquivo)

  }, error = function(e) {
    message("✗ Erro em ", sis, " - ", uf_, " - ", ano, ": ", e$message)
  })
}

message("\n=== IMPORTAÇÃO FINALIZADA ===")