library(tidyverse)
library(rvest)

prog_url <- "https://dcl-prog.stanford.edu/"

toc <-
  read_html(prog_url) %>%
  html_elements(".chapter")

id <-
  toc %>%
  html_attr("data-level") %>%
  forcats::fct_inorder()

depth <- str_count(id, fixed(".")) + 1

href <-
  toc %>%
  html_element("a") %>%
  html_attr("href") %>%
  str_c(prog_url, .)

title <-
  toc %>%
  map_chr(
    . %>%
      html_elements(xpath = "./a/node()[not(self::b)]") %>%
      html_text() %>%
      str_c(collapse = "") %>%
      str_trim()
  )

chapters <- tibble(id, title, depth, href)

chapters %>%
  filter(id != "", depth <= 3) %>%
  write_csv(here::here("data-raw/prog.csv"))
