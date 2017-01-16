#  ----------------------------------------------------------------------------
#  SPAIN CEMENT FORECAST
#  Reads data from Excel downloaded from INE
#  File: 01-Cement-OFICEMENT-Data.R
#  (c) 2017 - Enrique Pérez Herrero
#  email: eph.project1500@gmail.com
#  Apache License Version 2.0, January 2004
#  Start: 14/Jan/2017
#  End:   16/Jan/2017
#  Data: Consumo Aparente de Cemento (miles de Tm)
#  Source: OFICEMENT
#  https://www.oficemen.com/show_doc.asp?id_doc=692
#  ----------------------------------------------------------------------------

# https://www.oficemen.com/reportajePag.asp?id_rep=1619

# https://www.oficemen.com/show_doc.asp?id_doc=692


library(pdftools)
library(dygraphs)


data_url <- "https://www.oficemen.com/show_doc.asp?id_doc=692"
pdf_file <- "Evolución histórica mensual del consumo de cemento en España.pdf"
data_path <- "data/"

pdf_file <- paste0(data_path, pdf_file)

download.file(data_url,
              pdf_file,
              mode = "wb")

# Convert pdf to text and clean.
txt <- pdf_file %>%
  pdf_text %>%
  # Remove anotation "(1)"
  gsub("\\(1\\)", "", .) %>%
  # Remove duplicated spaces
  gsub("[[:blank:]]+", " ", .) %>%
  # Correct error in month names
  gsub("Septiempre", "Septiembre", .) %>%
  # Remove dots from numbers
  gsub("\\.", "", .)


# Read table and remove duplicated spaces.
txt  <- scan(text = txt, what = "", sep = "\n", nlines = 14L) %>%
  strsplit(., "[[:blank:]]+")

txt[[1]] <- c("" , txt[[1]])

# Cement data.frame
oficement_cement <- data.frame(txt[-c(1)], stringsAsFactors = FALSE)

# Month names in spanish as data.frame names
names(oficement_cement) <- oficement_cement[2, ]
# Remove rows
oficement_cement <- oficement_cement[-c(1, 2), ]

# Convert to numeric and to thousand tonnes
oficement_cement <- sapply(oficement_cement,
                           function(x) as.numeric(x) / 1000)


# Row names as years
row_names <- txt[[1]]
row_names <- row_names[row_names != ""]
row.names(oficement_cement) <- row_names


oficement_cement <- as.data.frame(oficement_cement)
oficement_cement$Total <- NULL


# Time Series
oficement_cement <- oficement_cement %>%
  t %>%
  data.frame %>%
  unlist(., use.names = FALSE) %>%
  ts(start = c(2006, 1), end = c(2015, 12), deltat = 1/12)

dygraph(oficement_cement) %>%
  dyRangeSelector()
