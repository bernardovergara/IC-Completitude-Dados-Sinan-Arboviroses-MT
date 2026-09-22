
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("microdatasus")) install.packages("microdatasus")

# # Pipeline completo: Importação → Incompletude → Visualização

# message("=== INICIANDO PIPELINE ===")
# message("Data/Hora: ", Sys.time())

# # 1. Importar dados filtrados
# message("\n[1/5] Importando dados...")
# source("source/importar_filtrado.r")

# 2. Calcular incompletude
message("\n[2/5] Calculando incompletude...")
source("source/incompletude_proc.r")

# 3. Contar registros por doença
message("\n[3/5] Contando registros por doença...")
source("source/contar_doencas.r")

# 4. Gerar plots
message("\n[4/5] Gerando plots...")
source("source/plot_proc.r")

message("\n[5/5] Gerando tabelas...")
source("scripts/criar_tabelas.r")

message("\n=== PIPELINE FINALIZADO ===")
message("Data/Hora: ", Sys.time())