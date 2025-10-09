#' Flatten data frames that contain (nested) lists
#' 
#' Function to process the various lists that are within lists, to the specified depth of nested lists. For several contextual examples of the use of this function, see the code chunks in the HTML version of the package vignette.
#' 
#' Repeated application of the `flatten_fetched()` function is equivalent to changing the value of `.depth`. For example, ` |> flatten_fetched() |> flatten_fetched() |> flatten_fetched()` is the same as ` |> flatten_fetched(.depth = 3)`
#' 
#' @param .data the data frame that contains lists of lists
#' 
#' @param .depth positive integer to determine how many sub-lists of lists to unnest. Default value is 1.
#'
#' @return a data frame with more columns than previously, from unnesting lists. Rows where fetch.href was "fail" are not dropped.
#'
#' @export
#'

flatten_fetched <- function(.data,
                            .depth = 1){
  
  #stop processing if any parameter has an invalid value
  stopifnot('.depth needs to be a positive integer' = .depth %% 1 == 0 & .depth > 0)
  
  # unnest columns that are lists
  .df = .data |> 
    tidyr::unnest_wider(col = where(is.list),
                        names_sep = '.') |>
    # duplicate rows where lists have multiple values for any row
    tidyr::unnest(cols = tidyr::contains("\\."))
  
  # if more depths to unnest, then recursively call itself
  if(.depth > 1) {
    .df = flatten_fetched(.data = .df,
                          .depth = .depth - 1)}
  
  return(.df)
  
}

