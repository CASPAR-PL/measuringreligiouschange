#' @include class_base.R

#' @name Country_object
Country_object$methods(
  #' @name Country_object$update_period
  #' @noRd
  update_period = function() {
    period <<- paste(as.character(year), as.character(year + 5), sep = "-")
  },

  #' @name Country_object$calculate_total_previous
  #' @noRd
  calculate_total_previous = function(switching, migration) {
    add_total <- function(dt, by_cols, period_col) {
      if (!is.data.table(dt) || nrow(dt) == 0L) {
        return(dt)
      }
      cur_val <- if (period_col == "Period") period else year
      curr <- dt[get(period_col) == cur_val]
      earlier <- dt[get(period_col) != cur_val]
      rel_cols <- setdiff(names(curr), c(by_cols, "Structure"))
      totals <- curr[, lapply(.SD, sum, na.rm = TRUE), by = by_cols, .SDcols = rel_cols]
      totals[, Structure := "total"]
      setcolorder(totals, names(curr))
      data.table::rbindlist(list(earlier, totals, curr), use.names = TRUE, fill = TRUE)
    }

    # Rates cannot be summed across structures. The total ASFR is the
    # exposure-weighted mean of the structure rates (= total births / total
    # exposure). Where exposure is zero the realised rate is undefined and is
    # reported as 0 (as in the May 2026 output); only *_post_switch columns,
    # which are empty until switching occurs, fall back to the unweighted mean
    # of the applied structure rates. TFR is the sum over age groups.
    add_total_asfr <- function(asfr, expo) {
      if (!is.data.table(asfr) || nrow(asfr) == 0L) {
        return(asfr)
      }
      meta <- c("Country", "Country_code", "Period", "Mother_age_group", "Structure", "Region")
      curr <- asfr[Period == period]
      earlier <- asfr[Period != period]
      rel_cols <- setdiff(names(curr), meta)
      rates <- curr[Mother_age_group != "TFR"]
      e <- expo[Period == period & Structure != "total"]
      e <- e[match(
        paste(rates$Mother_age_group, rates$Structure),
        paste(e$Mother_age_group, e$Structure)
      )]

      by_cols <- c("Country", "Country_code", "Period", "Mother_age_group", "Region")
      totals <- unique(rates[, ..by_cols])
      grp <- match(
        do.call(paste, rates[, ..by_cols]),
        do.call(paste, totals)
      )
      for (col in rel_cols) {
        r <- rates[[col]]
        w <- e[[col]]
        w[is.na(w)] <- 0
        w_sum <- tapply(w, grp, sum)
        weighted <- tapply(r * w, grp, sum) / w_sum
        fallback <- if (endsWith(col, "_post_switch")) tapply(r, grp, mean) else 0
        data.table::set(totals, j = col, value = as.numeric(ifelse(w_sum > 0, weighted, fallback)))
      }
      totals[, Structure := "total"]
      tfr <- totals[, lapply(.SD, sum), by = c("Country", "Country_code", "Period", "Structure", "Region"), .SDcols = rel_cols]
      tfr[, Mother_age_group := "TFR"]
      totals <- data.table::rbindlist(list(totals, tfr), use.names = TRUE)
      setcolorder(totals, names(curr))
      data.table::rbindlist(list(earlier, totals, curr), use.names = TRUE, fill = TRUE)
    }

    previous_mortality <<- add_total(
      previous_mortality,
      c("Country", "Country_code", "Period", "Sex", "Age_group", "Region"),
      "Period"
    )
    previous_fertility <<- add_total(
      previous_fertility,
      c("Country", "Country_code", "Period", "Mother_age_group", "Region"),
      "Period"
    )
    previous_fertility_exposure <<- add_total(
      previous_fertility_exposure,
      c("Country", "Country_code", "Period", "Mother_age_group", "Region"),
      "Period"
    )
    previous_asfr <<- add_total_asfr(previous_asfr, previous_fertility_exposure)

    if (switching) {
      has_sex <- is.data.table(previous_switching) &&
        "Sex" %in% names(previous_switching)
      sw_by <- if (has_sex) {
        c("Country", "Country_code", "Period", "Sex", "Age_group", "Origin_religion", "Region")
      } else {
        c("Country", "Country_code", "Period", "Origin_religion", "Region")
      }
      previous_switching <<- add_total(previous_switching, sw_by, "Period")
    }

    if (migration) {
      has_sex_em <- is.data.table(previous_emigration) &&
        "Sex" %in% names(previous_emigration)
      em_by <- if (has_sex_em) {
        c("Origin", "Country_code", "Period", "Destination", "Sex", "Age_group", "Region")
      } else {
        c("Origin", "Country_code", "Period", "Destination", "Region")
      }
      previous_emigration <<- add_total(previous_emigration, em_by, "Period")

      has_sex_im <- is.data.table(previous_immigration) &&
        "Sex" %in% names(previous_immigration)
      im_by <- if (has_sex_im) {
        c("Destination", "Country_code", "Period", "Origin", "Sex", "Age_group", "Region")
      } else {
        c("Destination", "Country_code", "Period", "Origin", "Region")
      }
      previous_immigration <<- add_total(previous_immigration, im_by, "Period")
    }
  }
)
