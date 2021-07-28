## code to prepare `04-disciplinas` dataset goes here

informacoes_programas_tidy %>%
  dplyr::filter(situacao_programa == "EM FUNCIONAMENTO") %>%
  dplyr::arrange(desc(nota_do_curso)) %>%
  dplyr::select(codigo_programa, url)


tibble::tibble(
  data_de_consulta = character(),
  codigo_programa = character(),
  url_estrutura_curricular = character(),
  disciplinas = character(),
  disciplina_dados = logical()
) %>%
  tibble::add_row(
    codigo_programa = "53001010044P0",
    data_de_consulta = "2021-07-27",
    url_estrutura_curricular = "http://www.cds.unb.br/index.php?option=com_content&view=article&id=119&Itemid=724",
    disciplinas = "
Ambiente, Sociedade e Educação |
Gestão Ambiental |
Interdisciplinaridade em Ciências Ambientais |
Metodologia Científica e Desenvolvimento de Projetos em Educação nas Ciências Ambientais |
Seminário de Pesquisa |
Gestão de Recursos Naturais |
Planejamento de Projetos em Educação Ambiental |
Química Ambiental |
Recursos Hídricos",
disciplina_dados = FALSE
  ) %>% View()









#usethis::use_data(04-disciplinas, overwrite = TRUE)
