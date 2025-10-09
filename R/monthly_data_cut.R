#' Save or Read in monthly data cuts from a nominated API
#' 
#' Function to either fetch monthly data from the nominated API, flatten, remove candidate Scottish Candidate Numbers (SCN), encrypt and save in stated folder; or to read in previously encrypted data cuts for analysis.
#' 
#' @param .api name of API to work with. One of "Result", "AnalyticsResult" or SummaryResult"
#' 
#' @param .action "save" to fetch from AnalyticsResult API (taking roughly 1h30m per month) or "read" to load in encrypted data cuts
#' 
#' @param .folder directory location for the data cuts e.g "api_data_cuts/encrypted"
#' 
#' @param .start date of first month, written in "YYYY_MM" format
#' 
#' @param .end date of last month, written in "YYYY_MM" format
#'
#' @return depending on the .action parameter, this either saves an encrypted .rds file with no return; or reads in and returns a row-binded data frame of multiple months' data.
#'
#' @examples
#' \dontrun{
#' 
#' # fetch the AnalyticsResult API data for month of April 2025 and store the resulting encrypted file in a previously created folder called "temp"
#' 
#' monthly_data_cut(.api = "AnalyticsResult",
#'                  .action = "save",
#'                  .folder = "temp",
#'                  .start= "2025_04",
#'                  .end = "2025_04")
#' 
#' # read in the four months' encrypted AnalyticsResult data cuts from January 2025 to April 2025 inclusive, and store the single resulting data frame in `df`
#' 
#' df = monthly_data_cut(.api = "AnalyticsResult",
#'                       .action = "read",
#'                       .folder = "temp",
#'                       .start= "2025_01",
#'                       .end = "2025_04")
#' }
#' @export
#'

monthly_data_cut = function(.api, .action, .folder, .start, .end){
  
  # declare the API taking monthly data cuts from
  stopifnot('.api needs to be either "Result" or "AnalyticsResult" or "SummaryResult' = .api %in% c("Result", "AnalyticsResult", "SummaryResult"))
  
  
  # verify if .action is either "read" or "save"
  stopifnot('.action needs to be either "read" or "save"' = .action %in% c("read", "save"))
  
  # verify if .folder exists
  stopifnot('Provided .folder does not exist. Please check the pathway, or create the folder.' = file.exists(.folder))
  
  # verify if .start is in format YYYY_MM
  stopifnot('.start needs to be in "YYYY_MM" format' = stringr::str_detect(string = .start,
                                                                           pattern = "^\\d{4}_\\d{2}"))
  
  # verify if .end is in format YYYY_MM
  stopifnot('.end needs to be in "YYYY_MM" format' = stringr::str_detect(string = .end,
                                                                         pattern = "^\\d{4}_\\d{2}"))
  
  # extract year_start, month_start, year_end, month_end
  year_start = as.numeric(stringr::str_extract(string = .start,
                                               pattern = "^\\d{4}"))
  month_start = as.numeric(stringr::str_extract(string = .start,
                                                pattern = "\\d{2}$"))
  year_end = as.numeric(stringr::str_extract(string = .end,
                                             pattern = "^\\d{4}"))
  month_end = as.numeric(stringr::str_extract(string = .end,
                                              pattern = "\\d{2}$"))
  
  # create data frame of all YYYY_MM months between .start and .end
  data_months = tidyr::crossing(year = c(year_start:year_end),
                                month = c(1:12)) |> 
    dplyr::mutate(keep = dplyr::case_when(
      year == year_start ~ month >= month_start,
      TRUE ~ TRUE
    )) |> 
    dplyr::filter(keep) |> 
    dplyr::mutate(keep = dplyr::case_when(
      year == year_end ~ month <= month_end,
      TRUE ~ TRUE
    )) |> 
    dplyr::filter(keep) |> 
    dplyr::mutate(YYYY_MM = paste(year,
                                  stringr::str_pad(string = month,
                                                   width = 2,
                                                   pad = "0"),
                                  sep = "_")) |> 
    # generate full encrypted filenames for all required months
    dplyr::mutate(encrypted_filename = paste0(.folder,
                                              "/",
                                              .api,
                                              "_",
                                              YYYY_MM,
                                              "_encrypted.rds"))
  
  # routine to read in existing encrypted data_cuts from .folder
  if(.action == "read"){
    
    # display reassuring message
    cli::cli_alert_info(paste("Reading in data cuts from", nrow(data_months),"months. Please wait."))
    
    # purrr::map to read in each file, decrypt it
    all_months = purrr::map(.progress = TRUE,
                            .x = data_months$encrypted_filename,
                            .f = ~ httr2::secret_read_rds(path = .x,
                                                          key = charToRaw(Sys.getenv("surpass_data_cut_encrypt_key")))) |>
      purrr::list_rbind(names_to = "id") |>
      # add in first column of 'cut_month' to hold YYYY_MM
      dplyr::mutate(cut_month = data_months$YYYY_MM[id],
                    .before = tidyselect::everything(),
                    .keep = "unused")
    
    # return single data frame of all monthly cuts
    return(all_months)
  }
  
  # routine to fetch monthly data cut from API and save processed and encrypted .rds files in .folder
  if (.action == "save") {
    
    # prepare dates' format ready for $filter
    data_months = data_months |> 
      dplyr::mutate(start_date = paste0(month, "/01/", year),
                    month_days = lubridate::days_in_month(x = lubridate::mdy(start_date)),
                    end_date = ifelse(test = month < 12,
                                      yes = paste0(month + 1, "/01/", year),
                                      no = paste0("01/01/", year + 1))) |> 
      dplyr::select(start_date,
                    end_date,
                    encrypted_filename)
    
    # define function to fetch and save data in both raw and flattened versions
    monthly_fetch <- function(api, start, end, filename) {
      
      # display reassuring message of action being undertaken
      cli::cli_alert_info(paste("Processing data cut for", filename))
      
      # fetch data from API for the nominated month
      month_fetched = fetch_filter(
        .api = api,
        # general form for splicing together several different filter criteria
        .filter = paste0("$filter=",
                         paste(
                           # note: dates should be in MM/DD/YYYY format
                           "startedDate ge", start, # ge = "greater than"
                           "and",
                           "startedDate le", end # le = "less than"
                         )),
        # return all records for the selected month
        .max_return = Inf) |> 
        # fetch data from URL links in the 'href' column, using the "live" instance
        fetch_href()
      
      # save encrypted data flattened to depth of 1, with candidate.reference (SCN) removed
      cli::cli_alert_info("Flattening and saving encrypted .rds of fetched data.")
      httr2::secret_write_rds(x = month_fetched |> 
                                flatten_fetched() |> 
                                # remove candidate.reference (SCN)
                                dplyr::select(-candidate.reference),
                              path = filename,
                              key = charToRaw(Sys.getenv("surpass_data_cut_encrypt_key")))
      
    }
    
    # loop to execute each monthly data cut
    loop = purrr::pmap(.l = data_months,
                       \(start_date, end_date, encrypted_filename )
                       monthly_fetch(api = .api,
                                     start = start_date,
                                     end = end_date,
                                     filename = encrypted_filename))
    
  }
  
}