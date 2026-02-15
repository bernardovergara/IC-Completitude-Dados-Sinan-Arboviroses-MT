library(readr)

ler_dados <- function(caminho) {
  tryCatch(
    lapply(caminho, \(x) read_csv(x, progress = show_progress())),
    error = function(e) {
      message("Arquivo não encontrado ou corrompido: ", e$message)
      NULL
    }
  )
}