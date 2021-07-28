library(magrittr)
library(rvest)
devtools::load_all(".")

links <-
  trabalho_ciencias_ambientais::lista_de_cursos$link[1]

buscar_info_programas <- function(links) {
  html <- links %>%
    rvest::read_html()

  col_md_10 <- html %>%
    rvest::html_nodes(xpath = "//*[@class='col-md-10']")

  email_programa <- col_md_10[18] %>%
    rvest::html_text() %>%
    stringr::str_remove_all("\n|\t") %>%
    stringr::str_squish()


  nome_programa <- col_md_10 %>%
    rvest::html_nodes(xpath = "//*[@id='form:nomeProg']") %>%
    rvest::html_text()


  codigo_programa <- col_md_10 %>%
    rvest::html_nodes(xpath = "//*[@id='form:codProg']") %>%
    rvest::html_text()

  instituicao <- col_md_10 %>%
    rvest::html_nodes(xpath = "//*[@id='form:j_idt53:0:iesNome']") %>%
    rvest::html_text()



  situacao_programa <- col_md_10 %>%
    rvest::html_nodes(xpath = "//*[@id='form:situacaoPrograma']") %>%
    rvest::html_text()

 data_inicio_programa <- col_md_10 %>%
    rvest::html_nodes(xpath = "//*[@id='form:j_idt53:0:dataInclusao']") %>%
    rvest::html_text()



  lat <- col_md_10 %>%
    rvest::html_nodes(xpath = "//*[@class='0lat']") %>%
    rvest::html_text()

  long <- col_md_10 %>%
    rvest::html_nodes(xpath = "//*[@class='0lng']") %>%
    rvest::html_text()

  grau_do_curso_0 <- col_md_10 %>%
    rvest::html_nodes(xpath = "//*[@id='form:j_idt86:0:grauCurso']") %>%
    rvest::html_text()

  situacao_do_curso_0 <- col_md_10 %>%
    rvest::html_nodes(xpath = "//*[@id='form:j_idt86:0:sitCurso']") %>%
    rvest::html_text()

  url  <- col_md_10 %>%
    rvest::html_nodes(xpath = "//*[@id='form:j_idt53:0:url']") %>%
    rvest::html_text()

  nota_do_curso_0  <- col_md_10[24] %>%
    rvest::html_text() %>%
    stringr::str_remove_all("\n|\t") %>%
    stringr::str_squish()


  grau_do_curso_1 <- col_md_10 %>%
    rvest::html_nodes(xpath = "//*[@id='form:j_idt86:1:grauCurso']") %>%
    rvest::html_text()

  grau_do_curso_1 <- if (length(grau_do_curso_1) == 0) {
    "Não existe"
  } else {
    grau_do_curso_1
  }




  situacao_do_curso_1 <- col_md_10 %>%
    rvest::html_nodes(xpath = "//*[@id='form:j_idt86:1:sitCurso']") %>%
    rvest::html_text()

  situacao_do_curso_1 <- if (length(situacao_do_curso_1) == 0) {
    "Não existe"
  } else {
    situacao_do_curso_1
  }



  nota_do_curso_1  <-  if (length(col_md_10) >= 50) {
    html %>%
      rvest::html_nodes(xpath = "//*[@id='form']/div[3]/div/div/div/fieldset/div[18]/div[2]") %>%
      rvest::html_text() %>%
      stringr::str_remove_all("\n|\t") %>%
      stringr::str_squish()
  } else {
    "Não existe"
  }

  nota_do_curso_1<- if (length(nota_do_curso_1) == 0) {
    "Não existe"
  } else {
    nota_do_curso_1
  }


  tibble::tibble(
    instituicao,
    nome_programa,
    codigo_programa,
    email_programa,
    situacao_programa,
    data_inicio_programa ,
    url,
    lat,
    long,
    grau_do_curso_0,
    situacao_do_curso_0,
    nota_do_curso_0 ,
    grau_do_curso_1,
    situacao_do_curso_1 ,
    nota_do_curso_1
  )




}



informacoes_programas <-
  purrr::map_dfr(.x = lista_de_cursos$link, .f = buscar_info_programas)


# verificando se tudo está na base final
length(lista_de_cursos$link) == nrow(informacoes_programas)

faltantes <- lista_de_cursos %>%
  dplyr::anti_join(informacoes_programas, by = c("codigo" = "codigo_programa"))


usethis::use_data(informacoes_programas, overwrite = TRUE)
