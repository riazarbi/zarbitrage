suppressPackageStartupMessages({
  library(dplyr)
  library(xts)
  library(data.table)
  library(ggplot2)
  library(lubridate)
  library(blastula)
  library(gt)
  library(glue)
  })


# DATA PROCESSING ##############################################################
# yahoo USDZAR
yahoo_usdzar <- fread("data/yahoo/USDZAR/data.csv")
  
time_component <- as.POSIXct(as.numeric(yahoo_usdzar$client_timestamp)/1000, origin="1970-01-01")
data_component <- yahoo_usdzar %>% 
  select(bid, ask) %>% 
  rename(yahoo_bid = bid,
         yahoo_ask = ask) %>%
  mutate(across(everything(), as.numeric))
yahoo_usdzar <- xts(data_component, order.by=time_component)

# kraken XXBTZUSD
kraken_pair <- fread("data/kraken/ETHUSD/data.csv")

time_component <- as.POSIXct(as.numeric(kraken_pair$client_timestamp)/1000, origin="1970-01-01")
data_component <- kraken_pair %>% 
  select(bid, ask, last) %>% 
  rename(kraken_bid = bid,
         kraken_ask = ask,
         kraken_spot = last) %>%
  mutate(across(everything(), as.numeric))
kraken_pair <- xts(data_component, order.by=time_component)
kraken_pair <- transform(kraken_pair, kraken_spread = (kraken_ask/ kraken_bid - 1)*10000) %>% as.xts

# luno XBTZAR
dir_path <- "data/luno/ETHZAR"
luno_pair <- do.call(rbind,lapply(list.files(dir_path, full.names = T),fread))

time_component <- as.POSIXct(as.numeric(luno_pair$client_timestamp)/1000, origin="1970-01-01")
data_component <- luno_pair %>% select(bid, ask, last_trade) %>% 
  rename(luno_bid = bid,
         luno_ask = ask,
         luno_last = last_trade) %>%
  mutate(across(everything(), as.numeric))
luno_pair <- xts(data_component, order.by=time_component)
luno_pair <- transform(luno_pair, luno_spread = (luno_ask/ luno_bid - 1)*10000) %>% as.xts

# Potential profit ----
timestamp <- round(as.numeric(as.POSIXct( Sys.time() ))*1000,0)
principals <- c(100000, 200000, 300000, 500000, 1000000)

result <- timestamp
for (principal in principals) {
  fee <- ifelse(principal > 100000, 450, 550)
  broker_spread <- 0.005
  
  interbank_usdzar_rate <- median(last(yahoo_usdzar$yahoo_ask, '1 day'), na.rm = T)
  broker_usdzar_rate <- interbank_usdzar_rate * (1+broker_spread)
  principal_usd <- (principal - fee) / broker_usdzar_rate 
  
  kraken_usd_deposit_fee <- 15
  kraken_usd_net <- principal_usd - kraken_usd_deposit_fee
  
  kraken_commission <- 0.0026
  kraken_pair_rate <- median(last(kraken_pair$kraken_ask, "1 day"), na.rm = T)
  kraken_coin <- principal_usd / kraken_pair_rate * (1-kraken_commission)
  
  kraken_coin_withdrawal_fee <-	0.00015
  luno_coin <- kraken_coin - kraken_coin_withdrawal_fee
  
  luno_commission <- 0.001
  luno_pair_rate <- median(last(luno_pair$luno_bid, "1 day"), na.rm = T)
  luno_zar_net <- luno_coin * luno_pair_rate /(1+luno_commission)
  luno_withdrawal_fee <- 0
  bank_zar_net <- luno_zar_net - luno_withdrawal_fee
  bank_zar_net
  
  overall_return <- bank_zar_net / principal - 1
  overall_return
  result <- c(result, overall_return)
}

# Write out to file
write(paste(result, collapse = ","), "data/arbitrage/zareth_estimated_return.csv", append = T)

