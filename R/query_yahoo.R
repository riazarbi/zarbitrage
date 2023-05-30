query_yahoo <-  function(cur){
    options(scipen = 999)

    suppressPackageStartupMessages({
    require(rvest)
    require(httr)
    require(dplyr)
    require(tidyr)
    require(readr)
    require(magrittr)
    })

    # USDZAR
    ua <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"

    result <- GET(paste0("https://finance.yahoo.com/quote/",cur,"=X"), user_agent(ua))
    html <- read_html(result)
    file <-  paste0("data/yahoo/USD",cur,".csv")
    timestamp <- round(as.numeric(as.POSIXct( Sys.time() ))*1000,0)
    dir.create(dirname(file), recursive = TRUE, showWarnings = F)


    if(!file.exists(file)){
    write("prev_close,open,bid,ask,client_timestamp,pair",file=file,append=TRUE)
    }


    dat <- html %>% 
    html_element("#quote-summary") %>% 
    html_table() %>% 
    as_tibble() %>%
    mutate(X2 = as.numeric(X2)) %>%
    select(X2) %>% 
    t() %>% as_tibble(.name_repair = "minimal") %>%
    set_colnames(c("prev_close", "open", "bid", "day_range", "52wk_range", "ask")) %>%
    select(-day_range, -`52wk_range`) %>%
    mutate(client_timestamp = timestamp) %>%
    mutate(pair=paste0("USD",cur))
    #print(dat)
    write.table(dat,
                file, 
                append = TRUE, 
                sep = ",", 
                dec = ".",
                row.names = FALSE, 
                col.names = FALSE)

}