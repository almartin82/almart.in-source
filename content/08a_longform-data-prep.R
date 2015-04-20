
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



## ------------------------------------------------------------------------

lf <- lf %>%
  dplyr::filter(
    lubridate::year(lf$posted_at) >= 2010  
  )



## ----by_year-------------------------------------------------------------
library(dplyr)

lf$year_posted <- lubridate::year(lf$posted_at)

lf_yr <- lf %>%
  group_by(year_posted) %>%
  summarize(
    n = n()
  )

names(lf_yr)[2] <- 'yr_total'

lf_pub_yr <- lf %>%
  group_by(publication, year_posted) %>%
  summarize(
    n_pub = n()  
  )

lf_pub_disp <- lf_pub_yr
lf_pub_disp$publication <- ifelse(
  (lf_pub_disp$year %in% c(2011, 2012, 2013, 2014) & lf_pub_disp$n < 5) | (lf_pub_disp$year %in% c(2010, 2015) & lf_pub_disp$n < 3), 'Other', lf_pub_disp$publication)

lf_pub_disp <- lf_pub_disp %>%
  group_by(publication, year_posted) %>%
  summarize(
    n_pub = sum(n_pub)
  ) %>%
  group_by(year_posted) %>%
  mutate(
    rank_pub = rank(desc(n_pub), ties.method='first')  
  )




## ----join_back-----------------------------------------------------------

#all
lf_pub_yr <- dplyr::left_join(
  lf_pub_yr, lf_yr  
)

#display formatted
lf_pub_disp <- dplyr::left_join(
  lf_pub_disp, lf_yr  
)


lf_pub_yr$pct_year_total <- (lf_pub_yr$n_pub / lf_pub_yr$yr_total) * 100
lf_pub_disp$pct_year_total <- (lf_pub_disp$n_pub / lf_pub_disp$yr_total) * 100

head(lf_pub_yr)
head(lf_pub_disp)



