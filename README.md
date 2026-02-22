# Análise de completude de dados do Datasus

## 📋 Descrição

Este projeto realiza o cálculo e visualização de indicadores de incompletude de variáveis essenciais em bases de dados do **Datasus** cobrindo múltiplos anos de análise.


## 🚀 Quick Start

### Pré-requisitos
- R 4.0+
- Pacotes: `tidyverse`, `microdatasus`

### Configuração

Edite `config.r` para definir:

```r
anos <- 2010:2025           # Anos a analisar
ufs  <- "MT"                # Unidades Federativas
siss <- c(                  # Sistemas de informação
  "SINAN-DENGUE",
  "SINAN-CHIKUNGUNYA",
  "SINAN-ZIKA",
  ...
)
```

### Execução

```bash
Rscript pipeline.r
```

O pipeline executa automaticamente em 3 etapas:
1. **Importação**: Download e filtragem dos dados do DATASUS
2. **Cálculo de Incompletude**: Processamento de variáveis
3. **Visualização**: Geração de gráficos de evolução temporal

## 📈 Saídas

### Arquivos de Incompletude
Formato: `incompletude_<SISTEMA>_<UF>_<ANO>.csv`

Exemplo: `incompletude_SINAN-DENGUE_MT_2010.csv`

### Gráficos
Formato: `plot_incompletude_<SISTEMA>_por_ano.png`

Exemplo: `plot_incompletude_SINAN-DENGUE_por_ano.png`

Mostra a evolução temporal das variáveis de incompletude para cada sistema.

## 📚 Referências

- [DATASUS - Microdados](https://www2.datasus.gov.br/)
- [Pacote microdatasus](https://github.com/rfsaldanha/microdatasus)
- [SINAN - Documentação](http://portalsinan.saude.gov.br/)

<br>
👨‍💻 Desenvolvido como Iniciação Científica (IC) - Universidade Federal de Rondonópolis
