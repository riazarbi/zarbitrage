query_luno <- function(luno_pair) {
    suppressPackageStartupMessages({
        require(httr)
        require(tibble)
        require(dplyr)
    })

    file <- paste0("data/luno/",luno_pair,".csv")

    dir.create(dirname(file), recursive = T, showWarnings = F)

    if(!file.exists(file)){
    write("pair,timestamp,bid,ask,last_trade,rolling_24_hour_volume,status,client_timestamp",file=file,append=TRUE)
    }

    timestamp <- round(as.numeric(as.POSIXct( Sys.time() ))*1000,0)

    response <- GET(paste0('https://api.mybitx.com/api/1/ticker?pair=', luno_pair))
    response_content <- content(response)
    #print(as_tibble(response_content))
    as_tibble(response_content) %>% 
    mutate(client_timestamp = timestamp) %>% 
    write.table(file, 
                append = TRUE, 
                sep = ",", 
                dec = ".",
                row.names = FALSE, 
                col.names = FALSE)
}