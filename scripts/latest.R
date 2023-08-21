library(duckdb)
library(dplyr)
library(lubridate)
library(tidyr)
library(jsonlite)

con <- dbConnect(duckdb::duckdb(), dbdir = "data/warehouse.duckdb", read_only=TRUE)
res <- dbGetQuery(con, "TABLE returns") %>% as_tibble()

# Latest Returns
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

# Latest USDZAR
con <- dbConnect(duckdb::duckdb(), dbdir = "data/warehouse.duckdb", read_only=TRUE)

dbGetQuery(con, "TABLE INT_YAHOO") %>% as_tibble() %>%
filter(hour == max(hour),
pair == "USDZAR") %>%
        toJSON(dataframe = "rows", pretty = FALSE) %>%
        write("docs/usdzar.json")

dbDisconnect(con, shutdown=TRUE)
