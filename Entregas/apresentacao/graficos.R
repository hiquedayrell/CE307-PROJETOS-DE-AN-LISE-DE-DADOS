# =====================================================================
# Entregas/apresentacao/graficos.R
# Gera, em PNG, os graficos dos relatorios usados na apresentacao.
# O codigo dos graficos e o mesmo de Entregas/relatorio_descritivo_revisado.Rmd
# (secao 4, "Quais grupos concentram mais alunos abaixo do basico") e de
# Entregas/relatorio_modelo.Rmd (fig-or e fig-acumulo); muda so o tamanho da
# letra, para o projetor.
#
# Rodar com o projeto aberto (diretorio de trabalho = raiz do repositorio):
#   source("Entregas/apresentacao/graficos.R", encoding = "UTF-8")
# Saidas: Entregas/apresentacao/assets/grupos_risco.png, razoes_chances.png e
#         acumulo_teste.png
# Arquivo so com caracteres ASCII (ver CLAUDE.md, decisao de 17/11/2026).
# =====================================================================

library(tidyverse)
library(scales)

# Usa a tabela `grupos` e a base `treino` do R/08 (mesmas 18 variaveis da secao 4)
source("R/08 Modelo log\u00edstico.R", encoding = "UTF-8")
curitiba <- read.csv("data/curitiba_limpa.csv")
codebook <- read.csv("docs/codebook.csv", encoding = "UTF-8")

pasta <- "Entregas/apresentacao/assets"
dir.create(pasta, showWarnings = FALSE)

cores       <- c("L\u00edngua Portuguesa" = "#2E6F9E", "Matem\u00e1tica" = "#D17A22")
cores_grupo <- c(Brasil = "#8C9BAB", Curitiba = "#1B7F5B")
cor_risco   <- "#B03A2E"

pct      <- label_percent(accuracy = 0.1, decimal.mark = ",", big.mark = ".")
num      <- function(x, d = 0) number(x, accuracy = 10^-d, decimal.mark = ",", big.mark = ".")
eixo_pct <- label_percent(decimal.mark = ",")

wilson <- function(x, n, z = 1.96) {
  p      <- x / n
  centro <- (p + z^2 / (2 * n)) / (1 + z^2 / n)
  margem <- z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / (1 + z^2 / n)
  tibble(p = p, li = centro - margem, ls = centro + margem)
}

rotulos <- function(var) {
  cats   <- codebook$categorias[codebook$variavel == var]
  partes <- str_split(cats, ";\\s*")[[1]]
  m      <- str_match(partes, "^\\s*(\\S+)\\s*[=-]\\s*(.*)$")
  setNames(str_remove(str_trim(m[, 3]), "\\.$"), m[, 2])
}

theme_set(theme_minimal(base_size = 22) +
            theme(panel.grid.minor = element_blank(),
                  panel.spacing = unit(2, "lines"),
                  strip.text = element_text(face = "bold", size = 24),
                  axis.text = element_text(color = "grey15"),
                  legend.position = "top",
                  plot.background = element_rect(fill = "white", color = NA)))

# --- Os 18 grupos: % abaixo do basico no grupo x demais (fig-risco) ---------
risco <- grupos %>%
  mutate(res = map2(variavel, cods, \(v, c) {
    g <- as.character(treino[[v]]) %in% str_split(c, ",")[[1]]
    tibble(n = sum(g), LP = sum(treino$abaixo_LP[g]), MT = sum(treino$abaixo_MT[g]),
           LP_demais = mean(treino$abaixo_LP[!g]), MT_demais = mean(treino$abaixo_MT[!g]))
  })) %>%
  unnest(res) %>%
  mutate(bloco = recode(bloco, "N\u00edvel socioecon\u00f4mico" = "N\u00edvel socioecon\u00f4mico e fam\u00edlia",
                        "Fam\u00edlia" = "N\u00edvel socioecon\u00f4mico e fam\u00edlia")) %>%
  group_by(bloco) %>%
  mutate(maior = max(LP / n)) %>%
  ungroup() %>%
  arrange(desc(maior), desc(LP / n)) %>%
  mutate(bloco = fct_inorder(bloco))

