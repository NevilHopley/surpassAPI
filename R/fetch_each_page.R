#' Fetches multiple pages of data from an API
#' 
#' Function that recursively calls itself to fetch 40 results at a time. This function is used by the `fetch_filter()` function, and users should therefore NOT need to directly make use of this function.
#' 
#' @param .url the URL endpoint that we are fetching data from
#' 
#' @param .instance "live" (the default) or "test"
#' 
#' @param .data the data frame being used to gather all of the returned hrefs
#' 
#' @param .max_return a positive integer that limits the number of returned links
#' 
#' @param .return "newest" (the default) or "oldest" which is used when .max_return is provided
#' 
#' @param .initial_skip initial number of records to omit. Not for use by user
#'
#' @return a data frame with API hrefs ready for fetch_href()
#' 
#' @seealso [fetch_href()]
#'
#' @export
#'

fetch_each_page <- function(.url,
                            .instance = "live",
                            .data = data.frame(),
                            .max_return,
                            .return,
                            .initial_skip = 0){
  
  # make enquiry to API to receive back relevant reference information
  json_data <- httr2::request(.url) |> 
    httr2::req_headers_redacted(authorization = Sys.getenv(paste0("surpass_", 
                                                                  .instance, 
                                                                  "_api_key"))) |> 
    httr2::req_perform() |> 
    httr2::resp_body_json(simplifyVector = TRUE)
  
  # display reassuring message at the start
  if (json_data$skip == 0){
    cli::cli_alert_info(paste("Identified", json_data$count, "records."))
    if (.max_return < Inf) {
      cli::cli_alert_info(paste("Fetching the",.return, .max_return, "records. Please wait."))
    } else {
      cli::cli_alert_info(paste("Fetching all records. Please wait."))
    }
    time_1 <<- Sys.time()
  }
  
  # if 'newest' records are to be returned, set up initial skip value and re-fetch
  if (.return == "newest" & .max_return < Inf & .initial_skip == 0) {
    
    # ensure initial_skip is non-negative
    .initial_skip = max(0, json_data$count - .max_return)
    
    # repeat enquiry to API to receive back relevant reference information, with initial_skip included
    json_data <- httr2::request(paste0(.url, "&$skip=", .initial_skip)) |> 
      httr2::req_headers_redacted(authorization = Sys.getenv(paste0("surpass_", 
                                                                    .instance, 
                                                                    "_api_key"))) |> 
      httr2::req_perform() |> 
      httr2::resp_body_json(simplifyVector = TRUE)
    
    time_1 <<- Sys.time()
  }
  
  # display message for ETA based on first 6 page fetches of 40 results
  if (json_data$skip == .initial_skip + 40 * 6){
    time_2 = Sys.time()
    multiplier = min(json_data$count, .max_return) / (40 * 6) - 1
    cli::cli_alert_info(paste("Fetching records expected to be completed by",
                              lubridate::round_date(
                                time_2 + multiplier * (time_2 - time_1),
                                unit = "second")))
  }
  
  # Combine the new data with the existing data
  .data <- dplyr::bind_rows(.data, json_data$response)
  
  # Check if there is a next page and we've not hit the maximum return yet
  if (!is.null(json_data$nextPageLink) & nrow(.data) < .max_return) {
    .data <- fetch_each_page(.url = json_data$nextPageLink,
                             .instance = .instance,
                             .data = .data,
                             .max_return = .max_return,
                             .return = .return,
                             .initial_skip = .initial_skip)
  }
  
  return(head(x = .data,
              n = .max_return))
}