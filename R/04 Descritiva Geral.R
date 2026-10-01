library(tidyverse)

treino <- read.csv("data/treino.csv")

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-ANÁLISE INICIAL-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

#--------------------------------------------------------
# 1.0 Medidas de tendência geral, disperção e frequências
#--------------------------------------------------------

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

#Distribuição das notas por INSE


#------------------------------------------------------
#1.1 Alunos abaixo do básico por categoria de variável:
#------------------------------------------------------

resumo_variavel <- function(dados, variavel) {
  dados %>%
    group_by({{ variavel }}) %>%
    summarise(total = n(),
              alunos_abaixo_LP = sum(abaixo_LP, na.rm = TRUE),
              prop_LP = mean(abaixo_LP, na.rm = TRUE),
              alunos_abaixo_MT = sum(abaixo_MT, na.rm = TRUE),
              prop_MT = mean(abaixo_MT, na.rm = TRUE))
}

#-----------------------------------
#1.1.1 - Características/Informações
#-----------------------------------

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

#IDADE *
resumo_variavel(treino, TX_RESP_Q02)

treino %>%
  mutate(TX_RESP_Q02 = case_when(
    TX_RESP_Q02 %in% c("A") ~ "9 ou menos",
    TX_RESP_Q02 %in% c("B", "C") ~ "10 e 11",
    TX_RESP_Q02 %in% c("D", "E", "F") ~ "12 ou mais",
    TRUE ~ NA_character_
  ),
TX_RESP_Q02 = factor(
  TX_RESP_Q02,
  levels = c("9 ou menos", "10 e 11", "12 ou mais")
)
) %>%
  group_by(TX_RESP_Q02) %>%
  summarise(total = n(),
            alunos_abaixo_LP = sum(abaixo_LP, na.rm = TRUE),
            prop_LP = mean(abaixo_LP, na.rm = TRUE),
            alunos_abaixo_MT = sum(abaixo_MT, na.rm = TRUE),
            prop_MT = mean(abaixo_MT, na.rm = TRUE))

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

#REPROVAÇÃO *
resumo_variavel(treino, TX_RESP_Q19)

#Já abandonou a escola, deixando de frequentar até o final do ano *
resumo_variavel(treino, TX_RESP_Q20)

#Com que idade entrou na escola *
resumo_variavel(treino, TX_RESP_Q17)

#Deficiência 
resumo_variavel(treino, TX_RESP_Q05a)

#Austismo
resumo_variavel(treino, TX_RESP_Q05b)

#Altas habilidades
resumo_variavel(treino, TX_RESP_Q05c)

#---------------------------------------------------
#1.1.2 - Ambiente que está inserido
#---------------------------------------------------

#MORA COM A MÃE *
resumo_variavel(treino, TX_RESP_Q07a)

#MORA COM O PAI *
resumo_variavel(treino, TX_RESP_Q07b)

#INDICADOR SOCIO-ECONÔMICO *
resumo_variavel(treino, NU_TIPO_NIVEL_INSE)

#Tipo de escola a partir do fundamental *
resumo_variavel(treino, TX_RESP_Q18)

#Localização *
resumo_variavel(treino, ID_LOCALIZACAO)

#RUA ASFALTADA OU NÃO *
resumo_variavel(treino, TX_RESP_Q11a)

#POSSUI ÁGUA TRATADA
resumo_variavel(treino, TX_RESP_Q11b)

#POSSUI ILUMINAÇÃO *
resumo_variavel(treino, TX_RESP_Q11c)

#QNT DE CELULARES EM CASA *
resumo_variavel(treino, TX_RESP_Q12g)

#POSSUI WI-FI
resumo_variavel(treino, TX_RESP_Q13b)

#MEIO DE TRANSPORTE PARA IR PARA A ESCOLA
resumo_variavel(treino, TX_RESP_Q16)

#------------------------------------
#1.1.3 - INFORMAÇÕES DOS RESPONSÁVEIS
#------------------------------------

#ESCOLARIDADE DA MÃE *
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

#ESCOLARIDADE DO PAI *
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

#RESPONSÁVEIS COSTUMAM LER EM CASA
resumo_variavel(treino, TX_RESP_Q10a)

#RESPONSÁVEIS INCENTIVAM IR A AULA *
resumo_variavel(treino, TX_RESP_Q10e)

#RESPONSÁVEIS VÃO NAS REUNIÕES *
resumo_variavel(treino, TX_RESP_Q10f)

