#' @include Loader.R

#' @name cap_adjust
#' @title Adjusting fertility cap
#' @description
#' Function for adjusting fertility to its limits
#'
#' @param vector Numeric vector; age-specific fertility rates to adjust
#' @param bottom_cap Numeric; minimum total fertility rate (TFR). If the TFR falls below this value the ASFR schedule is scaled up (no default)
#' @param upper_cap Numeric; maximum total fertility rate (TFR). If the TFR exceeds this value the ASFR schedule is scaled down (no default)
#' @param in_thousands Logical; if TRUE, ASFRs are interpreted as rates per 1000 women (no default)
#' @returns Adjusted age specific fertility rates
#' @examples
#' cap_adjust(vector = c(1.1, 1.2, 1), bottom_cap = 1, upper_cap = 0.9, in_thousands = FALSE)
#' @noRd

cap_adjust <- function(vector, bottom_cap, upper_cap, in_thousands) {
  # Adjusting bottom cap of fertility

  if (is.numeric(bottom_cap) & !is.na(bottom_cap)) {
    if (in_thousands) {
      if (sum(vector) / 1000 < bottom_cap) {
        vector <- vector * bottom_cap / sum(vector) * 1000
      }
    } else {
      if (sum(vector) < bottom_cap) {
        vector <- vector * bottom_cap / sum(vector)
      }
    }
  }

  # Adjusting upper cap of fertility

  if (is.numeric(upper_cap) & !is.na(upper_cap)) {
    if (in_thousands) {
      if (sum(vector) / 1000 > upper_cap) {
        vector <- vector * upper_cap / sum(vector) * 1000
      }
    } else {
      if (sum(vector) > upper_cap) {
        vector <- vector * upper_cap / sum(vector)
      }
    }
  }
  return(vector)
}


#' @name percentage_fertility_change
#' @title Changing fertility by percent
#' @description
#' Function for changing age specific fertility rates by rate and adjusting them to their limits
#'
#' @param asfr Matrix; age-specific fertility rates with periods as rows and age groups as columns
#' @param rate Numeric; multiplicative rate of change applied to ASFRs each period (default 1 — no change)
#' @param bottom_cap Numeric; minimum TFR cap applied after scaling (default NA — no cap)
#' @param upper_cap Numeric; maximum TFR cap applied after scaling (default NA — no cap)
#' @returns Adjusted age specific fertility rates
#' @examples
#' percentage_fertility_change(asfr = asfr, rate = 1.1, bottom_cap = 2, upper_cap = 1.5)
#' @noRd

percentage_fertility_change <- function(asfr, rate = 1, bottom_cap = NA, upper_cap = NA) {
  # Checking if asfr are in thousands

  in_thousands <- FALSE

  if (sum(asfr[1, ]) > 50) {
    in_thousands <- TRUE
  }

  # Changing the asfr by rate and adjusting them to match the given cap

  for (period in 1:nrow(asfr)) {
    asfr[period, ] <- asfr[period, ] * rate
    asfr[period, ] <- cap_adjust(asfr[period, ], bottom_cap, upper_cap, in_thousands)
  }
  return(asfr)
}

#' @name flat_fertility_change
#' @title Changing fertility by value
#' @description
#' Function for changing age specific fertility rates by value and adjusting them to their limits
#'
#' @param asfr Matrix; age-specific fertility rates with periods as rows and age groups as columns
#' @param change Numeric; additive change in TFR applied each period (default 0 — no change)
#' @param bottom_cap Numeric; minimum TFR cap applied after the change (default NA — no cap)
#' @param upper_cap Numeric; maximum TFR cap applied after the change (default NA — no cap)
#' @returns Adjusted age specific fertility rates
#' @examples
#' flat_fertility_change(asfr = asfr, change = 0.05, bottom_cap = 2, upper_cap = 1.5)
#' @noRd

flat_fertility_change <- function(asfr, change = 0, bottom_cap = NA, upper_cap = NA) {
  # Checking if asfr are in thousands

  in_thousands <- FALSE

  if (sum(asfr[1, ]) > 50) {
    in_thousands <- TRUE
  }

  # Changing the asfr by value and adjusting them to match the given cap

  for (period in 1:nrow(asfr)) {
    if (in_thousands) {
      asfr[period, ] <- asfr[period, ] * (sum(asfr[period, ]) + change * 1000) / sum(asfr[period, ])
    } else {
      asfr[period, ] <- asfr[period, ] * (sum(asfr[period, ]) + change) / sum(asfr[period, ])
    }
    asfr[period, ] <- cap_adjust(asfr[period, ], bottom_cap, upper_cap, in_thousands)
  }
  return(asfr)
}

