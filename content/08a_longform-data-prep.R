
## ----raw_data------------------------------------------------------------

lf <- read.csv('datasets/longform_sources.csv', stringsAsFactors=FALSE)

#html cleanup
lf$publication <- gsub('&#x27;', "'", lf$publication)

head(lf)



## ----the_x---------------------------------------------------------------

pubs <- unique(lf$publication)

dupes <- c()

for (i in pubs) {
  if (paste('The', i) %in% pubs) {
    dupes <- append(dupes, i)
  }
}

#print(dupes)


## ----fix_dupes-----------------------------------------------------------

for (j in dupes) {
  lf$publication <- gsub(paste('The', j), j, lf$publication)
}



## ----fix_date------------------------------------------------------------
library(lubridate)
library(magrittr)

lf$posted_at <- lubridate::parse_date_time(
  lf$posted_at, orders=c('d-m-y','d-M-y')
)


