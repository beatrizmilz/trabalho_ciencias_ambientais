## code to prepare `03-tidy-info-cursos` dataset goes here
devtools::load_all(".")

curso_0 <- trabalho_ciencias_ambientais::informacoes_programas %>%
  dplyr::select(instituicao:long, grau_do_curso_0:
                  nota_do_curso_0) %>%
  dplyr::rename(grau_do_curso = grau_do_curso_0,
                situacao_do_curso = situacao_do_curso_0,
                nota_do_curso = nota_do_curso_0
  ) %>%
  dplyr::filter(grau_do_curso != "Não existe")

curso_1 <- trabalho_ciencias_ambientais::informacoes_programas %>%
  dplyr::select(instituicao:long, grau_do_curso_1:
                  nota_do_curso_1)  %>%
  dplyr::rename(grau_do_curso = grau_do_curso_1,
                situacao_do_curso = situacao_do_curso_1,
                nota_do_curso = nota_do_curso_1
  ) %>%
  dplyr::filter(grau_do_curso != "Não existe")

informacoes_programas_tidy <- dplyr::bind_rows(curso_0, curso_1) %>%
  dplyr::mutate(nota_do_curso = dplyr::case_when(nota_do_curso == "Não existe" ~ "-",
                                                 TRUE ~ nota_do_curso),
                nota_do_curso = forcats::fct_relevel(nota_do_curso, c("-", "A", "3", "4", "5", "6", "7")))

usethis::use_data(informacoes_programas_tidy, overwrite = TRUE)
