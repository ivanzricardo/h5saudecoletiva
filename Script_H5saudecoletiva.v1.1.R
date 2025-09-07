#Script para extrair dados do índice h5 de arquivos html
#última atualização: 06/09/2025 Contato: ivanzricardo@gmail.com
#Versão: Este código faz a extração a partir de um arquivo csv contendo todos os htmls extraídos


# =========================
# EXTRAIR (título, h5-index) 
# =========================
library(readr)
library(dplyr)
library(stringr)
library(xml2)
library(rvest)
library(purrr)
library(tibble)
library(stringi)  # para normalização sem acentos

# ---- Entradas ----
csv_path_df_semicolon <- "Periodicos_Saude_Coletiva_com_urls_h5.csv"  # ;  (precisa ter 'URL' e 'titulo_limpo')
csv_path_fullhtml     <- "dataset_html_completo.csv"                            # ,  (precisa ter 'url' e 'fullhtml')

# ---- Ler df original (;) ----
df <- read_delim(
  file = csv_path_df_semicolon,
  delim = ";",
  col_types = cols(.default = "c"),
  locale = locale(encoding = "UTF-8")
)

# Normaliza chaves/colunas importantes
if (!"URL" %in% names(df)) {
  if ("url" %in% names(df)) df <- df %>% rename(URL = url) else stop("df original sem coluna 'URL'/'url'.")
}
if (!"titulo_limpo" %in% names(df)) stop("df original precisa conter a coluna 'titulo_limpo'.")

df <- df %>%
  mutate(
    URL = trimws(URL),
    titulo_limpo = if_else(is.na(titulo_limpo), "", trimws(titulo_limpo))
  )

# ---- Ler CSV com fullhtml (,) ----
raw_full <- read_csv(
  file = csv_path_fullhtml,
  col_types = cols(.default = "c"),
  locale = locale(encoding = "UTF-8")
)
names(raw_full) <- tolower(names(raw_full))
if (!all(c("url","fullhtml") %in% names(raw_full))) {
  stop("dataset_html.csv precisa conter as colunas 'url' e 'fullhtml'.")
}
raw_full <- raw_full %>%
  mutate(
    url = trimws(url),
    fullhtml = coalesce(fullhtml, "")
  )

`%||%` <- function(a, b) if (!is.null(a)) a else b

# --- util: desescapar entidades HTML comuns ---
decode_entities <- function(x) {
  x <- gsub("&lt;",  "<", x, fixed = TRUE)
  x <- gsub("&gt;",  ">", x, fixed = TRUE)
  x <- gsub("&amp;", "&", x, fixed = TRUE)
  x <- gsub("&quot;","\"", x, fixed = TRUE)
  x <- gsub("&#39;", "'", x, fixed = TRUE)
  x
}

# --- limpar tags residuais no título extraído por regex ---
html2text <- function(x) {
  x <- gsub("<[^>]+>", " ", x)
  x <- decode_entities(x)
  stringr::str_squish(x)
}

# --- tentativa via DOM (seletores) ---
extract_dom <- function(html_text) {
  h <- tryCatch(read_html(I(html_text)), error = function(e) NULL)
  if (is.null(h)) return(tibble(titulo_periodico = character(), `h5-index` = integer()))
  
  # Cada periódico em um <tr> que contenha um <td class="gsc_mvt_t">
  rows <- xml_find_all(h, ".//tr[.//td[contains(@class,'gsc_mvt_t')]]")
  if (length(rows) == 0) return(tibble(titulo_periodico = character(), `h5-index` = integer()))
  
  purrr::map_dfr(rows, function(r) {
    title_node <- html_element(r, xpath = ".//td[contains(@class,'gsc_mvt_t')]")
    title_txt  <- if (!is.na(title_node)) html_text2(title_node) else ""
    
    # h5-index = primeiro <a ... gsc_mp_anchor ...> sob algum td.gsc_mvt_n do mesmo tr
    h5_anchor  <- html_element(r, xpath = ".//td[contains(@class,'gsc_mvt_n')]//a[contains(@class,'gsc_mp_anchor')]")
    h5_txt     <- if (!is.na(h5_anchor)) html_text2(h5_anchor) else NA_character_
    h5_val     <- suppressWarnings(as.integer(str_extract(h5_txt %||% "", "\\d+")))
    
    if (nzchar(title_txt) && !is.na(h5_val)) tibble(titulo_periodico = title_txt, `h5-index` = h5_val)
    else tibble(titulo_periodico = character(), `h5-index` = integer())
  }) %>%
    filter(nzchar(titulo_periodico), !is.na(`h5-index`)) %>%
    distinct(titulo_periodico, `h5-index`, .keep_all = TRUE)
}

