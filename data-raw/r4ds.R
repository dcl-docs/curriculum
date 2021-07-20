library(tidyverse)
library(rvest)

toc <- 
  read_html("data-raw/r4ds.html") %>%
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
  str_c("http://r4ds.had.co.nz/", .)

title <- 
  toc %>%
  map_chr(. %>%
    html_elements(xpath = "./a/node()[not(self::b)]") %>%
    html_text() %>%
    str_c(collapse = "") %>%
    str_trim()
  )

chapters <- tibble(id, title, depth, href)

chapters %>%
  filter(id != "", depth <= 3) %>%
  write_csv("data-raw/r4ds.csv")
