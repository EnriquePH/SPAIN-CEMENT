#  ----------------------------------------------------------------------------
#  SPAIN CEMENT FORECAST
#  Reads data from Excel downloaded from INE
#  File: 03-Cement-TEMATICAS-Data.R
#  (c) 2017 - Enrique Pérez Herrero
#  email: eph.project1500@gmail.com
#  Apache License Version 2.0, January 2004
#  Start: 16/Jan/2017
#  End:   17/Jan/2017
#  Data: Consumo Aparente de Cemento (miles de Tm)
#  Source: INE
#  http://tematicas.org
#  ----------------------------------------------------------------------------

library(xml2)
library(rvest)
library(dygraphs)

# http://tematicas.org/
# sintesis-economica/
# indicadores-de-produccion-y-demanda-nacional/
# consumo-aparente-de-cemento/


data_url <- paste0("http://tematicas.org/",
                   "sintesis-economica/",
                   "indicadores-de-produccion-y-demanda-nacional/",
                   "consumo-aparente-de-cemento/")




data_page <- data_url %>%
  read_html




# TITLE
title <- data_page %>%
  html_node(xpath = "//h1") %>%
  html_text


# NOTES
notes <- data_page %>%
  html_node(xpath = "//*[@itemprop='description']") %>%
  html_text %>%
  gsub("\\.(\\D)", ".\n\\1", .)

# TABLE DATA 
table_cement <- data_page %>%
  html_table %>%
  data.frame %>%
  .[, -c(1)]



names(table_cement) <- c("Date", "kt")


table_cement$kt <- table_cement$kt %>%
  gsub(",", "", .) %>%
  as.numeric

my_LC_TIME <- Sys.getlocale("LC_TIME")

Sys.setlocale("LC_TIME", "es_ES.UTF-8")


table_cement$Date <- table_cement$Date %>%
  tolower %>%
  gsub("^([a-z]{3}).+([0-9]{4})$", "\\1-\\2", .) %>%
  paste0("1-", .) %>%
  as.Date(. , "%d-%b-%Y")

Sys.setlocale("LC_TIME", my_LC_TIME)

# Sort by date
table_cement <- table_cement[order(table_cement$Date), ]

summary(table_cement)

start_year <- table_cement$Date %>%
  min %>%
  format(., "%Y") %>%
  as.numeric

start_month <- table_cement$Date %>%
  min %>%
  format(., "%m") %>%
  as.numeric

end_year <- table_cement$Date %>%
  max %>%
  format(., "%Y") %>%
  as.numeric

end_month <- table_cement$Date %>%
  max %>%
  format(., "%m") %>%
  as.numeric


# TIME SERIES
ts_cement <- ts(table_cement$kt,
        start = c(start_year, start_month),
        end = c(end_year, end_month),
        deltat = 1/12)


dygraph(ts_cement, main = title) %>%
  dySeries("V1", label = "miles Tm") %>%
  dyOptions(fillGraph = TRUE) %>%
  dyRangeSelector()

library(xts)


barplot(apply.yearly(as.xts(ts_cement), sum))
