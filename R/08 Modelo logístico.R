# =====================================================================
# 08 Modelo logístico.R
# Projeto: Eixo 4 — Educação Básica Municipal (parceria SME Curitiba)
#
# Objetivo:
#   1. estimar, na base de TREINO, uma regressão logística para cada
#      resposta (abaixo_LP e abaixo_MT) com as 18 variáveis dicotômicas
#      da seção 4 do relatório descritivo revisado;
#   2. manter só as variáveis significativas (p < 0,05) e reestimar;
#   3. interpretar cada variável pela razão de chances (odds ratio);
#   4. verificar na base de TESTE se os dados vão na mesma direção do
#      modelo (proporções condicionais), a calibração e a AUC;
#   5. comparar com os coeficientes enviados pelo professor.
#
# Entradas: data/treino.csv, data/teste.csv,
#           data/modelo/coeficientes_LP.csv e coeficientes_MT.csv (professor)
# Saídas:   data/modelo/modelo_grupo_LP.csv e modelo_grupo_MT.csv
#           data/modelo/verificacao_teste.csv
# =====================================================================

library(tidyverse)

treino <- read.csv("data/treino.csv")
teste  <- read.csv("data/teste.csv")


# ---------------------------------------------------------------------
# 1. As 18 variáveis dicotômicas da seção 4
# ---------------------------------------------------------------------
# Cada variável vale 1 se o aluno está no grupo descrito e 0 caso contrário.

grupos <- tribble(
  ~nome,            ~bloco,                 ~grupo,                                        ~variavel,            ~cods,
  "reprovou",       "Trajetória escolar",   "Já reprovou ao menos uma vez",                "TX_RESP_Q19",        "B,C",
  "idade_12",       "Trajetória escolar",   "Tem 12 anos ou mais",                         "TX_RESP_Q02",        "D,E,F",
  "abandonou",      "Trajetória escolar",   "Já abandonou a escola",                       "TX_RESP_Q20",        "B,C",
  "entrada_8",      "Trajetória escolar",   "Entrou na escola com 8 anos ou mais",         "TX_RESP_Q17",        "D",
  "inse_baixo",     "Nível socioeconômico", "INSE nos níveis I e II",                      "NU_TIPO_NIVEL_INSE", "1,2",
  "mae_5ano",       "Nível socioeconômico", "Mãe estudou até o 5º ano",                    "TX_RESP_Q08",        "A,B",
  "sem_mae",        "Nível socioeconômico", "Não mora com a mãe",                          "TX_RESP_Q07a",       "A",
  "sem_wifi",       "Nível socioeconômico", "Sem Wi-Fi em casa",                           "TX_RESP_Q13b",       "A",
  "sem_asfalto",    "Entorno",              "Rua sem asfalto ou calçamento",               "TX_RESP_Q11a",       "A",
  "sem_iluminacao", "Entorno",              "Rua sem iluminação",                          "TX_RESP_Q11c",       "A",
  "rural",          "Entorno",              "Escola rural",                                "ID_LOCALIZACAO",     "2",
  "trabalha_fora",  "Rotina",               "Trabalha fora de casa",                       "TX_RESP_Q21d",       "B,C,D",
  "sem_lazer",      "Rotina",               "Não tem tempo de lazer",                      "TX_RESP_Q21e",       "A",
  "nao_estuda",     "Rotina",               "Não estuda fora da escola",                   "TX_RESP_Q21a",       "A",
  "prof_nao_acred", "Relação com a escola", "Discorda que os professores acreditam nele",  "TX_RESP_Q23h",       "C,D",
  "deficiencia",    "Inclusão",             "Declara deficiência",                         "TX_RESP_Q05a",       "B",
  "tea",            "Inclusão",             "Declara transtorno do espectro autista",      "TX_RESP_Q05b",       "B",
  "pouco_incentivo","Família",              "Pouco incentivo para ir às aulas",            "TX_RESP_Q10e",       "A,B"
)

# Cria as 18 colunas 0/1 em uma base
cria_dicotomicas <- function(dados) {
  for (i in seq_len(nrow(grupos))) {
    codigos <- str_split(grupos$cods[i], ",")[[1]]
    dados[[grupos$nome[i]]] <- as.integer(as.character(dados[[grupos$variavel[i]]]) %in% codigos)
  }
  dados
}

treino <- cria_dicotomicas(treino)
teste  <- cria_dicotomicas(teste)


