#' Fetch initial data from an API using a filter
#' 
#' Function to fetch the initial filtered data from the Surpass API. For several contextual examples of the use of this function, see the code chunks in HTML version of the package vignette
#' 
#' @param .api name of API requesting information from, such as "Candidate", "AnalyticsResult"
#' 
#' @param .filter vector of characters that specify the filters being applied. Note that if you are filtering on dates and using 'ge' and 'le' , then here 'ge' means 'greater than or equal to', but 'le' means 'strictly less than' (and not 'less than or equal to').
#' 
#' @param .instance "live" (the default) or "test"
#' 
#' @param .max_return a positive integer that limits the number of returned links. Default value is 'Inf'
#' 
#' @param .return "newest" (the default) or "oldest", which is used when .max_return is provided
#' 
#' @seealso [fetch_href()]
#'
#' @export
#'

fetch_filter <- function(.api,
                         .filter = "",
                         .instance = "live",
                         .return = "newest",
                         .max_return = Inf) {
  
  #stop processing if any parameter has an invalid value
  stopifnot('.instance needs to be either "live" or "test"' = .instance %in% c("live", "test"))
  stopifnot('.return needs to be either "newest" or "oldest"' = .return %in% c("newest", "oldest"))
  if(.max_return != Inf) stopifnot('.max_return needs to be a positive integer' = .max_return %% 1 == 0 & .max_return > 0)
  
  .url_api = paste0(.api,
                    "?",
                    paste("$top=40",
                          paste(.filter,
                                collapse = "&"),
                          sep = "&")
  )
  
  # check for '$filter=' instead of 'filter=' and report if the $ is suspected to be missing
  if (stringr::str_detect(string = .url_api,
                         pattern = "filter=")){
    if(stringr::str_detect(string = .url_api,
                           pattern = "\\$filter=") == FALSE) {
                             warning("Did you accidentally omit the $ sign in front of `filter`")
                           }
  }
  
  if(.instance == "live"){
    .url_stem = Sys.getenv("surpass_live_url_stem")
  } else {
    .url_stem = Sys.getenv("surpass_test_url_stem")
  }
  
  #replace any spaces in url with ASCII 32 = hex 20, or %20
  .url = stringr::str_replace_all(string = paste0(.url_stem, .url_api),
                                  pattern = " ",
                                  replacement = "%20")
  
  return(fetch_each_page(.url = .url,
                         .instance = .instance,
                         .max_return = .max_return,
                         .return = .return))
}