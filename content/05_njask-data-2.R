
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
#also read in the old NJASK layouts
load(file = 'datasets/njask05_layout.rda')
load(file = 'datasets/njask04_layout.rda')
load(file = 'datasets/njask07gr3_layout.rda')
load(file = 'datasets/njask06gr3_layout.rda')
load(file = 'datasets/njask06gr5_layout.rda')

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
    
  #url paths changed after the 2012 assessment
  years <- list(
    "2014"="14", "2013"="13", "2012"="2013", "2011"="2012", "2010"="2011", "2009"="2010", 
    "2008"="2009", "2007"="2008", "2006"="2007", "2005"="2006", "2004"="2005"
  )
  parsed_year <- years[[as.character(year)]]
  
  #2008 follows a totally unique pattern
  grade_str <- if (year==2008 & grade >=5) {
    paste0('58/g', grade)
  } else if (year %in% c(2006, 2007) & grade %in% c(5, 6, 7)) {
    '57'
  } else {
    grade
  }
  
  #filenames are also inconsistent 
  filename <- list(
    "2014"="state_summary.txt", "2013"="state_summary.txt", "2012"="state_summary.txt",
    "2011"="state_summary.txt", "2010"="state_summary.txt", "2009"="state_summary.txt",
    "2008"="state_summary.txt", "2007"=if(grade >= 5) {
        paste0('G', grade, 'state_summary.txt')
      } else {
        "state_summary.txt"
      }, 
      "2006"=if(grade >= 5) {
        paste0('G', grade, 'state_summary.txt')
      } else {
        "state_summary.txt"
      }, 
      "2005"= if(grade==3) {
        "njask005_state_summary3.txt"
      } else if (grade==4) {
        "njask2005_state_summary4.txt"
      }, 
    "2004"=paste0("njask", grade, "04state_summary.txt")   
  )
  parsed_filename <- filename[[as.character(year)]]
    
  #build url
  target_url <- paste0(
    "http://www.state.nj.us/education/schools/achievement/", parsed_year, 
    "/njask", grade_str, "/", parsed_filename
  )
    
  print(target_url)
  
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

process_njask <- function(df, mask=layout_njask$comments) {
  #keep the names to put back in the same order
  all_names <- names(df)
  
  #replace any line breaks in last column
  df$Grade <- gsub('\n', '', df$Grade, fixed = TRUE)
  
  mask_boolean <- mask == 'One implied decimal'
  #put some columns aside
  ignore <- df[, !mask_boolean]
  
  #process the columns that have an implied decimal
  processed <- df[, mask_boolean] %>%
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
  if (year == 2004) {
    df <- get_raw_njask(year, grade, layout=layout_njask04)  %>% 
      process_njask(mask=layout_njask04$comments)
  }
  else if (year == 2005) {
    df <- get_raw_njask(year, grade, layout=layout_njask05)  %>% 
      process_njask(mask=layout_njask05$comments) 
  } else if (year %in% c(2007, 2008) & grade %in% c(3, 4)) {
    df <- get_raw_njask(year, grade, layout=layout_njask07gr3)  %>% 
      process_njask(mask=layout_njask07gr3$comments) 
  }
  else if (year == 2006 & grade %in% c(3, 4)) {
    df <- get_raw_njask(year, grade, layout=layout_njask06gr3)  %>% 
      process_njask(mask=layout_njask06gr3$comments)
  } else if (year == 2006 & grade >= 5) {
    #fetch
    df <- get_raw_njask(year, grade, layout=layout_njask06gr5)  
    #inexplicably 2006 data has no Grade column
    df$Grade <- grade
    df <- df %>% process_njask(mask=layout_njask06gr5$comments)    
  }
  else {
    df <- get_raw_njask(year, grade) %>% process_njask()    
  }

  return(df)
}

fetch_njask(2014, 6) %>% head() %>% select(CDS_Code:TOTAL_POPULATION_LANGUAGE_ARTS_Scale_Score_Mean)



