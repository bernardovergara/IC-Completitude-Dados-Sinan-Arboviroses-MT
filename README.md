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

### Geração do artigo final (`.docx`)

Para gerar a versão final do paper em Word, pronta para submissão à RESS:

```bash
quarto render paper_corrigido.qmd --to docx
```

O comando produz `paper_corrigido.docx`. A renderização **não** refaz a análise:
os chunks de R no arquivo estão desativados (`eval: false`) e servem apenas de documentação do pipeline. O documento é montado a partir de artefatos já existentes no repositório.

**Arquivos evocados na renderização:**

| Arquivo | Papel |
| --- | --- |
| `ress-reference.docx` | Template de estilo (Times New Roman 12, A4, margens 1,5 cm) |
| `plots/plot_incompletude_SINAN_agregado_por_ano.png` | Figura 1 |
| `plots/plot_incompletude_SINAN-DENGUE_por_ano.png` | Figura 2 |
| `plots/plot_incompletude_SINAN-CHIKUNGUNYA_por_ano.png` | Figura 3 |
| `plots/plot_incompletude_SINAN-ZIKA_por_ano.png` | Figura 4 |

**Arquivos citados apenas nos chunks de documentação** (não lidos na renderização,
por estarem com `eval: false`) — reproduzem o pipeline que gera os insumos acima:
`config.r`, `packages/system_process_mapping.r`, `data/utils/uf_ibge_cods.csv`,
`source/incompletude_proc.r`, `source/plot_proc.r` e `source/paper_assets_base.r`.

> Caso os gráficos ainda não existam em `plots/`, gere-os antes com
> `Rscript pipeline.r` seguido de `Rscript source/paper_assets_base.r`.

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
