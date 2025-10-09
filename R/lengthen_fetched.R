#' Lengthen data frame that has multiple, similar column names
#' 
#' Function to reshape a data frame after using `flatten_fetched()` when multiple column names differ by numerical insertions and suffixes. This functions returns a longer data frame than that provided, which includes the column `lengthen_id` that records the insertions and suffixes that used to be part of the column names that have been renamed with an underscore character at their end. #' For several contextual examples of the use of this function, see the code chunks in the HTML version of the package vignette.
#' 
#' @param .data data frame that contains multiple similar columns, differing by numerical insertions and suffixes
#' 
#' @param .na_rm name of column within which all rows containing NA values are removed.
#' 
#' @return a data frame with fewer columns and more rows. Rows where fetch.href was "fail" are removed (as they contain no data).
#' 
#' @seealso [lengthen_itemResponse()]
#' 
#' @export
#'

lengthen_fetched <- function(.data,
                             .na_rm = ""){
  
  # replace all .N with .0N (insert leading zero for single digits)
  names_with_zeros = stringr::str_replace_all(string = names(.data),
                                              pattern = "\\.(\\d)(\\.|$)",
                                              replacement = ".0\\1\\2")
  
  
  # replace all .NN with _NN
  names_with_underscores = stringr::str_replace_all(string = names_with_zeros,
                                                    pattern = "\\.(\\d+)",
                                                    replacement = "_\\1")
  
  # move all _NN and _NN to the end, keeping order
  # code searches for up to 6 numerical identifiers
  names_with_numbers_at_end = stringr::str_replace_all(string = names_with_underscores,
                                                       pattern = "^(\\D+)(_\\d+)*(\\D+)*(_\\d+)*(\\D+)*(_\\d+)*(\\D+)*(_\\d+)*(\\D+)*(_\\d+)*(\\D+)*(_\\d+)*(\\D+)*$",
                                                       replacement = "\\1\\3\\5\\7\\9\\11\\13\\2\\4\\6\\8\\10\\12")
  
  # over-write column names with new names
  names(.data) <- names_with_numbers_at_end
  
  .data |> 
    # find columns that end in up to 6 repetitions of '_NN' where N is a number and pivot them longer
    # store the removed repetitions of _NN or in new column `lengthen_id`
    # all trimmed columns are to the *right* of the 'lengthen_id' column and have _ at their end to indicate they were trimmed
    tidyr::pivot_longer(cols = dplyr::matches(match = "_(\\d+_*\\d*_*\\d*_*\\d*_*\\d*_*\\d*)$"),
                        # split column names into (at least one non-number)_(at least one number and possibly a second underscore number)
                        names_pattern = "^(\\D+_)(\\d+_*\\d*_*\\d*_*\\d*_*\\d*_*\\d*)",
                        names_to = c(".value", "lengthen_id"),
                        values_drop_na = TRUE,
                        names_repair = "unique"
    ) |> 
    # remove rows with NA in the 'na.rm' column
    {\(x) if(.na_rm != "") dplyr::filter(x, !is.na(get(.na_rm))) else x}()
}