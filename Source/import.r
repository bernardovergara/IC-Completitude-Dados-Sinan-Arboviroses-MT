library(microdatasus)
library(dplyr)
library(lubridate)

importarDados <- TRUE
# Importar dados SINAN de dengue estado do Mato Grosso
if (importarDados) {
    dados_dengue_mt <- fetch_datasus(
    year_start = 2010,
    year_end = 2013,
    uf = "MT",
    information_system = "SINAN-DENGUE"
    )
    
    dados_dengue_mt <- process_sinan_dengue(dados_dengue_mt)
    
    write.csv(
        dados_dengue_mt,
        "data//raw//dengue_mt.csv"
    )

} else {
    dados_dengue_mt <- read.csv("data//raw//dengue_mt.csv")
}

