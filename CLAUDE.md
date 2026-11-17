# CE307 — Projetos de Análise de Dados (UFPR, 2026/2)

Projeto de extensão do Eixo 4: Educação Básica Municipal, em parceria com a
Secretaria Municipal de Educação de Curitiba (SME, André Zilio).
Grupo: Henrique, Kadu, João Pedro e Pedro.

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
07 fatores associados · 08 modelo logístico (estimação e interpretação; a
verificação no teste foi retirada em 17/11/2026, ver Decisões).

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

## Metodologia do modelo (segue a do professor)

Implementada em `R/08 Modelo logístico.R`:
1. Criar as 18 variáveis 0/1 da seção 4 no treino e no teste.
2. Ajustar a regressão logística com as 18 no treino (uma para LP, outra para MT).
3. Manter as variáveis com p < 0,05 e reestimar.
4. Interpretar pela razão de chances, `exp(beta)`, com IC de 95% (Wald).
5. (Retirado, aguardando o professor) Verificar no teste: proporção abaixo do
   básico de quem tem a característica contra a de quem não tem; calibração
   por número de fatores; AUC.
6. (Retirado, aguardando o professor) Comparar com os coeficientes do professor.

Saídas em `data/modelo/`: `modelo_grupo_LP.csv` e `modelo_grupo_MT.csv`.

## Resultados até aqui (treino 9.062, teste 1.006)

- Ficam 15 de 18 variáveis em cada disciplina. Saem nas duas: mãe até o 5º ano
  e rua sem iluminação. Só em LP sai TEA; só em MT sai abandono.
- Probabilidade base (nenhum fator): 3,2% em LP e 5,3% em MT.
- Maiores razões de chances em LP: professores não acreditam (1,90), trabalha
  fora (1,87), reprovou (1,85), 12 anos ou mais (1,80). Em MT: TEA (2,08),
  INSE I e II (2,04), reprovou (2,02), entrada com 8 anos ou mais (1,85).
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
- 17/11/2026 (Henrique): o trabalho é feito direto no `main`, só com commits,
  sem branches nem pull requests. A branch `modelo-logistico` já foi
  incorporada ao `main`.

## Próximos passos

1. Reunião com o professor: o que fazer com a base de teste, a comparação
   com as planilhas dele e as etapas seguintes.
2. Relatório do modelo em `Entregas/relatorio_modelo.Rmd` (até a
   interpretação): falta a revisão do grupo.
3. Apresentação final em 02/12/2026: 8 minutos, roteiro de 5 slides,
   todos os integrantes falam. Deck criado e ainda vazio:
   https://claude.ai/artifact/4bemDADkDxAS3gmjKvqmGf

## Convenções

- Código em R com tidyverse; textos e comentários em português.
- Números no formato brasileiro (vírgula decimal) nos relatórios.
- Antes de trabalhar: `git pull`. Commits com mensagens descritivas em português.
- Não versionar a base bruta do INEP.
