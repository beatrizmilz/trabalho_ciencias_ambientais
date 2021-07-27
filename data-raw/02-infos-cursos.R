library(magrittr)
library(rvest)

buscar_info_programas <- function(links) {
html <- links %>%
  rvest::read_html()

col_md_10 <- html %>%
  rvest::html_nodes(xpath = "//*[@class='col-md-10']")

nome <- col_md_10 %>%
  rvest::html_nodes(xpath = "//*[@id='form:nomeProg']") %>%
  rvest::html_text()


codigo <- col_md_10 %>%
  rvest::html_nodes(xpath = "//*[@id='form:codProg']") %>%
  rvest::html_text()

situacao <- col_md_10 %>%
  rvest::html_nodes(xpath = "//*[@id='form:situacaoPrograma']") %>%
  rvest::html_text()

url <- col_md_10 %>%
  rvest::html_nodes(xpath = "//*[@id='form:j_idt53:0:url']") %>%
  rvest::html_text()

lat <- col_md_10 %>%
  rvest::html_nodes(xpath = "//*[@class='0lat']") %>%
  rvest::html_text()

long <- col_md_10 %>%
  rvest::html_nodes(xpath = "//*[@class='0lng']") %>%
  rvest::html_text()


tibble::tibble(nome, codigo, situacao, url, lat, long)

}

# ta dando erro aqui
informacoes_programas_raw <-
  purrr::map_dfr(.x = links_completos, .f = buscar_info_programas)
