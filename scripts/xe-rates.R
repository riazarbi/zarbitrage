options(scipen = 999)

suppressPackageStartupMessages({
  library(rvest)
  library(dplyr)
  library(tidyr)
  library(readr)
  })

# USDZAR
html <- read_html("https://www.xe.com/currencyconverter/convert/?Amount=1&From=USD&To=ZAR")
file <-  "data/xe/USDZAR/data.csv"
timestamp <- round(as.numeric(as.POSIXct( Sys.time() ))*1000,0)
dir.create(dirname(file), recursive = TRUE, showWarnings = F)

html %>% 
  html_element(".iGrAod") %>% 
  html_text2() %>% 
  as_tibble() %>%
  separate(value, into = c("USDZAR"), extra = "drop", sep = " ") %>% 
  mutate(client_timestamp = timestamp) %>% 
  write.table(file, 
              append = TRUE, 
              sep = ",", 
              dec = ".",
              row.names = FALSE, 
              col.names = FALSE)


