# =====================================================================
# app/app.R: avaliação de risco de um aluno (Shiny)
# Projeto: Eixo 4, Educação Básica Municipal (parceria SME Curitiba)
#
# Marque as características de um aluno e veja a probabilidade prevista de
# ele estar abaixo do nível básico em LP e em MT, e se ele está entre os
# alunos de maior risco.
#
# O app NÃO estima nada. Ele lê o que o R/08 grava em data/modelo/:
#   - modelo_grupo_LP.csv e modelo_grupo_MT.csv: coeficientes dos modelos;
#   - classificacao_teste.csv: cortes de risco (definidos no treino) e o
#     desempenho da marcação na base de teste.
# Se o modelo mudar, rode o R/08 de novo antes de abrir o app.
#
# Como abrir: no RStudio, abra este arquivo e clique em "Run App"
# (ou, no console, com o projeto aberto: shiny::runApp("app")).
# Não rode por seleção (Ctrl+Enter): o Run App lê o arquivo em UTF-8.
#
# Visual pensado para projeção em sala (ver PRODUCT.md): fundo claro,
# contraste alto, texto grande, uma tarefa por tela. Cores do portal
# ufpr.br (variáveis --portal-ufpr e --padrao_ufpr do site, nov/2026), as
# mesmas da apresentação.
# =====================================================================

library(shiny)
library(bslib)
library(dplyr)

pasta_modelo <- file.path("..", "data", "modelo")
if (!dir.exists(pasta_modelo)) pasta_modelo <- file.path("data", "modelo")

le_modelo <- function(disc) {
  read.csv(file.path(pasta_modelo, paste0("modelo_grupo_", disc, ".csv")),
           encoding = "UTF-8")
}

modelos <- list(LP = le_modelo("LP"), MT = le_modelo("MT"))

cortes <- read.csv(file.path(pasta_modelo, "classificacao_teste.csv"))
valor_corte <- function(disc, nivel, coluna = "corte") {
  cortes[[coluna]][cortes$disciplina == disc & cortes$nivel == nivel]
}

# Características que aparecem em pelo menos um dos dois modelos, por bloco
caracteristicas <- bind_rows(modelos) %>%
  filter(nome != "(Intercept)") %>%
  distinct(bloco, grupo, nome)

ordem_blocos <- unique(caracteristicas$bloco)

disciplinas <- list(
  LP = list(nome = "Língua Portuguesa", cor = "#005296"),
  MT = list(nome = "Matemática",        cor = "#A35716")
)

pct <- function(x, d = 1) paste0(formatC(100 * x, format = "f", digits = d, decimal.mark = ","), "%")
dec <- function(x, d = 1) formatC(x, format = "f", digits = d, decimal.mark = ",")

# Probabilidade prevista: intercepto + soma dos coeficientes marcados
probabilidade <- function(disc, marcados) {
  m      <- modelos[[disc]]
  logito <- m$coeficiente[m$nome == "(Intercept)"] + sum(m$coeficiente[m$nome %in% marcados])
  plogis(logito)
}

nivel_risco <- function(disc, p) {
  if (p >= valor_corte(disc, "top10")) {
    list(rotulo = "Risco alto", detalhe = "entre os 10% de maior risco", classe = "alto")
  } else if (p >= valor_corte(disc, "top20")) {
    list(rotulo = "Risco moderado", detalhe = "entre os 20% de maior risco", classe = "moderado")
  } else {
    list(rotulo = "Fora dos cortes de risco", detalhe = "abaixo dos 20% de maior risco", classe = "baixo")
  }
}

# Régua de 0% a ESCALA_MAX: as faixas (cinza = fora dos cortes, areia =
# risco moderado, terracota = risco alto) mostram onde o aluno está. Os
# valores dos cortes ficam no texto "Como ler", porque na régua os números
# se sobrepõem. Acima do máximo, o marcador para na borda.
ESCALA_MAX <- 0.6
posicao <- function(p) 100 * min(p, ESCALA_MAX) / ESCALA_MAX

