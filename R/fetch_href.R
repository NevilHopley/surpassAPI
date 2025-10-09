#' Fetch data using provided href URL links
#'
#' Function to fetch data using the href's of interest from the declared column of the provided data frame. For several contextual examples of the use of this function, see the code chunks in the HTML version of the package vignette.
#' 
#' @param .data the data frame that contains hrefs
#' 
#' @param .col "href" (the default) or the column name to extract the hrefs from.
#' 
#' @param .instance "live" (the default) or "test"
#' 
#' @param .fails "keep" (the default) or "drop". This option is used to monitor if any hrefs fail. The returned data frame populates a column called fetch.href with either "success" or "fail".
#' 
#' @param .append name of linked API to append to href, such as "/TestForms", "/ItemResponse", "?showItemResponse=true", etc. See Vignette API summary for append text in bold.
#'
#' @return a data frame with many columns of data fetched from an API
#'
#' @seealso [fetch_filter()] for use before this function, [flatten_fetched()] for use after this after
#'
#' @export
#'

fetch_href <- function(.data,
                       .col = "href",
                       .instance = "live",
                       .fails = "keep",
                       .append = "") {
  
  #stop processing if any parameter has an invalid value
  stopifnot('.instance needs to be either "live" or "test"' = .instance %in% c("live", "test"))
  stopifnot('.fails needs to be either "keep" or "drop"' = .fails %in% c("keep", "drop"))
  stopifnot('.append should start with / or ?' = stringr::str_sub(string = .append,
                                                                  start = 1L,
                                                                  end = 1L) %in% c("/", "?", ""))
  
  # extract the unique urls from the provided dataframe
  .urls = .data |>
    dplyr::pull(.col) |>
    unique() |> 
    na.omit()
  
  # display reassuring message of what will happen
  cli::cli_alert_info(paste0("Fetching data using URLs in ",
              .col,
              " column",
              ifelse(test = .append == "",
                     yes = "",
                     no = paste0(", with ",
                                .append,
                                " appended to them")),
              "."))
  
  
  # fetch the specified data using href links
  df = purrr::map(
    .progress = TRUE,
    .x = .urls,
    .f = ~ httr2::request(base_url = paste0(.x, .append)) |> 
      httr2::req_headers_redacted(authorization = Sys.getenv(paste0("surpass_", 
                                                                    .instance, 
                                                                    "_api_key"))) |> 
      # suppress any HTTP 400 Bad Request, and similar errors
      httr2::req_error(is_error = \(resp) FALSE,
                       # body = function(resp) {
                       #   httr2::resp_body_json(resp)$error
                       # }
                       ) |>
      httr2::req_perform() |> 
      httr2::resp_body_json(simplifyVector = TRUE) |> 
      # extract only the data frame of response data
      purrr::pluck("response"))

  # deal with any empty lists
  df[lengths(df) == 0] <- list(NULL)
  
  # add in original href link to track source
  df = df |> 
    purrr::list_rbind(names_to = "id") |>
    dplyr::mutate(join.href = .urls[id],
                  fetch.href = "success",
                  .before = tidyselect::everything(),
                  .keep = "unused")
  
  # detect if any requests failed
  if(nrow(df) != length(.urls)){
    
    # identify the .urls that did not work
    failed_hrefs = dplyr::anti_join(x = data.frame(join.href = .urls),
                                      y = df |> dplyr::select(join.href),
                                      by = dplyr::join_by(join.href)) |> 
      dplyr::mutate(fetch.href = "fail",
                    href = join.href)
    
    if(.fails == "keep"){
    # display helpful message
      cli::cli_alert_warning(paste(nrow(failed_hrefs),
                                   "failed data fetches are identified in the fetch.href column."))
      
    # append failed .urls to data frame, with some error flag
    df = df |> 
      dplyr::bind_rows(failed_hrefs)
    } else {
      cli::cli_alert_warning(paste(nrow(failed_hrefs),
                                   "failed data fetches were removed."))
    }

  }
  
  return(df)
  
}

