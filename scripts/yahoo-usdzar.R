options(scipen = 999)

suppressPackageStartupMessages({
  library(rvest)
  library(httr)
  library(dplyr)
  library(tidyr)
  library(readr)
  library(magrittr)
  })

# USDZAR
ua <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"

result <- GET("https://finance.yahoo.com/quote/ZAR=X", user_agent(ua))
html <- read_html(result)
dirname <-  "data/yahoo/USDZAR"
timestamp <- round(as.numeric(as.POSIXct( Sys.time() ))*1000,0)
dir.create(dirname, recursive = TRUE, showWarnings = F)

html %>% 
  html_element("#quote-summary") %>% 
  html_table() %>% 
  as_tibble() %>%
  mutate(X2 = as.numeric(X2)) %>%
  select(X2) %>% 
  t() %>% as_tibble(.name_repair = "minimal") %>%
  set_colnames(c("prev_close", "open", "bid", "day_range", "52wk_range", "ask")) %>%
  select(-day_range, -`52wk_range`) %>%
  mutate(client_timestamp = timestamp) %>% 
  write.table("data/yahoo/USDZAR/data.csv", 
              append = TRUE, 
              sep = ",", 
              dec = ".",
              row.names = FALSE, 
              col.names = FALSE)

