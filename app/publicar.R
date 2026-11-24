# =====================================================================
# app/publicar.R
# Publica o painel no shinyapps.io.
#
# 1. Copia para app/dados/ os CSVs do modelo gravados pelo R/08 (no
#    shinyapps.io so sobe a pasta app/, entao os dados precisam estar nela).
# 2. Envia a pasta app/ para a conta configurada no rsconnect.
#
# Antes: rodar o R/08 se o modelo mudou. A conta do shinyapps.io precisa
# estar configurada no R (rsconnect::setAccountInfo, feito uma vez pelo dono
# da conta com o token do site; o token nao vai para o git).
#
# Rodar com o projeto aberto (diretorio de trabalho = raiz do repositorio):
#   source("app/publicar.R")
# Arquivo so com caracteres ASCII (ver CLAUDE.md, decisao de 17/11/2026).
# =====================================================================

arquivos <- c("modelo_grupo_LP.csv", "modelo_grupo_MT.csv", "classificacao_teste.csv")

dir.create("app/dados", showWarnings = FALSE)
ok <- file.copy(file.path("data/modelo", arquivos), file.path("app/dados", arquivos), overwrite = TRUE)
if (!all(ok)) stop("Nao foi possivel copiar: ", paste(arquivos[!ok], collapse = ", "))

rsconnect::deployApp(
  appDir      = "app",
  appFiles    = c("app.R", file.path("dados", arquivos)),
  appName     = "risco-abaixo-basico",
  appTitle    = "Risco de estar abaixo do b\u00e1sico (5\u00ba ano, Saeb 2023)",
  account     = "henriquedayrell",
  server      = "shinyapps.io",
  forceUpdate = TRUE,
  launch.browser = FALSE
)
