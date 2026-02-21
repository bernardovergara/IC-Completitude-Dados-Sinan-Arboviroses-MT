library(microdatasus)
library(tidyverse)

# diretório de trabalho
source("wd.r")
setwd(wd)

source("caminhos.r")

anos <- 2010:2025
uf_ <- "MT"
sis <- "SINAN-DENGUE"

source("filtro.r")
filtro <- names(filtro)

# Adicione tryCatch para capturar erros
for (ano in anos) {
  tryCatch({
    dados <- fetch_datasus(
      year_start = ano,
      year_end = ano,
      uf = uf_,
      information_system = sis,
      vars = filtro
    )

    if (nrow(dados) > 0) {
      if (sis == "SINAN-DENGUE") {
        dados <- process_sinan_dengue(dados)
      }

      caminho_arquivo <- paste0(dados_brutos$path, "dados_", sis, "_", ano, ".csv") # nolint: line_length_linter.
      write_csv(dados, caminho_arquivo)
      print(paste("Arquivo salvo:", caminho_arquivo))
    } else {
      print(paste("Sem dados para", ano))
    }
  }, error = function(e) {
    print(paste("Erro no ano", ano, ":", e$message))
  })
}