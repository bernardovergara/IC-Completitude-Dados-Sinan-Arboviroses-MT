library(tidyverse)
library(readr)

# diretório de trabalho
source("wd.r")
setwd(wd)

source("caminhos.r")
source("filtro.r")

filtro <- names(filtro)

entrada <- list.files(
  path = dados_brutos$path,
  pattern = dados_brutos$pattern,
  full.names = TRUE
)

saida <- c(
  path = dados_filtrados$path,
  prefix = dados_filtrados$prefix
)

filtrar_dados <- function(dados, filtro) {
  lapply(dados, dplyr::select(dplyr::all_of(filtro)))
}

exportar_dados <- function(dados) {
  lapply(dados, \(x) {
    write_csv(
      x,
      file.path(saida$path,
                paste0(saida$prefix, basename(x)))
    )
  })
}