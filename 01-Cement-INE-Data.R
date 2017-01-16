#  ----------------------------------------------------------------------------
#  SPAIN CEMENT FORECAST
#  Reads data from Excel downloaded from INE
#  File: 01-Cement-INE-Data.R
#  (c) 2017 - Enrique Pérez Herrero
#  email: eph.project1500@gmail.com
#  Apache License Version 2.0, January 2004
#  Start: 14/Jan/2017
#  End:   15/Jan/2017
#  Data: Consumo Aparente de Cemento (miles de Tm)
#  Source: INSTITUTO NACIONAL DE ESTADÍSTICA
#  http://www.ine.es/jaxiT3/Datos.htm?path=/t38/p604/a2000/l0/&file=1300011.px
#  ----------------------------------------------------------------------------

# 1) LOAD PACKAGES 
library(readxl)
library(dygraphs)

# 2) DATA SOURCE
# Data downloaded from INSTITUTO NACIONAL DE ESTADÍSTICA, format xlsx
# http://www.ine.es/jaxiT3/Datos.htm?path=/t38/p604/a2000/l0/&file=1300011.px
ine_file_path <- "data/1300011.xlsx"

# 3) HEADER INFO
ine_header <- read_excel(ine_file_path, sheet = "tabla-0")

# 3.1) Excel header
ine_header %>%
  names %>%
  .[[1]] %>%
  cat(., "\n")


# 3.2) Data description
ine_header %>%
  na.omit %>%
  .[[1]] %>%
  .[[2]] %>%
  cat(., "\n")


# 4) NOTES
ine_notes <- read_excel(ine_file_path, sheet = "tabla-0", skip = 18)

ine_notes <- ine_notes %>%
  na.omit %>%
  names %>%
  gsub("\\.", ".\n", .) %>%
  gsub("[[:blank:]]+", " ", .) %>%
  cat


# 5) TABLE DATA
# Read Aparent Cement Consumption
ine_cement <- read_excel(file_path, sheet = "tabla-0", skip = 5)
ine_cement <- ine_cement[-c(12:18), ]

ine_cement <- sapply(ine_cement[2, c(2:263)], as.numeric)

# Time Series
ine_cement <- ts(ine_cement,
                 start = c(1995, 1),
                 end = c(2016, 10),
                 deltat = 1/12)


# 6) VIEW AND PLOT DATA
ine_cement

summary(ine_cement)

plot(decompose(ine_cement, type = "multiplicative"))

dygraph(ine_cement) %>%
  dyRangeSelector()
