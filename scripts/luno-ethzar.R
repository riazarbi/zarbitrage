suppressPackageStartupMessages({
  library(httr)
  library(tibble)
  library(dplyr)
  })

file <- "data/luno/ETHZAR/data.csv"

dir.create(dirname(file), recursive = T, showWarnings = F)

timestamp <- round(as.numeric(as.POSIXct( Sys.time() ))*1000,0)

response <- GET('https://api.mybitx.com/api/1/ticker?pair=ETHZAR') 
response_content <- content(response)
as_tibble(response_content) %>% 
mutate(client_timestamp = timestamp) %>% 
  write.table(file, 
              append = TRUE, 
              sep = ",", 
              dec = ".",
              row.names = FALSE, 
              col.names = FALSE)
