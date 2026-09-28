# =====================================================================
# 01_preparacao_base.R
# Projeto: Eixo 4 — Educação Básica Municipal (parceria SME Curitiba)
# Disciplina: Projetos de Análise de Dados — 2026/2
#
# Objetivo: a partir dos microdados do Saeb 2023 (alunos do 5º ano),
#   1. sortear uma amostra estratificada por UF;
#   2. manter apenas alunos com prova e questionário válidos;
#   3. criar as variáveis resposta (abaixo do nível básico em LP e MT).
#
# A separação em treino e teste fica em R/02_treino_teste.R.
#
# Entrada: TS_ALUNO_5EF.csv
#   Fonte: https://download.inep.gov.br/microdados/microdados_saeb_2023.zip
#   (arquivo de alunos do 5º ano, dentro da pasta DADOS do zip)
#
# Saída:   data/amostra_limpa.csv
#
# Para reproduzir: rode o script inteiro, de cima para baixo, numa sessão
# nova do R. A semente abaixo só garante o mesmo sorteio nessa condição.
# =====================================================================

library(tidyverse)

set.seed(123)   # semente fixa: garante que o sorteio seja reprodutível


# ---------------------------------------------------------------------
# 1. Leitura da base de alunos do 5º ano
# ---------------------------------------------------------------------
# Arquivo do INEP separado por ponto e vírgula.
# Ajuste o caminho para o local onde o zip foi descompactado.

dados <- read.csv("data/raw/TS_ALUNO_5EF.csv", header = TRUE, sep = ";")

nrow(dados)   # total de alunos na base original (2.442.143)


# ---------------------------------------------------------------------
# 2. Tamanho da amostra por UF (estratificação proporcional)
# ---------------------------------------------------------------------
# Cada UF recebe uma fatia da amostra proporcional ao seu número de
# alunos na base original. O total sorteado é de 32.000 alunos, maior
# que o tamanho final desejado, para compensar as perdas dos filtros
# de qualidade da etapa 4.

tamanhos <- dados %>%
  group_by(ID_UF) %>%
  summarise(
    n       = n(),                        # alunos da UF na base original
    peso    = n / nrow(dados),            # participação da UF no total
    amostra = round(peso * 32000)         # alunos a sortear na UF
  ) %>%
  arrange(desc(n))

print(tamanhos, n = 27)


# ---------------------------------------------------------------------
# 3. Sorteio da amostra estratificada
# ---------------------------------------------------------------------
# Dentro de cada UF, sorteia aleatoriamente (sem reposição) o número de
# alunos definido na etapa anterior.

amostra <- dados %>%
  group_by(ID_UF) %>%
  group_modify(~ slice_sample(
    .x,
    n = tamanhos$amostra[tamanhos$ID_UF == .y$ID_UF]
  )) %>%
  ungroup()

nrow(amostra)   # alunos sorteados (~32.000)


# ---------------------------------------------------------------------
# 4. Filtros de qualidade
# ---------------------------------------------------------------------
# Mantém apenas alunos que:
#   - têm situação consistente no Censo Escolar;
#   - estiveram presentes e preencheram as provas de LP e MT;
#   - têm proficiência calculada em LP e MT;
#   - preencheram o questionário do aluno;
#   - responderam TODAS as perguntas do questionário
#     (no INEP, "." = não respondeu e "*" = resposta inválida).

amostra_limpa <- amostra %>%
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

nrow(amostra_limpa)   # alunos após os filtros (10.068)


# ---------------------------------------------------------------------
# 5. Variáveis resposta (dicotômicas)
# ---------------------------------------------------------------------
# 1 = abaixo do nível básico · 0 = básico ou acima
# Cortes para o 5º ano na escala Saeb (Soares, 2009):
#   Língua Portuguesa: até 150 pontos
#   Matemática:        até 175 pontos

amostra_limpa <- amostra_limpa %>%
  mutate(
    abaixo_LP = if_else(PROFICIENCIA_LP_SAEB <= 150, 1, 0),
    abaixo_MT = if_else(PROFICIENCIA_MT_SAEB <= 175, 1, 0)
  )


# ---------------------------------------------------------------------
# 6. Exportação da base limpa
# ---------------------------------------------------------------------

write.csv(amostra_limpa, "data/amostra_limpa.csv", row.names = FALSE)