g_risco <- risco %>%
  mutate(rotulo = fct_reorder(grupo, LP / n)) %>%
  pivot_longer(c(LP, MT), names_to = "sigla", values_to = "x") %>%
  mutate(disciplina = if_else(sigla == "LP", "L\u00edngua Portuguesa", "Matem\u00e1tica"),
         demais = if_else(sigla == "LP", LP_demais, MT_demais),
         wilson(x, n)) %>%
  ggplot(aes(y = rotulo)) +
  geom_segment(aes(x = demais, xend = p, yend = rotulo), color = "grey78", linewidth = 1.2) +
  geom_linerange(aes(xmin = li, xmax = ls), color = cor_risco, alpha = 0.3, linewidth = 4.5) +
  geom_point(aes(x = demais, color = "Demais alunos"), size = 3.6) +
  geom_point(aes(x = p, color = "Alunos do grupo"), size = 4.4) +
  facet_grid(bloco ~ disciplina, scales = "free_y", space = "free_y", switch = "y",
             labeller = labeller(bloco = label_wrap_gen(14))) +
  scale_color_manual(values = c("Alunos do grupo" = cor_risco, "Demais alunos" = "grey55")) +
  scale_x_continuous(labels = eixo_pct, limits = c(0, 0.42), breaks = seq(0, 0.4, 0.1),
                     expand = expansion(mult = c(0, 0))) +
  scale_y_discrete(labels = \(x) str_wrap(x, 34)) +
  labs(x = "% abaixo do b\u00e1sico (faixa: IC de 95%)", y = NULL, color = NULL) +
  theme(strip.placement = "outside",
        strip.text.y.left = element_text(angle = 0, hjust = 0, face = "bold", size = 18),
        axis.text.y = element_text(size = 18),
        panel.spacing.y = unit(0.6, "lines"),
        plot.margin = margin(5, 20, 5, 5))

ggsave(file.path(pasta, "grupos_risco.png"), g_risco, width = 2400, height = 1700, units = "px", dpi = 150)

# --- Razoes de chances do modelo final (fig-or do relatorio do modelo) --------
nome_disc <- c(LP = names(cores)[1], MT = names(cores)[2])
finais <- bind_rows(coeficientes, .id = "disc") %>% filter(nome != "(Intercept)")

g_or <- finais %>%
  mutate(disciplina = nome_disc[disc]) %>%
  ggplot(aes(odds_ratio, fct_reorder(grupo, odds_ratio, .fun = mean), color = disciplina)) +
  geom_vline(xintercept = 1, linetype = "dashed", color = "grey45") +
  geom_pointrange(aes(xmin = ic_inf, xmax = ic_sup), size = 0.6, linewidth = 1.2) +
  geom_text(aes(label = num(odds_ratio, 2)), vjust = -0.8, size = 6.2, color = "grey15") +
  facet_wrap(~ disciplina) +
  scale_color_manual(values = cores) +
  scale_x_log10(breaks = c(1, 1.5, 2, 3), labels = \(x) num(x, 1)) +
  scale_y_discrete(labels = \(x) str_wrap(x, 30)) +
  labs(x = "Raz\u00e3o de chances (ponto) e IC de 95% (barra)", y = NULL) +
  theme(legend.position = "none", axis.text.y = element_text(size = 19))

ggsave(file.path(pasta, "razoes_chances.png"), g_or, width = 2400, height = 1700, units = "px", dpi = 150)

# --- Acumulo de fatores na base de teste (fig-acumulo do relatorio do modelo) -
g_acum <- perfis %>%
  mutate(disciplina = nome_disc[disciplina]) %>%
  ggplot(aes(fatores, group = 1)) +
  geom_linerange(aes(ymin = ic_inf, ymax = ic_sup, color = disciplina), alpha = 0.3, linewidth = 5) +
  geom_point(aes(y = observado, color = disciplina), size = 5) +
  geom_line(aes(y = previsto), color = "grey35", linetype = "dashed", linewidth = 0.9) +
  geom_point(aes(y = previsto), color = "grey25", shape = 4, size = 5, stroke = 1.6) +
  geom_text(aes(y = observado, label = num(100 * observado, 1), color = disciplina),
            hjust = -0.4, size = 7, fontface = "bold", show.legend = FALSE) +
  facet_wrap(~ disciplina) +
  scale_color_manual(values = cores) +
  scale_y_continuous(labels = eixo_pct, limits = c(0, NA)) +
  labs(x = "N\u00famero de caracter\u00edsticas do aluno",
       y = "% abaixo do b\u00e1sico no teste",
       caption = "Ponto: observado no teste (IC 95%). X: previsto pelo modelo.") +
  theme(legend.position = "none", plot.caption = element_text(size = 19, color = "grey30"))

ggsave(file.path(pasta, "acumulo_teste.png"), g_acum, width = 2400, height = 1350, units = "px", dpi = 150)
