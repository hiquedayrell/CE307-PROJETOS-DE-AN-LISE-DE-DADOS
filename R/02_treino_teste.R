# =====================================================================
# 02_treino_teste.R
# Projeto: Eixo 4 — Educação Básica Municipal (parceria SME Curitiba)
# Disciplina: Projetos de Análise de Dados — 2026/2
#
# Objetivo: separar a base limpa em treino (90%) e teste (10%) e salvar
#   as duas em arquivo, para que todo o grupo use a mesma divisão.
#
# Entrada: data/amostra_limpa.csv  (gerada por R/01_preparacao_base.R)
# Saídas:  data/treino.csv
#          data/teste.csv
#
# Regra do grupo: os modelos são ajustados SÓ no treino. O teste fica
# guardado para a avaliação final e não deve ser usado para escolher
# variáveis nem comparar modelos.
# =====================================================================

library(tidyverse)

set.seed(123)   # semente fixa: garante que a divisão seja reprodutível


# ---------------------------------------------------------------------
# 1. Leitura da base limpa
# ---------------------------------------------------------------------

amostra_limpa <- read.csv("data/amostra_limpa.csv")

nrow(amostra_limpa)   # 10.068 alunos


# ---------------------------------------------------------------------
# 2. Sorteio do teste (10%), estratificado pelas duas variáveis resposta
# ---------------------------------------------------------------------
# O sorteio é feito dentro de cada combinação de abaixo_LP e abaixo_MT
# (0-0, 0-1, 1-0, 1-1). Assim o teste mantém a mesma proporção de alunos
# abaixo do básico em LP e em MT que a base completa.

teste <- amostra_limpa %>%
  group_by(abaixo_LP, abaixo_MT) %>%
  slice_sample(prop = 0.10) %>%
  ungroup()

# O treino é tudo o que não entrou no teste
treino <- amostra_limpa %>%
  anti_join(teste, by = "ID_ALUNO")


# ---------------------------------------------------------------------
# 3. Conferências
# ---------------------------------------------------------------------

# Nenhum aluno pode estar nas duas bases, e juntas devem somar a base toda
stopifnot(
  !any(duplicated(amostra_limpa$ID_ALUNO)),
  nrow(intersect(treino["ID_ALUNO"], teste["ID_ALUNO"])) == 0,
  nrow(treino) + nrow(teste) == nrow(amostra_limpa)
)

# Proporção de alunos abaixo do básico em cada base (devem ser parecidas)
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


# ---------------------------------------------------------------------
# 4. Exportação
# ---------------------------------------------------------------------

write.csv(treino, "data/treino.csv", row.names = FALSE)
write.csv(teste,  "data/teste.csv",  row.names = FALSE)
