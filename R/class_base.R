# Labels for mortality
rnames_mortality <- c()
for (sex in c("males", "females")) {
  for (age in c(0, 1, seq(from = 5, to = 95, by = 5))) {
    rnames_mortality <- c(
      rnames_mortality,
      paste(sex, as.character(age), sep = " ")
    )
  }
}

#' @title Reference Class representing a country as Country_object
#' @description
#' Object representing demographic and model-specific information for a single country used in the MRC projection framework.
#'
#' Each country object contains demographic inputs and parameters that define fertility, mortality, migration, and religious switching dynamics, as well as country-specific settings used for scenario projections.
#'
#' @details
#' Country_object stores initial and projected data, specific options and results of the MRC projection for each country.
#' @examples
#' \dontrun{
#' obj <- test_object_generator(object_name = "example")
#' # Access a country object by its c-prefixed ISO key
#' co <- obj$country_object_list[["c840"]]
#' co$name # "USA"
#' co$code # 840
#' dim(co$structure_data[[1]]) # 40 x 7
#' }
#'
#' @export
Country_object <- methods::setRefClass("Country_object",


  #' @field year Numeric; current projection year, advances by 5 at each step
  #' @field period Character; current five-year period label used in previous_* output tables (e.g. "2020-2025")
  #' @field name Character; name of the country
  #' @field code Numeric; ISO 3166-1 country code
  #' @field region Character; name of the region to which the country belongs
  #' @field structure_data List; population structure matrices indexed by year label. Before `project()` is called, contains only the starting period
  #' @field mortality_rates Matrix; age- and sex-specific survival rates for each projection period (rows = sex-age groups, cols = periods)
  #' @field age_specific_fertility_rates Matrix; total population ASFRs for each projection period (rows = periods, cols = age groups)
  #' @field fertility_differentials List; religion-specific fertility differential matrices indexed by period label (values are ratios relative to total ASFR)
  #' @field sex_ratio Numeric vector; fraction of boys at birth for each projection period
  #' @field switching_matrices_list List; decomposed switching probability matrices, one per origin religion
  #' @field outmigration_rates List; outmigration rate matrices by period (rows = sex-age groups, cols = religions)
  #' @field destination_matrix Matrix; share of emigrants directed to each destination country, by sex and religion (rows = sex-religion combos, cols = destination country codes)
  #' @field start_fertility_group Numeric; index of the first age group included in fertility calculations (default 3, corresponding to 10-14)
  #' @field combined_fertility_factorization Logical; if TRUE (default), a single global factor is applied across all fertile age groups; if FALSE, each age group's fertility births are normalised independently to match the total ASFR for that age group
  #' @field previous_mortality data.table; mortality output. Columns: Country, Country_code, Period, Sex (integer 1/2), Age_group, Structure, Region, then one column per religion
  #' @field previous_fertility data.table; fertility (births) output. Columns: Country, Country_code, Period, Mother_age_group, Structure, Region, Total, then one column per religion
  #' @field previous_asfr data.table; age-specific fertility rate output. Columns: Country, Country_code, Period, Mother_age_group, Structure, Region, Total (realised rate: births / exposure), then one column per religion; rows with Mother_age_group == "TFR" contain period totals. Religion columns of individual structures hold the applied rates and are reported even without exposure; Total and the "total" structure hold realised rates and are 0 where exposure is 0 (except *_post_switch columns, which show the mean applied rate)
  #' @field previous_fertility_exposure data.table; women-population exposure used in ASFR calculation. Columns: Country, Country_code, Period, Mother_age_group, Structure, Region, Total, then one column per religion
  #' @field old_fertility_factors Matrix; scaling factors applied to births to reconcile religion-specific fertility with total ASFR; one row per age group, one column per period
  #' @field previous_switching data.table; switching output. Columns: Country, Country_code, Period, Origin_religion, Region (light mode) or additionally Sex, Age_group, Structure (full mode), then one column per destination religion
  #' @field previous_immigration data.table; immigration output. Columns: Destination, Country_code, Period, Structure, Origin, Region (light mode) or additionally Sex, Age_group (full mode), then one column per religion
  #' @field previous_emigration data.table; emigration output. Columns: Origin, Country_code, Period, Structure, Destination, Region (light mode) or additionally Sex, Age_group (full mode), then one column per religion
  #' @field migration_list List; internal buffer accumulating immigration flows during a projection step
  #' @field emigration_list List; internal buffer accumulating emigration flows during a projection step
  #' @field migrant_sum Matrix; running total of emigrant counts by religion used to balance destination shares within a step
  #' @field temp List; internal scratch space used during projection calculations; not intended for direct access
  #' @field projection_owner Character; name of the Projection_object that has claimed this country object. Empty string (`""`) if unclaimed. Prevents the same country list from being reused across multiple projections
  fields = list(
    # Information fields
    year = "numeric",
    period = "character",
    name = "character",
    code = "numeric",
    region = "character",
    structure_data = "list",
    # Input data
    mortality_rates = "matrix",
    age_specific_fertility_rates = "matrix",
    fertility_differentials = "list",
    sex_ratio = "numeric",
    switching_matrices_list = "list",
    outmigration_rates = "list",
    destination_matrix = "matrix",
    start_fertility_group = "numeric",
    combined_fertility_factorization = "logical",
    # Output data
    previous_mortality = "ANY",
    previous_fertility = "ANY",
    previous_asfr = "ANY",
    previous_fertility_exposure = "ANY",
    old_fertility_factors = "matrix",
    previous_switching = "ANY",
    previous_immigration = "ANY",
    previous_emigration = "ANY",
    migration_list = "list",
    emigration_list = "list",
    migrant_sum = "matrix",
    # Technical
    temp = "list",
    projection_owner = "character" # name of projection object that owns this country; "" if unclaimed
  )
)

