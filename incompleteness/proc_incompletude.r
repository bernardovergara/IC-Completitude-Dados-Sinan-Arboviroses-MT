library(tidyverse)
library(readr)

# diretório de trabalho
source("wd.r")
setwd(wd)

source("caminhos.r")
source("lerdados.r")
source("incompleteness/incompletude.r")

entrada <- list.files(
  path = dados_brutos$path,
  pattern = dados_filtrados$pattern,
  full.names = TRUE
)

dados <- ler_dados(entrada)
incompletudes <- lapply(dados, \(x) calcular_incompletude(x))

n = 0
ano_inicio = 2010
for (incompletude in incompletudes) {
  ano = ano_inicio + n
  write_csv(incompletude, paste0("incompletude_", ano, ".csv")) 
  n = n + 1
}