library(duckdb)
library(dplyr)
library(lubridate)
library(tidyr)
library(jsonlite)

con <- dbConnect(duckdb::duckdb(), dbdir = "data/warehouse.duckdb", read_only=TRUE)
res <- dbGetQuery(con, "TABLE returns") %>% as_tibble()


res %>%
group_by(principal, kraken) %>%
             filter(hour == max(hour)) %>%
             select(-hour, -nominal) %>%
             arrange(principal,return,kraken) %>%
             ungroup() %>%
             group_by(principal) %>%
             nest() %>% toJSON(dataframe = "rows", pretty = FALSE) %>%
             write("docs/latest.json")

res %>%
filter(hour == max(hour)) %>%
    select(-hour) %>%
    group_by(principal) %>%
        filter(return == max(return)) %>%
        select(-nominal) %>%
        ungroup() %>%
        group_by(principal) %>%
        nest() %>% 
        toJSON(dataframe = "rows", pretty = FALSE) %>%
        write("docs/ranking.json")

dbDisconnect(con, shutdown=TRUE)
