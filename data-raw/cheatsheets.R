library(tidyverse)
library(rvest)

page <- read_html("https://www.rstudio.com/resources/cheatsheets/")

boxes <-
  page %>%
  html_elements("div.col-md-11 > div.row > div.col-md-7")

title <-
  boxes %>%
  html_element("h1") %>%
  html_text() %>%
  str_replace_all("\\s", " ")

href <-
  boxes %>%
  html_element("p:last-of-type > a") %>%
  html_attr("href") %>% 
  str_replace("/raw/", "/blob/")

id <-
  href %>%
  basename() %>%
  tools::file_path_sans_ext()

cheatsheets <- 
  tibble(id, title, href) %>% 
  drop_na() %>% 
  arrange(id)

cheatsheets %>%
  write_csv("data-raw/cheatsheets.csv")