#RESPONSÁVEIS INCENTIVAM A ESTUDAR *
resumo_variavel(treino, TX_RESP_Q10c)

#--------------
#1.1.4 - Rotina
#--------------

#Tempo utilizado para estudar *
resumo_variavel(treino, TX_RESP_Q21a)

#Tempo utilizado para fazer cursos extracurriculares 
resumo_variavel(treino, TX_RESP_Q21b)

#Tempo usado para trabalhar em casa 
resumo_variavel(treino, TX_RESP_Q21c)

#Tempo usado para trabalhar fora de casa *
resumo_variavel(treino, TX_RESP_Q21d)

#tempo destinado para lazer *
resumo_variavel(treino, TX_RESP_Q21e)

#----------------------------------------
#1.1.5 - Opiniões sobre escola/professor
#----------------------------------------

#Os professores desenvolvem trabalhos em grupo *
resumo_variavel(treino, TX_RESP_Q22g)

#Se interessa ou não pelo conteúdo *
resumo_variavel(treino, TX_RESP_Q23a)

#Professores motivam os alunos a continuar os estudos *
resumo_variavel(treino, TX_RESP_Q23i)

#Professores acreditam que o aluno é capaz de aprender *
resumo_variavel(treino, TX_RESP_Q23h)

#Se sente seguro na escola
resumo_variavel(treino, TX_RESP_Q23d)

#---------------------------------------------------------------------
#1.2 — Análises multivariadas/cruzamentos entre variáveis explicativas
#---------------------------------------------------------------------
install.packages("hrbrthemes")
library(hrbrthemes)
library(viridis)

#Relacão de reprovações com idade 
treino %>%
  mutate(Idade = case_when(
    TX_RESP_Q02 %in% c("A") ~ "9 ou menos",
    TX_RESP_Q02 %in% c("B", "C") ~ "10 e 11", 
    TX_RESP_Q02 %in% c("D", "E", "F") ~ "12 ou mais",
    TRUE ~ NA_character_
    ),
    Reprovações = case_when(
      TX_RESP_Q19 %in% c("A") ~ "Nenhuma",
      TX_RESP_Q19 %in% c("B") ~ "Uma",
      TX_RESP_Q19 %in% c("C") ~ "Duas ou mais"
    ),
  Idade = factor(
    Idade,
    levels = c("9 ou menos", "10 e 11", "12 ou mais")
  ),
  Reprovações = factor(
    Reprovações,
    levels = c("Nenhuma", "Uma", "Duas ou mais")
  )
  )%>%
  group_by(Idade, Reprovações) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(Idade) %>%
  mutate(
    total = sum(n),
    proporção = n / total
  ) %>%
  ungroup() %>%
  ggplot(aes(fill = Reprovações, y = proporção, x = Idade)) +
  geom_bar(position = "dodge", stat = "identity") +
  labs(title = "Proporção de alunos reprovados por faixa de idade",
         y = "Proporção") +
  scale_fill_viridis(discrete = T) +
  scale_y_continuous(labels = scales::percent) +
  scale_x_discrete(
    labels = c(
      "9 ou menos" = "9 ou menos\n(n = 46)",
      "10 e 11" = "10 e 11\n(n = 8348)",
      "12 ou mais" = "12 ou mais\n(n = 668)"
    )
  ) +
  theme_minimal()

# Alunos com 9 anos ou menos podem estar adiantados ou ainda vão fazer 10, apenas 1 aluno marcou que reprovou uma vez
# 10 anos é o padrão para o quinto ano, 11 anos pode indicar uma reprovação ou que o aluno foi segurado
# 12 anos para cima já indica uma ou mais reprovações
# Alunos que já reprovaram tendem a ter um desempenho pior, o que pode explicar o aumento da 
# proporção de alunos abaixo do básico conforme a idade aumenta

#----------------------------------------
#Tempo de trabalho fora de casa por Idade
#----------------------------------------

