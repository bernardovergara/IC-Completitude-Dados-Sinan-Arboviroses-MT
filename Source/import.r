library(microdatasus)
library(tidyverse)

anos <- 2010:2011
uf_ <- "MT"
sis <- "SINAN-DENGUE"

for(ano in anos) {
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
        paste0("data//raw//dados_", sis, "_", as.character(ano), ".csv"),
        progress = show_progress()
    )
}