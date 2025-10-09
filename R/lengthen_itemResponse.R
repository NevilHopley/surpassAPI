#' Lengthen data frame that contains item response data
#' 
#' Function to pivot longer on the different question types that are returned when using the `/itemResponse` API. This function returns a longer data frame than that provided, which includes the column `item_type` that records the type of item that the subsequent columns contain data upon.
#' 
#' @param .data data frame that contains multiple blocks of columns, one block for each question type
#' 
#' @return a data frame with fewer columns and more rows
#' 
#' @seealso [lengthen_fetched()]
#' 
#' @examples
#' \dontrun{
#' 
#' fetch_filter(.api = "AnalyticsResult",
#'              .filter = "",
#'              .max_return = 10) |>
#'   # extract the appropriate itemResponse hrefs by appending to the 'href' column's contents
#'   fetch_href(.append = "/ItemResponse") |>
#'   # fetch the data from the column 'href' using the "test" instance
#'   fetch_href() |>
#'   # deal with lists within columns, to the default depth of 1
#'   flatten_fetched() |>
#'   # reshape details for each item from wide to long, by question type
#'   lengthen_itemResponse()
#' }
#'
#' @export
#'

lengthen_itemResponse <- function(.data){
  
  .data |> 
    # pivot on all columns that do not contain 'href' in them
    tidyr::pivot_longer(cols = !tidyselect::contains("href"),
                        names_to = c("item_type", ".value"),
                        names_pattern = "(\\w+)\\.(\\w+)") |> 
    # remove surplus empty rows that hold no information
    tidyr::drop_na(type)
}