# ---------------------------------------------------------------------
# 2. Estimação: modelo completo -> seleção (p < 0,05) -> modelo final
# ---------------------------------------------------------------------

ajusta <- function(resposta, variaveis) {
  glm(reformulate(variaveis, resposta), data = treino, family = binomial)
}

# Tabela de coeficientes com razão de chances e IC de 95% (Wald, como no statsmodels)
tabela_modelo <- function(modelo) {
  coefs <- summary(modelo)$coefficients
  tibble(
    nome        = rownames(coefs),
    coeficiente = coefs[, "Estimate"],
    erro_padrao = coefs[, "Std. Error"],
    p_valor     = coefs[, "Pr(>|z|)"],
    odds_ratio  = exp(coeficiente),
    ic_inf      = exp(coeficiente - 1.96 * erro_padrao),
    ic_sup      = exp(coeficiente + 1.96 * erro_padrao)
  )
}

estima <- function(resposta) {
  completo <- ajusta(resposta, grupos$nome)
  tab      <- tabela_modelo(completo)
  mantidas <- tab$nome[tab$p_valor < 0.05 & tab$nome != "(Intercept)"]
  final    <- ajusta(resposta, mantidas)
  list(completo = completo, final = final, mantidas = mantidas,
       removidas = setdiff(grupos$nome, mantidas))
}

modelos <- list(LP = estima("abaixo_LP"), MT = estima("abaixo_MT"))

# Variáveis que saíram em cada modelo (não significativas junto com as demais)
modelos$LP$removidas
modelos$MT$removidas

coeficientes <- map(modelos, \(m) {
  tabela_modelo(m$final) %>%
    left_join(select(grupos, nome, bloco, grupo), by = "nome") %>%
    mutate(grupo = coalesce(grupo, "Intercepto")) %>%
    select(bloco, grupo, nome, everything())
})

coeficientes$LP %>% mutate(across(where(is.numeric), \(x) round(x, 3))) %>% print(n = Inf, width = Inf)
coeficientes$MT %>% mutate(across(where(is.numeric), \(x) round(x, 3))) %>% print(n = Inf, width = Inf)

write.csv(coeficientes$LP, "data/modelo/modelo_grupo_LP.csv", row.names = FALSE)
write.csv(coeficientes$MT, "data/modelo/modelo_grupo_MT.csv", row.names = FALSE)


# ---------------------------------------------------------------------
# 3. Interpretação
# ---------------------------------------------------------------------
# Intercepto: chance de estar abaixo do básico de um aluno SEM nenhuma
# das características do modelo. plogis() transforma em probabilidade.
#
# Razão de chances (OR) de uma variável: por quanto a CHANCE (p / (1 - p))
# é multiplicada quando o aluno tem a característica, mantendo as outras
# iguais. OR = 1,85 significa chance 85% maior. Não é "85% mais provável":
# chance e probabilidade só são parecidas quando o evento é raro.

map_dbl(modelos, \(m) plogis(coef(m$final)[["(Intercept)"]]))   # probabilidade base

# Exemplo: aluno sem nenhum fator x aluno que só reprovou x reprovou e trabalha fora
exemplo <- function(m, ...) {
  perfil <- as_tibble(setNames(as.list(rep(0, length(m$mantidas))), m$mantidas))
  for (v in c(...)) perfil[[v]] <- 1
  predict(m$final, perfil, type = "response")
}
exemplo(modelos$LP)
exemplo(modelos$LP, "reprovou")
exemplo(modelos$LP, "reprovou", "trabalha_fora")


# ---------------------------------------------------------------------
# 4. Verificação na base de teste
# ---------------------------------------------------------------------

## 4.1 Proporções condicionais --------------------------------------------
# Para cada variável do modelo: P(abaixo | tem a característica) contra
# P(abaixo | não tem). Se OR > 1, esperamos a primeira maior que a segunda.

verifica <- function(disc) {
  m        <- modelos[[disc]]
  resposta <- paste0("abaixo_", disc)
  map_dfr(m$mantidas, \(v) {
    no_grupo <- teste[[v]] == 1
    tibble(
      disciplina    = disc,
      nome          = v,
      alunos_grupo  = sum(no_grupo),
      abaixo_grupo  = sum(teste[[resposta]][no_grupo]),
      prop_grupo    = mean(teste[[resposta]][no_grupo]),
      prop_demais   = mean(teste[[resposta]][!no_grupo]),
      prop_grupo_treino  = mean(treino[[resposta]][treino[[v]] == 1]),
      prop_demais_treino = mean(treino[[resposta]][treino[[v]] == 0])
    )
  }) %>%
    left_join(select(coeficientes[[disc]], nome, grupo, odds_ratio), by = "nome") %>%
    mutate(mesma_direcao = (prop_grupo > prop_demais) == (odds_ratio > 1)) %>%
    select(disciplina, grupo, nome, odds_ratio, everything())
}

