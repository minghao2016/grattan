#' Australian estimated resident population by age and date
#' @param date A vector of dates. If \code{NULL}, values for all dates are returned in a table. The dates need not be quarters, provided \code{roll != FALSE}, 
#' @param age A vector of (integer) ages from 0 to 100 inclusive. If \code{NULL}, all ages are returned.
#' @param tbl Should a table be returned? If \code{FALSE}, a vector is returned.
#' @param roll Should a rolling join be performed? 
#' @param roll.beyond Should inputs be allowed to go beyond the limits of data (without a warning)?
#' This is passed to \code{data.table}'s join, so options other than \code{TRUE} and \code{FALSE} are available. 
#' See \code{?data.table}.
#' @return A \code{data.table} or \code{vector} with values of the estimated resident population.
#' @examples 
#' aus_pop_qtr_age(date = as.Date("2016-01-01"), age = 42)
#' @export 

aus_pop_qtr_age <- function(date = NULL, age = NULL, tbl = FALSE, roll = TRUE, roll.beyond = FALSE){
  if (!is.null(date)){
    stopifnot(all(lubridate::is.Date(date)))
  }
  
  if (!is.null(age)){
    stopifnot(is.numeric(age),
              all(age >= 0), 
              all(age <= 100))
  }
  
  if (!identical(roll, FALSE) && !roll.beyond && isTRUE(date > max(aust_pop_by_age_yearqtr$Date) || date < min(aust_pop_by_age_yearqtr$Date))){
    warning("Rolling join used beyond the limit of data.")
  }
  # CRAN note avoidance
  Date <- Age <- Value <- NULL
  if (is.null(date)){
    if (is.null(age)){
      out <- aust_pop_by_age_yearqtr
    } else {
      out <- aust_pop_by_age_yearqtr[Age %in% age]
    }
  } else {
    if (is.null(age)){
      input <-
        data.table(Date = date, 
                   Age = 1:100) %>%
        .[, ordering := 1:.N] %>%
        setkey(Age, Date)
      
      out <-
        aust_pop_by_age_yearqtr[input, roll = roll] %>%
        setorderv("ordering")
    } else {
      ordering <- NULL
      input <-
        data.table(Date = date,
                   Age = age) %>%
        .[, ordering := 1:.N] %>%
        setkey(Age, Date)
      
      out <-
        aust_pop_by_age_yearqtr[input, roll = roll] %>%
        setorderv("ordering")
    }
    out[, ordering := NULL]
  }

  if (tbl){
    return(out[])
  } else {
    return(out[["Value"]])
  }
}
