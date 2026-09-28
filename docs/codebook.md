# Codebook — Saeb 2023, alunos do 5º ano

Gerado por `R/00_codebook.R` a partir do dicionário oficial do INEP
(`docs/Dicionario_Saeb_2023.xlsx`, aba `TS_ALUNO_5EF`), mais as variáveis
criadas em `R/01_preparacao_base.R`.

No questionário, `*` = resposta nula e `.` = em branco. Alunos com qualquer
um desses códigos foram excluídos da amostra limpa.

## Resumo por papel

| Papel | Nº de variáveis |
|---|---|
| Estrato da amostra | 1 |
| Filtro de qualidade | 8 |
| Identificação | 22 |
| Não utilizada | 49 |
| Origem da resposta | 2 |
| Preditor (questionário) | 70 |
| Resposta | 2 |

## Variáveis

| Variável | Papel | Tipo | Descrição | Categorias |
|---|---|---|---|---|
| `ID_SAEB` | Identificação | Num | Ano de aplicação do Saeb | 2023 |
| `ID_REGIAO` | Identificação | Num | Código da Região | 1 - Norte; 2 - Nordeste; 3 - Sudeste; 4 - Sul; 5 - Centro-Oeste |
| `ID_UF` | Estrato da amostra | Num | Código da Unidade da Federação | 11-RO; 12-AC; 13-AM; 14-RR; 15-PA; 16-AP; 17-TO; 21-MA; 22-PI; 23-CE; 24-RN; 25-PB; 26-PE; 27-AL; 28-SE; 29-BA; 31-MG; 32-ES; 33-RJ; 35-SP; 41-PR; 42-SC; 43-RS; 50-MS; 51-MT; 52-GO; 53-DF |
| `ID_MUNICIPIO` | Identificação | Num | Máscaras dos Códigos de Municípios (são códigos fictícios) |  |
| `ID_AREA` | Identificação | Num | Área | 1 - Capital; 2 - Interior |
| `ID_ESCOLA` | Identificação | Num | Máscaras dos Códigos de Escola (são códigos fictícios) |  |
| `IN_PUBLICA` | Não utilizada | Num | Indica se a escola é pública ou não | 0 - Privada; 1 - Pública |
| `ID_LOCALIZACAO` | Identificação | Num | Localização | 1 - Urbana; 2 - Rural |
| `ID_TURMA` | Identificação | Num | Código da turma no Saeb |  |
| `ID_SERIE` | Identificação | Num | Ano Escolar | 5 - 5º ano do Ensino Fundamental |
| `ID_ALUNO` | Identificação | Num | Código do aluno no Saeb |  |
| `IN_SITUACAO_CENSO` | Filtro de qualidade | Num | Indicador de consistência entre os dados da aplicação do Saeb 2023 com o Censo da Educação Básica 2023 finalizado | 0 - Não consistente; 1 - Consistente |
| `IN_PREENCHIMENTO_LP` | Filtro de qualidade | Num | Indicador de preenchimento da prova de Língua Portuguesa | 0 - Prova não preenchida; 1 - Prova preenchida |
| `IN_PREENCHIMENTO_MT` | Filtro de qualidade | Num | Indicador de preenchimento da prova de Matemática | 0 - Prova não preenchida; 1 - Prova preenchida |
| `IN_PREENCHIMENTO_CH` | Não utilizada | Num | Indicador de preenchimento da prova de Ciências Humanas | 0 - Prova não preenchida; 1 - Prova preenchida; Vazio - Não selecionado para a amostra de CH |
| `IN_PREENCHIMENTO_CN` | Não utilizada | Num | Indicador de preenchimento da prova de Ciências da Natureza | 0 - Prova não preenchida; 1 - Prova preenchida; Vazio - Não selecionado para a amostra de CN |
| `IN_PRESENCA_LP` | Filtro de qualidade | Num | Indicador de presença na prova de Língua Portuguesa | 0 - Ausente; 1 - Presente |
| `IN_PRESENCA_MT` | Filtro de qualidade | Num | Indicador de presença na prova de Matemática | 0 - Ausente; 1 - Presente |
| `IN_PRESENCA_CH` | Não utilizada | Num | Indicador de presença na prova de Ciências Humanas | 0 - Ausente; 1 - Presente |
| `IN_PRESENCA_CN` | Não utilizada | Num | Indicador de presença na prova de Ciências da Natureza | 0 - Ausente; 1 - Presente |
| `ID_CADERNO_LP` | Identificação | Num | Número do caderno de prova de Língua Portuguesa | Prova Regular (Cadernos 1 a 21); Macrotipo 18 (Caderno 22) |
| `ID_BLOCO_1_LP` | Identificação | Num | Identificador do Bloco 1 de Língua Portuguesa | De 1 a 7 |
| `ID_BLOCO_2_LP` | Identificação | Num | Identificador do Bloco 2 de Língua Portuguesa | De 1 a 7 |
| `ID_CADERNO_MT` | Identificação | Num | Número do caderno de prova de Matemática | Prova Regular (Cadernos 1 a 21); Macrotipo 18 (Caderno 22) |
| `ID_BLOCO_1_MT` | Identificação | Num | Identificador do Bloco 1 de Matemática | De 1 a 7 |
| `ID_BLOCO_2_MT` | Identificação | Num | Identificador do Bloco 2 de Matemática | De 1 a 7 |
| `ID_CADERNO_CH` | Identificação | Num | Número do caderno de prova de Ciências Humanas | Prova Regular (Cadernos 1 a 28); Macrotipo 18 (Caderno 29) |
| `ID_BLOCO_1_CH` | Identificação | Num | Identificador do Bloco 1 de Ciências Humanas | De 1 a 8
Macrotipo 18 (Bloco 9) |
| `ID_BLOCO_2_CH` | Identificação | Num | Identificador do Bloco 2 de Ciências Humanas | De 1 a 8
Macrotipo 18 (Bloco 10) |
| `NU_BLOCO_1_ABERTA_CH` | Não utilizada | Num | Identificador do Bloco 1 de resposta construída em Ciências Humanas | De 1 a 8 |
| `NU_BLOCO_2_ABERTA_CH` | Não utilizada | Num | Identificador do Bloco 2 de resposta construída em Ciências Humanas | De 1 a 8 |
| `ID_CADERNO_CN` | Identificação | Num | Número do caderno de prova de Ciências da Natureza | Prova Regular (Cadernos 1 a 12); Macrotipo 18 (Caderno 13) |
| `ID_BLOCO_1_CN` | Identificação | Num | Identificador do Bloco 1 de Ciências da Natureza | De 1 a 9
Macrotipo 18 (Bloco 10) |
| `ID_BLOCO_2_CN` | Identificação | Num | Identificador do Bloco 2 de Ciências da Natureza | De 1 a 9
Macrotipo 18 (Bloco 11) |
| `ID_BLOCO_3_CN` | Identificação | Num | Identificador do Bloco 3 de Ciências da Natureza | De 1 a 9
Macrotipo 18 (Bloco 12) |
| `NU_BLOCO_1_ABERTA_CN` | Não utilizada | Num | Identificador do Bloco 1 de resposta construída em Ciências da Natureza | De 1 a 3 |
| `NU_BLOCO_2_ABERTA_CN` | Não utilizada | Num | Identificador do Bloco 2 de resposta construída em Ciências da Natureza | De 1 a 3 |
| `TX_RESP_BLOCO1_LP` | Não utilizada | Char | Resposta do aluno ao Bloco 1 de Língua Portuguesa | A, B, C, D, . (branco), * (nulo) |
| `TX_RESP_BLOCO2_LP` | Não utilizada | Char | Resposta do aluno ao Bloco 2 de Língua Portuguesa | A, B, C, D, . (branco), * (nulo) |
| `TX_RESP_BLOCO1_MT` | Não utilizada | Char | Resposta do aluno ao Bloco 1 de Matemática | A, B, C, D, . (branco), * (nulo) |
| `TX_RESP_BLOCO2_MT` | Não utilizada | Char | Resposta do aluno ao Bloco 2 de Matemática | A, B, C, D, . (branco), * (nulo) |
| `TX_RESP_BLOCO1_CH` | Não utilizada | Char | Resposta do aluno ao Bloco 1 da prova de Ciências Humanas | A, B, C, D, . (branco), * (nulo) |
| `TX_RESP_BLOCO2_CH` | Não utilizada | Char | Resposta do aluno ao Bloco 2 da prova de Ciências Humanas | A, B, C, D, . (branco), * (nulo) |
| `CO_CONCEITO_Q1_CH` | Não utilizada | Char | Conceito obtido na questão 1 de resposta construída em Ciências Humanas | 0 - Nenhum crédito
1 - Crédito parcial
11 - Crédito parcial
12 - Crédito parcial
2 - Crédito total
7 - Erros de impressão ou digitalização
.  - Branco |
| `CO_CONCEITO_Q2_CH` | Não utilizada | Char | Conceito obtido na questão 2 de resposta construída em Ciências Humanas | 0 - Nenhum crédito
1 - Crédito parcial
11 - Crédito parcial
12 - Crédito parcial
2 - Crédito total
7 - Erros de impressão ou digitalização
.  - Branco |
| `TX_RESP_BLOCO1_CN` | Não utilizada | Char | Resposta do aluno ao Bloco 1 da prova de Ciências da Natureza | A, B, C, D, . (branco), * (nulo) |
| `TX_RESP_BLOCO2_CN` | Não utilizada | Char | Resposta do aluno ao Bloco 2 da prova de Ciências da Natureza | A, B, C, D, . (branco), * (nulo) |
| `TX_RESP_BLOCO3_CN` | Não utilizada | Char | Resposta do aluno ao Bloco 2 da prova de Ciências da Natureza | A, B, C, D, . (branco), * (nulo) |
| `CO_CONCEITO_Q1_CN` | Não utilizada | Char | Conceito obtido na questão 1 de resposta construída em Ciências da Natureza | 0 - Nenhum crédito
1 - Crédito parcial
11 - Crédito parcial
12 - Crédito parcial
2 - Crédito total
7 - Erros de impressão ou digitalização
.  - Branco |
| `CO_CONCEITO_Q2_CN` | Não utilizada | Char | Conceito obtido na questão 2 de resposta construída em Ciências da Natureza | 0 - Nenhum crédito
1 - Crédito parcial
11 - Crédito parcial
12 - Crédito parcial
2 - Crédito total
7 - Erros de impressão ou digitalização
.  - Branco |
| `IN_PROFICIENCIA_LP` | Filtro de qualidade | Num | Indicador para cálculo da proficiência (no mínimo três itens respondidos no caderno de provas de Língua Portuguesa e Matemática) | 0 - Não; 1 - Sim |
| `IN_PROFICIENCIA_MT` | Filtro de qualidade | Num | Indicador para cálculo da proficiência (no mínimo três itens respondidos no caderno de provas de Língua Portuguesa e Matemática) | 0 - Não; 1 - Sim |
| `IN_PROFICIENCIA_CH` | Não utilizada | Num | Indicador para cálculo da proficiência (no mínimo três itens respondidos no caderno de prova de Ciências Humanas) | 0 - Não; 1 - Sim |
| `IN_PROFICIENCIA_CN` | Não utilizada | Num | Indicador para cálculo da proficiência (no mínimo três itens respondidos no caderno de prova de Ciências da Natureza) | 0 - Não; 1 - Sim |
| `IN_AMOSTRA` | Não utilizada | Num | Indicador de participação da amostra | 0 - Não; 1 - Sim |
| `ESTRATO` | Não utilizada | Char | Descrição dos estratos | Os estratos são compostos por características da participação da escola na avaliação e representam agrupamentos para os quais a avaliação fornece resultados confiáveis. Para mais detalhes consulte o Relatório de Amostragem do Saeb 2023. |
| `ESTRATO_CIENCIAS` | Não utilizada | Char | Descrição dos estratos para amostra de Ciências Humanas e Ciências da Natureza | Os estratos são compostos por características da participação da escola na avaliação e representam agrupamentos para os quais a avaliação fornece resultados confiáveis para Ciências Humanas e Ciências da Natureza. Para mais detalhes consulte o Relatório de Amostragem do Saeb 2023. |
| `PESO_ALUNO_LP` | Não utilizada | Num | Peso do aluno em Língua Portuguesa | Valor com 7 casas decimais |
| `PROFICIENCIA_LP` | Não utilizada | Num | Proficiência do aluno em Língua Portuguesa calculada na escala única do SAEB, com média = 0 e desvio = 1 na população de referência | Valor com 7 casas decimais |
| `ERRO_PADRAO_LP` | Não utilizada | Num | Erro padrão da proficiência em Língua Portuguesa | Valor com 7 casas decimais |
| `PROFICIENCIA_LP_SAEB` | Origem da resposta | Num | Proficiência em Língua Portuguesa transformada na escala única do SAEB, com média = 250, desvio = 50 (do SAEB/97) | Valor com 7 casas decimais |
| `ERRO_PADRAO_LP_SAEB` | Não utilizada | Num | Erro padrão da proficiência transformada em Língua Portuguesa | Valor com 7 casas decimais |
| `PESO_ALUNO_MT` | Não utilizada | Num | Peso do aluno em Matemática | Valor com 7 casas decimais |
| `PROFICIENCIA_MT` | Não utilizada | Num | Proficiência do aluno em Matemática calculada na escala única do SAEB, com média = 0 e desvio = 1 na população de referência | Valor com 7 casas decimais |
| `ERRO_PADRAO_MT` | Não utilizada | Num | Erro padrão da proficiência em Matemática | Valor com 7 casas decimais |
| `PROFICIENCIA_MT_SAEB` | Origem da resposta | Num | Proficiência do aluno em Matemática transformada na escala única do SAEB, com média = 250, desvio = 50 (do SAEB/97) | Valor com 7 casas decimais |
| `ERRO_PADRAO_MT_SAEB` | Não utilizada | Num | Erro padrão da proficiência transformada em Matemática | Valor com 7 casas decimais |
| `PESO_ALUNO_CH` | Não utilizada | Num | Peso do aluno em Ciências Humanas | Valor com 7 casas decimais |
| `PROFICIENCIA_CH` | Não utilizada | Num | Proficiência do aluno em Ciências Humanas calculada na escala única do SAEB, com média = 0 e desvio = 1 na população de referência | Valor com 7 casas decimais |
| `ERRO_PADRAO_CH` | Não utilizada | Num | Erro padrão da proficiência em Ciências Humanas | Valor com 7 casas decimais |
| `PROFICIENCIA_CH_SAEB` | Não utilizada | Num | Proficiência do aluno em Ciências Humanas transformada na escala única do SAEB, com média = 250, desvio = 50 (do SAEB/23) | Valor com 7 casas decimais |
| `ERRO_PADRAO_CH_SAEB` | Não utilizada | Num | Erro padrão da proficiência transformada em Ciências Humanas | Valor com 7 casas decimais |
| `PESO_ALUNO_CN` | Não utilizada | Num | Peso do aluno em Ciências da Natureza | Valor com 7 casas decimais |
| `PROFICIENCIA_CN` | Não utilizada | Num | Proficiência do aluno em Ciências da Natureza calculada na escala única do SAEB, com média = 0 e desvio = 1 na população de referência | Valor com 7 casas decimais |
| `ERRO_PADRAO_CN` | Não utilizada | Num | Erro padrão da proficiência em Ciências da Natureza | Valor com 7 casas decimais |
| `PROFICIENCIA_CN_SAEB` | Não utilizada | Num | Proficiência do aluno em Ciências da Natureza transformada na escala única do SAEB, com média = 250, desvio = 50 (do SAEB/23) | Valor com 7 casas decimais |
| `ERRO_PADRAO_CN_SAEB` | Não utilizada | Num | Erro padrão da proficiência transformada em Ciências da Natureza | Valor com 7 casas decimais |
| `IN_PREENCHIMENTO_QUESTIONARIO` | Filtro de qualidade | Num | Indicador de preenchimento do questionário | 0 - Não preenchido; 1 - Preenchido parcial ou totalmente |
| `IN_INSE` | Não utilizada | Num | Indicador para cálculo do INSE (São considerados válidos os estudantes que responderam pelo menos 8 itens, dentre os 17 utilizados para o cálculo do indicador) | 0 - Não; 1 - Sim |
| `INSE_ALUNO` | Não utilizada | Num | Resultado individual do INSE para o aluno |  |
| `NU_TIPO_NIVEL_INSE` | Não utilizada | Num | Classificação do Indicador de Nível Socioeconômico em 8 Grupos (para melhor entendimento dos grupos, consultar a nota técnica disponível no portal do Inep em <https://www.gov.br/inep/pt-br/acesso-a-informacao/dados-abertos/indicadores-educacionais/nivel-socioeconomico>) | 1 - Nível I; 2  - Nível II; 3 - Nível III; 4 - Nível IV; 5 - Nível V; 6 - Nível VI; 7 - Nível VII; 8 - Nível VIII |
| `PESO_ALUNO_INSE` | Não utilizada | Num | Peso do Aluno para cálculo do INSE 2023 | Valor com 7 casas decimais |
| `TX_RESP_Q01` | Preditor (questionário) | Char | Qual é o seu sexo? | * = Nulo; . = Branco; A = Masculino.; B = Feminino.; C = Não quero declarar. |
| `TX_RESP_Q02` | Preditor (questionário) | Char | Qual é a sua idade? | * = Nulo; . = Branco; A = 9 anos ou menos.; B = 10 anos.; C = 11 anos.; D = 12 anos.; E = 13 anos.; F = 14 anos ou mais. |
| `TX_RESP_Q03` | Preditor (questionário) | Char | Qual língua que seus pais falam com mais frequência em casa? | * = Nulo; . = Branco; A = Português.; B = Espanhol.; C = Língua de Sinais (Libras, Língua de Sinais Argentina, Língua de Sinais Boliviana etc.).; D = Outra língua. |
| `TX_RESP_Q04` | Preditor (questionário) | Char | Qual é a sua cor ou raça? | * = Nulo; . = Branco; A = Branca.; B = Preta.; C = Parda.; D = Amarela.; E = Indígena.; F = Não quero declarar. |
| `TX_RESP_Q05a` | Preditor (questionário) | Char | Você possui deficiência, transtorno do espectro autista ou superdotação? - Deficiência. | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q05b` | Preditor (questionário) | Char | Você possui deficiência, transtorno do espectro autista ou superdotação? - Transtorno do espectro autista. | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q05c` | Preditor (questionário) | Char | Você possui deficiência, transtorno do espectro autista ou superdotação? - Altas habilidades ou superdotação. | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q06` | Preditor (questionário) | Char | Quantas pessoas moram na sua casa, contando com você? | * = Nulo; . = Branco; A = 2 pessoas.; B = 3 pessoas.; C = 4 pessoas.; D = 5 pessoas.; E = 6 pessoas ou mais. |
| `TX_RESP_Q07a` | Preditor (questionário) | Char | Normalmente, quem mora na sua casa? - Mãe(s) ou madrasta(s). | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q07b` | Preditor (questionário) | Char | Normalmente, quem mora na sua casa? - Pai(s) ou padrasto(s). | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q07c` | Preditor (questionário) | Char | Normalmente, quem mora na sua casa? - Avó(s). | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q07d` | Preditor (questionário) | Char | Normalmente, quem mora na sua casa? - Avô(s). | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q07e` | Preditor (questionário) | Char | Normalmente, quem mora na sua casa? - Outros familiares, irmãos(ãs), tios(as), primos(as) etc. | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q08` | Preditor (questionário) | Char | Qual é a maior escolaridade da sua mãe (ou madastra ou mulher responsável por você)? | * = Nulo; . = Branco; A = Não completou o 5º ano do Ensino Fundamental.; B = Ensino Fundamental, até o 5º ano.; C = Ensino Fundamental completo.; D = Ensino Médio completo.; E = Ensino Superior completo (faculdade ou graduação).; F = Não sei. |
| `TX_RESP_Q09` | Preditor (questionário) | Char | Qual é a maior escolaridade de seu pai (ou padrasto homem responsável por você)? | * = Nulo; . = Branco; A = Não completou o 5º ano do Ensino Fundamental.; B = Ensino Fundamental, até o 5º ano.; C = Ensino Fundamental completo.; D = Ensino Médio completo.; E = Ensino Superior completo (faculdade ou graduação).; F = Não sei. |
| `TX_RESP_Q10a` | Preditor (questionário) | Char | Com que frequência seus pais ou responsáveis costumam: - Ler em casa. | * = Nulo; . = Branco; A = Nunca ou quase nunca.; B = De vez em quando.; C = Sempre ou quase sempre. |
| `TX_RESP_Q10b` | Preditor (questionário) | Char | Com que frequência seus pais ou responsáveis costumam: - Conversar com você sobre o que acontece na escola. | * = Nulo; . = Branco; A = Nunca ou quase nunca.; B = De vez em quando.; C = Sempre ou quase sempre. |
| `TX_RESP_Q10c` | Preditor (questionário) | Char | Com que frequência seus pais ou responsáveis costumam: - Incentivar você a estudar. | * = Nulo; . = Branco; A = Nunca ou quase nunca.; B = De vez em quando.; C = Sempre ou quase sempre. |
| `TX_RESP_Q10d` | Preditor (questionário) | Char | Com que frequência seus pais ou responsáveis costumam: - Incentivar você a fazer a tarefa de casa. | * = Nulo; . = Branco; A = Nunca ou quase nunca.; B = De vez em quando.; C = Sempre ou quase sempre. |
| `TX_RESP_Q10e` | Preditor (questionário) | Char | Com que frequência seus pais ou responsáveis costumam: - Incentivar você a comparecer às aulas. | * = Nulo; . = Branco; A = Nunca ou quase nunca.; B = De vez em quando.; C = Sempre ou quase sempre. |
| `TX_RESP_Q10f` | Preditor (questionário) | Char | Com que frequência seus pais ou responsáveis costumam: - Ir às reuniões de pais na escola. | * = Nulo; . = Branco; A = Nunca ou quase nunca.; B = De vez em quando.; C = Sempre ou quase sempre. |
| `TX_RESP_Q11a` | Preditor (questionário) | Char | Na rua em que você mora tem: - Asfalto ou calçamento. | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q11b` | Preditor (questionário) | Char | Na rua em que você mora tem: - Água tratada. | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q11c` | Preditor (questionário) | Char | Na rua em que você mora tem: - Iluminação. | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q12a` | Preditor (questionário) | Char | Dos itens relacionados abaixo, quantos existem na sua casa? - Geladeira. | * = Nulo; . = Branco; A = Nenhum.; B = 1.; C = 2.; D = 3 ou mais. |
| `TX_RESP_Q12b` | Preditor (questionário) | Char | Dos itens relacionados abaixo, quantos existem na sua casa? - Computador (ou notebook). | * = Nulo; . = Branco; A = Nenhum.; B = 1.; C = 2.; D = 3 ou mais. |
| `TX_RESP_Q12c` | Preditor (questionário) | Char | Dos itens relacionados abaixo, quantos existem na sua casa? - Quartos para dormir. | * = Nulo; . = Branco; A = Nenhum.; B = 1.; C = 2.; D = 3 ou mais. |
| `TX_RESP_Q12d` | Preditor (questionário) | Char | Dos itens relacionados abaixo, quantos existem na sua casa? - Televisão. | * = Nulo; . = Branco; A = Nenhum.; B = 1.; C = 2.; D = 3 ou mais. |
| `TX_RESP_Q12e` | Preditor (questionário) | Char | Dos itens relacionados abaixo, quantos existem na sua casa? - Banheiro. | * = Nulo; . = Branco; A = Nenhum.; B = 1.; C = 2.; D = 3 ou mais. |
| `TX_RESP_Q12f` | Preditor (questionário) | Char | Dos itens relacionados abaixo, quantos existem na sua casa? - Carro. | * = Nulo; . = Branco; A = Nenhum.; B = 1.; C = 2.; D = 3 ou mais. |
| `TX_RESP_Q12g` | Preditor (questionário) | Char | Dos itens relacionados abaixo, quantos existem na sua casa? - Celular com internet (smartphone). | * = Nulo; . = Branco; A = Nenhum.; B = 1.; C = 2.; D = 3 ou mais. |
| `TX_RESP_Q13a` | Preditor (questionário) | Char | Na sua casa tem: - Tv por internet (Netflix, GloboPlay, etc.). | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q13b` | Preditor (questionário) | Char | Na sua casa tem: - Rede Wi-Fi. | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q13c` | Preditor (questionário) | Char | Na sua casa tem: - Um quarto só seu. | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q13d` | Preditor (questionário) | Char | Na sua casa tem: - Mesa para estudar. | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q13e` | Preditor (questionário) | Char | Na sua casa tem: - Forno de microondas. | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q13f` | Preditor (questionário) | Char | Na sua casa tem: - Aspirador de pó. | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q13g` | Preditor (questionário) | Char | Na sua casa tem: - Máquina de lavar roupa. | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q13h` | Preditor (questionário) | Char | Na sua casa tem: - Freezer (independente ou segunda porta da geladeira). | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q13i` | Preditor (questionário) | Char | Na sua casa tem: - Garagem. | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q14` | Preditor (questionário) | Char | Quanto tempo você demora para chegar à sua escola? | * = Nulo; . = Branco; A = Menos de 30 minutos.; B = Entre 30 minutos e uma hora.; C = Mais de uma hora. |
| `TX_RESP_Q15a` | Preditor (questionário) | Char | Você utiliza para ir à escola: - Transporte gratuito escolar. | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q15b` | Preditor (questionário) | Char | Você utiliza para ir à escola: - Passe escolar. | * = Nulo; . = Branco; A = Não.; B = Sim. |
| `TX_RESP_Q16` | Preditor (questionário) | Char | Considerando a maior distância percorrida, normalmente de que forma você chega à sua escola? | * = Nulo; . = Branco; A = À pé.; B = De bicicleta.; C = De Van (ou Kombi).; D = De ônibus.; E = De metrô (ou trem urbano).; F = De carro.; G = De barco.; H = De motocicleta.; I = Outro meio de transporte. |
| `TX_RESP_Q17` | Preditor (questionário) | Char | Com que idade você entrou na escola? | * = Nulo; . = Branco; A = 3 anos ou menos.; B = 4 ou 5 anos.; C = 6 ou 7 anos.; D = 8 anos ou mais. |
| `TX_RESP_Q18` | Preditor (questionário) | Char | A partir do primeiro ano do ensino fundamental, em que tipo de escola você estudou? | * = Nulo; . = Branco; A = Somente em escola pública.; B = Somente em escola particular.; C = Em escola pública e em escola particular. |
| `TX_RESP_Q19` | Preditor (questionário) | Char | Você já foi reprovado(a)? | * = Nulo; . = Branco; A = Não.; B = Sim, uma vez.; C = Sim, duas vezes ou mais. |
| `TX_RESP_Q20` | Preditor (questionário) | Char | Alguma vez você abandonou a escola deixando de frequentá-la até o final do ano escolar? | * = Nulo; . = Branco; A = Nunca.; B = Sim, uma vez.; C = Sim, duas vezes ou mais. |
| `TX_RESP_Q21a` | Preditor (questionário) | Char | Fora da escola em dias de aula, quanto tempo você usa para: - Estudar (lição de casa, trabalhos escolares, etc.). | * = Nulo; . = Branco; A = Não uso meu tempo para isso.; B = Menos de 1 hora.; C = Entre 1 e 2 horas.; D = Mais de 2 horas. |
| `TX_RESP_Q21b` | Preditor (questionário) | Char | Fora da escola em dias de aula, quanto tempo você usa para: - Fazer cursos ou atividades extracurriculares (idioma, artes, informática etc.). | * = Nulo; . = Branco; A = Não uso meu tempo para isso.; B = Menos de 1 hora.; C = Entre 1 e 2 horas.; D = Mais de 2 horas. |
| `TX_RESP_Q21c` | Preditor (questionário) | Char | Fora da escola em dias de aula, quanto tempo você usa para: - Trabalhar em casa (lavar louça, limpar quintal, cuidar dos irmãos, etc.). | * = Nulo; . = Branco; A = Não uso meu tempo para isso.; B = Menos de 1 hora.; C = Entre 1 e 2 horas.; D = Mais de 2 horas. |
| `TX_RESP_Q21d` | Preditor (questionário) | Char | Fora da escola em dias de aula, quanto tempo você usa para: - Trabalhar fora de casa (recebendo ou não um salário). | * = Nulo; . = Branco; A = Não uso meu tempo para isso.; B = Menos de 1 hora.; C = Entre 1 e 2 horas.; D = Mais de 2 horas. |
| `TX_RESP_Q21e` | Preditor (questionário) | Char | Fora da escola em dias de aula, quanto tempo você usa para: -  Lazer (TV, brincar, internet, música etc.). | * = Nulo; . = Branco; A = Não uso meu tempo para isso.; B = Menos de 1 hora.; C = Entre 1 e 2 horas.; D = Mais de 2 horas. |
| `TX_RESP_Q22a` | Preditor (questionário) | Char | Para os próximos itens, indique qual é a proporção de professores(as) da sua turma que abordam os seguintes temas em sala de aula: - No início do ano, eles(as) informaram sobre o que seria ensinado e aprendido? | * = Nulo; . = Branco; A = Todos eles.; B = A maior parte deles.; C = Poucos deles.; D = Nenhum deles. |
| `TX_RESP_Q22b` | Preditor (questionário) | Char | Para os próximos itens, indique qual é a proporção de professores(as) da sua turma que abordam os seguintes temas em sala de aula: - Antes de iniciar um novo conteúdo, eles(as) perguntam o que vocês sabem sobre o conteúdo? | * = Nulo; . = Branco; A = Todos eles.; B = A maior parte deles.; C = Poucos deles.; D = Nenhum deles. |
| `TX_RESP_Q22c` | Preditor (questionário) | Char | Para os próximos itens, indique qual é a proporção de professores(as) da sua turma que abordam os seguintes temas em sala de aula: - Eles(as) trazem temas do cotidiano para serem debatidos em sala de aula? | * = Nulo; . = Branco; A = Todos eles.; B = A maior parte deles.; C = Poucos deles.; D = Nenhum deles. |
| `TX_RESP_Q22d` | Preditor (questionário) | Char | Para os próximos itens, indique qual é a proporção de professores(as) da sua turma que abordam os seguintes temas em sala de aula: - Eles(as) abordam temas sobre desigualdade racial? | * = Nulo; . = Branco; A = Todos eles.; B = A maior parte deles.; C = Poucos deles.; D = Nenhum deles. |
| `TX_RESP_Q22e` | Preditor (questionário) | Char | Para os próximos itens, indique qual é a proporção de professores(as) da sua turma que abordam os seguintes temas em sala de aula: - Eles(as) abordam temas sobre desigualdade de gênero? | * = Nulo; . = Branco; A = Todos eles.; B = A maior parte deles.; C = Poucos deles.; D = Nenhum deles. |
| `TX_RESP_Q22f` | Preditor (questionário) | Char | Para os próximos itens, indique qual é a proporção de professores(as) da sua turma que abordam os seguintes temas em sala de aula: - Eles(as) abordam temas como bullying e outras formas de violência? | * = Nulo; . = Branco; A = Todos eles.; B = A maior parte deles.; C = Poucos deles.; D = Nenhum deles. |
| `TX_RESP_Q22g` | Preditor (questionário) | Char | Para os próximos itens, indique qual é a proporção de professores(as) da sua turma que abordam os seguintes temas em sala de aula: - Eles(as) desenvolvem trabalhos em grupos? | * = Nulo; . = Branco; A = Todos eles.; B = A maior parte deles.; C = Poucos deles.; D = Nenhum deles. |
| `TX_RESP_Q22h` | Preditor (questionário) | Char | Para os próximos itens, indique qual é a proporção de professores(as) da sua turma que abordam os seguintes temas em sala de aula: - Eles(as) abordam questões relacionadas ao futuro profissional dos(as) estudantes? | * = Nulo; . = Branco; A = Todos eles.; B = A maior parte deles.; C = Poucos deles.; D = Nenhum deles. |
| `TX_RESP_Q23a` | Preditor (questionário) | Char | Sobre sua escola, indique o quanto você concorda ou discorda das afirmações abaixo: - Eu me interesso sobre o que foi ensinado na escola neste ano. | * = Nulo; . = Branco; A = Concordo totalmente.; B = Concordo.; C = Discordo.; D = Discordo totalmente. |
| `TX_RESP_Q23b` | Preditor (questionário) | Char | Sobre sua escola, indique o quanto você concorda ou discorda das afirmações abaixo: - Eu me sinto motivado(a), no dia a dia, a usar o que foi ensinado. | * = Nulo; . = Branco; A = Concordo totalmente.; B = Concordo.; C = Discordo.; D = Discordo totalmente. |
| `TX_RESP_Q23c` | Preditor (questionário) | Char | Sobre sua escola, indique o quanto você concorda ou discorda das afirmações abaixo: - Há espaço para diferentes opiniões na minha sala de aula. | * = Nulo; . = Branco; A = Concordo totalmente.; B = Concordo.; C = Discordo.; D = Discordo totalmente. |
| `TX_RESP_Q23d` | Preditor (questionário) | Char | Sobre sua escola, indique o quanto você concorda ou discorda das afirmações abaixo: - Eu me sinto seguro(a) quando estou na escola. | * = Nulo; . = Branco; A = Concordo totalmente.; B = Concordo.; C = Discordo.; D = Discordo totalmente. |
| `TX_RESP_Q23e` | Preditor (questionário) | Char | Sobre sua escola, indique o quanto você concorda ou discorda das afirmações abaixo: - Eu me sinto à vontade para discordar dos(as) meus(minhas) professores(as). | * = Nulo; . = Branco; A = Concordo totalmente.; B = Concordo.; C = Discordo.; D = Discordo totalmente. |
| `TX_RESP_Q23f` | Preditor (questionário) | Char | Sobre sua escola, indique o quanto você concorda ou discorda das afirmações abaixo: - Eu consigo argumentar sobre conteúdos difíceis. | * = Nulo; . = Branco; A = Concordo totalmente.; B = Concordo.; C = Discordo.; D = Discordo totalmente. |
| `TX_RESP_Q23g` | Preditor (questionário) | Char | Sobre sua escola, indique o quanto você concorda ou discorda das afirmações abaixo: - Os resultados das avaliações representam o quanto eu aprendi. | * = Nulo; . = Branco; A = Concordo totalmente.; B = Concordo.; C = Discordo.; D = Discordo totalmente. |
| `TX_RESP_Q23h` | Preditor (questionário) | Char | Sobre sua escola, indique o quanto você concorda ou discorda das afirmações abaixo: -Meus (Minhas) professores(as) acreditam que eu sou capaz de aprender. | * = Nulo; . = Branco; A = Concordo totalmente.; B = Concordo.; C = Discordo.; D = Discordo totalmente. |
| `TX_RESP_Q23i` | Preditor (questionário) | Char | Sobre sua escola, indique o quanto você concorda ou discorda das afirmações abaixo: -Meus (Minhas) professores(as) me motivam a continuar meus estudos. | * = Nulo; . = Branco; A = Concordo totalmente.; B = Concordo.; C = Discordo.; D = Discordo totalmente. |
| `abaixo_LP` | Resposta | Num | Aluno abaixo do nível básico em Língua Portuguesa (PROFICIENCIA_LP_SAEB <= 150) | 0 = Básico ou acima; 1 = Abaixo do básico |
| `abaixo_MT` | Resposta | Num | Aluno abaixo do nível básico em Matemática (PROFICIENCIA_MT_SAEB <= 175) | 0 = Básico ou acima; 1 = Abaixo do básico |
