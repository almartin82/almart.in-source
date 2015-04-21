
## ----pelican_conf, echo=FALSE--------------------------------------------
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



## ----libraries, message=FALSE, warning=FALSE-----------------------------
library(readr)
library(dplyr)
library(magrittr)


## ----hspa1---------------------------------------------------------------

load(file = 'datasets/hspa_layout.rda')
load(file = 'datasets/hspa2010_layout.rda')
head(layout_hspa)



## ----hspa2---------------------------------------------------------------

hspa_url <- 'http://www.state.nj.us/education/schools/achievement/14/hspa/state_summary.txt'

hspa_ex <- readr::read_fwf(
  file = hspa_url,
  col_positions = readr::fwf_positions(
    start = layout_hspa$field_start_position,
    end = layout_hspa$field_end_position,
    col_names = layout_hspa$final_name
  ),
  na = "*"
)

hspa_ex %>% as.data.frame() %>% select(CDS_Code:TOTAL_POPULATION_LANGUAGE_ARTS_Scale_Score_Mean) %>% head()



## ----generalize_processing-----------------------------------------------

process_nj_assess <- function(df, layout) {
  #build a mask
  mask <- layout$comments == 'One implied decimal'
    
  #keep the names to put back in the same order
  all_names <- names(df)
  
  #make sure df is data frame (not dplyr data frame) so that normal subsetting
  df <- as.data.frame(df)

  #get name of last column and kill \n characters
  last_col <- names(df)[ncol(df)]
  df[, last_col] <- gsub('\n', '', df[, last_col], fixed = TRUE)
      
  #put some columns aside
  ignore <- df[, !mask]
  
  implied_decimal_fix <- function(x) {
    #strip out anything that's not a number.
    x <- as.numeric(gsub("[^\\d]+", "", x, perl=TRUE))
    x / 10
  }

  #process the columns that have an implied decimal
  processed <- df[, mask] %>%
    dplyr::mutate_each(
      dplyr::funs(implied_decimal_fix)  
    )
  
  #put back together 
  final <- cbind(ignore, processed)
  
  #reorder and return
  final %>%
    select(
      one_of(names(df))
    )
}

process_nj_assess(hspa_ex, layout_hspa) %>% select(CDS_Code:TOTAL_POPULATION_LANGUAGE_ARTS_Scale_Score_Mean) %>% head()



## ----fetch_hspa----------------------------------------------------------

get_raw_hspa <- function(year, layout=layout_hspa) {
  require(readr)
    
  #url paths changed in 2012
  years <- list(
    "2014"="14", "2013"="13", "2012"="2013", "2011"="2012", "2010"="2011", "2009"="2010", 
    "2008"="2009", "2007"="2008", "2006"="2007", "2005"="2006", "2004"="2005"
  )
  parsed_year <- years[[as.character(year)]]
  
  #filenames are screwy
  parsed_filename <- if(year > 2005) {
    "state_summary.txt"
  } else if (year == 2005) {
    "2005hspa_state_summary.txt" 
  } else if (year == 2004) {
    "hspa04state_summary.txt"
  }
      
  #build url
  target_url <- paste0(
    "http://www.state.nj.us/education/schools/achievement/", parsed_year, 
    "/hspa/", parsed_filename
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

#final wrapper
fetch_hspa <- function(year) {
  if (year >= 2011) {
    hspa_df <- get_raw_hspa(year) %>% process_nj_assess(layout=layout_hspa)
  } else if (year >= 2004) {
    hspa_df <- get_raw_hspa(year, layout=layout_hspa2010) %>% process_nj_assess(layout=layout_hspa2010) 
  }
  
  return(hspa_df)
}

fetch_hspa(2010) %>% select(CDS_Code:TOTAL_POPULATION_LANGUAGE_ARTS_Scale_Score_Mean) %>% head()



## ----gepa1---------------------------------------------------------------

load(file = 'datasets/gepa_layout.rda')
load(file = 'datasets/njask05_layout.rda')

head(layout_gepa)



## ----gepa2---------------------------------------------------------------

get_raw_gepa <- function(year, layout=layout_gepa) {
  require(readr)
    
  #url paths changed in 2012
  years <- list(
    "2007"="2008", "2006"="2007", "2005"="2006", "2004"="2005"
  )
  parsed_year <- years[[as.character(year)]]
  
  filename <- list(
    "2007"="state_summary.txt", "2006"="state_summary.txt",
    "2005"="2005njgepa_state_summary.txt", "2004"="gepa04state_summary.txt"   
  )
  parsed_filename <- filename[[as.character(year)]]

  #build url
  target_url <- paste0(
    "http://www.state.nj.us/education/schools/achievement/", parsed_year, 
    "/gepa/", parsed_filename
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

gepa_ex <- get_raw_gepa(2007)

gepa_ex %>% as.data.frame() %>% select(CDS_Code:TOTAL_POPULATION_LANGUAGE_ARTS_Scale_Score_Mean) %>% head()



## ----gepa3---------------------------------------------------------------

process_nj_assess(gepa_ex, layout_gepa) %>% select(CDS_Code:TOTAL_POPULATION_LANGUAGE_ARTS_Scale_Score_Mean) %>% head()



## ----gepa_wrapper--------------------------------------------------------

#final wrapper
fetch_gepa <- function(year) {
  get_raw_gepa(year) %>% process_nj_assess(layout=layout_gepa)
  
}

fetch_gepa(2007) %>% as.data.frame() %>% select(CDS_Code:TOTAL_POPULATION_LANGUAGE_ARTS_Scale_Score_Mean) %>% head()



