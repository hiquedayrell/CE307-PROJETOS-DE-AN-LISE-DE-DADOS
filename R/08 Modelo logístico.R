# =====================================================================
# 08 Modelo logistico.R
# Projeto: Eixo 4 - Educacao Basica Municipal (parceria SME Curitiba)
#
# Objetivo:
#   1. estimar, na base de TREINO, uma regressao logistica para cada
#      resposta (abaixo_LP e abaixo_MT) com as 18 variaveis dicotomicas
#      da secao 4 do relatorio descritivo revisado;
#   2. manter so as variaveis significativas (p < 0,05) e reestimar;
#   3. interpretar cada variavel pela razao de chances (odds ratio);
#   4. na base de TESTE, comparar o que o modelo preve com o que se ve na
#      pratica, em probabilidades condicionais (reuniao de 18/11/2026):
#      por caracteristica (4.1), por numero de fatores acumulados (4.2) e
#      na classificacao "em risco ou nao" (4.3);
#   5. aplicacao: dadas as caracteristicas de um aluno, dizer a
#      probabilidade de estar abaixo do basico e se ele esta em risco.
#
# A comparacao com as planilhas do professor e a AUC ainda estao fora.
# A versao anterior, com elas, esta no historico do git (commit 8a6d632).
#
# Entradas: data/treino.csv, data/teste.csv
# Saidas:   data/modelo/modelo_grupo_LP.csv e modelo_grupo_MT.csv
#           data/modelo/probabilidades_condicionais_teste.csv
#           data/modelo/perfis_fatores_teste.csv
#           data/modelo/classificacao_teste.csv
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


# ---------------------------------------------------------------------
# 4. Base de teste: o que o modelo preve x o que se ve na pratica
# ---------------------------------------------------------------------
# O teste NAO entra na estimacao: o modelo continua o do treino. Aqui ele
# so e aplicado aos alunos do teste, que ele nunca viu.
#
# Para cada caracteristica do modelo, comparamos dois numeros no grupo de
# alunos do teste que tem a caracteristica:
#   - previsto:  media das probabilidades que o modelo da a esses alunos;
#   - observado: proporcao desses alunos que esta de fato abaixo do basico,
#                ou seja, a probabilidade condicional P(abaixo | caracteristica).
# O mesmo e feito para quem NAO tem a caracteristica.
#
# A primeira linha ("Todos os alunos") nao condiciona a nada. Nela previsto
# e observado ficam quase iguais por construcao, entao ela nao testa o
# modelo: serve de referencia. O teste esta nas linhas condicionadas.

teste <- cria_dicotomicas(read.csv("data/teste.csv"))

# Intervalo de confianca de 95% de Wilson para uma proporcao
wilson <- function(x, n, z = 1.96) {
  p      <- x / n
  centro <- (p + z^2 / (2 * n)) / (1 + z^2 / n)
  margem <- z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / (1 + z^2 / n)
  tibble(ic_inf = centro - margem, ic_sup = centro + margem)
}

# Uma linha por grupo de alunos: quantos sao, quantos estao abaixo do basico,
# proporcao observada (com IC de 95%) e probabilidade media prevista
resume_grupo <- function(no_grupo, y, previsto) {
  tibble(alunos    = sum(no_grupo),
         abaixo    = sum(y[no_grupo]),
         observado = mean(y[no_grupo]),
         previsto  = mean(previsto[no_grupo])) %>%
    bind_cols(wilson(.$abaixo, .$alunos))
}

## 4.1 Por caracteristica ---------------------------------------------

