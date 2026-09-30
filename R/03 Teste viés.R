library(tidyverse)

dados <- read.csv("data/raw/TS_ALUNO_5EF.csv", header = TRUE, sep = ";")

questoes <- names(dados)[startsWith(names(dados), "TX_RESP_Q")]

dados <- dados %>%
  mutate(
    n_invalidas = rowSums(across(all_of(questoes), ~ .x %in% c(".", "*", NA))),
    abaixo_LP   = if_else(PROFICIENCIA_LP_SAEB <= 150, 1, 0),
    abaixo_MT   = if_else(PROFICIENCIA_MT_SAEB <= 175, 1, 0)
  )

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
    removidos    = lag(alunos) - alunos,
    pct_restante = round(100 * alunos / first(alunos), 1)
  ) %>%
  print(n = Inf)

validos <- dados %>%
  filter(!!!unname(filtros[-length(filtros)]))

validos %>%
  mutate(faixa = cut(n_invalidas, c(-Inf, 0, 1, 2, 5, 10, Inf),
                     labels = c("0 (fica)", "1", "2", "3 a 5", "6 a 10", "mais de 10"))) %>%
  count(faixa) %>%
  mutate(pct = round(100 * n / sum(n), 1))

validos %>%
  summarise(across(all_of(questoes), ~ mean(.x %in% c(".", "*", NA)))) %>%
  pivot_longer(everything(), names_to = "variavel", values_to = "pct_invalido") %>%
  mutate(pct_invalido = round(100 * pct_invalido, 1)) %>%
  arrange(desc(pct_invalido)) %>%
  print(n = 15)

validos %>%
  mutate(grupo = if_else(n_invalidas == 0, "Fica (questionário completo)",
                                           "Sai (alguma pergunta inválida)")) %>%
  group_by(grupo) %>%
  summarise(
    alunos        = n(),
    media_LP      = round(mean(PROFICIENCIA_LP_SAEB), 1),
    media_MT      = round(mean(PROFICIENCIA_MT_SAEB), 1),
    pct_abaixo_LP = round(100 * mean(abaixo_LP), 1),
    pct_abaixo_MT = round(100 * mean(abaixo_MT), 1)
  )
