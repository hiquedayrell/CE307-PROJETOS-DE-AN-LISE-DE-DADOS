# CE307 — Projetos de Análise de Dados (UFPR, 2026/2)

Projeto de extensão do Eixo 4: Educação Básica Municipal, em parceria com a
Secretaria Municipal de Educação de Curitiba (SME, André Zilio).
Grupo: Henrique Dayrell, Pedro Groxko, Kadu Blank e João Pedro Brustulin.
Professor orientador: Eduardo Vargas Ferreira. Na SME: André Zilio,
estatístico. Nomes completos usados na capa e no último slide da apresentação.

**Pergunta de pesquisa:** quais fatores estão associados à maior probabilidade
de um estudante do 5º ano apresentar proficiência abaixo do nível básico em
Língua Portuguesa e Matemática?

## Dados

- Fonte: microdados do Saeb 2023 (INEP), alunos do 5º ano (`TS_ALUNO_5EF.csv`).
  A base bruta fica em `data/raw/` e NÃO vai para o GitHub (`.gitignore`).
- `data/amostra_limpa.csv`: 10.068 alunos (amostra estratificada por UF +
  filtros de qualidade, incluindo questionário completo).
- `data/treino.csv` (9.062) e `data/teste.csv` (1.006): partição 90/10,
  estratificada por `abaixo_LP` e `abaixo_MT`.
- `data/curitiba_limpa.csv`: 4.452 alunos de Curitiba.
- Variáveis resposta: `abaixo_LP = PROFICIENCIA_LP_SAEB <= 150` e
  `abaixo_MT = PROFICIENCIA_MT_SAEB <= 175` (Soares, 2009).
- Codebook em `docs/codebook.md`; dicionário oficial em `docs/Dicionario_Saeb_2023.xlsx`.
- `ID_ESCOLA` e `ID_MUNICIPIO` são códigos mascarados: não cruzam com o Censo Escolar.

## Scripts (`R/`)

01 preparação da base · 02 separação treino/teste · 03 teste de viés ·
04 descritiva geral · 05 base Curitiba · 06 comparação Curitiba ·
07 fatores associados · 08 modelo logístico (estimação, interpretação e,
desde 18/11/2026, probabilidades condicionais na base de teste).

App Shiny em `app/app.R` (18/11/2026): o usuário marca as características de
um aluno e vê a probabilidade prevista em LP e MT e o nível de risco (alto =
top 10%, moderado = top 20%). O app não estima nada: lê
`data/modelo/modelo_grupo_*.csv` e `classificacao_teste.csv`, gravados pelo
`R/08`; se o modelo mudar, rodar o `R/08` antes. Abrir com o botão "Run App"
do RStudio ou `shiny::runApp("app")`. O app tem acentos em UTF-8, o que
funciona porque o `runApp` lê o arquivo em UTF-8; não rodar por seleção.
Conferido: dá as mesmas probabilidades que `avalia_aluno()`.
Publicado em https://henriquedayrell.shinyapps.io/risco-abaixo-basico/
(24/11/2026, conta henriquedayrell). Para atualizar: rodar o `R/08` se o
modelo mudou e depois `source("app/publicar.R")`, que copia os 3 CSVs para
`app/dados/` (no shinyapps.io só sobe a pasta `app/`) e reenvia. O app procura
os CSVs em `app/dados/`, depois em `../data/modelo/` e `data/modelo/`.
`.claude/` (com o `launch.json` que o Claude usa para abrir o app no navegador
dele) e `PRODUCT.md` (público e princípios do app para a skill /impeccable:
projeção em sala, tom institucional e sóbrio, evitar cara de template padrão
do Shiny) ficam só na máquina do Henrique, fora do git: estão em
`.git/info/exclude`, não no `.gitignore` (decisão do Henrique, 18/11/2026).

## Tema visual (app e apresentação)

