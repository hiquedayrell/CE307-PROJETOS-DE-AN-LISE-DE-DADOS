library(tidyverse)
library(scales)

treino   <- read.csv("data/treino.csv")
codebook <- read.csv("docs/codebook.csv", encoding = "UTF-8")

selecionadas <- tribble(
  ~variavel,            ~bloco,                   ~nome,
  "TX_RESP_Q02",        "Trajetória escolar",     "Idade",
  "TX_RESP_Q19",        "Trajetória escolar",     "Reprovação",
  "TX_RESP_Q17",        "Trajetória escolar",     "Idade de entrada na escola",
  "TX_RESP_Q07a",       "Estrutura familiar",     "Mora com a mãe",
  "TX_RESP_Q07b",       "Estrutura familiar",     "Mora com o pai",
  "NU_TIPO_NIVEL_INSE", "Nível socioeconômico",   "INSE",
  "TX_RESP_Q08",        "Nível socioeconômico",   "Escolaridade da mãe",
  "TX_RESP_Q09",        "Nível socioeconômico",   "Escolaridade do pai",
  "TX_RESP_Q12g",       "Nível socioeconômico",   "Celulares em casa",
  "TX_RESP_Q11a",       "Entorno",                "Rua asfaltada",
  "TX_RESP_Q11c",       "Entorno",                "Iluminação na rua",
  "TX_RESP_Q10c",       "Envolvimento dos pais",  "Incentivam a estudar",
  "TX_RESP_Q10e",       "Envolvimento dos pais",  "Incentivam a ir à aula",
  "TX_RESP_Q10f",       "Envolvimento dos pais",  "Vão às reuniões",
  "TX_RESP_Q21d",       "Rotina",                 "Trabalho fora de casa",
  "TX_RESP_Q21e",       "Rotina",                 "Tempo de lazer",
  "TX_RESP_Q22g",       "Escola",                 "Trabalhos em grupo",
  "TX_RESP_Q23a",       "Escola",                 "Interesse pelo conteúdo",
  "TX_RESP_Q23i",       "Escola",                 "Professores motivam",
  "TX_RESP_Q23h",       "Escola",                 "Professores acreditam que é capaz"
)

cores <- c("Língua Portuguesa" = "#2E6F9E", "Matemática" = "#D17A22")
pct   <- label_percent(accuracy = 0.1, decimal.mark = ",")

theme_set(theme_minimal(base_size = 12) +
            theme(legend.position = "top",
                  panel.grid.minor = element_blank(),
                  panel.spacing = unit(2, "lines"),
                  strip.text = element_text(face = "bold")))

rotulos <- function(var) {
  cats   <- codebook$categorias[codebook$variavel == var]
  partes <- str_split(cats, ";\\s*")[[1]]
  m      <- str_match(partes, "^\\s*(\\S+)\\s*[=-]\\s*(.*)$")
  setNames(str_remove(str_trim(m[, 3]), "\\.$"), m[, 2])
}

com_rotulo <- function(dados, var) {
  lab     <- rotulos(var)
  valores <- as.character(dados[[var]])
  niveis  <- lab[names(lab) %in% valores]
  dados %>%
    mutate(categoria = factor(coalesce(lab[valores], "Sem informação"),
                              levels = c(unname(niveis), "Sem informação")) %>%
             fct_drop())
}


# 1. Teste de associação de cada variável com abaixo_LP e abaixo_MT ------

associacao <- function(x, y) {
  tab   <- table(x, y)
  teste <- suppressWarnings(chisq.test(tab, correct = FALSE))
  tibble(
    qui2   = unname(teste$statistic),
    gl     = unname(teste$parameter),
    p      = teste$p.value,
    v      = sqrt(qui2 / (sum(tab) * (min(dim(tab)) - 1))),
    esp_5  = mean(teste$expected < 5)
  )
}

resultados <- selecionadas %>%
  mutate(
    LP = map(variavel, \(v) associacao(treino[[v]], treino$abaixo_LP)),
    MT = map(variavel, \(v) associacao(treino[[v]], treino$abaixo_MT))
  ) %>%
  unnest(c(LP, MT), names_sep = "_") %>%
  arrange(desc(LP_v + MT_v))

resultados %>%
  transmute(
    bloco, nome, variavel,
    V_LP = round(LP_v, 3), p_LP = signif(LP_p, 2),
    V_MT = round(MT_v, 3), p_MT = signif(MT_p, 2),
    celulas_esperado_menor_5 = pct(pmax(LP_esp_5, MT_esp_5))
  ) %>%
  print(n = Inf, width = Inf)

resultados %>%
  select(nome, bloco, `Língua Portuguesa` = LP_v, `Matemática` = MT_v) %>%
  pivot_longer(c(`Língua Portuguesa`, `Matemática`), names_to = "disciplina", values_to = "v") %>%
  ggplot(aes(v, fct_reorder(nome, v, .fun = sum), color = disciplina)) +
  geom_line(aes(group = nome), color = "grey75", linewidth = 1) +
  geom_point(size = 3) +
  geom_vline(xintercept = 0.1, linetype = "dashed", color = "grey50") +
  scale_color_manual(values = cores) +
  labs(title = "Força da associação com estar abaixo do nível básico",
       subtitle = "V de Cramér (0 = nenhuma associação; linha tracejada = 0,1, associação fraca)",
       x = "V de Cramér", y = NULL, color = NULL)

resultados %>%
  group_by(bloco) %>%
  summarise(V_LP_medio = mean(LP_v), V_MT_medio = mean(MT_v), variaveis = n()) %>%
  arrange(desc(V_LP_medio + V_MT_medio))


# 2. Detalhe por variável: % abaixo do básico em cada categoria ----------

detalhe <- function(var) {
  com_rotulo(treino, var) %>%
    group_by(categoria) %>%
    summarise(
      alunos      = n(),
      pct_alunos  = pct(n() / nrow(treino)),
      abaixo_LP   = pct(mean(abaixo_LP)),
      abaixo_MT   = pct(mean(abaixo_MT))
    )
}

grafico_detalhe <- function(var, titulo) {
  com_rotulo(treino, var) %>%
    group_by(categoria) %>%
    summarise(alunos = n(), `Língua Portuguesa` = mean(abaixo_LP), `Matemática` = mean(abaixo_MT)) %>%
    pivot_longer(c(`Língua Portuguesa`, `Matemática`), names_to = "disciplina", values_to = "prop") %>%
    ggplot(aes(fct_rev(categoria), prop, fill = disciplina)) +
    geom_col(width = 0.7) +
    geom_text(aes(label = pct(prop)), hjust = -0.1, size = 3.2) +
    geom_hline(data = tibble(disciplina = names(cores),
                             geral = c(mean(treino$abaixo_LP), mean(treino$abaixo_MT))),
               aes(yintercept = geral), linetype = "dashed") +
    coord_flip() +
    facet_wrap(~ disciplina) +
    scale_fill_manual(values = cores) +
    scale_x_discrete(labels = \(x) str_wrap(x, 35)) +
    scale_y_continuous(labels = label_percent(decimal.mark = ","),
                       expand = expansion(mult = c(0, 0.25))) +
    labs(title = titulo,
         subtitle = "% abaixo do nível básico em cada categoria (tracejado = média geral)",
         x = NULL, y = "% abaixo do básico") +
    theme(legend.position = "none")
}

for (i in seq_len(nrow(resultados))) {
  print(detalhe(resultados$variavel[i]))
  print(grafico_detalhe(resultados$variavel[i], resultados$nome[i]))
}
