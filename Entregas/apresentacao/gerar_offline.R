# Gera apresentacao_offline.html: a mesma apresentacao em um arquivo so,
# para abrir sem internet.
# - As imagens de assets/ vao embutidas no HTML (base64).
# - O painel ao vivo (iframe do shinyapps.io) e trocado pela imagem do painel.
# - Os botoes "Abrir o painel" continuam, mas so funcionam com internet.
# - Os links dos relatorios apontam para relatorios/: funcionam se o arquivo
#   ficar nesta pasta.
#
# Rodar de novo sempre que apresentacao.html mudar:
#   source("Entregas/apresentacao/gerar_offline.R")
# (ou com esta pasta como diretorio de trabalho: source("gerar_offline.R"))

pasta <- if (file.exists("apresentacao.html")) "." else "Entregas/apresentacao"
entrada <- file.path(pasta, "apresentacao.html")
saida <- file.path(pasta, "apresentacao_offline.html")

html <- paste(readLines(entrada, encoding = "UTF-8", warn = FALSE), collapse = "\n")

# 1. Painel ao vivo -> imagem. O div .vivo ja tem a imagem do painel como
#    fundo (url("assets/app.png")); basta tirar o iframe.
html <- gsub('<iframe src="https://henriquedayrell[^>]*></iframe>', "", html)
html <- gsub("<span>Painel ao vivo", "<span>Painel (imagem; ao vivo precisa de internet)", html, fixed = TRUE)
if (grepl("<iframe", html, fixed = TRUE)) stop("ainda sobrou um iframe")

# 2. Imagens de assets/ embutidas em base64 (no HTML e no CSS)
for (arq in list.files(file.path(pasta, "assets"), pattern = "\\.png$")) {
  uri <- paste0("data:image/png;base64,",
                base64enc::base64encode(file.path(pasta, "assets", arq)))
  html <- gsub(paste0("assets/", arq), uri, html, fixed = TRUE)
}
if (grepl('"assets/', html, fixed = TRUE)) stop("ainda sobrou referencia a assets/")

con <- file(saida, open = "w", encoding = "UTF-8")
writeLines(html, con, useBytes = FALSE)
close(con)
cat("Gerado:", saida, "(", round(file.size(saida) / 1e6, 1), "MB )\n")
