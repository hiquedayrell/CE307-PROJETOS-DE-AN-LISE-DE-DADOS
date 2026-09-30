library(tidyverse)

dados <- read.csv("data/raw/TS_ALUNO_5EF.csv", header = TRUE, sep = ";")

curitiba <- dados %>%
  filter(ID_UF == 41, ID_AREA == 1)

nrow(curitiba)

curitiba_limpa <- curitiba %>%
  filter(
    IN_SITUACAO_CENSO             != 0,
    IN_PREENCHIMENTO_LP           != 0,
    IN_PREENCHIMENTO_MT           != 0,
    IN_PRESENCA_LP                != 0,
    IN_PRESENCA_MT                != 0,
    IN_PREENCHIMENTO_QUESTIONARIO != 0,
    IN_PROFICIENCIA_LP            != 0,
    IN_PROFICIENCIA_MT            != 0
  ) %>%
  filter(if_all(starts_with("TX_RESP_Q"), ~ !.x %in% c(".", "*", NA)))

nrow(curitiba_limpa)

curitiba_limpa <- curitiba_limpa %>%
  mutate(
    abaixo_LP = if_else(PROFICIENCIA_LP_SAEB <= 150, 1, 0),
    abaixo_MT = if_else(PROFICIENCIA_MT_SAEB <= 175, 1, 0)
  )

curitiba_limpa %>%
  summarise(
    alunos    = n(),
    escolas   = n_distinct(ID_ESCOLA),
    publicas  = mean(IN_PUBLICA),
    abaixo_LP = mean(abaixo_LP),
    abaixo_MT = mean(abaixo_MT)
  )

write.csv(curitiba_limpa, "data/curitiba_limpa.csv", row.names = FALSE)
