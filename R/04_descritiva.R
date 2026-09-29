library(tidyverse)

treino <- read.csv("data/treino.csv")

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-ANÁLISE INICIAL-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

# 1.0 Medidas de tendência geral, disperção e frequências

#LP
mean(treino$PROFICIENCIA_LP_SAEB, na.rm = T)
median(treino$PROFICIENCIA_LP_SAEB, na.rm = T)
sd(treino$PROFICIENCIA_LP_SAEB, na.rm = T)
var(treino$PROFICIENCIA_LP_SAEB, na.rm = T)
quantile(treino$PROFICIENCIA_LP_SAEB, na.rm = T)

treino %>%
  summarise(alunos_abaixo_basico = sum(abaixo_LP), proporção = mean(abaixo_LP, na.rm = T))

#HISTOGRAMA
treino %>%
  ggplot() +
  aes(x = PROFICIENCIA_LP_SAEB) +
  geom_histogram(color = "red",
                 fill = "salmon",
                 bins = 39) +
  labs(x = "Proficiência em Língua Portuguesa",
       y = "Frequência") +
  geom_vline(xintercept = 150, color = "red", linetype = "dashed", linewidth = 1) +
  theme_minimal()

#MATEMÁTICA:
mean(treino$PROFICIENCIA_MT_SAEB, na.rm = T)
median(treino$PROFICIENCIA_MT_SAEB, na.rm = T)
sd(treino$PROFICIENCIA_MT_SAEB, na.rm = T)
var(treino$PROFICIENCIA_MT_SAEB, na.rm = T)
quantile(treino$PROFICIENCIA_MT_SAEB, na.rm = T)

treino %>%
  summarise(total = sum(abaixo_MT), proporção = mean(abaixo_MT, na.rm = T))

#HISTOGRAMA
treino %>%
  ggplot() +
  aes(x = PROFICIENCIA_MT_SAEB) +
  geom_histogram(color = "red",
                 fill = "salmon",
                 bins = 42) +
  labs(x = "Proficiência em Matemática",
       y = "Frequência") +
  geom_vline(xintercept = 175, color = "red", linetype = "dashed", linewidth = 1) +
  theme_minimal()

#Indicador Combinado
treino %>%
  count(abaixo_LP, abaixo_MT) %>%
  mutate(prop = n / sum(n))

#Gráfico de Dispersão entre notas de LP e MT:
treino %>%
  ggplot() +
  aes(x = PROFICIENCIA_MT_SAEB,
      y = PROFICIENCIA_LP_SAEB) +
  geom_point(alpha = 0.4, pch = "circle") +
  geom_smooth(method = "loess", color = "red", se = FALSE) +
  labs(
    title = "Relação entre notas de Língua Portuguesa e Matemática",
    x = "Nota de Matemática",
    y = "Nota de Língua Portuguesa"
  )

#1.1 Alunos abaixo do básico por categoria de variável:
resumo_variavel <- function(dados, variavel) {
  dados %>%
    group_by({{ variavel }}) %>%
    summarise(total = n(),
              alunos_abaixo_LP = sum(abaixo_LP, na.rm = TRUE),
              prop_LP = mean(abaixo_LP, na.rm = TRUE),
              alunos_abaixo_MT = sum(abaixo_MT, na.rm = TRUE),
              prop_MT = mean(abaixo_MT, na.rm = TRUE))
}

#1.1.1 - Características/Informações
#Sexo
resumo_variavel(treino, TX_RESP_Q01)

#LP:
#Colunas
treino %>%
  group_by(TX_RESP_Q01) %>%
  summarise(proporção = mean(abaixo_LP, na.rm = T)) %>%
  ggplot(aes(x=TX_RESP_Q01 ,y=proporção)) +
  geom_col() +
  labs(title = "Proporção de alunos abaixo do nível básico de Língua Portuguesa para cada gênero",
       x = "Sexo",
       y = "Frequência") +
  scale_x_discrete(labels = c("A" = "Masculino",
                                "B" = "Feminino",
                                "C" = "Não declarado")) +
  theme_minimal()