#' @name percentage_migration_change
#' @title Changing migration rates by percent
#' @description
#' Function for changing migration rates by rate and adjusting them to their limits
#'
#' @param mig_rates List of matrices; migration rates by period, as stored in a country object's `outmigration_rates` field
#' @param rate Numeric; multiplicative rate of change applied to all migration rates (default 1 — no change)
#' @returns Adjusted migration rates
#' @examples
#' percentage_migration_change(mig_rates = migration_rates, rate = 1.5)
#' @noRd

percentage_migration_change <- function(mig_rates, rate = 1) {
  # Changing the outmigration rates by rate

  for (i in seq_along(mig_rates)) {
    mig_rates[[i]] <- mig_rates[[i]] * rate
  }
  return(mig_rates)
}

#' @name convergence
#' @title Calculating convergence of fertility
#' @description
#' Function for calculating convergence of age specific fertility rates between religions
#'
#' @param fdlist List; fertility differential matrices indexed by period name, as stored in a country object's `fertility_differentials` field
#' @param steps Numeric; number of 5-year projection steps over which full convergence to uniform differentials is achieved. 0 disables convergence (default 0)
#' @param object_year Numeric; starting year of the current projection period (no default)
#' @returns Adjusted for convergence fertility differentials
#' @examples
#' convergence(fdlist = fertility_differentials, steps = 6, object_year = 2025)
#' @noRd
convergence <- function(fdlist, steps = 0, object_year) {
  if (steps == 0) {} else {
    year <- object_year + 5
    fd <- fdlist[[1]]

    # Applying convergence to fertility differentials

    for (i in 1:steps) {
      fd <- ((fd - 1) * (steps - i) / (steps - i + 1)) + 1
      fdlist <- append(fdlist, list("filler" = fd))
      names(fdlist)[length(fdlist)] <- paste(as.character(year), as.character(year + 5), sep = "-")
      year <- year + 5
    }
  }
  return(fdlist)
}
#' @name variants_loader
#' @title Calculate variant and create modified country_list_object
#' @description
#' Applies per-country variant settings (e.g. fertility convergence, migration
#' adjustments) from \code{\link{info_variants}} to the country objects stored
#' inside a projection object. Must be called after
#' \code{\link{create_projection_object}} and before \code{\link{project}}.
#' Calling it a second time on the same object is blocked unless \code{force = TRUE}.
#'
#' @param projection_object Projection_object; an unresolved projection object whose country objects will be modified by variant settings
#' @param country_info Data frame; variant settings for each country, typically `base_data_list$info_variants` (default `base_data_list[[10]]`)
#' @param force Logical, if TRUE loads a variant even if a variant has been already loaded. (default FALSE)
#' @returns The input \code{projection_object} with modified \code{country_object_list}.
#' @seealso
#' \code{\link{info_variants}} for a description of the variant settings table,
#' \code{\link{create_projection_object}} to create the object passed here,
#' \code{\link{project}} to run the projection after loading a variant.
#' \code{vignette("conducting-projections")} for a full walkthrough.
#' @examples
#' p_object <- create_projection_object(name = "test")
#' p_object <- variants_loader(projection_object = p_object)
#' @export variants_loader
variants_loader <- function(projection_object, country_info = base_data_list[[10]], force = FALSE) {
  if (projection_object$variant & !force) {
    print("Variant already loaded. To force second loading of variant use argument 'force' within variants_loader. Aborting.")
    return(projection_object)
  }
  for (object in projection_object$country_object_list) {
    # Pulling variants information from data_list

    country_code <- object$code
    country_single <- country_info[country_info[[2]] == country_code, ]
    fertility_rate <- dplyr::pull(country_single, 4)
    fertility_flat <- dplyr::pull(country_single, 5)
    bottom_cap <- dplyr::pull(country_single, 6)
    upper_cap <- dplyr::pull(country_single, 7)
    migration_rate <- dplyr::pull(country_single, 8)
    convergence_steps <- dplyr::pull(country_single, 9)
    fert_fact <- dplyr::pull(country_single, 10)

    # Applying fertility change by rate

    object$age_specific_fertility_rates <- percentage_fertility_change(
      object$age_specific_fertility_rates,
      fertility_rate,
      bottom_cap,
      upper_cap
    )

    # Applying fertility change by value

    object$age_specific_fertility_rates <- flat_fertility_change(
      object$age_specific_fertility_rates,
      fertility_flat,
      bottom_cap,
      upper_cap
    )

    # Applying outmigrations rates change

    object$outmigration_rates <- percentage_migration_change(
      object$outmigration_rates,
      migration_rate
    )

    # Applying convergence

    object$fertility_differentials <- convergence(
      object$fertility_differentials,
      convergence_steps, object$year
    )

    # Applying fertility factorization

    # 1 = combined (default), 2 = per age group; missing values fall back to combined
    object$combined_fertility_factorization <- length(fert_fact) == 0L || is.na(fert_fact) || fert_fact != 2
  }
  projection_object$variant <- TRUE
  print("Variant successfully loaded.")
  return(projection_object)
}


# rm(list = c("ccrow", "local_parameters"))
