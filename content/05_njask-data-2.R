
## ----, echo=FALSE--------------------------------------------------------
#SET THIS TO TRUE WHEN READY TO PUBLISH
ready_to_ship = TRUE

library(knitr)
hook_plot <- knit_hooks$get('plot')

knit_hooks$set(plot=function(x, options) {
    if (!is.null(options$pelican.publish) && options$pelican.publish) {
        x <- paste0("{filename}", x)
    }
    hook_plot(x, options)
})
opts_chunk$set(dev='Cairo_svg')
opts_chunk$set(pelican.publish=ready_to_ship)



## ----load_layout---------------------------------------------------------

load(file = 'datasets/njask_layout.rda')

head(layout_njask)



## ----final_fwf-----------------------------------------------------------

sample_file = "http://www.state.nj.us/education/schools/achievement/14/njask8/state_summary.txt"

njask14_gr8 <- readr::read_fwf(
  file = sample_file,
  col_positions = readr::fwf_positions(
    start = layout_njask$field_start_position,
    end = layout_njask$field_end_position,
    col_names = layout_njask$final_name
  ),
  na = "*"
)



## ----as_function---------------------------------------------------------

get_raw_njask <- function(year, grade, layout=layout_njask) {
  require(readr)
    
  #url paths changed in 2012
  years <- list(
    "2014"="14", "2013"="13", "2012"="2013", "2011"="2012", "2010"="2011", "2009"="2010", 
    "2008"="2009", "2007"="2008", "2006"="2007", "2005"="2006", "2004"="2005"
  )
  parsed_year <- years[[as.character(year)]]
  
  #build url
  target_url <- paste0(
    "http://www.state.nj.us/education/schools/achievement/", parsed_year, 
    "/njask", grade, "/state_summary.txt"
  )
  
  #read_fwf
  df <- readr::read_fwf(
    file = target_url,
    col_positions = readr::fwf_positions(
      start = layout$field_start_position,
      end = layout$field_end_position,
      col_names = layout$final_name
    ),
    na = "*"
  )
  
  #return df
  return(df)
  
}



## ----test_get_raw_njask--------------------------------------------------
library(magrittr)

ex <- get_raw_njask(2014, 6)

dplyr::sample_n(ex[, sample(c(1:551), 10)], 10) %>% as.data.frame()



## ----limit_df------------------------------------------------------------
library(dplyr)

process_njask <- function(df, mask=layout_njask$comments == 'One implied decimal') {
  #keep the names to put back in the same order
  all_names <- names(df)
  
  #replace any line breaks in last column
  df$Grade <- gsub('\n', '', df$Grade, fixed = TRUE)
  
  #put some columns aside
  ignore <- df[, !mask]
  
  #process the columns that have an implied decimal
  processed <- df[, mask] %>%
    dplyr::mutate_each(
      dplyr::funs(implied_decimal = . / 10)  
    )
  
  #put back together 
  final <- cbind(ignore, processed)
  
  #reorder and return
  final %>%
    select(
      one_of(names(df))
    )
}

ex_process <- process_njask(ex)

head(ex_process[, 1:15])



## ----wrapper-------------------------------------------------------------

fetch_njask <- function(year, grade) {
  get_raw_njask(year, grade) %>% process_njask()
}

fetch_njask(2014, 6) %>% head() %>% select(CDS_Code:TOTAL_POPULATION_LANGUAGE_ARTS_Scale_Score_Mean)



