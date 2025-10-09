#' Format a time duration into seconds, minutes or HH:MM:SS
#' 
#' Function to take two input date-times and output the duration between them in HH:MM:SS format.
#'
#' @param .start a date-time in format YYYY-MM-DDTHH:MM:SS.SSS
#' 
#' @param .end a date-time in format YYYY-MM-DDTHH:MM:SS.SSS
#' 
#' @param .format "s" (the default) for seconds, or "m" for minutes, or "hms" for HH:MM:SS
#'
#' @return either a numerical value or a character string, depending on the chosen .format parameter
#'
#' @examples
#' \dontrun{
#' # calculate the duration of the assessment to the nearest minute
#' dplyr::mutate(timeTaken = format_interval(.start = startedDate,
#'                                           .end = submittedDate,
#'                                           .format = "m"))
#' }
#'
#' @export
#'
#'

format_interval <- function(.start,
                            .end,
                            .format = "s") {
  
  stopifnot('.format needs to be either "s" or "m" or "hms"' = .format %in% c("s", "m", "hms"))
  
  .gap <- as.integer(round(
    lubridate::as.period(
      lubridate::interval(.start,
                          .end),
      unit = "second")))
  
  if(.format == "s") return(.gap)
  if(.format == "m") return(janitor::round_half_up(.gap / 60, digits = 0))
  if(.format == "hms") return(sprintf(fmt = '%02i:%02i:%02i', .gap %/% 3600, .gap %/% 60 %% 60, .gap %% 60))
}