Decisão do Henrique (18/11/2026): usar o tema da UFPR no app e na
apresentação. Cores tiradas do portal ufpr.br (variáveis CSS do site, nov/2026;
o PDF do manual de marca não pôde ser lido):
- azul UFPR `#005296` (`--portal-ufpr`, barra do site): cor principal;
- azul-marinho `#273272` (`--padrao_ufpr`): detalhes e filetes;
- azul escuro `#003D68`; azul claro `#E0EBF5`; fundo `#F1F3F8`;
  cinza do rodapé `#58595B`.
- LP em azul UFPR `#005296`, MT em laranja `#A35716`.
- Faixas de risco: cinza `#E2E7EF` (fora dos cortes), areia `#EFD9AE`
  (moderado), terracota `#E2B7A3` (alto); selo de risco alto `#7E3520`.
- Fonte: a do sistema (o portal usa system-ui no corpo), sem depender de
  internet na hora de apresentar.

Relatórios em `Entregas/` (R Markdown). O principal é
`relatorio_descritivo_revisado.Rmd`; a seção 4 ("Quais grupos concentram mais
alunos abaixo do básico") define 18 variáveis dicotômicas em um `tribble`
(bloco, grupo, variável do questionário, códigos).

O relatório do modelo é `Entregas/relatorio_modelo.Rmd`. Ele não reestima nada:
dá `source()` no `R/08` e só formata os objetos do script, então qualquer
mudança no modelo deve ser feita no `R/08`. Os `.html` não são versionados.
Para renderizar fora do RStudio, o pandoc é o do Quarto:
`RSTUDIO_PANDOC=<Quarto>/bin/tools Rscript -e 'rmarkdown::render("Entregas/relatorio_modelo.Rmd")'`.

## Pedido do professor (áudio, nov/2026)

O professor estimou duas regressões logísticas (LP e MT) com as variáveis
dicotômicas da seção 4, manteve só as significativas e enviou as planilhas de
coeficientes (`data/modelo/coeficientes_LP.csv` e `coeficientes_MT.csv`:
variável, coeficiente, p-valor, odds ratio e IC 95%). Objetivo didático:
entender o processo, não a seleção ideal de variáveis.

Ele pede:
1. Interpretar cada variável pela razão de chances (odds ratio).
2. Verificar na base de TESTE se os dados vão na mesma direção do modelo,
   agrupando os alunos pela característica e calculando proporções condicionais.

## Reunião com o professor (18/11/2026)

Anotações do Henrique (brainstorm, transcritas como estão):
- Dado visto no modelo, avaliar o que está sendo visto na prática.
- Entender o papel da interpretação do modelo, com probabilidades condicionais.
- Não condicionar a nada: fica a mesma proporção da base geral, "vai dar igual".
- Compreender como verificamos na base de teste o que interpretamos; pensar como fazer.
- Comparação da descritiva com o modelo: exemplo da iluminação.
- Extrair o tipo de informação; interpretação dos resultados após o modelo.
- Apresentação: mais mostrar domínio do que cada um falar.

Leitura do grupo com o Claude (interpretação nossa, não fala do professor):
- O próximo passo é a base de teste.
- Sem condicionar a nada, modelo e dados dão a mesma coisa: a média das
  probabilidades previstas é igual à proporção geral (treino 7,66% e 11,04%,
  igual ao observado; teste 7,44% e 10,90%, contra 7,7% e 11,0%). Essa
  comparação não testa nada; o teste está em condicionar.
- Verificar no teste a interpretação em probabilidades condicionais: para cada
  característica, comparar a probabilidade média que o modelo prevê para os
  alunos do grupo com a proporção observada no grupo.
- Iluminação: na descritiva (treino) 12,9% x 7,4% em LP; no modelo sai (razão
  de chances 0,88 no modelo completo). Dos alunos em rua sem iluminação, 66%
  moram em rua sem asfalto e 31% estudam em escola rural, contra 20% e 10% dos
  demais. Separando por asfalto, a diferença diminui (LP: 6,2% x 9,1% com
  asfalto; 11,9% x 14,8% sem asfalto). No teste são só 45 alunos sem iluminação.

## Metodologia do modelo (segue a do professor)

Implementada em `R/08 Modelo logístico.R`:
1. Criar as 18 variáveis 0/1 da seção 4 no treino e no teste.
2. Ajustar a regressão logística com as 18 no treino (uma para LP, outra para MT).
3. Manter as variáveis com p < 0,05 e reestimar.
4. Interpretar pela razão de chances, `exp(beta)`, com IC de 95% (Wald).
5. Base de teste (seção 4 do script, desde 18/11/2026): para cada
   característica, nos alunos do teste que a têm e nos que não a têm,
   comparar a probabilidade média prevista pelo modelo do treino com a
   proporção observada (com IC de 95% de Wilson). A primeira linha, "Todos os
   alunos", não condiciona a nada e serve só de referência (4.1). Perfis por
   número de fatores acumulados (0 a 4 ou mais), previsto x observado (4.2).
   Classificação "em risco ou não" (4.3): corte definido no TREINO (top 20% e
   top 10% da probabilidade prevista), avaliado no teste.
   AUC fora do script; comparação com o professor não volta.
6. Aplicação (seção 5 do script): `avalia_aluno("reprovou", "idade_12", ...)`
   recebe as características de um aluno (nomes curtos da tabela `grupos`) e
   devolve, para LP e MT, a probabilidade prevista, quantas vezes ela é a
   média, se o aluno passa dos cortes de risco e quais características o
   modelo de cada disciplina usou ou ignorou. É ferramenta de priorização,
   não diagnóstico.
6. (Retirado, aguardando o professor) Comparar com os coeficientes do professor.

Saídas em `data/modelo/`: `modelo_grupo_LP.csv`, `modelo_grupo_MT.csv`,
`probabilidades_condicionais_teste.csv`, `perfis_fatores_teste.csv` e
`classificacao_teste.csv`.

## Resultados até aqui (treino 9.062, teste 1.006)

- Ficam 15 de 18 variáveis em cada disciplina. Saem nas duas: mãe até o 5º ano
  e rua sem iluminação. Só em LP sai TEA; só em MT sai abandono.
- Probabilidade base (nenhum fator): 3,2% em LP e 5,3% em MT.
- Maiores razões de chances em LP: professores não acreditam (1,90), trabalha
  fora (1,87), reprovou (1,85), 12 anos ou mais (1,80). Em MT: TEA (2,08),
  INSE I e II (2,04), reprovou (2,02), entrada com 8 anos ou mais (1,85).
- Probabilidades condicionais no teste (18/11/2026): em 59 dos 60 grupos
  (15 características x tem/não tem x LP/MT), a probabilidade média prevista
  cai dentro do IC de 95% da proporção observada. A exceção é "não mora com a
  mãe" em LP: previsto 12,9%, observado 5,1% (5 de 99; IC 2,2% a 11,3%).
  Deficiência em LP (1 de 32) fica dentro do IC só porque o intervalo é largo.
  Exemplo: reprovou, LP, previsto 18,2% e observado 19,3%; MT, 25,1% e 30,3%.
- Perfis por número de fatores no teste (18/11/2026), observado x previsto.
  LP: 0 → 2,3% x 3,2%; 1 → 6,8% x 5,1%; 2 → 10,8% x 8,0%; 3 → 9,2% x 12,4%;
  4 ou mais → 24,7% x 25,9%. MT: 4,7% x 5,3%; 8,5% x 8,0%; 17,1% x 12,6%;
  16,9% x 18,1%; 29,1% x 34,0%. Previsto dentro do IC nas 10 faixas.
  Cerca de 35% dos alunos não têm nenhum fator, mas concentram só 10% dos
  abaixo do básico em LP e 15% em MT; os 9% com 4 ou mais concentram 29% (LP)
  e 22% (MT).
- Classificação no teste (18/11/2026). Corte top 20% do treino (LP 9,6%,
  MT 13,9%): marca 20% dos alunos do teste; entre os marcados, 15,6% (LP) e
  23,9% (MT) estão abaixo do básico, contra 5,6% e 7,7% dos não marcados; a
  marcação alcança 42% (LP) e 45% (MT) dos abaixo do básico. Corte top 10%
  (LP 15,1%, MT 20,9%): marca 10%; 23,2% e 26,3% abaixo entre os marcados;
  alcança 30% e 23% dos abaixo.
- Combinações de fatores: no teste há 228 combinações distintas em LP, 158
  com um único aluno e só 16 com 10 ou mais. Por isso o teste de combinações
  é feito pela probabilidade prevista (classificação), não combinação a
  combinação.
- `avalia_aluno`: um fator sozinho não passa do corte top 20%; reprovou + 12
  anos ou mais passa (LP 10,0%, MT 16,1%). TEA sozinho em MT dá 10,4%, abaixo
  da média geral (11,0%), porque o aluno médio já tem outros fatores.
- Os itens abaixo sobre o teste e a comparação são da versão anterior do `R/08`
  (commit 8a6d632), retirada em 17/11/2026. Ficam como registro do que já foi
  calculado.
- Teste, mesma direção do modelo: 15 de 15 em MT; 13 de 15 em LP. Exceções em
  LP, ambas com poucos casos: não mora com a mãe (5 em 99) e deficiência (1 em 32).
- Calibração no teste por número de fatores, LP: 0 → 2,3%; 1 → 6,8%; 2 → 10,8%;
  3 → 9,2%; 4 ou mais → 24,7%. MT: 4,7%; 8,5%; 17,1%; 16,9%; 29,1%.
- AUC no teste: 0,71 (LP) e 0,71 (MT). No treino: 0,74 e 0,71.
- Conferido em 16/11/2026: o `R/08` rodado na máquina do Henrique (R 4.4.3)
  reproduz todos os números acima.
- Teste com IC de Wilson: em 13 variáveis de LP e 12 de MT o intervalo do grupo
  fica inteiro acima da proporção dos demais. Nas duas exceções de LP o
  intervalo contém a proporção dos demais (não dá para afirmar direção
  contrária), mas não alcança a proporção do treino (13,9% e 17,7%).
- Calibração: em todas as faixas de número de fatores, a probabilidade prevista
  cai dentro do IC de 95% da proporção observada, nas duas disciplinas.
- Modelo completo (18 variáveis): mãe até o 5º ano tem razão de chances de 1,02
  (LP) e 1,18 (MT); abandono entra em LP com p = 0,047 e sai em MT com p = 0,237.

## Sobre as planilhas do professor

- Mesma população: intercepto dele dá base de 3,3% (LP) e 5,4% (MT).
- Erros-padrão cerca de 15% maiores que os nossos: amostra de uns 6.800 alunos
  (hipótese: ~75% do nosso treino). Não foi possível reproduzir exatamente.
- Correspondência dos nomes (hipótese, pela ordem no bloco e pelo erro-padrão):
  Repetiu ano = reprovou; Atraso escolar = 12 anos ou mais; Abandono ou
  interrupção = abandonou; Entrada tardia = entrou com 8 ou mais; INSE baixo =
  INSE I e II; Entorno desfavorável 1 = rua sem asfalto; Rotina doméstica
  desfavorável = trabalha fora; Trabalho doméstico = sem lazer; Rotina pessoal
  desfavorável = não estuda; Relação desfavorável com a escola = professores
  não acreditam; Indicador familiar = pouco incentivo.
- Comparação no relatório: 22 pares de variáveis (12 em LP, 10 em MT); em todos
  a nossa razão de chances cai dentro do IC de 95% do professor. Erros-padrão
  dele 16% maiores na mediana (amostra de cerca de 75% do nosso treino).
- Em dúvida: "Responsável sem ocupação indicada" e "Baixa escolaridade
  responsável 2" (provavelmente não mora com a mãe e sem Wi-Fi); "Indicador de
  inclusão 1" (deficiência ou TEA).
- DECISÃO (Henrique, 17/11/2026): não perguntar ao professor; seguir com o
  nosso modelo pela metodologia dele e usar as planilhas como comparação.

## Decisões de implementação

- 16/11/2026: o `R/08` grava os CSVs de `data/modelo/` com 10 algarismos
  significativos (função `grava`). Antes, os últimos dígitos mudavam de uma
  máquina para outra e o git acusava diferença a cada execução.
- 17/11/2026: o `R/08` tem só caracteres ASCII. Os rótulos acentuados ficam
  como códigos Unicode (barra invertida + u + 4 dígitos, por exemplo u00e3 para
  "ã") e os comentários, sem acento. O relatório sai com os acentos normais.
  Motivo: no RStudio do Henrique, rodar o script por seleção (Ctrl+Enter)
  quebrava no `tribble` com "unexpected symbol", porque o texto acentuado
  chegava ao R em outra codificação. Manter assim ao editar o script.
- 17/11/2026 (Henrique): o `R/08` e o relatório do modelo vão só até a
  interpretação das razões de chances. A verificação na base de teste (seção 4
  do script) e a comparação com as planilhas do professor (seção 5) foram
  retiradas, e o script não lê mais `data/teste.csv`. Motivo: discutir com o
  professor o que fazer com a base de teste e as próximas etapas antes de
  usá-la. O código retirado está no commit 8a6d632. Saiu também
  `data/modelo/verificacao_teste.csv`. As planilhas do professor continuam em
  `data/modelo/`.
- 18/11/2026 (Henrique): a comparação com as planilhas do professor não volta
  ao script nem ao relatório. A tabela descritiva x modelo (iluminação,
  escolaridade da mãe) fica só para um slide. Nos slides, registrar que o
  professor ajudou no modelo. O foco do trabalho é interpretar o que os
  testes na base de teste concluem.
- 17/11/2026 (Henrique): o trabalho é feito direto no `main`, só com commits,
  sem branches nem pull requests. A branch `modelo-logistico` já foi
  incorporada ao `main`.

## Próximos passos

1. Base de teste, plano de 18/11/2026: (1) probabilidades condicionais,
   modelo x prática: feito; (2) descritiva x modelo: só em slide; (3) perfis
   por número de fatores: feito; (3b) classificação em risco no teste e
   função `avalia_aluno`: feito; (4) seção nova no relatório: feito em
   19/11/2026.
2. Relatório do modelo em `Entregas/relatorio_modelo.Rmd`, completo: seleção,
   razões de chances, verificação na base de teste (por característica,
   acúmulo de fatores, classificação em risco, combinações específicas) e
   aplicação (`avalia_aluno` e app). O relatório usa o objeto `perfis` do
   `R/08`; o exemplo de perfis do próprio relatório se chama `perfis_ex`.
   Falta a revisão do grupo.
3. Pergunta enviada (ou a enviar) ao professor, 19/11/2026: é correto aplicar
   o modelo a combinações de características que não existem nos dados
   (multiplicando as razões de chances)? Vale avisar no app quando a
   combinação tem poucos alunos parecidos, ou testar interações? Evidência:
   reprovou + 12 anos tem 462 alunos no treino e previsto = observado; com
   5 características da cadeia do exemplo sobram 3 alunos, com 6 nenhum.
   Com 8+ fatores, previsto 67,3% x observado 52,9% em LP (treino).
   Resposta do professor (20/11/2026): "faz sentido, sim, porque as variáveis
   foram incluídas no modelo sem considerar interações entre elas. Então,
   estamos assumindo que seus efeitos são aditivos na escala do logito." Ele
   pediu como foi calculado o 62,9% do exemplo do app (LP, 8 características:
   reprovou, idade_12, abandonou, entrada_8, inse_baixo, sem_mae, sem_wifi,
   sem_asfalto): logito = -3,4042 + soma dos 8 coeficientes (3,9315) = 0,5274;
   p = 1/(1 + e^-0,5274) = 62,9%. Equivale a chance base 0,0332 x produto das
   razões de chances (50,99) = 1,6945.
4. Apresentação final em 02/12/2026, 8 minutos: refeita no roteiro da
   professora em `Entregas/apresentacao/apresentacao.html` (22/11/2026). Falta
   o grupo revisar, dividir as falas e ensaiar o tempo. O deck vazio do claude.ai
   (https://claude.ai/artifact/4bemDADkDxAS3gmjKvqmGf) foi abandonado.

## Apresentação (22/11/2026)

Roteiro obrigatório da professora (8 min, todos falam, foco no que o dado
revela e para que serve, gráficos legíveis): 1 contexto e demanda; 2 solução
desenvolvida; 3 principais resultados; 4 impacto extensionista; 5 lições e
próximos passos.

Decisões do Henrique: em 22/11/2026, apresentação cobrindo o trabalho
completo com os números observados em primeiro plano (uma versão centrada só
no modelo foi rejeitada). Em 24/11/2026: o foco não é Curitiba (a descritiva
foi feita para Curitiba, mas o modelo não foi aplicado lá), e o item 3 do
roteiro mostra o processo em três slides: descritiva, modelo e teste.
Pergunta ao professor sobre usar mais de 5 slides: sem resposta registrada.

- `Entregas/apresentacao/apresentacao.html`: capa + 7 slides numerados 1/7 a
  7/7, seguindo os 5 itens do roteiro: 1 contexto; 2 solução; 3a descritiva
  (fig-risco, 18 grupos); 3b modelo (fig-or); 3c teste (fig-acumulo); 4
  impacto, com o painel do shinyapps.io embutido ao vivo (iframe; sem internet
  aparece a imagem `assets/app.png`); 5 próximos passos e desafios (aplicar
  o painel e o modelo na rede para orientar ações; amostras pequenas dão
  estimativas incertas; entender e comunicar o modelo). Curitiba só nas notas e no
  slide 1. Notas de fala somam cerca de 7 min 50 s. Título da capa: "Fatores
  associados à proficiência abaixo do nível básico no 5º ano do Ensino
  Fundamental". Estrutura da skill frontend-slides
  (github.com/zarazhangrui/frontend-slides, MIT). Setas navegam, N mostra
  notas de fala (com "Fala: [quem]" a preencher), E edita, Ctrl+S baixa uma
  cópia, F tela cheia. Depois de clicar no painel ao vivo, clicar fora dele
  para voltar a navegar pelo teclado.
- Gráficos em `Entregas/apresentacao/assets/` (grupos_risco, razoes_chances,
  acumulo_teste), gerados por `Entregas/apresentacao/graficos.R` com o mesmo
  código dos relatórios (só ASCII; nome de coluna com acento não pode ficar
  entre crases usando código Unicode). `assets/app.png` é a tela do
  painel com 4 características marcadas.
- Visual (decisão do Henrique, 24/11/2026): fundo branco com azul UFPR
  `#005296` (faixa no topo, marcadores, números em destaque, alunos abaixo do
  básico na grade da capa), logo da UFPR em todos os slides (arquivo
  `assets/logo_ufpr_portal.png`, branco, baixado do portal ufpr.br; no HTML vai
  embutido em base64 e pintado de azul por máscara CSS, para funcionar também
  aberto direto do disco). Sem negrito em nenhum texto além dos títulos.
  Títulos diretos, sem jogos de palavra: "O que foi desenvolvido", "Análise
  descritiva: alunos abaixo do básico por grupo", "Modelo de regressão
  logística: razões de chances", "Verificação do modelo na base de teste",
  "Painel de risco e priorização de alunos", "Próximos passos e desafios".
  Fontes do sistema para funcionar offline.
- Botão "Abrir o painel" (slides 2 e 4) leva ao app publicado no
  shinyapps.io (precisa de internet). O app aceita
  `?marcar=reprovou,idade_12,...` na URL para abrir com características já
  marcadas.
- Números escritos à mão no HTML, copiados dos relatórios.
- Relatórios em HTML para a apresentação e para o git (24/11/2026):
  `Entregas/apresentacao/relatorios/relatorio_descritivo.html` (do
  `relatorio_descritivo_revisado.Rmd`) e `relatorio_modelo.html`. Ficam nessa
  subpasta porque o `.gitignore` ignora só `Entregas/*.html`. Os slides 2 e 5
  têm links para eles. Se um relatório mudar: renderizar o `.Rmd` e copiar o
  HTML de `Entregas/` para essa pasta.

## Convenções

- Código em R com tidyverse; textos e comentários em português.
- Números no formato brasileiro (vírgula decimal) nos relatórios.
- Antes de trabalhar: `git pull`. Commits com mensagens descritivas em português.
- Não versionar a base bruta do INEP.
