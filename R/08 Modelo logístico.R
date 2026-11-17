# =====================================================================
# 08 Modelo logistico.R
# Projeto: Eixo 4 - Educacao Basica Municipal (parceria SME Curitiba)
#
# Objetivo:
#   1. estimar, na base de TREINO, uma regressao logistica para cada
#      resposta (abaixo_LP e abaixo_MT) com as 18 variaveis dicotomicas
#      da secao 4 do relatorio descritivo revisado;
#   2. manter so as variaveis significativas (p < 0,05) e reestimar;
#   3. interpretar cada variavel pela razao de chances (odds ratio).
#
# A base de TESTE ainda nao e usada: o que fazer com ela (e a comparacao
# com as planilhas do professor) fica para discutir com o professor.
# A versao anterior, com a verificacao no teste e a comparacao, esta no
# historico do git (commit 8a6d632).
#
# Entradas: data/treino.csv
# Saidas:   data/modelo/modelo_grupo_LP.csv e modelo_grupo_MT.csv
# =====================================================================

library(tidyverse)

treino <- read.csv("data/treino.csv")


# ---------------------------------------------------------------------
# 1. As 18 variaveis dicotomicas da secao 4
# ---------------------------------------------------------------------
# Cada variavel vale 1 se o aluno esta no grupo descrito e 0 caso contrario.

grupos <- tribble(
  ~nome,            ~bloco,                 ~grupo,                                        ~variavel,            ~cods,
  "reprovou",       "Trajet\u00f3ria escolar",   "J\u00e1 reprovou ao menos uma vez",                "TX_RESP_Q19",        "B,C",
  "idade_12",       "Trajet\u00f3ria escolar",   "Tem 12 anos ou mais",                         "TX_RESP_Q02",        "D,E,F",
  "abandonou",      "Trajet\u00f3ria escolar",   "J\u00e1 abandonou a escola",                       "TX_RESP_Q20",        "B,C",
  "entrada_8",      "Trajet\u00f3ria escolar",   "Entrou na escola com 8 anos ou mais",         "TX_RESP_Q17",        "D",
  "inse_baixo",     "N\u00edvel socioecon\u00f4mico", "INSE nos n\u00edveis I e II",                      "NU_TIPO_NIVEL_INSE", "1,2",
  "mae_5ano",       "N\u00edvel socioecon\u00f4mico", "M\u00e3e estudou at\u00e9 o 5\u00ba ano",                    "TX_RESP_Q08",        "A,B",
  "sem_mae",        "N\u00edvel socioecon\u00f4mico", "N\u00e3o mora com a m\u00e3e",                          "TX_RESP_Q07a",       "A",
  "sem_wifi",       "N\u00edvel socioecon\u00f4mico", "Sem Wi-Fi em casa",                           "TX_RESP_Q13b",       "A",
  "sem_asfalto",    "Entorno",              "Rua sem asfalto ou cal\u00e7amento",               "TX_RESP_Q11a",       "A",
  "sem_iluminacao", "Entorno",              "Rua sem ilumina\u00e7\u00e3o",                          "TX_RESP_Q11c",       "A",
  "rural",          "Entorno",              "Escola rural",                                "ID_LOCALIZACAO",     "2",
  "trabalha_fora",  "Rotina",               "Trabalha fora de casa",                       "TX_RESP_Q21d",       "B,C,D",
  "sem_lazer",      "Rotina",               "N\u00e3o tem tempo de lazer",                      "TX_RESP_Q21e",       "A",
  "nao_estuda",     "Rotina",               "N\u00e3o estuda fora da escola",                   "TX_RESP_Q21a",       "A",
  "prof_nao_acred", "Rela\u00e7\u00e3o com a escola", "Discorda que os professores acreditam nele",  "TX_RESP_Q23h",       "C,D",
  "deficiencia",    "Inclus\u00e3o",             "Declara defici\u00eancia",                         "TX_RESP_Q05a",       "B",
  "tea",            "Inclus\u00e3o",             "Declara transtorno do espectro autista",      "TX_RESP_Q05b",       "B",
  "pouco_incentivo","Fam\u00edlia",              "Pouco incentivo para ir \u00e0s aulas",            "TX_RESP_Q10e",       "A,B"
)

# Cria as 18 colunas 0/1 na base
cria_dicotomicas <- function(dados) {
  for (i in seq_len(nrow(grupos))) {
    codigos <- str_split(grupos$cods[i], ",")[[1]]
    dados[[grupos$nome[i]]] <- as.integer(as.character(dados[[grupos$variavel[i]]]) %in% codigos)
  }
  dados
}

treino <- cria_dicotomicas(treino)


# ---------------------------------------------------------------------
# 2. Estimacao: modelo completo -> selecao (p < 0,05) -> modelo final
# ---------------------------------------------------------------------

ajusta <- function(resposta, variaveis) {
  glm(reformulate(variaveis, resposta), data = treino, family = binomial)
}

# Tabela de coeficientes com razao de chances e IC de 95% (Wald, como no statsmodels)
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

# Variaveis que sairam em cada modelo (nao significativas junto com as demais)
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

# Grava com 10 algarismos significativos: os ultimos digitos mudam de uma
# maquina para outra e fariam o git acusar diferenca a cada execucao.
grava <- function(tabela, arquivo) {
  tabela %>%
    mutate(across(where(is.double), \(x) signif(x, 10))) %>%
    write.csv(arquivo, row.names = FALSE)
}

grava(coeficientes$LP, "data/modelo/modelo_grupo_LP.csv")
grava(coeficientes$MT, "data/modelo/modelo_grupo_MT.csv")


# ---------------------------------------------------------------------
# 3. Interpretacao
# ---------------------------------------------------------------------
# Intercepto: chance de estar abaixo do basico de um aluno SEM nenhuma
# das caracteristicas do modelo. plogis() transforma em probabilidade.
#
# Razao de chances (OR) de uma variavel: por quanto a CHANCE (p / (1 - p))
# e multiplicada quando o aluno tem a caracteristica, mantendo as outras
# iguais. OR = 1,85 significa chance 85% maior. Nao e "85% mais provavel":
# chance e probabilidade so sao parecidas quando o evento e raro.

map_dbl(modelos, \(m) plogis(coef(m$final)[["(Intercept)"]]))   # probabilidade base

# Exemplo: aluno sem nenhum fator x aluno que so reprovou x reprovou e trabalha fora
exemplo <- function(m, ...) {
  perfil <- as_tibble(setNames(as.list(rep(0, length(m$mantidas))), m$mantidas))
  for (v in c(...)) perfil[[v]] <- 1
  predict(m$final, perfil, type = "response")
}
exemplo(modelos$LP)
exemplo(modelos$LP, "reprovou")
exemplo(modelos$LP, "reprovou", "trabalha_fora")
