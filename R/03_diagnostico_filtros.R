# =====================================================================
# 03_diagnostico_filtros.R
# Projeto: Eixo 4 — Educação Básica Municipal (parceria SME Curitiba)
# Disciplina: Projetos de Análise de Dados — 2026/2
#
# Objetivo: avaliar os filtros de qualidade de R/01_preparacao_base.R,
#   usando a base completa do 5º ano (sem sorteio):
#   1. quantos alunos cada filtro remove;
#   2. quais perguntas do questionário mais causam exclusões;
#   3. se os alunos excluídos por questionário incompleto têm desempenho
#      diferente dos que ficaram (viés de seleção).
#
# Entrada: data/raw/TS_ALUNO_5EF.csv
# Saída:   apenas resultados no console (não altera nenhuma base)
# =====================================================================

library(tidyverse)


# ---------------------------------------------------------------------
# 1. Leitura
# ---------------------------------------------------------------------

dados <- read.csv("data/raw/TS_ALUNO_5EF.csv", header = TRUE, sep = ";")

questoes <- names(dados)[startsWith(names(dados), "TX_RESP_Q")]

# Nº de perguntas em branco (".") ou inválidas ("*") por aluno
dados <- dados %>%
  mutate(
    n_invalidas = rowSums(across(all_of(questoes), ~ .x %in% c(".", "*", NA))),
    abaixo_LP   = if_else(PROFICIENCIA_LP_SAEB <= 150, 1, 0),
    abaixo_MT   = if_else(PROFICIENCIA_MT_SAEB <= 175, 1, 0)
  )


# ---------------------------------------------------------------------
# 2. Funil: alunos restantes após cada filtro, na ordem do script
# ---------------------------------------------------------------------

filtros <- list(
  "Situação consistente no Censo"   = quote(IN_SITUACAO_CENSO != 0),
  "Presente na prova de LP"         = quote(IN_PRESENCA_LP != 0),
  "Presente na prova de MT"         = quote(IN_PRESENCA_MT != 0),
  "Preencheu a prova de LP"         = quote(IN_PREENCHIMENTO_LP != 0),
  "Preencheu a prova de MT"         = quote(IN_PREENCHIMENTO_MT != 0),
  "Tem proficiência em LP"          = quote(IN_PROFICIENCIA_LP != 0),
  "Tem proficiência em MT"          = quote(IN_PROFICIENCIA_MT != 0),
  "Preencheu o questionário"        = quote(IN_PREENCHIMENTO_QUESTIONARIO != 0),
  "Respondeu TODAS as 70 perguntas" = quote(n_invalidas == 0)
)

restantes <- nrow(dados)
funil <- tibble(etapa = "Base original", alunos = restantes)
base <- dados
for (nome in names(filtros)) {
  base <- filter(base, !!filtros[[nome]])
  funil <- add_row(funil, etapa = nome, alunos = nrow(base))
}

funil %>%
  mutate(
    removidos   = lag(alunos) - alunos,
    pct_restante = round(100 * alunos / first(alunos), 1)
  ) %>%
  print(n = Inf)


# ---------------------------------------------------------------------
# 3. Quais perguntas mais eliminam alunos
# ---------------------------------------------------------------------
# Considera só quem passou por todos os filtros do INEP (tem nota e
# preencheu o questionário), para isolar o efeito das perguntas.

validos <- dados %>%
  filter(!!!unname(filtros[-length(filtros)]))

# Quantas perguntas inválidas os alunos excluídos costumam ter
validos %>%
  mutate(faixa = cut(n_invalidas, c(-Inf, 0, 1, 2, 5, 10, Inf),
                     labels = c("0 (fica)", "1", "2", "3 a 5", "6 a 10", "mais de 10"))) %>%
  count(faixa) %>%
  mutate(pct = round(100 * n / sum(n), 1))

# % de branco/inválido em cada pergunta (as 15 piores)
validos %>%
  summarise(across(all_of(questoes), ~ mean(.x %in% c(".", "*", NA)))) %>%
  pivot_longer(everything(), names_to = "variavel", values_to = "pct_invalido") %>%
  mutate(pct_invalido = round(100 * pct_invalido, 1)) %>%
  arrange(desc(pct_invalido)) %>%
  print(n = 15)


# ---------------------------------------------------------------------
# 4. Viés de seleção: quem sai é diferente de quem fica?
# ---------------------------------------------------------------------
# Entre os alunos com nota válida, compara os que responderam o
# questionário inteiro (ficam na amostra) com os que deixaram alguma
# pergunta em branco (saem). Se o desempenho for muito diferente, a
# amostra final não representa bem os alunos do 5º ano.

validos %>%
  mutate(grupo = if_else(n_invalidas == 0, "Fica (questionário completo)",
                                           "Sai (alguma pergunta inválida)")) %>%
  group_by(grupo) %>%
  summarise(
    alunos       = n(),
    media_LP     = round(mean(PROFICIENCIA_LP_SAEB), 1),
    media_MT     = round(mean(PROFICIENCIA_MT_SAEB), 1),
    pct_abaixo_LP = round(100 * mean(abaixo_LP), 1),
    pct_abaixo_MT = round(100 * mean(abaixo_MT), 1)
  )
