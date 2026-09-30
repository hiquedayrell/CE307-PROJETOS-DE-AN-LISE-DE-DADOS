library(tidyverse)
library(scales)

codebook <- read.csv("docs/codebook.csv", encoding = "UTF-8")

variaveis <- c("PROFICIENCIA_LP_SAEB", "PROFICIENCIA_MT_SAEB", "abaixo_LP", "abaixo_MT",
               "NU_TIPO_NIVEL_INSE", "ID_LOCALIZACAO", "IN_PUBLICA",
               names(read.csv("data/treino.csv", nrows = 1)) %>% str_subset("^TX_RESP_Q"))

base <- bind_rows(
  Brasil   = read.csv("data/treino.csv")          %>% select(all_of(variaveis)),
  Curitiba = read.csv("data/curitiba_limpa.csv")  %>% select(all_of(variaveis)),
  .id = "grupo"
)

cores_grupo <- c(Brasil = "#8C9BAB", Curitiba = "#1B7F5B")
pct <- label_percent(accuracy = 0.1, decimal.mark = ",")
cortes <- tibble(disciplina = c("Língua Portuguesa", "Matemática"), corte = c(150, 175))

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


# 1. Visão geral ---------------------------------------------------------

base %>%
  group_by(grupo) %>%
  summarise(
    alunos     = n(),
    media_LP   = mean(PROFICIENCIA_LP_SAEB),
    mediana_LP = median(PROFICIENCIA_LP_SAEB),
    dp_LP      = sd(PROFICIENCIA_LP_SAEB),
    media_MT   = mean(PROFICIENCIA_MT_SAEB),
    mediana_MT = median(PROFICIENCIA_MT_SAEB),
    dp_MT      = sd(PROFICIENCIA_MT_SAEB),
    abaixo_LP  = mean(abaixo_LP),
    abaixo_MT  = mean(abaixo_MT)
  )

notas <- base %>%
  select(grupo, `Língua Portuguesa` = PROFICIENCIA_LP_SAEB, `Matemática` = PROFICIENCIA_MT_SAEB) %>%
  pivot_longer(-grupo, names_to = "disciplina", values_to = "nota")

ggplot(notas, aes(nota, fill = grupo, color = grupo)) +
  geom_density(alpha = 0.3, linewidth = 0.8) +
  geom_vline(data = cortes, aes(xintercept = corte), linetype = "dashed") +
  facet_wrap(~ disciplina) +
  scale_fill_manual(values = cores_grupo) +
  scale_color_manual(values = cores_grupo) +
  labs(title = "Distribuição das notas: Curitiba x Brasil",
       subtitle = "Linha tracejada = corte do nível básico",
       x = "Proficiência (escala Saeb)", y = "Densidade", fill = NULL, color = NULL)

ggplot(notas, aes(grupo, nota, fill = grupo)) +
  geom_boxplot(alpha = 0.5, outlier.alpha = 0.3) +
  geom_hline(data = cortes, aes(yintercept = corte), linetype = "dashed", color = "red") +
  facet_wrap(~ disciplina) +
  scale_fill_manual(values = cores_grupo) +
  labs(title = "Notas por grupo", x = NULL, y = "Proficiência (escala Saeb)") +
  theme(legend.position = "none")

base %>%
  group_by(grupo) %>%
  summarise(`Língua Portuguesa` = mean(abaixo_LP), `Matemática` = mean(abaixo_MT)) %>%
  pivot_longer(-grupo, names_to = "disciplina", values_to = "prop") %>%
  ggplot(aes(disciplina, prop, fill = grupo)) +
  geom_col(position = position_dodge(0.8), width = 0.7) +
  geom_text(aes(label = pct(prop)), position = position_dodge(0.8), vjust = -0.4) +
  geom_hline(yintercept = 0.05, linetype = "dashed") +
  annotate("text", x = 0.5, y = 0.052, label = "Expectativa: até 5% (Soares, 2009)",
           hjust = 0, vjust = 0, size = 3.5) +
  scale_fill_manual(values = cores_grupo) +
  scale_y_continuous(labels = label_percent(decimal.mark = ","), expand = expansion(mult = c(0, 0.15))) +
  labs(title = "Alunos abaixo do nível básico", x = NULL, y = "% dos alunos", fill = NULL)

combinado <- base %>%
  mutate(situacao = case_when(
    abaixo_LP == 0 & abaixo_MT == 0 ~ "Básico ou acima nas duas",
    abaixo_LP == 1 & abaixo_MT == 0 ~ "Abaixo só em LP",
    abaixo_LP == 0 & abaixo_MT == 1 ~ "Abaixo só em MT",
    TRUE                            ~ "Abaixo nas duas"
  )) %>%
  count(grupo, situacao) %>%
  group_by(grupo) %>%
  mutate(prop = n / sum(n)) %>%
  ungroup()

combinado %>%
  select(-n) %>%
  pivot_wider(names_from = grupo, values_from = prop)


