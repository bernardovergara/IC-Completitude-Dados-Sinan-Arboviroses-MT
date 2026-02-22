# Pipeline completo: Importação → Incompletude → Visualização

message("=== INICIANDO PIPELINE ===")
message("Data/Hora: ", Sys.time())

# 1. Importar dados filtrados
message("\n[1/3] Importando dados...")
source("source/importar_filtrado.r")

# 2. Calcular incompletude
message("\n[2/3] Calculando incompletude...")
source("source/incompletude_proc.r")

# 3. Gerar plots
message("\n[3/3] Gerando plots...")
source("source/plot_proc.r")

message("\n=== PIPELINE FINALIZADO ===")
message("Data/Hora: ", Sys.time())