condicionais <- function(disc) {
  m        <- modelos[[disc]]
  y        <- teste[[paste0("abaixo_", disc)]]
  previsto <- predict(m$final, teste, type = "response")

  todos <- resume_grupo(rep(TRUE, nrow(teste)), y, previsto) %>%
    mutate(nome = "todos", grupo = "Todos os alunos", tem = NA)

  por_variavel <- map_dfr(m$mantidas, \(v) {
    bind_rows(
      resume_grupo(teste[[v]] == 1, y, previsto) %>% mutate(tem = TRUE),
      resume_grupo(teste[[v]] == 0, y, previsto) %>% mutate(tem = FALSE)
    ) %>%
      mutate(nome = v)
  }) %>%
    left_join(select(grupos, nome, grupo), by = "nome")

  bind_rows(todos, por_variavel) %>%
    mutate(disciplina = disc,
           previsto_no_ic = previsto >= ic_inf & previsto <= ic_sup) %>%
    select(disciplina, grupo, nome, tem, alunos, abaixo, observado,
           ic_inf, ic_sup, previsto, previsto_no_ic)
}

prob_cond <- bind_rows(condicionais("LP"), condicionais("MT"))

prob_cond %>%
  mutate(across(c(observado, ic_inf, ic_sup, previsto), \(x) round(100 * x, 1))) %>%
  print(n = Inf, width = Inf)

# Em quantos grupos a probabilidade prevista cai dentro do IC do observado
prob_cond %>%
  filter(nome != "todos") %>%
  count(disciplina, tem, previsto_no_ic)

grava(prob_cond, "data/modelo/probabilidades_condicionais_teste.csv")


## 4.2 Por numero de fatores acumulados ---------------------------------
# Agrupa os alunos do teste pelo numero de caracteristicas do modelo que
# cada um tem (0, 1, 2, 3, 4 ou mais) e compara, em cada faixa, a
# probabilidade media prevista com a proporcao observada.
#
# Responde a interpretacao do modelo de que o risco se acumula: cada
# fator a mais multiplica a chance. Se o modelo estiver certo, a proporcao
# observada deve subir com o numero de fatores, acompanhando a prevista.
#
# A coluna pct_dos_abaixo diz em que faixa estao os alunos abaixo do
# basico do teste: mostra se eles se concentram em quem acumula fatores
# ou se aparecem tambem entre quem nao tem nenhum.

perfis_fatores <- function(disc) {
  m        <- modelos[[disc]]
  y        <- teste[[paste0("abaixo_", disc)]]
  previsto <- predict(m$final, teste, type = "response")
  fatores  <- pmin(rowSums(teste[m$mantidas]), 4)

  map_dfr(0:4, \(k) resume_grupo(fatores == k, y, previsto)) %>%
    mutate(disciplina     = disc,
           fatores        = c("0", "1", "2", "3", "4 ou mais"),
           pct_dos_alunos = alunos / sum(alunos),
           pct_dos_abaixo = abaixo / sum(abaixo),
           previsto_no_ic = previsto >= ic_inf & previsto <= ic_sup) %>%
    select(disciplina, fatores, alunos, pct_dos_alunos, abaixo, pct_dos_abaixo,
           observado, ic_inf, ic_sup, previsto, previsto_no_ic)
}

perfis <- bind_rows(perfis_fatores("LP"), perfis_fatores("MT"))

perfis %>%
  mutate(across(c(pct_dos_alunos, pct_dos_abaixo, observado, ic_inf, ic_sup, previsto),
                \(x) round(100 * x, 1))) %>%
  print(n = Inf, width = Inf)

grava(perfis, "data/modelo/perfis_fatores_teste.csv")


## 4.3 Classificacao "em risco ou nao" --------------------------------
# A aplicacao do modelo e marcar alunos "em risco" para que a escola
# intervenha. Para isso e preciso um corte na probabilidade prevista.
#
# O corte e definido no TREINO, nunca no teste: "em risco" = estar entre
# os 20% (ou os 10%) de maior probabilidade prevista no treino. Depois o
# mesmo corte e aplicado aos alunos do teste, e medimos:
#   - pct_marcados:      quantos alunos a escola teria de acompanhar;
#   - abaixo_marcados:   entre os marcados, quantos estao de fato abaixo
#                        do basico (o quanto a marcacao acerta);
#   - abaixo_nao_marc:   o mesmo entre os nao marcados;
#   - pct_abaixo_pegos:  dos alunos abaixo do basico, quantos foram
#                        marcados (quantos a escola alcancaria).

