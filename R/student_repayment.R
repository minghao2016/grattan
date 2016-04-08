#' HELP / HECS repayment amounts
#' 
#' @name student_repayment
#' 
#' @param repayment_income The repayment income of the individual, equal to 
#' \deqn{{Taxable Income} + {Total net investment loss (incl Net rental loss)} + {reportable fringe benefits amounts} + {Reportable super contributions} + {exempt foreign income}}
#' @param fy.year The financial year \code{repayment_income} was earned.
#' @param debt The amount of student debt held.
#' @return The repayment amount.
#' @source \url{https://www.ato.gov.au/Rates/HELP,-TSL-and-SFSS-repayment-thresholds-and-rates/?page=2#HELP_repayment_thresholds_and_rates_2013_14}
#' @author Ittima Cherastidtham, Hugh Parsonage
#' @export

student_repayment <- function(repayment_income, fy.year, debt){
  # CRAN NOTE avoidance
  fy_year <- repayment_threshold <- liability <- repayment_rate <- ordering <- NULL
  stopifnot(debt >= 0, repayment_income >= 0)
  prohibit_vector_recycling(repayment_income, fy.year, debt)
  if (any(!is.fy(fy.year))){
    stop("fy.year need to be in form '2012-13'")
  } else {
    if (!all(fy.year %in% hecs_tbl$fy_year)){
      invalid_fys <- unique(fy.year[!fy.year %in% hecs_tbl$fy_year])
      stop("No data available for ", invalid_fys)
    }
  }
  input <- 
    data.table::data.table(repayment_income = repayment_income, 
                           # for join.
                           repayment_threshold = repayment_income, 
                           fy_year = fy.year, debt = debt) %>%
    # to preserve ordering
    dplyr::mutate(ordering = seq.int(1, .N, by = 1L)) %>%
    data.table::setkeyv(c("fy_year", "repayment_threshold"))
  
  # repayment rate applies to the entire repayment income (not that > threshold, as it is for general tax).
  # If the person's repayment rate extinguishes their debt, they only have to pay their debt back. This 
  # also ensure that those with 0 debt do not have any liability
  hecs_tbl[input, roll = Inf][ ,liability := pminV(repayment_rate * repayment_income, debt)][order(ordering)]$liability
}