Country_object$methods(
  list(
    # Functions used in dem_proj


    #' @name add_next_structure
    #' @title Duplicate last structure data
    #' @name Country_object$add_next_structure
    #' @title Adding next structure
    #' @description
    #' Function for adding a new structure by copying current structure_data list element and pasting it at the end of the list
    #' @return New element in structure_data list
    #' @examples
    #' measuringreligiouschange2::Country_object$add_next_structure()
    #' @noRd
    add_next_structure = function() {
      structure_data <<- append(
        structure_data,
        list(structure_data[[length(structure_data)]])
      )
      names(structure_data)[[length(structure_data)]] <<- as.character(year + 5)
      update_period()
    },

    #' @name Country_object$mortality_step
    #' @title Calculating mortality
    #' @description
    #' Function for calculating and saving mortality of chosen structure
    #' @param target Character; which population structure to apply mortality to — either `"sd"` (main) or `"sd2"` (post-switch) (no default)
    #' @return Called for its side effects. Updates `structure_data`, `emigration_list`, or `temp` in place and appends rows to `previous_mortality`.
    #' @noRd

    mortality_step = function(target = "sd") {
      # Choosing target structure and calculating surviving/dead population

      n_sd <- length(structure_data) # idea 4: cache once
      n_sd1 <- n_sd - 1L

      mrates <- mortality_rates[c(2:21, 23:42), n_sd1]
      if (target == "sd") {
        population_after_mortality <- structure_data[[n_sd]] * mrates
        mortality_data <- structure_data[[n_sd]] - population_after_mortality
      } else if (target %in% names(emigration_list)) {
        population_after_mortality <- emigration_list[[target]] * mrates
        mortality_data <- emigration_list[[target]]
      } else {
        population_after_mortality <- temp[[target]] * mrates
        mortality_data <- temp[[target]] - population_after_mortality
      }

      # Preparing for saving new population after mortality
      # idea 6: pre-allocate one 40-row matrix and fill by index — no rbind

      nc <- ncol(population_after_mortality)
      rn <- rownames(structure_data[[1L]])
      cn <- colnames(structure_data[[1L]])
      pam <- matrix(0, 40L, nc, dimnames = list(rn, cn))
      # Males: age-advance into rows 2-19; fold top two groups (90-94 + 95+) into row 20
      pam[2:19, ] <- population_after_mortality[1:18, ]
      pam[20, ] <- population_after_mortality[19, ] + population_after_mortality[20, ]
      # Females: same, offset by 20
      pam[22:39, ] <- population_after_mortality[21:38, ]
      pam[40, ] <- population_after_mortality[39, ] + population_after_mortality[40, ]
      population_after_mortality <- pam

      colnames(mortality_data) <- cn

      # Saving new population after mortality

      structure_name <- if (target == "sd") "switching first" else target

      # Expand mortality_data from 40 to 42 rows (placeholder age-"0" rows filled by fertility_step)
      # idea 6: pre-allocate instead of rbind
      mortality_data_42 <- matrix(0, 42L, nc, dimnames = list(age_vector_mortality, cn))
      mortality_data_42[2:21, ] <- mortality_data[1:20, ]
      mortality_data_42[23:42, ] <- mortality_data[21:40, ]

      pm <- cbind(
        data.table::data.table(
          Country      = rep(name, 42L),
          Country_code = rep(code, 42L),
          Period       = rep(period, 42L),
          Sex          = c(rep(1L, 21L), rep(2L, 21L)),
          Age_group    = age_vector_mortality,
          Structure    = rep(structure_name, 42L),
          Region       = rep(region, 42L)
        ),
        data.table::as.data.table(mortality_data_42)
      )
      if (!is.data.table(previous_mortality)) {
        previous_mortality <<- pm
      } else {
        previous_mortality <<- rbind(previous_mortality, pm)
      }

      if (target == "sd") {
        temp[["prev"]] <<- structure_data[[n_sd]]
        structure_data[[n_sd]] <<- population_after_mortality
      } else if (target %in% names(emigration_list)) {
        temp[["prev"]] <<- emigration_list[[target]]
        emigration_list[[target]] <<- population_after_mortality
      } else {
        temp[["prev"]] <<- temp[[target]]
        temp[[target]] <<- population_after_mortality
      }
    },

    #' @name Country_object$fertility_step
    #' @title Calculating fertility
    #' @description
    #' Function for calculating and saving fertility of chosen structure
    #' @param target Character; which population structure to apply fertility to — either `"sd"` (main) or `"sd2"` (post-switch) (no default)
    #' @param no_diff Logical; if TRUE, fertility differentials are ignored and all religions use the total ASFR (no default)
    #' @param post_switch Logical; if TRUE, post-switch populations are stored in separate columns (no default)
    #' @return Called for its side effects. Updates `structure_data`, `emigration_list`, or `temp` in place and appends rows to `previous_fertility`, `previous_asfr`, and `previous_fertility_exposure`.
    #' @noRd

    fertility_step = function(target = "sd", no_diff = FALSE, post_switch) {
      # Choosing correct structure

      n_sd <- length(structure_data) # idea 4: cache once
      n_sd1 <- n_sd - 1L

      if (target == "sd") {
        sd <- (structure_data[[n_sd]] + temp[["prev"]]) / 2
      } else if (target %in% names(emigration_list)) {
        sd <- (emigration_list[[target]] + temp[["prev"]]) / 2
      } else {
        sd <- (temp[[target]] + temp[["prev"]]) / 2
      }

      # Choosing correct asfr

      period_specific_asfr <- age_specific_fertility_rates[n_sd1, ]

      # Checking if fertility differentials are presented in their correct form

      if (!is.matrix(fertility_differentials[[length(fertility_differentials)]])) {
        print("Wrong differential input - not a matrix!")
        return(NULL)
      }

      # Adjusting asfr

      if (period_specific_asfr[3] > 5) {
        period_specific_asfr <- period_specific_asfr / 1000
      }

      # Choosing correct fertility differentials

      if (length(fertility_differentials) >= n_sd) {
        fd <- fertility_differentials[[n_sd1]]
      } else {
        fd <- fertility_differentials[[length(fertility_differentials)]]
      }

      # Checking correctness of the data

      if (nrow(fd) == 0) {
        fd <- matrix(
          data = 1, nrow = ncol(age_specific_fertility_rates),
          ncol = ncol(sd)
        )
        colnames(fd) <- colnames(sd)
        alldifferentials <- TRUE
      } else if ((nrow(fd) > 1 & ncol(fd) == ncol(sd) & !post_switch) |
        (nrow(fd) > 1 & 2 * ncol(fd) == ncol(sd) & post_switch)) {
        alldifferentials <- TRUE
      } else {
        alldifferentials <- FALSE
      }
      if (alldifferentials) {
        if (post_switch) {
          if (ncol(sd) != 2 * ncol(fd)) {
            print("Wrong differencial data.frame - religions")
            return(NULL)
          } else {
            fd <- cbind(fd, fd)
            colnames(fd) <- colnames(sd)
          }
        } else {
          if (ncol(sd) != ncol(fd)) {
            print("Wrong differencial data.frame - religions")
            return(NULL)
          }
        }
      }
      if (length(period_specific_asfr) != nrow(fd)) {
        print("Wrong differencial data.frame - age groups")
        return(NULL)
      }

      # Preparation of structure to which the fertility will be applied

      sd <- sd[(nrow(sd) / 2 + 1):nrow(sd), ]
      sd <- sd[start_fertility_group:(length(period_specific_asfr) + start_fertility_group - 1), ]

      if (no_diff) {
        relasfr <- matrix(
          data = rep(period_specific_asfr, ncol(sd)),
          nrow = length(period_specific_asfr), ncol = ncol(sd)
        )
      } else {
        relasfr <- fd * period_specific_asfr
      }
      colnames(relasfr) <- colnames(sd)
      rownames(relasfr) <- rownames(sd)

      # Calculating expected results of fertility

      total_in_groups <- rowSums(sd)
      expected_age_groups_totals <- c()
      expected_age_groups_totals <- total_in_groups * period_specific_asfr

      # Calculating non factorized results

      raw_age_groups_totals <- c()
      raw_age_groups <- sd * relasfr
      raw_age_groups_totals <- rowSums(raw_age_groups)

      # Calculating fertility

      if (combined_fertility_factorization) {
        factor <- sum(expected_age_groups_totals) / sum(raw_age_groups_totals)

        children_df <- raw_age_groups * factor
      } else {
        factors_vector <- expected_age_groups_totals / raw_age_groups_totals

        factors_vector[is.nan(factors_vector)] <- 0

        children_df <- raw_age_groups * factors_vector
      }
      fraction_of_born_boys <- sex_ratio[n_sd1]

      children_df[is.nan(children_df)] <- 0
      male_df <- children_df * fraction_of_born_boys
      female_df <- children_df * (1 - fraction_of_born_boys)


      male_vector <- colSums(male_df)
      female_vector <- colSums(female_df)


      nr <- nrow(structure_data[[n_sd]])
      nc <- ncol(structure_data[[n_sd]])
      rown <- rownames(structure_data[[n_sd]])
      result <- matrix(
        data = c(male_vector, female_vector),
        ncol = nc, nrow = 2, byrow = TRUE
      ) * mortality_rates[c(1, 22), n_sd1]

      # "Unswitching" children

      if (post_switch) {
        result[, 1:(nc / 2)] <- result[, 1:(nc / 2)] + result[, (ncol(result) / 2 + 1):ncol(result)]
        result[, (ncol(result) / 2 + 1):ncol(result)] <- 0
      }

      # Preparing for saving new population after fertility

      result <- data.frame(result)
      colnames(result) <- colnames(structure_data[[n_sd]])
      if (target == "sd") {
        result <- data.matrix(rbind(result[1, ], structure_data[[n_sd]][2:(nr / 2), ], result[2, ], structure_data[[n_sd]][(nr / 2 + 2):nr, ]))
      } else {
        result <- data.matrix(rbind(
          result[1, ], temp[[target]][2:(nr / 2), ],
          result[2, ], temp[[target]][(nr / 2 + 2):nr, ]
        ))
      }

      rownames(children_df) <- rownames(sd)
      colnames(children_df) <- colnames(sd)
      total_children <- matrix(rowSums(children_df), ncol = 1)
      colnames(total_children) <- c("Total")
      rownames(total_children) <- rownames(children_df)
      children_df <- cbind(total_children, children_df)

      rownames(result) <- rown

      if (combined_fertility_factorization) {
        relasfr <- relasfr * factor
      } else {
        relasfr <- relasfr * factors_vector
      }
      # Realised total ASFR (births / exposure); differs from the input ASFR
      # under combined factorisation. Zero exposure yields NaN, set to 0 below.
      total_asfr <- matrix(total_children[, 1] / rowSums(sd), ncol = 1)
      colnames(total_asfr) <- c("Total")
      rownames(total_asfr) <- rownames(total_asfr)
      relasfr <- cbind(total_asfr, relasfr)
      tfr <- matrix(colSums(relasfr), nrow = 1)
      colnames(tfr) <- colnames(relasfr)
      rownames(tfr) <- c("TFR")
      relasfr <- rbind(relasfr, tfr)
      relasfr[is.nan(relasfr)] <- 0


      # Calculating children mortality

      newborn_mortality <- matrix(
        data = c(male_vector, female_vector),
        ncol = ncol(sd),
        nrow = 2, byrow = TRUE
      ) * (1 - mortality_rates[c(1, 22), n_sd1])
      if (post_switch) {
        newborn_mortality[, 1:(ncol(result) / 2)] <- newborn_mortality[, 1:(ncol(result) / 2)] + newborn_mortality[, (ncol(result) / 2 + 1):ncol(result)]
        newborn_mortality[, (ncol(result) / 2 + 1):ncol(result)] <- 0
      }

      newborn_mortality[is.nan(newborn_mortality)] <- 0
      colnames(newborn_mortality) <- colnames(sd)

      # Saving new population after fertility

      structure_name <- if (target == "sd") "switching first" else target

      n_fert <- nrow(children_df)
      fert_ages <- sub("^\\S+\\s+", "", rownames(children_df))
      fert_meta <- data.table::data.table(
        Country = rep(name, n_fert),
        Country_code = rep(code, n_fert),
        Period = rep(period, n_fert),
        Mother_age_group = fert_ages,
        Structure = rep(structure_name, n_fert),
        Region = rep(region, n_fert)
      )

      pf <- cbind(fert_meta, data.table::as.data.table(children_df))
      if (!is.data.table(previous_fertility)) {
        previous_fertility <<- pf
      } else {
        previous_fertility <<- rbind(previous_fertility, pf)
      }

      asfr_ages <- ifelse(rownames(relasfr) == "TFR", "TFR",
        sub("^\\S+\\s+", "", rownames(relasfr))
      )
      n_asfr <- nrow(relasfr)
      pa <- cbind(
        data.table::data.table(
          Country          = rep(name, n_asfr),
          Country_code     = rep(code, n_asfr),
          Period           = rep(period, n_asfr),
          Mother_age_group = asfr_ages,
          Structure        = rep(structure_name, n_asfr),
          Region           = rep(region, n_asfr)
        ),
        data.table::as.data.table(relasfr)
      )
      if (!is.data.frame(previous_asfr)) {
        previous_asfr <<- pa
      } else {
        previous_asfr <<- rbind(previous_asfr, pa)
      }

      total_pe <- matrix(rowSums(sd), ncol = 1)
      colnames(total_pe) <- c("Total")
      rownames(total_pe) <- rownames(total_pe)
      pe_data <- cbind(total_pe, sd)
      pe <- cbind(fert_meta, data.table::as.data.table(pe_data))
      if (!is.data.table(previous_fertility_exposure)) {
        previous_fertility_exposure <<- pe
      } else {
        previous_fertility_exposure <<- rbind(previous_fertility_exposure, pe)
      }

      # Patch the age-0 rows in previous_mortality with actual newborn mortality
      rel_cols <- colnames(newborn_mortality)
      pm <- data.table::copy(previous_mortality)
      # Restrict to the current period so earlier periods are not overwritten
      pm[Period == period & Structure == structure_name & Sex == 1L & Age_group == "0", (rel_cols) := as.list(newborn_mortality[1, ])]
      pm[Period == period & Structure == structure_name & Sex == 2L & Age_group == "0", (rel_cols) := as.list(newborn_mortality[2, ])]
      previous_mortality <<- pm

      if (target == "sd") {
        structure_data[[n_sd]] <<- data.matrix(result)
      } else if (target %in% names(emigration_list)) {
        # Population already updated by mortality_step; no further action needed
      } else {
        temp[[target]] <<- data.matrix(result)
      }
    },


    #' @name Country_object$switching_step
    #' @title Calculating switching
    #' @description
    #' Function for calculating and saving switching of chosen structure
    #' @param target Character; which population structure to apply switching to — either `"sd"` (main) or `"sd2"` (post-switch) (no default)
    #' @param post_switch Logical; if TRUE, post-switch populations are stored in separate columns (no default)
    #' @param light_switching Logical; if TRUE, switching output is stored in abbreviated form to reduce memory usage (no default)
    #' @return Called for its side effects. Updates `structure_data`, `emigration_list`, or `temp` in place and appends rows to `previous_switching`.
    #' @noRd

    switching_step = function(target = "sd", post_switch, light_switching) {
      # Checking if switching data exists

      if (length(switching_matrices_list) == 0) {
        print("No switching data!")
        return(NULL)
      }

      # idea 4: cache length once
      n_sd <- length(structure_data)

      # Choosing correct structure

      if (target == "sd") {
        sd <- structure_data[[n_sd]]
      } else if (target %in% names(emigration_list)) {
        sd <- emigration_list[[target]]
      } else {
        sd <- temp[[target]]
      }

      # Conducting calculations for each religion separately

      n_sw <- length(switching_matrices_list)
      nr_sd <- nrow(sd)
      nc_sd <- ncol(sd)
      dest_names <- colnames(sd)

      prediction_religions_list <- lapply(seq_len(n_sw), function(i) {
        m <- switching_matrices_list[[i]] * sd[, i] # broadcasts sd[,i] column-wise
        m[is.nan(m)] <- 0
        colnames(m) <- dest_names
        m
      })

      if (post_switch) {
        # idea 5: vectorised off-diagonal column update — eliminates inner j loop
        n_base <- nc_sd / 2L
        for (i in seq_len(n_base)) {
          off <- seq_len(n_base)[-i]
          m <- prediction_religions_list[[i]]
          m[, off + n_base] <- m[, off + n_base] + m[, off]
          m[, off] <- 0
          prediction_religions_list[[i]] <- m
        }
      }

      # idea 5: reduce via 3D array — one C-level sum instead of n_sw R-level additions
      prediction_output <- matrix(
        rowSums(simplify2array(prediction_religions_list), dims = 2L),
        nr_sd, nc_sd,
        dimnames = list(rownames(sd), dest_names)
      )

      names(prediction_religions_list) <- dest_names

      if (light_switching) {
        prediction_religions_list <- lapply(prediction_religions_list, function(m) {
          if (!is.matrix(m)) {
            return(m)
          }
          out <- matrix(colSums(m), 1L, ncol(m), dimnames = list("Total", colnames(m)))
          out
        })
      }

      # Saving calculations

      structure_name <- if (target == "sd") "switching first" else target

      for (i in seq_along(prediction_religions_list)) {
        origin_rel_name <- names(prediction_religions_list)[i]
        sw_data <- data.table::as.data.table(prediction_religions_list[[i]])
        n <- nrow(prediction_religions_list[[i]])

        if (n == 1L) {
          meta <- data.table::data.table(
            Country         = name,
            Country_code    = code,
            Period          = period,
            Origin_religion = origin_rel_name,
            Structure       = structure_name,
            Region          = region
          )
        } else {
          meta <- data.table::data.table(
            Country         = rep(name, n),
            Country_code    = rep(code, n),
            Period          = rep(period, n),
            Sex             = c(rep(1L, 20L), rep(2L, 20L)),
            Age_group       = rep(age_vector, 2L),
            Origin_religion = rep(origin_rel_name, n),
            Structure       = rep(structure_name, n),
            Region          = rep(region, n)
          )
        }
        sw_row <- cbind(meta, sw_data)
        if (!is.data.table(previous_switching)) {
          previous_switching <<- sw_row
        } else {
          previous_switching <<- data.table::rbindlist(list(previous_switching, sw_row),
            use.names = TRUE, fill = TRUE
          )
        }
      }

      if (target == "sd") {
        structure_data[[n_sd]] <<- prediction_output
      } else if (target %in% names(emigration_list)) {
        emigration_list[[target]] <<- prediction_output
      } else {
        temp[[target]] <<- prediction_output
      }
    },

    # Test for debugging

    #' @name Country_object$testself
    #' @title Function for debugging
    #' @description
    #' Function intended for debugging
    #' @return Called for its side effects. Prints the country name to the console.
    #' @noRd

    testself = function() {
      print(name)
    }
  )
)
