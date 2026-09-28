# =====================================================================
# 00_codebook.R
# Projeto: Eixo 4 — Educação Básica Municipal (parceria SME Curitiba)
# Disciplina: Projetos de Análise de Dados — 2026/2
#
# Objetivo: gerar o codebook das variáveis da base de alunos do 5º ano
#   a partir do dicionário oficial do INEP, acrescentando as variáveis
#   criadas no projeto e o papel de cada variável na análise.
#
# Entrada: docs/Dicionario_Saeb_2023.xlsx (aba TS_ALUNO_5EF)
#   Fonte: microdados_saeb_2023.zip, pasta DICIONÁRIO
#
# Saídas:  docs/codebook.csv   (uma linha por variável)
#          docs/codebook.md    (versão para leitura)
# =====================================================================

library(tidyverse)
library(readxl)


# ---------------------------------------------------------------------
# 1. Leitura da aba do 5º ano
# ---------------------------------------------------------------------
# A aba tem duas partes, cada uma com seu próprio cabeçalho:
#   - variáveis de identificação, prova e proficiência (5 colunas);
#   - questionário do aluno (7 colunas, com código e texto da questão).
# Em ambas, a variável aparece só na primeira linha e as linhas de baixo
# trazem as demais categorias de resposta.

bruto <- read_excel(
  "docs/Dicionario_Saeb_2023.xlsx",
  sheet = "TS_ALUNO_5EF",
  col_names = FALSE,
  col_types = "text",
  .name_repair = ~ paste0("c", seq_along(.x))
)

inicio_quest <- which(bruto$c4 == "Código da Questão")


# ---------------------------------------------------------------------
# 2. Uma linha por variável, com as categorias juntas
# ---------------------------------------------------------------------

junta_categorias <- function(cod, txt) {
  ok <- !is.na(cod) | !is.na(txt)
  paste(
    if_else(is.na(txt[ok]), cod[ok], paste(cod[ok], "=", txt[ok])),
    collapse = "; "
  )
}

gerais <- bruto %>%
  slice(4:(inicio_quest - 1)) %>%
  fill(c1, c2, c3, c4) %>%
  filter(!is.na(c1)) %>%
  group_by(variavel = c1) %>%
  summarise(
    tipo      = first(c2),
    tamanho   = first(c3),
    questao   = NA_character_,
    descricao = first(c4),
    categorias = paste(na.omit(c5), collapse = "; "),
    .groups = "drop"
  )

questionario <- bruto %>%
  slice((inicio_quest + 1):n()) %>%
  fill(c1, c2, c3, c4, c5) %>%
  filter(!is.na(c1)) %>%
  group_by(variavel = c1) %>%
  summarise(
    tipo      = first(c2),
    tamanho   = first(c3),
    questao   = first(c4),
    descricao = first(c5),
    categorias = junta_categorias(c6, c7),
    .groups = "drop"
  )

# Mantém a ordem das colunas do dicionário (igual à da base)
ordem <- unique(na.omit(bruto$c1[-c(1:3, inicio_quest)])) %>%
  str_replace("^TX_RESP_BLOCO_(\\d)_CH$", "TX_RESP_BLOCO\\1_CH")

codebook <- bind_rows(gerais, questionario) %>%
  mutate(
    categorias = na_if(categorias, ""),
    origem = "INEP",
    # o dicionário escreve TX_RESP_BLOCO_1_CH, mas a base usa TX_RESP_BLOCO1_CH
    variavel = str_replace(variavel, "^TX_RESP_BLOCO_(\\d)_CH$", "TX_RESP_BLOCO\\1_CH")
  ) %>%
  arrange(match(variavel, ordem))


# ---------------------------------------------------------------------
# 3. Variáveis criadas no projeto (01_preparacao_base.R)
# ---------------------------------------------------------------------

criadas <- tribble(
  ~variavel,   ~tipo, ~tamanho, ~descricao,                                                        ~categorias,
  "abaixo_LP", "Num", "1",      "Aluno abaixo do nível básico em Língua Portuguesa (PROFICIENCIA_LP_SAEB <= 150)", "0 = Básico ou acima; 1 = Abaixo do básico",
  "abaixo_MT", "Num", "1",      "Aluno abaixo do nível básico em Matemática (PROFICIENCIA_MT_SAEB <= 175)",        "0 = Básico ou acima; 1 = Abaixo do básico"
) %>%
  mutate(questao = NA_character_, origem = "Projeto")

codebook <- bind_rows(codebook, criadas)


# ---------------------------------------------------------------------
# 4. Papel de cada variável no projeto
# ---------------------------------------------------------------------

filtros <- c(
  "IN_SITUACAO_CENSO", "IN_PREENCHIMENTO_LP", "IN_PREENCHIMENTO_MT",
  "IN_PRESENCA_LP", "IN_PRESENCA_MT", "IN_PREENCHIMENTO_QUESTIONARIO",
  "IN_PROFICIENCIA_LP", "IN_PROFICIENCIA_MT"
)

codebook <- codebook %>%
  mutate(papel = case_when(
    variavel %in% c("abaixo_LP", "abaixo_MT")          ~ "Resposta",
    variavel %in% c("PROFICIENCIA_LP_SAEB",
                    "PROFICIENCIA_MT_SAEB")            ~ "Origem da resposta",
    variavel %in% filtros                              ~ "Filtro de qualidade",
    variavel == "ID_UF"                                ~ "Estrato da amostra",
    str_starts(variavel, "TX_RESP_Q")                  ~ "Preditor (questionário)",
    str_starts(variavel, "ID_")                        ~ "Identificação",
    TRUE                                               ~ "Não utilizada"
  )) %>%
  select(variavel, origem, papel, tipo, tamanho, questao, descricao, categorias)


# ---------------------------------------------------------------------
# 5. Conferência com as colunas da base bruta
# ---------------------------------------------------------------------

colunas_base <- names(read.csv("data/raw/TS_ALUNO_5EF.csv", sep = ";", nrows = 1))

setdiff(colunas_base, codebook$variavel)                   # na base, fora do codebook
setdiff(codebook$variavel[codebook$origem == "INEP"], colunas_base)  # no codebook, fora da base


# ---------------------------------------------------------------------
# 6. Exportação
# ---------------------------------------------------------------------

write.csv(codebook, "docs/codebook.csv", row.names = FALSE, fileEncoding = "UTF-8")

linha_md <- function(x) str_replace_all(replace_na(x, ""), "\\|", "/")

md <- c(
  "# Codebook — Saeb 2023, alunos do 5º ano",
  "",
  "Gerado por `R/00_codebook.R` a partir do dicionário oficial do INEP",
  "(`docs/Dicionario_Saeb_2023.xlsx`, aba `TS_ALUNO_5EF`), mais as variáveis",
  "criadas em `R/01_preparacao_base.R`.",
  "",
  "No questionário, `*` = resposta nula e `.` = em branco. Alunos com qualquer",
  "um desses códigos foram excluídos da amostra limpa.",
  "",
  "## Resumo por papel",
  "",
  "| Papel | Nº de variáveis |",
  "|---|---|",
  codebook %>% count(papel) %>% glue::glue_data("| {papel} | {n} |"),
  "",
  "## Variáveis",
  "",
  "| Variável | Papel | Tipo | Descrição | Categorias |",
  "|---|---|---|---|---|",
  codebook %>%
    glue::glue_data(
      "| `{variavel}` | {papel} | {tipo} | {linha_md(descricao)} | {linha_md(categorias)} |"
    )
)

writeLines(md, "docs/codebook.md", useBytes = FALSE)
