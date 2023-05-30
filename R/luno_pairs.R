luno_pairs <- function() {
    suppressPackageStartupMessages({
        require(httr)
        require(tibble)
        require(dplyr)
        require(purrr)
    })

    response <- GET('https://api.luno.com/api/1/tickers')
    response_content <- content(response)
    response_tbl <- map(as_tibble(response_content), bind_rows)
    luno_pairs <- response_tbl$tickers %>% pull(pair)
    return(luno_pairs)

}