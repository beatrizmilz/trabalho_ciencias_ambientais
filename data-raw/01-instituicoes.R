## code to prepare `instituicoes` dataset goes here

# cursos de pós-graduação
# plataforma sucupira
# cursos avaliados e reconhecidos por área de avaliação
# filtro: ciências ambientais
# data da busca 27/07/2021
library(magrittr)
library(rvest)


url <-
  "https://sucupira.capes.gov.br/sucupira/public/consultas/coleta/programa/quantitativos/quantitativoIes.xhtml?areaAvaliacao=49&areaConhecimento=90500008"

html <- rvest::read_html(url)


raw_table <- html %>%
  rvest::html_table() %>%
  purrr::pluck(1)


instituicoes <- raw_table %>%
  dplyr::rename(
    instituicao_de_ensino = X1,
    uf = X2,
    total_de_programas_de_pos_graduacao_total = X3,
    total_de_programas_de_pos_graduacao_me = X4,
    total_de_programas_de_pos_graduacao_do = X5,
    total_de_programas_de_pos_graduacao_mp = X6,
    total_de_programas_de_pos_graduacao_dp = X7,
    total_de_programas_de_pos_graduacao_me_do = X8,
    total_de_programas_de_pos_graduacao_mp_do = X9,

    total_de_cursos_de_pos_graduacao_total = X10,
    total_de_cursos_de_pos_graduacao_me = X11,
    total_de_cursos_de_pos_graduacao_do = X12,
    total_de_cursos_de_pos_graduacao_mp = X13,
    total_de_cursos_de_pos_graduacao_dp = X14
  ) %>%
  dplyr::slice(-c(1, 2),-dplyr::n())



usethis::use_data(instituicoes, overwrite = TRUE)


# lista de cursos ------ data da busca 27/07/2021 -------------
links_sujos <- html %>%
  rvest::html_node(xpath = "//*[@class='col-xs-12 table-responsive']") %>%
  rvest::html_nodes(xpath = "//tbody") %>%
  rvest::html_nodes(xpath = "//a") %>%
  rvest::html_attr("href")


links_limpos <-
  links_sujos[stringr::str_starts(
    links_sujos,
    "/sucupira/public/consultas/coleta/programa/quantitativos/quantitativoPrograma.xhtml"
  )]


links_completos <-
  paste0("https://sucupira.capes.gov.br", links_limpos)


buscar_lista_de_cursos <- function(links) {
  base_tabela <- links %>%
    rvest::read_html() %>%
    rvest::html_table() %>%
    purrr::pluck(1) %>%
    dplyr::mutate_all(as.character)



  links_cursos_sujo <-  links %>%
    rvest::read_html() %>%
    rvest::html_node(xpath = "//*[@class='col-xs-12 table-responsive']") %>%
    rvest::html_nodes(xpath = "//tbody") %>%
    rvest::html_nodes(xpath = "//a") %>%
    rvest::html_attr("href")

  links_curso_limpos <-
    links_cursos_sujo[stringr::str_starts(
      links_cursos_sujo,
      "/sucupira/public/consultas/coleta/programa/viewPrograma.xhtml?"
    )]

  links_curso_completos <-
    paste0("https://sucupira.capes.gov.br", links_curso_limpos) %>%
    tibble::as_tibble() %>%
    dplyr::rename(link = value)

  dplyr::bind_cols(base_tabela, links_curso_completos)

}

lista_de_cursos_raw <-
  purrr::map_dfr(.x = links_completos, .f = buscar_lista_de_cursos)


lista_de_cursos <- lista_de_cursos_raw %>%
  janitor::clean_names() %>%
  tidyr::separate(
    programa,
    into = c("programa", "codigo"),
    sep = "\\(",
    extra = "merge"
  ) %>%
  tidyr::separate(
    ies,
    into = c("ies", "ies_sigla"),
    sep = "\\(",
    extra = "merge"
  ) %>%
  dplyr::mutate(
    codigo = stringr::str_remove(codigo, "\\)$"),
    codigo = stringr::str_remove(codigo, "RENAC\\) \\("),
    ies_sigla = stringr::str_remove(ies_sigla, "\\)"),
    ies = dplyr::case_when(
      ies_sigla == "SÃO CARLOS (USP/SC)" ~ "UNIVERSIDADE DE SÃO PAULO - SÃO CARLOS",
      ies_sigla == " ESCOLA SUPERIOR DE AGRICULTURA LUIZ DE QUEIROZ  (USP/ESALQ)" ~ "UNIVERSIDADE DE SÃO PAULO - ESCOLA SUPERIOR DE AGRICULTURA LUIZ DE QUEIROZ",
      TRUE ~ ies
    ),

    ies_sigla = dplyr::case_when(
      ies_sigla == "SÃO CARLOS (USP/SC)" ~ "USP",
      ies_sigla == " ESCOLA SUPERIOR DE AGRICULTURA LUIZ DE QUEIROZ  (USP/ESALQ)" ~ "USP",
      TRUE ~ ies_sigla
    ),
    dplyr::across(.cols = me:dp, readr::parse_number),
    dplyr::across(.cols = me:dp, tidyr::replace_na, 0),

  )

usethis::use_data(lista_de_cursos, overwrite = TRUE)
