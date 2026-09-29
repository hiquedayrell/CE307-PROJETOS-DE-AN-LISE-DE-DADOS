library(tidyverse)

set.seed(123)

amostra_limpa <- read.csv("data/amostra_limpa.csv")

nrow(amostra_limpa)

teste <- amostra_limpa %>%
  group_by(abaixo_LP, abaixo_MT) %>%
  slice_sample(prop = 0.10) %>%
  ungroup()

treino <- amostra_limpa %>%
  anti_join(teste, by = "ID_ALUNO")

stopifnot(
  !any(duplicated(amostra_limpa$ID_ALUNO)),
  nrow(intersect(treino["ID_ALUNO"], teste["ID_ALUNO"])) == 0,
  nrow(treino) + nrow(teste) == nrow(amostra_limpa)
)

bind_rows(
  completa = amostra_limpa,
  treino   = treino,
  teste    = teste,
  .id = "base"
) %>%
  group_by(base) %>%
  summarise(
    alunos    = n(),
    abaixo_LP = mean(abaixo_LP),
    abaixo_MT = mean(abaixo_MT)
  )

write.csv(treino, "data/treino.csv", row.names = FALSE)
write.csv(teste,  "data/teste.csv",  row.names = FALSE)
