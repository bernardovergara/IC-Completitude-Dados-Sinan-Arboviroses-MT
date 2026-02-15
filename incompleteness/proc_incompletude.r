library(tidyverse)
library(readr)

# diretório de trabalho
source("wd.r")
setwd(wd)

source("caminhos.r")
source("lerdados.r")
source("incompletude.r")

entrada <- list.files(
  path = dados_filtrados$path,
  pattern = dados_filtrados$pattern,
  full.names = TRUE
)

dados <- ler_dados(entrada)
incompletudes <- lapply(dados, \(x) calcular_incompletude(x))