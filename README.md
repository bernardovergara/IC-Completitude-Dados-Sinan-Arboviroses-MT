# Análise da completude dos dados do SINAN

Este projeto calcula e visualiza indicadores de incompletude de variáveis essenciais em registros do Sistema de Informação de Agravos de Notificação (SINAN), com foco em dengue, chikungunya e zika no estado de Mato Grosso.

## Estrutura

```text
artigo-completude-sinan-arboviroses.qmd  Manuscrito Quarto
referencias.bib                          Referências bibliográficas
modelo/                                   Modelo DOCX, CSS e estilo CSL
scripts/                                  Configuração, tabelas e pipeline
source/                                   Etapas de processamento
data/                                     Dados filtrados e processados
packages/                                 Funções auxiliares
plots/                                    Gráficos gerados
```

## Requisitos

- R 4.0 ou superior
- Quarto
- Pacotes R: `tidyverse`, `microdatasus` e `knitr`

O pipeline instala `tidyverse` e `microdatasus` quando necessário. O manuscrito instala `knitr` automaticamente durante a renderização, caso o pacote não esteja disponível.

## Configuração

Edite [`scripts/config.r`](scripts/config.r) para definir os anos, a unidade federativa, os sistemas de informação e as variáveis analisadas:

```r
anos <- 2010:2025
ufs  <- c("MT")
siss <- c("SINAN-DENGUE", "SINAN-CHIKUNGUNYA", "SINAN-ZIKA")
```

## Execução

Execute os comandos a partir da raiz do projeto:

```bash
Rscript pipeline.r
```

O pipeline executa as seguintes etapas:

1. Calcula a incompletude dos arquivos disponíveis em `data/filtered/`.
2. Conta os registros por doença e por ano.
3. Gera gráficos de evolução da incompletude em `plots/`.
4. Gera tabelas resumidas em `data/tables/`.

A etapa de importação e filtragem dos dados do DATASUS está disponível em [`source/importar_filtrado.r`](source/importar_filtrado.r), mas permanece comentada no pipeline. Para executá-la, descomente a chamada correspondente em [`pipeline.r`](pipeline.r).

## Manuscrito

O manuscrito é renderizado com:

- [`modelo/modelo.docx`](modelo/modelo.docx) como modelo do Word;
- [`referencias.bib`](referencias.bib) como banco bibliográfico;
- [`modelo/vancouver.csl`](modelo/vancouver.csl) como estilo de citações.

Para gerar o DOCX:

```bash
quarto render artigo-completude-sinan-arboviroses.qmd --to docx
```

Os heatmaps usados no manuscrito são construídos pelo script [`scripts/criar_tabelas.r`](scripts/criar_tabelas.r) e inseridos diretamente nos blocos R do documento.

## Saídas

Arquivos de incompletude:

```text
data/processed/incompletude_<SISTEMA>_<UF>_<ANO>.csv
```

Contagens:

```text
data/processed/contagem_doencas_por_ano.csv
data/processed/contagem_doencas_total.csv
```

Tabelas resumidas:

```text
data/tables/tabela_incompletude_dengue.csv
data/tables/tabela_incompletude_chikungunya.csv
data/tables/tabela_incompletude_zika.csv
data/tables/tabela_incompletude_consolidada.csv
data/tables/tabela_incompletude_arboviroses_agregado.csv
```

Gráficos de evolução:

```text
plots/plot_incompletude_SINAN-DENGUE_por_ano.png
plots/plot_incompletude_SINAN-CHIKUNGUNYA_por_ano.png
plots/plot_incompletude_SINAN-ZIKA_por_ano.png
```

## Referências externas

- [DATASUS - Microdados](https://www2.datasus.gov.br/)
- [Pacote microdatasus](https://github.com/rfsaldanha/microdatasus)
- [SINAN - Documentação](http://portalsinan.saude.gov.br/)

Projeto desenvolvido como Iniciação Científica (IC) na Universidade Federal de Rondonópolis.