treino %>%
  mutate(Idade = case_when(
    TX_RESP_Q02 %in% c("A") ~ "9 ou menos",
    TX_RESP_Q02 %in% c("B", "C") ~ "10 e 11", 
    TX_RESP_Q02 %in% c("D", "E", "F") ~ "12 ou mais",
    TRUE ~ NA_character_
  ),
  Horas = case_when(
    TX_RESP_Q21d %in% c("A") ~ "Nenhuma",
    TX_RESP_Q21d %in% c("B") ~ "Menos de 1 hora",
    TX_RESP_Q21d %in% c("C") ~ "Entre 1 e 2 horas",
    TX_RESP_Q21d %in% c("D") ~ "2 ou mais horas",
  ),
  Idade = factor(
    Idade,
    levels = c("9 ou menos", "10 e 11", "12 ou mais")
  ),
  Horas = factor(
    Horas,
    levels = c("Nenhuma", "Menos de 1 hora", "Entre 1 e 2 horas", "2 ou mais horas")
  )
  )%>%
  group_by(Idade, Horas) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(Idade) %>%
  mutate(
    total = sum(n),
    proporção = n / total
  ) %>%
  ungroup() %>%
  ggplot(aes(fill = Horas, y = proporção, x = Idade)) +
  geom_bar(position = "dodge", stat = "identity") +
  labs(title = "Horas/ dia de trabalho fora de casa por faixa de idade",
       y = "Proporção") +
  scale_fill_viridis(discrete = T, option = "E") +
  scale_y_continuous(labels = scales::percent) +
  scale_x_discrete(
    labels = c(
      "9 ou menos" = "9 ou menos\n(n = 46)",
      "10 e 11" = "10 e 11\n(n = 8348)",
      "12 ou mais" = "12 ou mais\n(n = 668)"
    )
  ) +
  theme_minimal()

#-------------------------------------------------
#Relação entre tempo de estudo e tempo trabalhando
#-------------------------------------------------
treino %>%
  mutate(Horas_estudo = case_when(
    TX_RESP_Q21a %in% c("A") ~ "Nenhuma",
    TX_RESP_Q21a %in% c("B") ~ "Menos de 1 hora",
    TX_RESP_Q21a %in% c("C") ~ "Entre 1 e 2 horas",
    TX_RESP_Q21a %in% c("D") ~ "2 ou mais horas",
  ),
  Horas_trabalho = case_when(
    TX_RESP_Q21d %in% c("A") ~ "Nenhuma",
    TX_RESP_Q21d %in% c("B") ~ "Menos de 1 hora",
    TX_RESP_Q21d %in% c("C") ~ "Entre 1 e 2 horas",
    TX_RESP_Q21d %in% c("D") ~ "2 ou mais horas",
  ),
  Horas_trabalho = factor(
    Horas_trabalho,
    levels = c("Nenhuma", "Menos de 1 hora", "Entre 1 e 2 horas", "2 ou mais horas")
  ),
  Horas_estudo = factor(
    Horas_estudo,
    levels = c("Nenhuma", "Menos de 1 hora", "Entre 1 e 2 horas", "2 ou mais horas")
  )
  )%>%
  group_by(Horas_trabalho, Horas_estudo) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(Horas_trabalho) %>%
  mutate(
    total = sum(n),
    proporção = n / total
  ) %>%
  ungroup() %>%
  ggplot(aes(fill = Horas_estudo, y = proporção, x = Horas_trabalho)) +
  geom_bar(position = "dodge", stat = "identity") +
  labs(title = "Relação entre horas por dia de estudo e trabalho",
       y = "Proporção") +
  scale_fill_viridis(discrete = T, option = "E") +
  scale_y_continuous(labels = scales::percent) +
  theme_minimal()

#Esperava-se que conforme mais horas trabalhadas, o estudante estudaria menos, mas não se observa isso
# A proporção de alunos abaixo do básico é maior conforme as horas trabalhadas aumentam
# Talvez o aluno que trabalhe mais tenha mais dificuldade e estude mais

#------------------------------------------------------
#Quem não tem a mãe/pai em casa tem que trabalhar?
#------------------------------------------------------
treino %>%
  mutate(estrutura_familiar = case_when(
    TX_RESP_Q07a == "B" & TX_RESP_Q07b == "B" ~ "Mora com os dois",
    TX_RESP_Q07a == "B" & TX_RESP_Q07b == "A" ~ "Só com a mãe",
    TX_RESP_Q07a == "A" & TX_RESP_Q07b == "B" ~ "Só com o pai",
    TRUE ~ "Com nenhum dos dois"
  ),
  Horas_trabalho = case_when(
    TX_RESP_Q21d %in% c("A") ~ "Nenhuma",
    TX_RESP_Q21d %in% c("B") ~ "Menos de 1 hora",
    TX_RESP_Q21d %in% c("C") ~ "Entre 1 e 2 horas",
    TX_RESP_Q21d %in% c("D") ~ "2 ou mais horas",
  ),
  estrutura_familiar = factor(
    estrutura_familiar,
    levels = c("Mora com os dois", "Só com a mãe", "Só com o pai", "Com nenhum dos dois")
  ),
  Horas_trabalho = factor(
    Horas_trabalho,
    levels = c("Nenhuma", "Menos de 1 hora", "Entre 1 e 2 horas", "2 ou mais horas")
  )
  ) %>%
 # filter(Horas_trabalho != "Nenhuma") %>% (Fltra a barra "nenhuma" pois ela ofusca as outras)
  group_by(estrutura_familiar, Horas_trabalho) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(estrutura_familiar) %>%
  mutate(
    total = sum(n),
    proporção = n/total) %>%
    ungroup() %>%
  ggplot(aes(fill = Horas_trabalho, y = proporção, x = estrutura_familiar)) +
  geom_bar(position = "dodge", stat = "identity") +
  labs(title = "Relação entre a estrutura familiar com horas de trabalho fora de casa por dia",
       y = "Proporção") +
  scale_fill_viridis(discrete = T, option = "E") +
  scale_y_continuous(labels = scales::percent) +
  theme_minimal()

