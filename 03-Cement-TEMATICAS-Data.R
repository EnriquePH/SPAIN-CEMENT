#  ----------------------------------------------------------------------------
#  SPAIN CEMENT FORECAST
#  Reads data from Excel downloaded from http://tematicas.org
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


# 1) LOAD PACKAGES 

library(xml2)
library(rvest)
library(dygraphs)
library(xts)



# 2) DATA SOURCE

data_url <- paste0("http://tematicas.org/",
                   "sintesis-economica/",
                   "indicadores-de-produccion-y-demanda-nacional/",
                   "consumo-aparente-de-cemento/")


# 3) READ HTML PAGE

data_page <- data_url %>%
  read_html


# 4) EXTRACT INFO AND CLEAN

# 4.1) Title
title <- data_page %>%
  html_node(xpath = "//h1") %>%
  html_text

# 4.2) Notes
notes <- data_page %>%
  html_node(xpath = "//*[@itemprop='description']") %>%
  html_text %>%
  gsub("\\.(\\D)", ".\n\\1", .)

# 4.3) Table data 
table_cement <- data_page %>%
  html_table %>%
  data.frame %>%
  .[, -c(1)]


names(table_cement) <- c("Date", "kt")

# Convert data to numeric
table_cement$kt <- table_cement$kt %>%
  gsub(",", "", .) %>%
  as.numeric

# Change locale for spanish date conversion

my_LC_TIME <- Sys.getlocale("LC_TIME")
Sys.setlocale("LC_TIME", "es_ES.UTF-8")

# Convert Date

table_cement$Date <- table_cement$Date %>%
  tolower %>%
  gsub("^([a-z]{3}).+([0-9]{4})$", "\\1-\\2", .) %>%
  paste0("1-", .) %>%
  as.Date(. , "%d-%b-%Y")

# Back up locale
Sys.setlocale("LC_TIME", my_LC_TIME)

# Sort by date
table_cement <- table_cement[order(table_cement$Date), ]

summary(table_cement)

# Extract start and end dates
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


# 5) CONVERT TO TIME SERIES
ts_cement <- ts(table_cement$kt,
        start = c(start_year, start_month),
        end = c(end_year, end_month),
        deltat = 1/12)

xts_cement <- as.xts(ts_cement)

# 6) SAVE xts AS csv

xts_file_path <- "data/xts_cement.csv"

write.zoo(xts_cement, file = xts_file_path, sep = ",")



# 7) PLOT DATA
dygraph(xts_cement, main = title) %>%
  dySeries("V1", label = "miles Tm") %>%
  dyOptions(fillGraph = TRUE) %>%
  dyRangeSelector()



dyBarChart <- function(dygraph) {
  dyPlotter(dygraph = dygraph,
            name = "BarChart",
            path = system.file("examples/plotters/barchart.js",
                               package = "dygraphs"))
}



# dygraph(apply.yearly(xts_cement, sum)) %>%
#   dySeries("V1", label = "miles Tm") %>%
#   dyOptions(fillGraph = TRUE) %>%
#   dyRangeSelector()

dygraph(apply.yearly(xts_cement, sum)) %>%
  dyRangeSelector() %>%
  dyBarChart()