# 2. Perfil dos alunos: quem são os alunos de cada grupo -----------------

compara_perfil <- function(var, titulo) {
  com_rotulo(base, var) %>%
    count(grupo, categoria) %>%
    group_by(grupo) %>%
    mutate(prop = n / sum(n)) %>%
    ungroup() %>%
    ggplot(aes(fct_rev(categoria), prop, fill = grupo)) +
    geom_col(position = position_dodge(0.8), width = 0.7) +
    geom_text(aes(label = pct(prop)), position = position_dodge(0.8),
              hjust = -0.1, size = 3) +
    coord_flip() +
    scale_fill_manual(values = cores_grupo) +
    scale_x_discrete(labels = \(x) str_wrap(x, 35)) +
    scale_y_continuous(labels = label_percent(decimal.mark = ","), expand = expansion(mult = c(0, 0.15))) +
    guides(fill = guide_legend(reverse = TRUE)) +
    labs(title = titulo, subtitle = "Distribuição dos alunos em cada categoria",
         x = NULL, y = "% dos alunos", fill = NULL)
}

compara_perfil("TX_RESP_Q01", "Sexo")
compara_perfil("TX_RESP_Q04", "Cor/raça")
compara_perfil("TX_RESP_Q02", "Idade")
compara_perfil("TX_RESP_Q19", "Reprovação")
compara_perfil("TX_RESP_Q08", "Escolaridade da mãe")
compara_perfil("TX_RESP_Q09", "Escolaridade do pai")
compara_perfil("NU_TIPO_NIVEL_INSE", "Nível socioeconômico (INSE)")
compara_perfil("TX_RESP_Q18", "Tipo de escola desde o 1º ano")
compara_perfil("TX_RESP_Q21d", "Tempo de trabalho fora de casa")


# 3. Alunos abaixo do básico por categoria: Curitiba x Brasil ------------

tabela_abaixo <- function(var) {
  com_rotulo(base, var) %>%
    group_by(grupo, categoria) %>%
    summarise(alunos = n(), LP = mean(abaixo_LP), MT = mean(abaixo_MT), .groups = "drop") %>%
    pivot_wider(names_from = grupo, values_from = c(alunos, LP, MT))
}

compara_abaixo <- function(var, titulo, minimo = 30) {
  com_rotulo(base, var) %>%
    group_by(grupo, categoria) %>%
    summarise(alunos = n(), `Língua Portuguesa` = mean(abaixo_LP), `Matemática` = mean(abaixo_MT),
              .groups = "drop") %>%
    pivot_longer(c(`Língua Portuguesa`, `Matemática`), names_to = "disciplina", values_to = "prop") %>%
    mutate(
      prop   = if_else(alunos < minimo, NA_real_, prop),
      rotulo = if_else(is.na(prop), paste("n <", minimo), pct(prop)),
      y_txt  = coalesce(prop, 0)
    ) %>%
    ggplot(aes(fct_rev(categoria), prop, fill = grupo)) +
    geom_col(position = position_dodge(0.8), width = 0.7, na.rm = TRUE) +
    geom_text(aes(y = y_txt, label = rotulo), position = position_dodge(0.8),
              hjust = -0.1, size = 3) +
    coord_flip() +
    facet_wrap(~ disciplina) +
    scale_fill_manual(values = cores_grupo) +
    scale_x_discrete(labels = \(x) str_wrap(x, 35)) +
    scale_y_continuous(labels = label_percent(decimal.mark = ","), expand = expansion(mult = c(0, 0.25))) +
    guides(fill = guide_legend(reverse = TRUE)) +
    labs(title = titulo, subtitle = "% de alunos abaixo do nível básico em cada categoria",
         x = NULL, y = "% abaixo do básico", fill = NULL)
}

tabela_abaixo("TX_RESP_Q01")
compara_abaixo("TX_RESP_Q01", "Sexo")

tabela_abaixo("TX_RESP_Q04")
compara_abaixo("TX_RESP_Q04", "Cor/raça")

tabela_abaixo("TX_RESP_Q02")
compara_abaixo("TX_RESP_Q02", "Idade")

tabela_abaixo("TX_RESP_Q19")
compara_abaixo("TX_RESP_Q19", "Reprovação")

tabela_abaixo("TX_RESP_Q08")
compara_abaixo("TX_RESP_Q08", "Escolaridade da mãe")

tabela_abaixo("TX_RESP_Q09")
compara_abaixo("TX_RESP_Q09", "Escolaridade do pai")

tabela_abaixo("NU_TIPO_NIVEL_INSE")
compara_abaixo("NU_TIPO_NIVEL_INSE", "Nível socioeconômico (INSE)")

tabela_abaixo("TX_RESP_Q18")
compara_abaixo("TX_RESP_Q18", "Tipo de escola desde o 1º ano")

tabela_abaixo("TX_RESP_Q21d")
compara_abaixo("TX_RESP_Q21d", "Tempo de trabalho fora de casa")