# 

#-----------------------------------------------
#O incentivo dos pais realmente faz a diferença?
#-----------------------------------------------
treino %>%
  mutate(Horas_estudo = case_when(
    TX_RESP_Q21a %in% c("A") ~ "Nenhuma",
    TX_RESP_Q21a %in% c("B") ~ "Menos de 1 hora",
    TX_RESP_Q21a %in% c("C") ~ "Entre 1 e 2 horas",
    TX_RESP_Q21a %in% c("D") ~ "2 ou mais horas"
  ),
  Incentivo = case_when(
    TX_RESP_Q10c %in% c("A") ~ "Nunca ou quase nunca",
    TX_RESP_Q10c %in% c("B") ~ "De vez em quando",
    TX_RESP_Q10c %in% c("C") ~ "Sempre ou quase sempre",
  ),
  Incentivo = factor(
    Incentivo,
    levels = c("Nunca ou quase nunca", "De vez em quando", "Sempre ou quase sempre")
  ),
  Horas_estudo = factor(
    Horas_estudo,
    levels = c("Nenhuma", "Menos de 1 hora", "Entre 1 e 2 horas", "2 ou mais horas")
  )
  )%>%
  group_by(Incentivo, Horas_estudo) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(Incentivo) %>%
  mutate(
    total = sum(n),
    proporção = n / total
  ) %>%
  ungroup() %>%
  ggplot(aes(fill = Horas_estudo, y = proporção, x = Incentivo)) +
  geom_bar(position = "dodge", stat = "identity") +
  labs(title = "Relação entre incentivo dos responsáveis com horas de estudo por dia",
       y = "Proporção") +
  scale_fill_viridis(discrete = T, option = "E") +
  scale_y_continuous(labels = scales::percent) +
  theme_minimal()

#Observa-se um aumento na quantidade de horas de estudo por dia conforme o incentivo é mais presente

#-----------------------------------------------
#Tempo de estudo por reprovação
#-----------------------------------------------
treino %>%
  mutate(reprovação = case_when(
    TX_RESP_Q19 %in% c("A") ~ "Nenhuma",
    TX_RESP_Q19 %in% c("B") ~ "Uma",
    TX_RESP_Q19 %in% c("C") ~ "Duas ou mais"
  ),
  Horas_estudo = case_when(
    TX_RESP_Q21a %in% c("A") ~ "Nenhuma",
    TX_RESP_Q21a %in% c("B") ~ "Menos de 1 hora",
    TX_RESP_Q21a %in% c("C") ~ "Entre 1 e 2 horas",
    TX_RESP_Q21a %in% c("D") ~ "2 ou mais horas"
  ),
  reprovação = factor(
    reprovação,
    levels = c("Nenhuma", "Uma", "Duas ou mais")
  ),
  Horas_estudo = factor(
    Horas_estudo,
    levels = c("Nenhuma", "Menos de 1 hora", "Entre 1 e 2 horas", "2 ou mais horas")
  )
  ) %>%
  group_by(reprovação, Horas_estudo) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(reprovação) %>%
  mutate(
    total = sum(n),
    proporção = n / total
  ) %>%
  ungroup() %>%
  ggplot(aes(fill = Horas_estudo, y = proporção, x = reprovação)) +
  geom_bar(position = "dodge", stat = "identity") +
  labs(title = "Relação entre reprovação com horas de estudo por dia",
       y = "Proporção") +
  scale_fill_viridis_d(option = "E") +
  scale_y_continuous(labels = scales::percent) +
  theme_minimal()
  



#OUTRAS ANÁlISES