niveis_risco <- c(top20 = 0.80, top10 = 0.90)

cortes <- map(modelos, \(m) quantile(fitted(m$final), niveis_risco, names = FALSE) %>%
                setNames(names(niveis_risco)))

classificacao <- map_dfr(c("LP", "MT"), \(disc) {
  y        <- teste[[paste0("abaixo_", disc)]]
  previsto <- predict(modelos[[disc]]$final, teste, type = "response")
  map_dfr(names(niveis_risco), \(nivel) {
    marcado <- previsto >= cortes[[disc]][[nivel]]
    tibble(disciplina       = disc,
           nivel            = nivel,
           corte            = cortes[[disc]][[nivel]],
           alunos_marcados  = sum(marcado),
           pct_marcados     = mean(marcado),
           abaixo_marcados  = mean(y[marcado]),
           abaixo_nao_marc  = mean(y[!marcado]),
           pct_abaixo_pegos = sum(marcado & y == 1) / sum(y))
  })
})

classificacao %>%
  mutate(across(c(corte, pct_marcados, abaixo_marcados, abaixo_nao_marc, pct_abaixo_pegos),
                \(x) round(100 * x, 1))) %>%
  print(width = Inf)

grava(classificacao, "data/modelo/classificacao_teste.csv")


# ---------------------------------------------------------------------
# 5. Aplicacao: avaliar um aluno
# ---------------------------------------------------------------------
# Recebe as caracteristicas de um aluno (os nomes curtos da tabela
# `grupos`) e devolve, para LP e MT:
#   - probabilidade:  chance prevista de estar abaixo do basico;
#   - vezes_media:    quantas vezes isso e a proporcao geral do treino;
#   - em_risco_top20 / em_risco_top10: se passa dos cortes da secao 4.3;
#   - considerados:   caracteristicas que o modelo daquela disciplina usa;
#   - ignorados:      caracteristicas informadas que sairam do modelo.
#
# Exemplo de uso:
#   avalia_aluno("reprovou", "idade_12", "inse_baixo")
#
# Lembrete: e uma ferramenta de PRIORIZACAO. Pelo teste (secao 4.3), a
# maioria dos alunos marcados nao esta abaixo do basico, e parte dos que
# estao nao e marcada. Nao serve como diagnostico de um aluno.

avalia_aluno <- function(...) {
  informados <- c(...)
  desconhecidos <- setdiff(informados, grupos$nome)
  if (length(desconhecidos) > 0) {
    stop("Caracteristica(s) desconhecida(s): ", paste(desconhecidos, collapse = ", "),
         ". Use os nomes da coluna `nome` da tabela `grupos`.")
  }

  map_dfr(c("LP", "MT"), \(disc) {
    m      <- modelos[[disc]]
    perfil <- as_tibble(setNames(as.list(rep(0, length(m$mantidas))), m$mantidas))
    for (v in intersect(informados, m$mantidas)) perfil[[v]] <- 1
    p <- unname(predict(m$final, perfil, type = "response"))
    tibble(disciplina     = disc,
           probabilidade  = p,
           vezes_media    = p / mean(treino[[paste0("abaixo_", disc)]]),
           em_risco_top20 = p >= cortes[[disc]][["top20"]],
           em_risco_top10 = p >= cortes[[disc]][["top10"]],
           considerados   = paste(intersect(informados, m$mantidas), collapse = ", "),
           ignorados      = paste(setdiff(informados, m$mantidas), collapse = ", "))
  })
}

avalia_aluno()
avalia_aluno("sem_asfalto")
avalia_aluno("reprovou", "idade_12")
avalia_aluno("reprovou", "idade_12", "inse_baixo", "sem_lazer")