# PLOT GENERATION ##############################################################
# Plot potential profit
file_path <- "data/arbitrage/zareth_estimated_return.csv"
pair_estimated_return <- fread(file_path)
time_component <- as.POSIXct(as.numeric(pair_estimated_return$timestamp)/1000, origin="1970-01-01")
data_component <- pair_estimated_return %>% select(starts_with("ZAR"))
pair_estimated_return <- xts(data_component, order.by=time_component)

# Make plots
estimated_return_plot <- pair_estimated_return %>% 
  window(start = as_datetime(now() - weeks(4))) %>%
    ggplot(aes(x = Index)) + 
   geom_line(aes(y = ZAR100k, color = "ZAR100k")) +
  geom_line(aes(y = ZAR200k, color = "ZAR200k")) +
  geom_line(aes(y = ZAR300k, color = "ZAR300k")) +
  geom_line(aes(y = ZAR500k, color = "ZAR500k")) +
  geom_line(aes(y = ZAR1m, color = "ZAR1m")) +
  scale_colour_manual("", 
                      values = c("ZAR100k"="green", "ZAR200k"="red", 
                                 "ZAR300k"="blue", "ZAR500k"="black", "ZAR1m"="yellow")) +
    scale_y_continuous(name = "Estimated % return",labels = scales::percent) +
    ggtitle('Estimated % return, last month')  +
  theme(legend.position = "bottom",
      legend.title = element_text( size=7), 
      legend.text=element_text(size=7))

yahoo_plot <- yahoo_usdzar %>%   window(start = as_datetime(now() - weeks(4))) %>%
  ggplot(aes(x = Index, y = yahoo_ask)) + 
  geom_line()  + 
  scale_y_continuous(name = "USDZAR") +
  ggtitle('Yahoo USDZAR Spot Prices, last month') 

luno_plot <- luno_pair %>%   window(start = as_datetime(now() - weeks(4))) %>%
  ggplot(aes(x = Index, y = luno_last)) + 
  geom_line()  + 
  scale_y_continuous(name = "Luno Last") +
  ggtitle('Luno ETHZAR Last Trade Price, last month') 

kraken_plot <- kraken_pair %>%   window(start = as_datetime(now() - weeks(4))) %>%
  ggplot(aes(x = Index, y = kraken_spot)) + 
  geom_line()  + 
  scale_y_continuous(name = "Kraken Spot") +
  ggtitle('Kraken ETHUSD Spot Prices, last month') 

# HTML REPORT GENERATION #######################################################

# Ok, I know this is a silly method. But originally this was an email I sent myself daily
# So, rather than write a new Rmd, I'm just going to save the email to an html file.

# Date ---
date_time <- add_readable_time()

# Plots ----
luno_plot <- add_ggplot(luno_plot)
kraken_plot <- add_ggplot(kraken_plot)
yahoo_plot <- add_ggplot(yahoo_plot)
estimated_return_plot <- add_ggplot(estimated_return_plot)

result <- round(result,4)*100

mood <- ifelse(result[3] < 1, "You'll lose money",
               ifelse(result[3] < 2, "Maybe if you're desperate",
                      ifelse(result[3] < 3, 
                             "Lookin pretty good",
                             "Holy shit do it now!!")))

# Subject ---
subject <- paste("ETHZAR Arb:", mood)

# Body ---
message_body <-
  glue(
    "
### Last Run: {date_time}

### TL;DR: ZAR300k nets {result[4]}% 

### Detail

Over the last 24 hours:

- A ZAR100k round trip could net a {result[2]}% return
- A ZAR200k round trip could net a {result[3]}% return
- A ZAR300k round trip could net a {result[4]}% return
- A ZAR500k round trip could net a {result[5]}% return
- A ZAR1m round trip could net a {result[6]}% return


#### Estimated Return Plot
{estimated_return_plot}

#### Kraken Plot
{kraken_plot}

#### Luno Plot
{luno_plot}

#### Yahoo Plot
{yahoo_plot}

Cheerio,

Riaz

"
  )

email <- blastula::compose_email(body = md(message_body))

htmltools::save_html(email$html_html, file = "docs/index.html")
