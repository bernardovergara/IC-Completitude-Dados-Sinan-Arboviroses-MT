library(microdatasus)
library(tidyverse)

# diretório de trabalho
source("wd.r")
setwd(wd)

source("caminhos.r")

anos <- 2010:2025
uf_ <- "MT"
sis <- "SINAN-DENGUE"

for (ano in anos) {
  dados <- fetch_datasus(
    year_start = ano,
    year_end = ano,
    uf = uf_,
    information_system = sis
  )

  if (sis == "SINAN-DENGUE") {
    dados <- process_sinan_dengue(dados)
  }

  write_csv(
    dados,
    paste0(dados_brutos$path, "dados_", sis, "_", as.character(ano), ".csv"),
    progress = show_progress()
  )
}