regua <- function(disc, p) {
  c20 <- posicao(valor_corte(disc, "top20"))
  c10 <- posicao(valor_corte(disc, "top10"))
  div(class = "regua",
    div(class = "regua-trilho",
      div(class = "faixa faixa-baixo",    style = sprintf("left:0;width:%.2f%%", c20)),
      div(class = "faixa faixa-moderado", style = sprintf("left:%.2f%%;width:%.2f%%", c20, c10 - c20)),
      div(class = "faixa faixa-alto",     style = sprintf("left:%.2f%%;width:%.2f%%", c10, 100 - c10)),
      div(class = "regua-marcador", style = sprintf("left:%.2f%%;--cor:%s", posicao(p), disciplinas[[disc]]$cor))
    ),
    div(class = "regua-escala",
      span("0%"),
      span(class = "fim", paste0(pct(ESCALA_MAX, 0), " ou mais"))
    )
  )
}

estilo <- "
:root {
  --ufpr: #005296;
  --ufpr-escuro: #003D68;
  --ufpr-marinho: #273272;
  --ufpr-claro: #E0EBF5;
  --tinta: #1B2233;
  --tinta-2: #4A4F5C;
  --linha: #D3DCE8;
  --fundo: #F1F3F8;
  --superficie: #FFFFFF;
  --baixo: #E2E7EF;
  --moderado: #EFD9AE;
  --alto: #E2B7A3;
}
body { background: var(--fundo); color: var(--tinta); font-size: 1.125rem; }
.bslib-page-sidebar > .navbar, .navbar { background: var(--ufpr) !important; border-bottom: 4px solid var(--ufpr-marinho); }
.navbar .navbar-brand, .navbar .bslib-page-title { color: #FFFFFF; }
.titulo-app { font-weight: 700; font-size: 1.35rem; line-height: 1.2; margin: 0; color: #FFFFFF; }
.subtitulo-app { font-size: 0.95rem; color: var(--ufpr-claro); margin: 0.15rem 0 0; }

.bslib-sidebar-layout > .sidebar { background: var(--superficie); border-right: 1px solid var(--linha); }
.intro-lateral { font-weight: 600; margin-bottom: 0.25rem; }
.contagem { color: var(--tinta-2); font-size: 0.95rem; margin-bottom: 1rem; }
.shiny-input-checkboxgroup > label.control-label {
  font-size: 0.95rem; font-weight: 700; color: var(--tinta); margin: 0.9rem 0 0.35rem;
}
.shiny-input-checkboxgroup { margin-bottom: 0; }
.checkbox label { font-size: 1rem; line-height: 1.35; color: var(--tinta); }
.checkbox { margin-bottom: 0.2rem; }
.form-check-input:checked { background-color: var(--ufpr); border-color: var(--ufpr); }
.form-check-input:focus { box-shadow: 0 0 0 0.2rem rgba(0, 82, 150, 0.35); }
.btn-desmarcar { margin-top: 1.25rem; width: 100%; border: 1px solid var(--linha); color: var(--tinta); background: var(--superficie); font-size: 1rem; }
.btn-desmarcar:hover { background: var(--ufpr-claro); border-color: var(--ufpr); color: var(--ufpr-escuro); }
.btn-desmarcar:focus-visible { outline: 3px solid rgba(0, 82, 150, 0.5); outline-offset: 2px; }

.resultados { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 1.25rem; }
.resultado { background: var(--superficie); border: 1px solid var(--linha); border-radius: 10px; padding: 1.5rem 1.75rem 1.4rem; }
.resultado-disc { display: flex; align-items: center; gap: 0.55rem; font-weight: 700; font-size: 1.2rem; margin: 0; }
.resultado-disc .ponto { width: 0.8rem; height: 0.8rem; border-radius: 50%; background: var(--cor); flex: none; }
.resultado-numero { font-size: 4rem; font-weight: 700; line-height: 1; margin: 1rem 0 0.75rem;
  font-variant-numeric: tabular-nums; letter-spacing: -0.02em; }
.selo { display: inline-block; font-weight: 700; font-size: 1rem; padding: 0.3rem 0.75rem; border-radius: 999px; }
.selo-baixo { background: var(--baixo); color: #2F3A47; }
.selo-moderado { background: var(--moderado); color: #5A3D07; }
.selo-alto { background: #7E3520; color: #FFFFFF; }
.selo-detalhe { color: var(--tinta-2); font-size: 1rem; margin-left: 0.5rem; }
.comparacao { margin: 1rem 0 0; color: var(--tinta-2); font-size: 1rem; max-width: 60ch; }
.fora-modelo { margin: 0.6rem 0 0; color: var(--tinta-2); font-size: 0.95rem; font-style: italic; }

.regua { margin-top: 1.4rem; }
.regua-trilho { position: relative; height: 14px; border-radius: 7px; overflow: visible; }
.faixa { position: absolute; top: 0; height: 100%; }
.faixa-baixo { background: var(--baixo); border-radius: 7px 0 0 7px; }
.faixa-moderado { background: var(--moderado); }
.faixa-alto { background: var(--alto); border-radius: 0 7px 7px 0; }
.regua-marcador {
  position: absolute; top: 50%; width: 22px; height: 22px; margin-left: -11px; margin-top: -11px;
  border-radius: 50%; background: var(--cor); border: 3px solid var(--superficie);
  box-shadow: 0 0 0 1px var(--tinta-2);
  transition: left 220ms cubic-bezier(0.25, 1, 0.5, 1);
}
.regua-escala { position: relative; height: 1.5rem; margin-top: 0.4rem; font-size: 0.85rem; color: var(--tinta-2);
  font-variant-numeric: tabular-nums; }
.regua-escala span { position: absolute; top: 0; left: 0; white-space: nowrap; }
.regua-escala span.fim { right: 0; left: auto; }

.leitura { margin-top: 2rem; max-width: 75ch; }
.leitura h2 { font-size: 1.2rem; font-weight: 700; margin: 0 0 0.75rem; }
.leitura p { margin: 0 0 0.75rem; line-height: 1.55; color: var(--tinta); }
.leitura .aviso { font-weight: 600; }
.rodape { margin-top: 1.5rem; font-size: 0.9rem; color: var(--tinta-2); }

@media (prefers-reduced-motion: reduce) { .regua-marcador { transition: none; } }
"

# ---------------------------------------------------------------------
# Interface
# ---------------------------------------------------------------------

caixas_por_bloco <- lapply(seq_along(ordem_blocos), function(i) {
  c_b <- caracteristicas[caracteristicas$bloco == ordem_blocos[i], ]
  checkboxGroupInput(paste0("bloco_", i), label = ordem_blocos[i],
                     choiceNames = c_b$grupo, choiceValues = c_b$nome)
})

ui <- page_sidebar(
  title = div(
    p(class = "titulo-app", "Risco de um aluno do 5º ano estar abaixo do nível básico"),
    p(class = "subtitulo-app", "Língua Portuguesa e Matemática · Saeb 2023 · modelo de regressão logística")
  ),
  window_title = "Risco abaixo do básico",
  lang = "pt-BR",
  theme = bs_theme(
    version = 5,
    bg = "#F1F3F8", fg = "#1B2233", primary = "#005296",
    base_font = font_collection("Segoe UI", "system-ui", "-apple-system", "Roboto", "Helvetica Neue", "Arial", "sans-serif"),
    "border-radius" = "10px"
  ),
  fillable = FALSE,
  sidebar = sidebar(
    width = 400,
    open = list(desktop = "open", mobile = "always-above"),
    p(class = "intro-lateral", "Marque o que se aplica ao aluno."),
    uiOutput("contagem"),
    caixas_por_bloco,
    actionButton("desmarcar", "Desmarcar tudo", class = "btn-desmarcar")
  ),
  tags$head(tags$style(HTML(estilo))),
  div(class = "resultados",
    uiOutput("resultado_LP"),
    uiOutput("resultado_MT")
  ),
  div(class = "leitura",
    h2("Como ler"),
    p("A porcentagem é a probabilidade estimada de um aluno com essas características estar abaixo do",
      "nível básico. Ela vem de uma regressão logística ajustada com 9.062 alunos do Saeb 2023."),
    p(sprintf(paste("Na régua, a faixa cinza fica fora dos cortes de risco. Risco moderado (faixa areia):",
                    "o aluno está entre os 20%% com maior probabilidade, a partir de %s em LP e %s em MT.",
                    "Risco alto (faixa terracota): entre os 10%%, a partir de %s e %s."),
              pct(valor_corte("LP", "top20")), pct(valor_corte("MT", "top20")),
              pct(valor_corte("LP", "top10")), pct(valor_corte("MT", "top10")))),
    p(sprintf(paste("Testado em 1.006 alunos que o modelo não viu: marcar os 20%% de maior risco alcançou",
                    "%s (LP) e %s (MT) dos alunos abaixo do básico. Mas a maioria dos marcados não estava",
                    "abaixo do básico."),
              pct(valor_corte("LP", "top20", "pct_abaixo_pegos"), 0),
              pct(valor_corte("MT", "top20", "pct_abaixo_pegos"), 0))),
    p(class = "aviso", "Use para decidir quais alunos acompanhar primeiro, não para diagnosticar um aluno.",
      "As características vêm do questionário respondido pelo próprio aluno e indicam associação, não causa."),
    p(class = "rodape", "Projeto de extensão CE307, UFPR, em parceria com a Secretaria Municipal de Educação de Curitiba.")
  )
)

# ---------------------------------------------------------------------
# Servidor
# ---------------------------------------------------------------------

server <- function(input, output, session) {

  marcados <- reactive({
    unlist(lapply(seq_along(ordem_blocos), function(i) input[[paste0("bloco_", i)]]))
  })

  output$contagem <- renderUI({
    n <- length(marcados())
    p(class = "contagem",
      if (n == 0) "Nenhuma característica marcada."
      else if (n == 1) "1 característica marcada."
      else paste(n, "características marcadas."))
  })

  observeEvent(input$desmarcar, {
    for (i in seq_along(ordem_blocos)) {
      updateCheckboxGroupInput(session, paste0("bloco_", i), selected = character(0))
    }
  })

  resultado <- function(disc) {
    renderUI({
      d      <- disciplinas[[disc]]
      p      <- probabilidade(disc, marcados())
      base   <- probabilidade(disc, character(0))
      risco  <- nivel_risco(disc, p)
      usados <- intersect(marcados(), modelos[[disc]]$nome)
      fora   <- setdiff(marcados(), modelos[[disc]]$nome)

      div(class = "resultado", style = sprintf("--cor:%s", d$cor),
        h2(class = "resultado-disc", span(class = "ponto"), d$nome),
        p(class = "resultado-numero", pct(p)),
        div(span(class = paste("selo", paste0("selo-", risco$classe)), risco$rotulo),
            span(class = "selo-detalhe", risco$detalhe)),
        regua(disc, p),
        p(class = "comparacao",
          if (length(usados) == 0) {
            "Probabilidade de um aluno sem nenhuma das características do modelo."
          } else {
            sprintf("%s vezes a de um aluno sem nenhuma das características (%s).", dec(p / base), pct(base))
          }),
        if (length(fora) > 0) {
          p(class = "fora-modelo",
            paste0("Não entra no modelo de ", d$nome, " e foi ignorado: ",
                   paste(caracteristicas$grupo[match(fora, caracteristicas$nome)], collapse = "; "), "."))
        }
      )
    })
  }

  output$resultado_LP <- resultado("LP")
  output$resultado_MT <- resultado("MT")
}

shinyApp(ui, server)
