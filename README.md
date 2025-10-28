surpassAPI
================

## Overview

This `surpassAPI` package contains a collection of R functions that fetch and wrangle assessment data from Surpass APIs.

You can view a 15 minute video from the 2025 Surpass International Conference about this package on [YouTube.](
https://youtu.be/iYAgIriy-kw)

## Installing

You can install the latest version of this package direct from Github. Note that this method requires access to GitHub and the
remotes package to be installed.

``` r
remotes::install_github(
  repo = "NevilHopley/surpassAPI",
  upgrade = "never",
  build_vignettes = TRUE
)

```

### Required Packages

The following R packages are a requirement for this package to function
and will be installed by default:

- httr2
- jsonlite
- stringr 
- purrr
- lubridate
- tidyr
- tidyselect
- cli

## Getting Started

Once installed, surpassAPI can be loaded using the library() function:

`library(surpassAPI)`

Help files for each function can be obtained by typing ?function_name into the RStudio console. For example:

`?fetch_filter()`

However, you are strongly recommended to read the next section's detailed descriptions of Surpass API structures and reviewing the example code using the functions.

This is the same information that is in the package's vignette


## Detailed User Information from the package's Vignette

This `surpassAPI` package contains a collection of R functions that support the fetching of assessment data from Surpass' Application Programming Interface (API). Some functions fetch the data from the API, whilst other functions reshape and process the information that has been fetched.

The functions called `fetch_filter()` and `fetch_href()` retrieve the data from the API, with no processing of the data performed.

The functions called `flatten_fetch()`, `lengthen_fetched()` and `lengthen_itemResponse()` do all of the required reshaping and processing of the fetched data.

The function called `monthly_data_cut()` is used to manage monthly data cuts from the AnalyticsResult API.

## Initial Setup

The Surpass API system requires authentication of the user before it will release any information. This authentication is in the form of a long alphanumeric key. For security reasons, this key is not included in this package, or in any scripts. You would obtain the alphanumeric key from your Surpass account administrator. The key is kept in a local R environment file on your laptop, where the fetching functions read it from.

In fact, there are two keys supported by this package: one for any "test" instance that you have available, and one for the "live" instance. The "test" instance of the API would contain fictional assessment data that has a similar structure to the "live" instance which is where real candidate assessment data for Surpass assessments resides.

The two keys are stored in the `.Renviron` file that should be in the following folder on your laptop:

`C:\Users\....\Documents`

The `.Renviron` file can be edited directly from within RStudio by using

`usethis::edit_r_environ()`

The `.Renviron` is a plain text file that may already contain other text, and the following two lines would need to be added to it (where the XXX's represent the real alphanumeric keys)

`surpass_test_api_key="Basic XXXXXXXXXXXXXXXXXXXXXXXXXXXXX"`

`surpass_live_api_key="Basic XXXXXXXXXXXXXXXXXXXXXXXXXXXXX"`

You can request the  keys from the Surpass account manager in your organisation.

In addition, there is a third key is used to encrypt and decrypt the monthly data cuts from the AnalyticsResults API. This key is also stored in `.Renviron" and it takes the form:

`surpass_data_cut_encrypt_key="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"`

This key can be of any alphanumeric length or structure that you desire. You can have a website generate a random key for you such as [this one](https://generate-random.org/encryption-key-generator)

Finally, you will also need to include in the `.Renviron` file the URL addresses used by your organisation to access Surpass assessment data (both 'live' and 'test' instances). These URLs will likely take the form of the two examples given below:

`surpass_test_url_stem="https://YOURTESTINSTANCE.surpass.com/api/v2/"`

`surpass_live_url_stem="https://YOURLIVEINSTANCE.surpass.com/api/v2/"`

If you change the `.Renviron` file, then to incorporate the changes you either need to restart RStudio desktop or re-load the `.Renviron` file, using:

`readRenviron("~/.Renviron")`


## The Application Programming Interfaces (APIs)

Instead of one API that delivers all assessment information, there are multiple APIs that all interconnect with one another. Listed below are the most useful API names, with hyperlinks to their Surpass technical guides and brief summaries of what they provide.

[Surpass Glossary](https://help.surpass.com/glossary/)

API Name | API Filters | Fetched Data | Fetched API links | 
---------|-------------|--------------|-------------------|
[Result](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/test-administration/result-api/) | subject/id <br> subject/reference <br> centre/id <br> centre/reference <br> test/id <br> test/reference <br> testForm/id <br> testForm/reference <br> candidate/id <br> candidate/reference <br> keycode <br> started date <br> submitted date <br> warehoused date | Available marks, viewing times, item type, date-time stamps, etc for the latest version of a result. There are four possible appendices to the fetched API href links that give access to further information (see items in bold, on the right) | HistoricalResult <br> User <br> RescoringRule <br> Test <br> TestForm <br> Subject <br> Centre <br> Candidate <br> **/ItemResponse** <br> **/CandidateInteractions** <br> **/ClientInformation** <br> **/StateChanges**|
[AnalyticsResult](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/reporting/analyticsresult-api/) | subject/id <br> subject/reference <br> centre/id <br> centre/reference <br> test/id <br> test/reference <br> testForm/id <br> testForm/reference <br> candidate/id <br> candidate/reference <br> keycode <br> applied date <br> started date <br> submitted date <br> warehoused date | Available marks, viewing times, item type, date-time stamps, etc for the latest version of a result. There is one possible appendix to the fetched API href links that gives access to further information (see item in bold, on the right) | HistoricalResult <br> User <br> RescoringRule <br> Test <br> TestForm <br> Subject <br> Centre <br> Candidate <br> **/ItemResponse** |
[Candidate](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/setup/candidate-api/) | firstName <br> middleName <br> lastName <br> dateOfBirth <br> gender <br> email <br> tel <br> reasonableAdjustments <br> retired <br> centres <br> subjects <br> tags | Same fields as available to filter on, links to other subjects studied, and centres enrolled at. | Centre <br> Subject |
[Centre](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/setup/centre-api/) | id <br> reference <br> name <br> randomiseTestForms <br> hideSubjectsIncludedInSubjectGroups <br> excludeItemStatistics | Centre name and address | Centre <br> County <br> Country |
[Item](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/item-authoring/item-api/) | name <br> itemType <br> subject/id <br> subject/reference <br> status | Item specification information and the text that would be displayed | Subject <br> ItemTagValue <br> User <br> ItemList |
[Subject](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/setup/subject-api/) | id <br> reference <br> name <br> status <br> deliveryType <br> htmlOnly <br> subjectMasterList <br> enableCheckboxesInItemAuthoring | Subject specification information | Centre |
[SummaryResult](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/test-administration/summaryresult-api/) | subject/id <br> subject/reference <br> centre/id <br> centre/reference <br> test/id <br> test/reference <br> testForm/id <br> testForm/reference <br> candidate/id <br> candidate/reference <br> keycode <br> markedExternally <br> includeExamsInMarking <br> started date <br> submitted date <br> warehoused date | awarded marks, available marks, final grade | Test <br> Subject <br> Centre <br> Candidate |
[Test](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/test-creation/test-api/) | reference <br> subject/id <br> subject/reference | High level details about a test specification. Appending '/TestForms' to the fetched API href links gives access to further information | Subject <br> **/TestForms** |
[TestForm](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/test-creation/testform-api/) | *no filters* | details of an individual test. Appending '/Section' to the fetched API href links gives access to further information | Subject <br> Test <br> **/Section** |
[HistoricalResult](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/reporting/historicalresult-api/) | subject/id <br> subject/reference <br> centre/id <br> centre/reference <br> test/id <br> test/reference <br> testForm/id <br> testForm/reference <br> candidate/id <br> candidate/reference <br> keycode | Contains every version of a result from, and the latest result can be accessed using the AnalyticsResult API. Appending '/ItemResponse' to the fetched API href links gives access to further information | User <br> RescoringRule <br> Test <br> TestForm <br> Subject <br> Centre <br> Candidate <br> **/ItemResponse** |
[TestSession](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/test-administration/testsession-api/) | candidate/id <br> candidate/reference <br> centre/id <br> centre/reference <br> test/id <br> test/reference <br> testForm/id <br> testForm/reference <br> scheduledTo <br> scheduledFrom <br>  state <br> showMarkingProgress <br> includeAdditionalInfo <br> showTestForm <br> showTest | Information on individual test sessions| Test <br> Centre <br> Candidate <br> TestForm |

There are many more APIs that also provide information:

[BasicPage](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/item-authoring/basicpage-api/)  
[CentreSubjectAssociation](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/setup/centresubjectassociation-api/)  
[Country](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/setup/country-api/)  
[County](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/setup/county-api/)  
[Folder](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/item-authoring/folder-api/)  
[ItemList](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/item-authoring/itemlist-api/)  
[ItemSet](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/item-authoring/itemset-api/)  
[ItemTagValue](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/item-authoring/itemtagvalue-api/)  
[Permission](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/setup/permission-api/)  
[Report](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/reporting/report-api/)  
[RescoringRule](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/reporting/rescoringrule-api/)  
[TagCategory](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/setup/tagcategory-api/)  
[TagCollectionGroup](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/setup/tagcollectiongroup-api/)  
[TagGroup](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/setup/taggroup-api/)  
[TagValue](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/setup/tagvalue-api/)  
[Task](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/tasks/task-api/)  
[TaskAttachment](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/tasks/taskattachment-api/)  
[TestProfile](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/test-creation/testprofile-api/)  
[User](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/setup/user-api/)  
[UserPermission](https://help.surpass.com/developer/surpass-api-v2/api-v2-reference/setup/userpermission-api/)  

There are even more APIs available(!), but they are mainly for setting up Tests and other administrative activities, and they generally do not provide analytical information.


## Description of the general process

The following steps are typically undertaken when requesting data from the Surpass APIs:

1. Use `fetch_filter()` to make an initial call to a specific API, using whatever filters you need.

2. The returned data frame will contain URL links to the data that is available which met the criteria of your filter. These URL links are typically in a column called `href`.

3. Use `fetch_href()` to actually fetch the required data from the API.

4. The returned data frame can often have lists of data in its columns, or even lists-of-lists of data that can go down to any level of nested depth. The un-nesting of these lists can be achieved by using `flatten_fetched()` 

5. One possible effect of using `flatten_fetched()` is the creation of a very wide data frame with multiple columns whose names have a common 'stem' to them, with either numerical insertions or suffixes, or both. Using `lengthen_fetched()` reshapes the data frame to be longer whilst keeping track of the numerical ID numbers that were within the original column names.

6. Depending on the initial API call and the number of URL links it returns, you may `fetch_href(.col = '...')` multiple times to create several data frames of related information, that can then be joined together to form a single, cohesive data frame. Thereafter, use of `dplyr::select()` can extract the required columns of data.

## Technical considerations

In addition to the above description of the general process, the following points should be considered:

- if the `fetch_filter()` and `fetch_href()` functions are used on the "test" instance of fictional assessment data, then `.instance = "test"` needs to be explicitly included in each and every function call. This ensures that the correct authentication key is used. The default setting is "live" and so the argument of `.instance = "live"` can be omitted from the function calls.

- when using `fetch_filter()` and including a filter on dates, you will likely use 'ge' and 'le' to indicate periods of time between two dates. Here 'ge' means 'greater than or equal to', but 'le' means 'strictly less than' (and **not** 'less than or equal to').

- the `fetch_href()` function has a `.fails` parameter (either "keep" or "drop") to keep track of any hrefs that returned errors such as 'HTTP 400 Bad Request'. Such errors can arise if Surpass API hrefs provided by `fetch_filter()` turn out to be invalid or expired.

- after fetching data from an API, you should interrogate the data frame using the **Environment pane** of RStudio Desktop. This will enable you to see most clearly the structure of the data frame, in terms of the depth of lists that it contains. If you only `View(...)` your data frame, you may only see the single upper layer of lists (indicated by a single '$' sign in the column name)

- there is a default limit within R on the number of recursive function calls that can be made. This limit therefore means that attempts to fetch more than 60,000 records from an API will fail. To avoid this problem, consider using different filter values, or change the value of the `.max_return` parameter.

- after scrutiny of the data frame, if lists exist within lists then use the `.depth` argument of the `flatten_fetched()` function to specify to what depth to extract these lower leveled lists. The initial default value is `.depth = 1` and this can be increased steadily to larger integer values, where required.

- repeated application of the `flatten_fetched()` function is equivalent to changing the value of `.depth`. For example, ` |> flatten_fetched() |> flatten_fetched() |> flatten_fetched()` is the same as ` |> flatten_fetched(.depth = 3)`

- if you obtain lots of column names with numerical insertions or suffixes, then be aware they they may not all hold the same type of data (numeric, character, more lists, etc). If this happens, then `lengthen_fetched()` will return an error as different types cannot be mixed within the same column. The solution to this is to use `flatten_fetched(.depth = N)` with incrementally larger values of `N` until it gives rise to data types that can be joined in the same column, thereby allowing `lengthen_fetched()` to work.

- for `fetch_filter()`, the default value of the `.return` argument is "newest" when used in conjunction with setting a value for `.max_return`. This ensures that when a subset of data is returned from the API, is it the most recent. Errors can occur if the "oldest" data is returned because it may contain references to other data, such as specific Tests or TestForms that no longer exist as they have been deleted in favour of newer versions. The typical error message when this happens is 'HTTP 400 Bad Request'.

## Other functions

`fetch_each_page()` is a function used by `fetch_filter()` which retrieves the initial data request in pages of 40 results at a time. 40 is the maximum number of rows of data that can be downloaded at a time, and this limit has been put in place by the Surpass API. Users should not need to make direct use of the `fetch_each_page()` function.

`lengthen_itemResponse()` is a special function for dealing with the information returned when making a request of the AnalyticsResult API after appending '/ItemResponse' to the href. Typically this will be required to be used after running code that may look something like this: 

```{r eval = FALSE}
fetch_filter(.api = "AnalyticsResult",
             .filter = "",
             .max_return = 10) |>
  # extract the appropriate itemResponse hrefs by appending to the 'href' column's contents
  fetch_href(.append = "/ItemResponse") |>
  # fetch the data from the column 'href' using the "test" instance
  fetch_href() |>
  # deal with lists within columns, to the default depth of 1
  flatten_fetched() |>
  # reshape details for each item from wide to long, by question type
  lengthen_itemResponse()
```

`format_interval()` returns time-interval information in either seconds, minutes or HH:MM:SS format from initial inputs of a start date-time and an end date-time. This function can be used to determine how long a candidate took to complete an assessment.

`monthly_data_cut()` performs two functions: 

- it can fetch multiple monthly data cuts from the Result API, the AnalyticsResult API or the SummaryResult API. Depending on the volume of assessment data being processed each month, be warned that each month's data cut can take in excess of 1 hour to be fetched. These data cuts are initially flattened to a depth of 1, then the candidate.reference field is removed as it captures your organisations unique Candidate Number for the candidate, and then they are encrypted with the `surpass_data_cut_encrypt_key` and saved as an .rds file. 

- it can read in previously fetched monthly data cuts in order to decrypt them and then row bind them into a single data frame, ready for analysis. Each month's data cut can take between 5 and 25 seconds (depending on the number of records) to be read in from a local C: drive folder, and prepared.

Note that some assessments on Surpass require manual human marking, and this can be completed during the 90 days (or whatever time duration your organisation has agreed with Surpass) after a candidate submits their work. Hence, the last 4 months' data cuts may still be subject to change.

## Example Code Chunks

To help see the functions within this package being used within a context, the following code chunks demonstrate many of the above processes and technical considerations in action, and they are fully commented.

You are recommended to copy these example code chunks into their own R scripts and step through them line by line. Your focus can be on the structures and content of the data frames both before and after each of the package's functions are applied.

### Retrieve all subjects which have assessments on Surpass

```{r eval = FALSE}

subject_index = fetch_filter(.api = "Subject",
                             .filter = "$filter=id ge 0")

```

### Extract all candidates registered at a Centre, using the "test" instance

```{r eval = FALSE}

surpass_data = fetch_filter(.api = "Candidate",
                            # filter by the centre reference number equalling '12345678'
                            .filter = "$filter=centres/any(c/reference eq 12345678)",
                            .instance = "test") |> 
  # fetch the data from the column 'href' using the "test" instance
  fetch_href(.instance = "test") |> 
  # to access those candidates registered at more than one centre, go to depth 2
  flatten_fetched(.depth = 2) |> 
  # pivot longer for those candidates registered at more than one centre
  lengthen_fetched(.na_rm = "centres.id_") |> 
  # select only those columns required
  dplyr::select(`Candidate User Name` = reference,
                `Candidate First Name` = firstName,
                `Candidate Middle Name` = middleName,
                `Candidate Last Name` = lastName,
                `Candidate Date of Birth` = dateOfBirth,
                `Candidate Gender` = gender,
                `Candidate Email` = email,
                `Candidate Reasonable Adjustments` = reasonableAdjustments,
                `Candidate Retired?` = retired,
                `Candidate Expiry Date` = expiryDate,
                `Centre Number` = centres.reference_,
                `Centre API` = centres.href_,
                `Candidate Reasonable Adjustment Percentage` = reasonableAdjustmentPercentage)

```

### Extract Summary Information of Candidates Performance, using the "test" instance

```{r eval = FALSE}

initial_data = fetch_filter(
  .api = "SummaryResult",
  # filter by subject, centre and startDate
  .filter = "$filter=subject/id eq 3 and centre/id eq 2 and startedDate ge 01/01/2022",
  .instance = "test") |> 
  # fetch the data from the column 'href' using the "test" instance
  fetch_href(.instance = "test") |> 
  # deal with lists within lists for candidate and test href data
  flatten_fetched()

# fetch candidate data from API
candidate_data = initial_data |> 
  # fetch the data from the column 'candidate.href' using the "test" instance
  fetch_href(.col = "candidate.href",
             .instance = "test") |> 
  # deal with lists within lists, to the default depth of 1
  flatten_fetched()

# fetch candidate data from API
test_data = initial_data |> 
  # fetch the data from the column 'test.href' using the "test" instance
  fetch_href(.col = "test.href",
             .instance = "test") |> 
  # deal with lists within lists, to the default depth of 1
  flatten_fetched()

# join all the API data extractions
all_data = initial_data |> 
  dplyr::left_join(y = candidate_data,
                   by = dplyr::join_by(candidate.href == href)) |> 
  dplyr::left_join(y = test_data,
                   by = dplyr::join_by(test.reference == reference)) |> 
  dplyr::select(`Test Name`= name,
                `Test Reference` = test.reference,
                Keycode = reference.x,
                `Candidate Reference` = candidate.reference,
                `Candidate First Name` = firstName,
                `Candidate Last Name` = lastName,
                Mark = mark,
                Grade = grade,
                `Start Date` = startedDate,
                `Finish Date` = submittedDate)

```

### Retrieve candidates' results for assessments completed between two specified dates

```{r eval = FALSE}

initial_data = fetch_filter(
  .api = "AnalyticsResult",
  # general form for splicing together several different filter criteria
  .filter = paste0("$filter=",
                   paste(
                     # note: dates should be in MM/DD/YYYY format
                     "startedDate ge 03/10/2025", # ge = "greater than"
                     "startedDate le 03/17/2025", # le = "less than"
                     sep = " and ")),
  # limit returns to the 100 newest in the time interval
  .max_return = 100) |> 
  # fetch data from URL links in the 'href' column, using the "live" instance
  fetch_href() |> 
  # deal with lists within lists for candidate, test and subject href data
  flatten_fetched()

candidate_data = initial_data |> 
  # fetch the data from the column 'candidate.href' using the "live" instance
  fetch_href(.col = "candidate.href") |> 
  # deal with lists within columns to the default depth of 1
  flatten_fetched()

test_data = initial_data |> 
  # fetch the data from the column 'test.href' using the "live" instance
  fetch_href(.col = "test.href") |> 
  # deal with lists within columns to the default depth of 1
  flatten_fetched()

subject_data = initial_data |> 
  # fetch the data from the column 'subject.href' using the "live" instance
  fetch_href(.col = "subject.href") |> 
  # deal with lists within columns to the default depth of 1
  flatten_fetched()

centre_data = initial_data |> 
  # fetch the data from the column 'centre.href' using the "live" instance
  fetch_href(.col = "centre.href") |> 
  # deal with lists within columns to the default depth of 1
  flatten_fetched()

# join all the API data extractions
all_data = initial_data |> 
  dplyr::left_join(y = candidate_data,
                   by = dplyr::join_by(candidate.href == join.href),
                   suffix = c("", ".candidate")) |> 
  dplyr::left_join(y = test_data,
                   by = dplyr::join_by(test.href == join.href),
                   suffix = c("", ".test")) |> 
  dplyr::left_join(y = subject_data,
                   by = dplyr::join_by(subject.href == join.href),
                   suffix = c("", ".subject")) |> 
  dplyr::left_join(y = centre_data,
                   by = dplyr::join_by(centre.href == join.href),
                   suffix = c("", ".centre")) |> 
  # calculate the duration of the assessment
  dplyr::mutate(timeTaken = format_interval(.start = startedDate,
                                            .end = submittedDate,
                                            .format = "m")) |> 
  # select only the required columns
  dplyr::select(`Subject Name` = name.subject,
                `Subject Reference` = subject.reference,
                `Test Name`= name,
                `Test Reference` = test.reference,
                `Centre Name` = name.centre,
                `Centre Reference` = reference.centre,
                `Candidate First Name` = firstName,
                `Candidate Last Name` = lastName,
                `Candidate Date of Birth` = dateOfBirth,
                `Candidate Reference` = candidate.reference,
                Keycode = reference,
                Mark = mark,
                `Marks available` = availableMarks,
                Percentage = percentageMark,
                Result = grade,
                `Test Duration` = allowedDuration,
                `Reasonable Adjustments Duration` = reasonableAdjustments.totalTimeAdded,
                `Reasonable Adjustments Reason` = reasonableAdjustments.reasonForAdjustment,
                `Started Date/Time` = startedDate,
                `Submitted Date/Time` = submittedDate,
                `Test Time Taken` = timeTaken)

```

### Detect assessments that require manual marking before they become invalid

Background information: When an assessment is attempted on Surpass, and it requires manual marking, then this must be completed within 90 days (or whatever your oranisation has set as the limit). The following code chunk first identifies all those assessments that require marking as they are within the 90 day limit, and then it shortlists it to those that still have 30 days remaining before the assessment result is void. If an assessment is void, then the candidate would have to reattempt the assessment.

```{r eval = FALSE}

# enter time until auto voided,
auto_void_time = 90

# enter period of notice until void
reminder_time = 30

initial_data <- fetch_filter(
  .api = "TestSession",
  # this vector of filters will ultimately be collapsed together using the '&' separator
  .filter = c("showMarkingProgress=true",
              "includeAdditionalInfo=true",
              "showTestForm=true",
              "showTest=true")) |> 
  # deal with lists within columns to the default depth of 1.
  flatten_fetched()

testSession_data = initial_data |> 
  # fetch the data from the column 'href' using the "live" instance
  fetch_href() |> 
  # deal with lists within columns to the default depth of 1
  flatten_fetched() |> 
  # determine which tests are within the reminder_time of the auto_void date using the current system date
  dplyr::mutate(
    sDate = as.Date(testActivatedInfo.submittedDate),
    `Date Test Submitted` = format.Date(x = sDate,
                                        format = "%d/%m/%Y"),
    `Auto Void Date` = format.Date(x = sDate + lubridate::days(auto_void_time),
                                   format = "%d/%m/%Y"),
    `Reminder Date` = format.Date(x = sDate + lubridate::days(auto_void_time - reminder_time),
                                  format = "%d/%m/%Y"),
    `Send Reminder` = sDate + lubridate::days(auto_void_time - reminder_time) < Sys.Date()) |> 
  # only keep those testSessions that need a 30 day reminder sent
  dplyr::filter(`Send Reminder` == TRUE)

# only keep testSessions that are getting close to their auto void date
href_to_keep = testSession_data |> 
  dplyr::pull(join.href)

# filter all testSessions down to just those that are due a reminder
initial_data = initial_data |> 
  dplyr::filter(href %in% href_to_keep)

testForm_data = initial_data |>
  # fetch the data from the column 'testForm.href' using the "live" instance
  fetch_href(.col = "testForm.href") |> 
  # deal with lists within columns to the default depth of 1
  flatten_fetched()

subject_data = testForm_data |> 
  # fetch the data from the column 'subject.href' using the "live" instance
  fetch_href(.col = "subject.href")

# join testForm and subject data extractions
testForm_subject_data = dplyr::left_join(x = testForm_data,
                                         y = subject_data,
                                         by = dplyr::join_by(subject.href == join.href),
                                         suffix = c(".testForm", ".subject"))

candidate_data = initial_data |> 
  # fetch the data from the column 'candidate.href' using the "live" instance
  fetch_href(.col = "candidate.href")

centre_data = initial_data |> 
  # fetch the data from the column 'centre.href' using the "live" instance
  fetch_href(.col = "centre.href")

# join all the API data extractions
all_data = initial_data |> 
  dplyr::left_join(y = testSession_data,
                   by = dplyr::join_by(href == join.href),
                   suffix = c("", ".testSession")) |> 
  dplyr::left_join(y = candidate_data,
                   by = dplyr::join_by(candidate.href == join.href),
                   suffix = c("", ".candidate")) |> 
  dplyr::left_join(y = centre_data,
                   by = dplyr::join_by(centre.href == join.href),
                   suffix = c("", ".centre")) |> 
  dplyr::left_join(y = testForm_subject_data,
                   by = dplyr::join_by(testForm.href == join.href),
                   suffix = c("", ".testForm.subject")) |> 
  # select only the required columns
  dplyr::select(`Subject Name` = name.subject,
                `Test Name` = test.name,
                `Test Reference` = test.reference,
                `Test Form Name` = testForm.name,
                `Test Form Reference` = testForm.reference,
                `Keycode` = keycode,
                `Test State` = testState,
                `Candidate First Name` = firstName,
                `Candidate Last Name` = lastName,
                `Candidate Reference` = candidate.reference,
                `Centre Name` = name,
                `Centre Reference` = centre.reference,
                `Date Test Submitted`,
                `Auto Void Date`,
                `Reminder Date`,
                `Send Reminder`)

```

### Obtain item-level data on candidates who have attempted an assessment for a given Subject

```{r eval = FALSE}

# obtain the subject reference from the subject_index data frame, generated by the very first example code chunk given in this vignette guide.
subject_reference = "YOUR SUBJECT REFERENCE"

analytics_data = fetch_filter(
  .api = "AnalyticsResult",
  .filter = paste0("$filter=subject/reference eq ",
                   subject_reference),
  # limit returns to the 50 newest
  .max_return = 50) |> 
  # fetch the data from the column 'href' using the "live" instance
  fetch_href() |> 
  # depth set to at least 4 in order to gain access to items' availableMarks
  flatten_fetched(.depth = 5) |> 
  # pivot longer on any column with text.N or text.N.text.N
  lengthen_fetched()

# get candidate name and details
candidate_data = analytics_data |> 
  # fetch the data from the column 'candidate.href' using the "live" instance
  fetch_href(.col = "candidate.href") |> 
  # select only the required columns
  dplyr::select(join.href,
                reference,
                firstName, 
                lastName,
                gender)

candidate_item_data = analytics_data |> 
  # ensure data type is numeric to support arranging it in numerical
  dplyr::mutate(sections.items.displayNumber_  = as.numeric(sections.items.displayNumber_)) |> 
  # select only the required columns
  dplyr::select(join.href,
                subject.reference,
                subject.name,
                test.name,
                test.href,
                testForm.href,
                centre.reference,
                centre.href,
                candidate.reference, # this is their SCN number
                candidate.href, # to support the joining of data frames
                testMark = mark,
                testAvailableMarks = availableMarks,
                testGrade = grade,
                startedDate,
                submittedDate,
                allowedDuration,
                lengthen_id,
                sections.items.unit_,
                sections.items.surpassReference_,
                sections.items.awardedMark_,
                sections.items.availableMarks_,
                sections.items.viewingTime_,
                sections.items.marker_,
                sections.items.displayNumber_,
                sections.items.type_) |>
  # filter out 'InformationPage' and only keep 'Question'
  dplyr::filter(sections.items.type_ != "InformationPage") |> 
  # for each candidate's attempt, arrange by item order within each test
  dplyr::arrange(candidate.reference,
                 submittedDate, # in case they had multiple attempts at same test
                 lengthen_id, # to put sections in sequential order
                 sections.items.marker_,
                 sections.items.displayNumber_) |> 
  # join with candidate name data
  dplyr::left_join(y = candidate_data,
                   by = dplyr::join_by(candidate.href == join.href,
                                       candidate.reference == reference)) |> 
  # re-order columns to put candidates' names next to their SCN
  dplyr::relocate(c(firstName, lastName, gender),
                  .after = candidate.reference)

# as a further stage, could also explicitly cite the question number order by using: dplyr::group_by(candidate.reference, submittedDate) |> dplyr::mutate(question_order = dplyr::row_number())

```

### Fetch monthly data cuts from AnalyticsResult API

```{r eval = FALSE}

# this example will fetch the months of April, May and June 2025 and store the resulting encrypted files in a previously created folder called "temp". The filenames will become "AnalyticsResult_2025_MM_encrypted.rds"

# be warned that this code chunk could take several hours to complete, depending on the volume of monthly assessments and the numbers of months requested

monthly_data_cut(.api = "AnalyticsResult",
                 .action = "save",
                 .folder = "temp",
                 .start= "2025_04",
                 .end = "2025_06")
```

### Read in several monthly data cuts that were originally fetched from AnalyticsResult API

```{r eval = FALSE}

# this example will read in the AnalyticsResult data cuts for the months of January 2025 to April 2025 inclusive, and store the resulting data frame in `monthly_cuts`

monthly_cuts = monthly_data_cut(.api = "AnalyticsResult",
                                .action = "read",
                                .folder = "temp",
                                .start= "2025_01",
                                .end = "2025_04")

```

### Read in several monthly data cuts that were originally fetched from AnalyticsResult API and re-instate Candidate SCN information.

```{r eval = FALSE}

# this example will read in the AnalyticsResult data cuts for the months of January 2025 to April 2025 inclusive, fetch the information on candidates, and merge together to create a single data frame

monthly_cuts = monthly_data_cut(.api = "AnalyticsResult",
                                .action = "read",
                                .folder = "temp",
                                .start= "2025_01",
                                .end = "2025_04")

candidate_data = monthly_cuts |> 
  fetch_href(.col ="candidate.href")

merged_data = monthly_cuts |> 
  dplyr::left_join(y = candidate_data,
                   by = dplyr::join_by(candidate.href == join.href),
                   suffix = c("", ".candidate"))
```



## Using surpassAPI

At present, this package is maintained by Nevil Hopley.

This package has primarily been developed for use by the Scottish Qualifications Authority Data & Analytics team. However, its contents may be useful more widely. As such, suggestions and contributions are welcome.

