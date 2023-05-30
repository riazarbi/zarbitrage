query_xe <- function(cur1, cur2) {
    options(scipen = 999)

    suppressPackageStartupMessages({
    require(rvest)
    require(dplyr)
    require(tidyr)
    require(readr)
    })

    # USDZAR
    html <- read_html(paste0("https://www.xe.com/currencyconverter/convert/?Amount=1&From=",cur1,"&To=",cur2))
    file <-  paste0("data/xe/",cur1,cur2,".csv")
    timestamp <- round(as.numeric(as.POSIXct( Sys.time() ))*1000,0)
    dir.create(dirname(file), recursive = TRUE, showWarnings = F)

    if(!file.exists(file)){
    write("rate,client_timestamp,pair",file=file,append=TRUE)
    }

    dat <- html %>% 
    html_element(".iGrAod") %>% 
    html_text2() %>% 
    as_tibble() %>%
    separate(value, into = c(paste0(cur1,cur2)), extra = "drop", sep = " ") %>% 
    mutate(client_timestamp = timestamp) %>%
    mutate(pair=paste0(cur1,cur2))
    #print(dat)
    write.table(dat, 
                file, 
                append = TRUE, 
                sep = ",", 
                dec = ".",
                row.names = FALSE, 
                col.names = FALSE)

}