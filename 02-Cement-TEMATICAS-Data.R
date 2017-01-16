

library(xml2)
library(rvest)

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




View(tematicas_cement)

# TITLE
data_page %>%
  html_node(xpath = "//h1") %>%
  html_text %>%
  cat

# NOTES
data_page %>%
  html_node(xpath = "//*[@itemprop='description']") %>%
  html_text %>%
  gsub("\\.(\\D)", ".\n\\1", .) %>%
  cat

# TABLE DATA 
tematicas_cement <- data_page %>%
  html_table %>%
  data.frame %>%
  .[, -c(1)]



names(tematicas_cement) <- c("Date", "kT")

my_LC_TIME <- Sys.getlocale("LC_TIME")
my_LC_TIME
Sys.setlocale("LC_TIME", "es_ES.UTF-8")


tematicas_cement$Date2 <- tematicas_cement$Date %>%
  tolower %>%
  gsub("^([a-z]{3}).+([0-9]{4})$", "\\1-\\2", .) %>%
  paste0("1-", .) %>%
  as.Date(. , "%d-%b-%Y")

View(tematicas_cement)

