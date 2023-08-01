library(tidyverse)
library(rvest)

url_r4ds2 <- "https://r4ds.hadley.nz/"

urls_r4ds2 <- 
  url_r4ds2 |> 
  read_html() |> 
  html_elements("a.sidebar-item-text") |> 
  html_attr("href") |> 
  str_replace("\\./", url_r4ds2)

section <- function(html_element) {
  text <-
    html_element |> 
    html_element("a") |> 
    html_text(trim = TRUE)
  tibble(
    id = str_extract(text, "^\\S+"),
    title = str_remove(text, "^\\S+\\s+"),
    href =
      html_element |> 
      html_element("a") |> 
      html_attr("href")
  )
}

chapter <- function(url_chapter) {
  html_chapter <- read_html(url_chapter)
  toc <- 
    html_chapter |> 
    html_element("nav#TOC")
  if (is_empty(toc))
    return(NULL)
  
  bind_rows(
    tibble(
      id = 
        html_chapter |> 
        html_element("h1.title span.chapter-number") |> 
        html_text(trim = TRUE),
      title =
        html_chapter |> 
        html_element("h1.title span.chapter-title") |> 
        html_text(trim = TRUE),
      href = ""
    ),
    toc |> 
      html_elements("li") |> 
      map_dfr(section)
  ) |> 
    mutate(href = str_c(url_chapter, href))
}

chapters <- 
  urls_r4ds2 |> 
  map_dfr(chapter)

chapters |> 
  filter(!str_detect(href, str_c(url_r4ds2, "index.html"))) |> 
  mutate(depth = str_count(id, "\\.") + 1) |> 
  relocate(depth, .after = title) |> 
  filter(depth <= 3) |> 
  write_csv("data-raw/r4ds2.csv")
