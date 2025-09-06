#Script para extrair dados do índice h5 de arquivos html
#última atualização: 06/09/2025 Contato: ivanzricardo@gmail.com

# ---- Pacotes necessários ----
library(readr)
library(dplyr)
library(stringr)
library(xml2)
library(rvest)

# ---- Caminhos (ajuste) ----
csv_path <- "Periodicos_Saude_Coletiva_com_urls_h5.csv"            # CSV base (;)
html_dir <- "D://OneDrive/Projetos/H5-index/H5saudecoletiva/htmls"                                             # pasta com .html
out_path <- "Periodicos_Saude_Coletiva_com_urls_h5_h5index.csv"    # saída

# ---- Ler CSV base (;) ----
df <- read_delim(
  file = csv_path,
  delim = ";",
  col_types = cols(.default = "c"),
  locale = locale(encoding = "UTF-8")
)

# Garante coluna de saída
if (!("h5-index" %in% names(df))) df[["h5-index"]] <- NA_integer_

# ---- Lista de arquivos HTML ----
h5url <- list.files(html_dir, pattern = "\\.html?$", full.names = TRUE)

# -------- Função de extração (apenas h5-index) --------
extract_h5_index <- function(file_path) {
  # 1) DOM: primeiro <a class="gs_ibl gsc_mp_anchor">NUM</a>
  h <- tryCatch(read_html(file_path), error = function(e) NULL)
  if (!is.null(h)) {
    anchors <- html_elements(h, css = "a.gs_ibl.gsc_mp_anchor")
    if (length(anchors) > 0) {
      vals <- html_text2(anchors)
      nums <- suppressWarnings(as.integer(na.omit(str_extract(vals, "\\b\\d+\\b"))))
      if (length(nums) >= 1) return(nums[1])  # 1º número = h5-index
    }
  }
  # 2) Fallback: regex no HTML bruto (captura o primeiro número dentro do anchor)
  raw <- tryCatch(read_file(file_path), error = function(e) "")
  if (nzchar(raw)) {
    m <- str_match(raw, "<a[^>]*class=\"[^\"]*gs_ibl\\s+gsc_mp_anchor[^\"]*\"[^>]*>(\\d+)</a>")
    if (!is.na(m[1, 2])) return(as.integer(m[1, 2]))
  }
  # 3) Se nada encontrado
  return(0L)
}

# -------- Loop principal --------
# Se os arquivos seguirem "00001_hash.html", mapeamos pela numeração; senão, preenche sequencialmente.
prox_seq <- 1L

for (fp in h5url) {
  h5i <- extract_h5_index(fp)
  
  base <- basename(fp)
  # tenta mapear "00001_hash.html" -> 1
  idx_str <- str_match(base, "^(\\d{1,6})_")[, 2]
  if (!is.na(idx_str)) {
    idx <- suppressWarnings(as.integer(idx_str))
    if (!is.na(idx) && idx >= 1L && idx <= nrow(df)) {
      df[["h5-index"]][idx] <- h5i
      next
    }
  }
  
  # fallback: preencher sequencialmente na próxima linha sem valor
  repeat {
    if (prox_seq > nrow(df)) break
    if (is.na(df[["h5-index"]][prox_seq])) {
      df[["h5-index"]][prox_seq] <- h5i
      prox_seq <- prox_seq + 1L
      break
    }
    prox_seq <- prox_seq + 1L
  }
}

# NAs restantes -> 0
df[["h5-index"]][is.na(df[["h5-index"]])] <- 0L

# -------- Exporta CSV final (;) --------
write_delim(df, file = out_path, delim = ";", na = "", append = FALSE)