#Boxplot
treino %>%
  ggplot() +
  aes(x = TX_RESP_Q01, y = PROFICIENCIA_LP_SAEB, fill = TX_RESP_Q01, color = TX_RESP_Q01) +
  geom_boxplot(, outlier.colour = "red", alpha = 0.1) +
  scale_x_discrete(labels = c("A" = "Masculino",
                   "B" = "Feminino",
                   "C" = "Não Informado")) +
  theme_minimal()

#MT:
#Colunas:
treino %>%
  group_by(TX_RESP_Q01) %>%
  summarise(proporção = mean(abaixo_MT, na.rm = T)) %>%
  ggplot(aes( x = TX_RESP_Q01 , y = proporção)) +
  geom_col() +
  labs(title = "Proporção de alunos abaixo do nível básico de Matemática para cada gênero",
       x = "Sexo",
       y = "Frequência") +
  scale_x_discrete(labels = c("A" = "Masculino",
                              "B" = "Feminino",
                              "C" = "Não declarado")) +
  theme_minimal()

#Boxplot
treino %>%
  ggplot() +
  aes(x = TX_RESP_Q01, y = PROFICIENCIA_MT_SAEB, fill = TX_RESP_Q01, color = TX_RESP_Q01) +
  geom_boxplot(, outlier.colour = "red", alpha = 0.1) +
  scale_x_discrete(labels = c("A" = "Masculino",
                              "B" = "Feminino",
                              "C" = "Não Informado")) +
  theme_minimal()

#COR/RAÇA
resumo_variavel(treino, TX_RESP_Q04)

#LP:
#Colunas:
treino %>%
  group_by(TX_RESP_Q04) %>%
  summarise(proporção = mean(abaixo_LP, na.rm = T)) %>%
  ggplot(aes(x=TX_RESP_Q04 ,y=proporção)) +
  geom_col()

#Boxplot:
treino %>%
  ggplot() +
  aes(x = TX_RESP_Q04, y = PROFICIENCIA_LP_SAEB, fill = TX_RESP_Q04, color = TX_RESP_Q04) +
  geom_boxplot(, outlier.colour = "red", alpha = 0.1) +
  theme_minimal()

#MT:
#colunas
treino %>%
  group_by(TX_RESP_Q04) %>%
  summarise(proporção = mean(abaixo_MT, na.rm = T)) %>%
  ggplot(aes(x=TX_RESP_Q04 ,y=proporção)) +
  geom_col()

#Boxplot:
treino %>%
  ggplot() +
  aes(x = TX_RESP_Q04, y = PROFICIENCIA_MT_SAEB, fill = TX_RESP_Q04, color = TX_RESP_Q04) +
  geom_boxplot(, outlier.colour = "red", alpha = 0.1) +
  theme_minimal()

#IDADE
resumo_variavel(treino, TX_RESP_Q02)

#LP:
#Boxplot:
treino %>%
  ggplot() +
  aes(x = TX_RESP_Q02, y = PROFICIENCIA_LP_SAEB, fill = TX_RESP_Q02, color = TX_RESP_Q02) +
  geom_boxplot(, outlier.colour = "red", alpha = 0.1) +
  theme_minimal()

#MT:
#Boxplot:
treino %>%
  ggplot() +
  aes(x = TX_RESP_Q02, y = PROFICIENCIA_MT_SAEB, fill = TX_RESP_Q02, color = TX_RESP_Q02) +
  geom_boxplot(, outlier.colour = "red", alpha = 0.1) +
  theme_minimal()

#REPROVAÇÃO
resumo_variavel(treino, TX_RESP_Q19)

#1.1.2 - Informações do ambiente que está inserido