# --- fallback via REGEX global (casa pares no mesmo <tr>) ---
extract_regex <- function(html_text) {
  pat <- "(?s)<tr[^>]*>.*?<td[^>]*class=\"[^\"]*gsc_mvt_t[^\"]*\"[^>]*>(.*?)</td>.*?<td[^>]*class=\"[^\"]*gsc_mvt_n[^\"]*\"[^>]*>\\s*<a[^>]*class=\"[^\"]*gsc_mp_anchor[^\"]*\"[^>]*>(\\d+)</a>.*?</tr>"
  m <- stringr::str_match_all(html_text, regex(pat, dotall = TRUE, ignore_case = TRUE))[[1]]
  if (nrow(m) == 0) return(tibble(titulo_periodico = character(), `h5-index` = integer()))
  tibble(
    titulo_periodico = stringr::str_squish(html2text(m[,2])),
    `h5-index`       = as.integer(m[,3])
  ) %>% distinct(titulo_periodico, `h5-index`, .keep_all = TRUE)
}

# --- função principal: tenta DOM -> DOM com desescape -> REGEX ---
extract_h5_title_list <- function(html_text) {
  if (is.na(html_text) || !nzchar(html_text))
    return(tibble(titulo_periodico = character(), `h5-index` = integer()))
  
  r1 <- extract_dom(html_text)
  if (nrow(r1) > 0) return(r1)
  
  unesc <- decode_entities(html_text)
  r2 <- extract_dom(unesc)
  if (nrow(r2) > 0) return(r2)
  
  r3 <- extract_regex(unesc)
  if (nrow(r3) > 0) return(r3)
  
  tibble(titulo_periodico = character(), `h5-index` = integer())
}

# ---- Extrai (url, titulo_periodico, h5-index) para TODAS as linhas de dataset_html.csv ----
df_h5_long <- purrr::map2_dfr(
  raw_full$url, raw_full$fullhtml,
  function(u, html_txt) {
    tib <- extract_h5_title_list(html_txt)
    if (nrow(tib) == 0) tibble(url = u, titulo_periodico = NA_character_, `h5-index` = NA_integer_)
    else tib %>% mutate(url = u, .before = 1L)
  }
) %>%
  filter(!is.na(titulo_periodico) | !is.na(`h5-index`)) %>%
  distinct(url, titulo_periodico, `h5-index`, .keep_all = TRUE)

# ----- salvar o arquivo com os dados extraídos
readr::write_excel_csv2(df_h5_long, "df_h5_long.csv")

# =========================
# JOIN por TÍTULO (evita duplicar mantendo o MAIOR h5 por título)
# =========================

# normalizador (remove acentos, caixa baixa, tira espaços extras)
normalize_title <- function(x) {
  x <- ifelse(is.na(x), "", x)
  x <- str_squish(trimws(x))
  x <- stringi::stri_trans_general(x, "Latin-ASCII")
  tolower(x)
}

# agrega df_h5_long por título, mantendo o MAIOR h5-index
df_h5_best <- df_h5_long %>%
  mutate(titulo_periodico_norm = normalize_title(titulo_periodico)) %>%
  filter(nzchar(titulo_periodico_norm), !is.na(`h5-index`)) %>%
  group_by(titulo_periodico_norm) %>%
  summarise(
    `h5-index` = max(`h5-index`, na.rm = TRUE),
    # opcional: um exemplo do título original
    titulo_periodico = dplyr::first(titulo_periodico),
    .groups = "drop"
  )

# normaliza df$titulo_limpo e faz o join por título normalizado
df_final <- df %>%
  mutate(titulo_limpo_norm = normalize_title(titulo_limpo)) %>%
  left_join(df_h5_best, by = c("titulo_limpo_norm" = "titulo_periodico_norm")) %>%
  select(-titulo_limpo_norm)

# Salvar com BOM para Excel
readr::write_excel_csv2(df_final, "base_h5_saude_coletiva_2025.csv")

