query_kraken <- function(kraken_pair) {
    suppressPackageStartupMessages({
    require(httr)
    require(dplyr)
    })

    file <- paste0("data/kraken/",kraken_pair,".csv")

    dir.create(dirname(file), recursive = T, showWarnings = F)

    if(!file.exists(file)){
        write("pair,client_timestamp,ask,bid,last,volume,vwap_today,num_trades_today,low_today,high_today",file=file,append=TRUE)
    }

    timestamp <- round(as.numeric(as.POSIXct( Sys.time() ))*1000,0)

    response <- GET(paste0('https://api.kraken.com/0/public/Ticker?pair=', kraken_pair))
    response_content <- content(response)
    result <- response_content$result

    if (length(result) != 0) {
        # do some processing
        pair <- result[[1]]
        ask <- as.numeric(pair$a[[1]])
        bid <- as.numeric(pair$b[[1]])
        last <- as.numeric(pair$c[[1]])
        volume <- as.numeric(pair$v[[1]])
        vwap_today <- as.numeric(pair$p[[1]])
        num_trades_today <- as.numeric(pair$t[[1]])
        low_today <- as.numeric(pair$l[[1]])
        high_today <- as.numeric(pair$h[[1]])
        #print(paste(timestamp,ask,bid,last,volume,vwap_today,num_trades_today,low_today,high_today,sep=","))
        paste(kraken_pair,timestamp,ask,bid,last,volume,vwap_today,num_trades_today,low_today,high_today,sep=",") %>%
        write(file, append = T)
    
    }  
  

}