#ESCOLARIDADE DA MÃE:
resumo_variavel(treino, TX_RESP_Q08)

#GRÁFICOS LP:
#colunas:
treino %>%
  group_by(TX_RESP_Q08) %>%
  summarise(proporção = mean(abaixo_LP, na.rm = T)) %>%
  ggplot(aes(x=TX_RESP_Q08 ,y=proporção)) +
  geom_col()

#Boxplot:
treino %>%
  ggplot() +
  aes(x = TX_RESP_Q08, y = PROFICIENCIA_LP_SAEB, fill = TX_RESP_Q08, color = TX_RESP_Q08) +
  geom_boxplot(, outlier.colour = "red", alpha = 0.1) +
  theme_minimal()

#GRÁFICOS MT:
#Colunas:
treino %>%
  group_by(TX_RESP_Q08) %>%
  summarise(proporção = mean(abaixo_MT, na.rm = T)) %>%
  ggplot(aes(x=TX_RESP_Q08 ,y=proporção)) +
  geom_col()

#Boxplot:
treino %>%
  ggplot() +
  aes(x = TX_RESP_Q08, y = PROFICIENCIA_MT_SAEB, fill = TX_RESP_Q08, color = TX_RESP_Q08) +
  geom_boxplot(, outlier.colour = "red", alpha = 0.1) +
  theme_minimal()

#ESCOLARIDADE DO PAI:
resumo_variavel(treino, TX_RESP_Q09)

#GRÁFICOS LP:
#Colunas:
treino %>%
  group_by(TX_RESP_Q09) %>%
  summarise(proporção = mean(abaixo_LP, na.rm = T)) %>%
  ggplot(aes(x=TX_RESP_Q09 ,y=proporção)) +
  geom_col()

#Boxplot:
treino %>%
  ggplot() +
  aes(x = TX_RESP_Q09, y = PROFICIENCIA_LP_SAEB, fill = TX_RESP_Q09, color = TX_RESP_Q09) +
  geom_boxplot(, outlier.colour = "red", alpha = 0.1) +
  theme_minimal()

#GRÁFICOS MT:
#COLUNAS:
treino %>%
  group_by(TX_RESP_Q09) %>%
  summarise(proporção = mean(abaixo_MT, na.rm = T)) %>%
  ggplot(aes(x=TX_RESP_Q09 ,y=proporção)) +
  geom_col()

#Boxplot:
treino %>%
  ggplot() +
  aes(x = TX_RESP_Q09, y = PROFICIENCIA_MT_SAEB, fill = TX_RESP_Q09, color = TX_RESP_Q09) +
  geom_boxplot(, outlier.colour = "red", alpha = 0.1) +
  theme_minimal()

#INDICADOR SOCIO-ECONÔMICO
resumo_variavel(treino, NU_TIPO_NIVEL_INSE)

#Tipo de escola a partir do fundamental
resumo_variavel(treino, TX_RESP_Q18)

#Localização
resumo_variavel(treino, ID_LOCALIZACAO)

#1.1.3 - Rotina
#Tempo utilizado para estudar
resumo_variavel(treino, TX_RESP_Q21a)

#Tempo usado para trabalhar em casa
resumo_variavel(treino, TX_RESP_Q21c)

#Tempo usado para trabalhar fora de casa
resumo_variavel(treino, TX_RESP_Q21d)

#tempo destinado para lazer
resumo_variavel(treino, TX_RESP_Q21e)

#1.1.4 - Opiniões sobre escola/professor
#Os professores desenvolvem trabalhos em grupo?
resumo_variavel(treino, TX_RESP_Q22g)

#Se interessa ou não pelo conteúdo
resumo_variavel(treino, TX_RESP_Q23a)

#Professores motivam os alunos a continuar os estudos
resumo_variavel(treino, TX_RESP_Q23i)

#Se sente seguro na escola
resumo_variavel(treino, TX_RESP_Q23d)