verificacao <- bind_rows(verifica("LP"), verifica("MT"))

verificacao %>%
  mutate(across(c(odds_ratio, starts_with("prop")), \(x) round(x, 3))) %>%
  print(n = Inf, width = Inf)

verificacao %>% filter(!mesma_direcao)   # onde o teste discorda do modelo

write.csv(verificacao, "data/modelo/verificacao_teste.csv", row.names = FALSE)


## 4.2 Calibração por número de fatores -----------------------------------
# Agrupa os alunos do teste pelo número de fatores do modelo que acumulam
# e compara a proporção observada com a probabilidade média prevista.

calibracao <- function(disc) {
  m <- modelos[[disc]]
  teste %>%
    mutate(previsto = predict(m$final, teste, type = "response"),
           fatores  = pmin(rowSums(across(all_of(m$mantidas))), 4),
           fatores  = if_else(fatores == 4, "4 ou mais", as.character(fatores))) %>%
    group_by(fatores) %>%
    summarise(alunos    = n(),
              observado = mean(.data[[paste0("abaixo_", disc)]]),
              previsto  = mean(previsto))
}

calibracao("LP")
calibracao("MT")


## 4.3 AUC -----------------------------------------------------------------
# Probabilidade de o modelo dar nota de risco maior a um aluno abaixo do
# básico do que a um aluno acima, sorteados ao acaso (0,5 = acaso; 1 = perfeito).

auc <- function(resposta, previsto) {
  postos <- rank(previsto)
  n1 <- sum(resposta == 1)
  n0 <- sum(resposta == 0)
  (sum(postos[resposta == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}

map_dfr(c("LP", "MT"), \(disc) {
  m <- modelos[[disc]]
  tibble(disciplina = disc,
         auc_treino = auc(treino[[paste0("abaixo_", disc)]], fitted(m$final)),
         auc_teste  = auc(teste[[paste0("abaixo_", disc)]], predict(m$final, teste, type = "response")))
})


# ---------------------------------------------------------------------
# 5. Comparação com os coeficientes do professor
# ---------------------------------------------------------------------
# Os nomes do professor não têm definição no repositório. A correspondência
# abaixo é uma HIPÓTESE do grupo (mesma ordem do tribble dentro de cada
# bloco); onde não há correspondência clara, fica NA.

correspondencia <- tribble(
  ~variavel_professor,                                         ~nome,
  "Trajetória escolar - Repetiu ano",                          "reprovou",
  "Trajetória escolar - Atraso escolar",                       "idade_12",
  "Trajetória escolar - Abandono ou interrupção",              "abandonou",
  "Trajetória escolar - Entrada tardia",                       "entrada_8",
  "Nível socioeconômico - INSE baixo",                         "inse_baixo",
  "Nível socioeconômico - Responsável sem ocupação indicada",  NA,
  "Nível socioeconômico - Baixa escolaridade responsável 2",   NA,
  "Entorno - Entorno desfavorável 1",                          "sem_asfalto",
  "Rotina - Rotina doméstica desfavorável",                    "trabalha_fora",
  "Rotina - Trabalho doméstico",                               "sem_lazer",
  "Rotina - Rotina pessoal desfavorável",                      "nao_estuda",
  "Relação com a escola - Relação desfavorável com a escola",  "prof_nao_acred",
  "Inclusão - Indicador de inclusão 1",                        "deficiencia",
  "Família - Indicador familiar",                              "pouco_incentivo"
)

compara_professor <- function(disc) {
  read.csv(paste0("data/modelo/coeficientes_", disc, ".csv")) %>%
    filter(variavel != "const") %>%
    select(variavel_professor = variavel, or_professor = odds_ratio) %>%
    left_join(correspondencia, by = "variavel_professor") %>%
    left_join(select(coeficientes[[disc]], nome, or_grupo = odds_ratio), by = "nome") %>%
    mutate(across(starts_with("or_"), \(x) round(x, 2)))
}

compara_professor("LP")
compara_professor("MT")
