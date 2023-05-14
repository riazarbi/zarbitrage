#!/bin/Rscript

files.sources = list.files("R", full.names=T)
sapply(files.sources, source)

kraken_pairs <- c("ETHUSD", "XXBTZUSD", "XMRUSD", "XRPUSD", "LTCUSD", "UNIUSD", "USDCUSD", "ADAUSD", "UNIETH", "ADAETH")
luno_pairs <- luno_pairs()
xe_pairs <- list(c("USD","ZAR"), c("USD", "BWP"), c("ZAR", "BWP"))
yahoo_pairs <- c("ZAR", "BWP", "EUR")

for (pair in kraken_pairs) {
    print(pair)
    query_kraken(pair)
}

for (pair in luno_pairs) {
    print(pair)
    query_luno(pair)
}

for (pair in xe_pairs) {
    print(pair)
    query_xe(pair[1], pair[2])
}

for (pair in yahoo_pairs) {
    print(pair)
    query_yahoo(pair)
}
