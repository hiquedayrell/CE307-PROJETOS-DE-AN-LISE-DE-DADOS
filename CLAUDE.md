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
07 fatores associados · 08 modelo logístico (estimação, interpretação e
verificação no teste).

Relatórios em `Entregas/` (R Markdown). O principal é
`relatorio_descritivo_revisado.Rmd`; a seção 4 ("Quais grupos concentram mais
alunos abaixo do básico") define 18 variáveis dicotômicas em um `tribble`
(bloco, grupo, variável do questionário, códigos).

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
5. Verificar no teste: proporção abaixo do básico de quem tem a característica
   contra a de quem não tem; calibração por número de fatores; AUC.
6. Comparar com os coeficientes do professor.

Saídas em `data/modelo/`: `modelo_grupo_LP.csv`, `modelo_grupo_MT.csv`,
`verificacao_teste.csv`.

## Resultados até aqui (treino 9.062, teste 1.006)

- Ficam 15 de 18 variáveis em cada disciplina. Saem nas duas: mãe até o 5º ano
  e rua sem iluminação. Só em LP sai TEA; só em MT sai abandono.
- Probabilidade base (nenhum fator): 3,2% em LP e 5,3% em MT.
- Maiores razões de chances em LP: professores não acreditam (1,90), trabalha
  fora (1,87), reprovou (1,85), 12 anos ou mais (1,80). Em MT: TEA (2,08),
  INSE I e II (2,04), reprovou (2,02), entrada com 8 anos ou mais (1,85).
- Teste, mesma direção do modelo: 15 de 15 em MT; 13 de 15 em LP. Exceções em
  LP, ambas com poucos casos: não mora com a mãe (5 em 99) e deficiência (1 em 32).
- Calibração no teste por número de fatores, LP: 0 → 2,3%; 1 → 6,8%; 2 → 10,8%;
  3 → 9,2%; 4 ou mais → 24,7%. MT: 4,7%; 8,5%; 17,1%; 16,9%; 29,1%.
- AUC no teste: 0,71 (LP) e 0,71 (MT).

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
- Em dúvida: "Responsável sem ocupação indicada" e "Baixa escolaridade
  responsável 2" (provavelmente não mora com a mãe e sem Wi-Fi); "Indicador de
  inclusão 1" (deficiência ou TEA).
- DECISÃO (Henrique, 17/11/2026): não perguntar ao professor; seguir com o
  nosso modelo pela metodologia dele e usar as planilhas como comparação.

## Próximos passos

1. Trabalhar em cima do `R/08` e registrar aqui o que for decidido.
2. Escrever o relatório do modelo (R Markdown em `Entregas/`): metodologia do
   professor, interpretação das razões de chances, verificação no teste.
3. Apresentação final em 02/12/2026: 8 minutos, roteiro de 5 slides,
   todos os integrantes falam. Deck criado e ainda vazio:
   https://claude.ai/artifact/4bemDADkDxAS3gmjKvqmGf

## Convenções

- Código em R com tidyverse; textos e comentários em português.
- Números no formato brasileiro (vírgula decimal) nos relatórios.
- Antes de trabalhar: `git pull`. Commits com mensagens descritivas em português.
- Não versionar a base bruta do INEP.
