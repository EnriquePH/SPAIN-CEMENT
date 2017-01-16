#https://www.oficemen.com/reportajePag.asp?id_rep=1619

#https://www.oficemen.com/show_doc.asp?id_doc=692


library(pdftools)
library(qdapRegex)
rm_white(string)

data_url <- "https://www.oficemen.com/show_doc.asp?id_doc=692"
pdf_file <- "Evolución histórica mensual del consumo de cemento en España.pdf"

download.file(data_url,
              pdf_file,
              mode = "wb")
txt <- pdf_text(pdf_file)
# Remove anotation "(1)"
txt <- gsub("\\(1\\)", "", txt)
# Remove duplicated spaces
txt <- gsub("[[:blank:]]+", " ", txt)
# Correct error in month names
txt <- gsub("Septiempre", "Septiembre", txt)
txt <- gsub("\\.", "", txt)


txt <- scan(text = txt, what = "", sep = "\n", nlines = 14L)
txt <- strsplit(txt, "[[:blank:]]+")
txt[[1]] <- c("" , txt[[1]])


cemento <- data.frame(txt[-c(1)], stringsAsFactors = FALSE)

# Month names in spanish as data.frame names
names(cemento) <- cemento[2, ]
# Remove rows
cemento <- cemento[-c(1, 2), ]

cemento <- sapply(cemento, as.numeric)

# Row names as years
row_names <- txt[[1]]
row_names <- row_names[row_names != ""]
row.names(cemento) <- row_names


cemento <- as.data.frame(cemento)
cemento$Total <- NULL

#cemento <- cemento[-c(13), ]

View(cemento)

plot(as.ts(cemento))


plot(ts(unlist(cemento), start = c(2006, 1), end = c(2015, 12)))

plot(unlist((cemento)))

plot(ts(unlist(cemento), start = c(2006, 1), end = c(2015, 12), frequency = 12))
