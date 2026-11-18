#' @include data_adjustment.R projection_class_plots.R


# Functions for loading and adjusting data

#' @name c_codes_creator
#' @title Creating custom codes
#' @description
#' Function for converting numeric codes to codes starting with "c" and leading zeroes
#'
#' @param country_codes Numeric vector of ISO 3166-1 country codes to convert
#' @returns Vector of codes in adjusted format
#' @examples
#' c_codes_creator(country_codes = c(1, 2, 3))
#' @noRd

c_codes_creator <- function(country_codes) {
  c_country_codes <- c()

  # Adjusting the codes format to be "00X", "0XY" or "XYZ"

  for (i in seq_along(country_codes)) {
    if (country_codes[i] < 10) {
      c_country_codes[i] <- paste("00", country_codes[i], sep = "")
    } else if (country_codes[i] > 9 & country_codes[i] < 100) {
      c_country_codes[i] <- paste("0", country_codes[i], sep = "")
    } else {
      c_country_codes[i] <- country_codes[i]
    }
  }

  # Adding "c" suffix before the code

  for (i in seq_along(c_country_codes)) {
    c_country_codes[i] <- paste("c", c_country_codes[i], sep = "")
  }
  return(c_country_codes)
}

migration_limit_check <- function(data_list, on_country_mismatch =
                                    c("error", "rescale", "ignore")) {
  rescale_destination <- function(data_list) {
    codes <- data_list[[10]][[2]]
    data_list[[3]] <- data_list[[3]][
      data_list[[3]]$Country_code %in% codes,
      c(colnames(data_list[[3]])[1:3], as.character(codes))
    ]
    ncols <- ncol(data_list[[3]])
    for (row in 1:nrow(data_list[[3]])) {
      nums <- data_list[[3]][row, 4:ncols]
      s <- sum(nums)
      data_list[[3]][row, 4:ncols] <- if (isTRUE(s == 0)) 1 / ncol(nums) else nums / s
    }
    data_list
  }

  if (nrow(data_list[[10]]) < (ncol(data_list[[3]]) - 3)) {
    # Interactive path: no explicit choice provided - prompt the user
    if (interactive() && length(on_country_mismatch) > 1) {
      print("Migration destination matrix has more countries than info_variants dataframe. Most likely reason for that is deleting entries from info_variants to reduce scope of the prediction.")

      continue <- "3"
      while (!continue %in% c("1", "2")) {
        print("This package doesn't have the capabilities to calculate simulated rate for the rest of the world. Projection from these parameters will not be accurate unless you have created and placed 'Rest of World' manually into all dataframes of your data list. Do you wish to continue?")
        print("1 - Yes")
        print("2 - No")
        continue <- readline(prompt = "Enter your choice:")
      }

      if (continue == "2") {
        stop("Halted execution due to mismatch between migration_destination_matrix and amount of countries in country_object_list")
      }

      factorize <- "3"
      while (!factorize %in% c("1", "2")) {
        print("Your destination matrix entries may sum to less than one for origin countries. This will result in 'disappearance' of migrant populations. Do you wish to factor them to sum equal one?")
        print("1 - Yes")
        print("2 - No")
        factorize <- readline(prompt = "Enter your choice:")
      }

      if (factorize == "1") {
        data_list <- rescale_destination(data_list)
      }

      # Programmatic path: explicit on_country_mismatch provided
    } else {
      on_country_mismatch <- match.arg(on_country_mismatch)
      if (on_country_mismatch == "error") {
        stop(
          "Migration destination matrix has more countries than info_variants.",
          " Projection will not be accurate unless 'Rest of World' rows are provided manually."
        )
      }
      print("Migration destination matrix has more countries than info_variants dataframe. Most likely reason for that is deleting entries from info_variants to reduce scope of the prediction.")
      if (on_country_mismatch == "rescale") {
        print("Your destination matrix entries may sum to less than one for origin countries. This will result in 'disappearance' of migrant populations. They will be factored to sum equal one.")
        data_list <- rescale_destination(data_list)
      } else {
        print("This will result in 'disappearance' of migrant populations.")
      }
    }
  }
  return(data_list)
}


#' @name country_info_adjustment
#' @title Loading countries information
#' @description
#' Function for loading and adjusting countries information
#'
#' @param country_info Data frame containing country metadata with at least three columns: Country, Country_code, and Region_name; typically `base_data_list$info_variants`
#' @returns Data frame containing adjusted countries information
#' @noRd
country_info_adjustment <- function(country_info) {
  # Adjusting country codes by changing their format to the one presented in c_codes_creator()

  country_info <- country_info[, 1:3]
  country_info <- country_info[order(country_info[[2]]), ]
  country_info <- cbind(country_info, c_codes_creator(country_info[[2]]))
  colnames(country_info) <- c(colnames(country_info)[1:3], "C_country_code")
  return(country_info)
}

#' @name structure_data_adjustment
#' @title Loading structure data
#' @description
#' Function for loading and adjusting structure data by multiplying population counts by religious composition shares
#'
#' @param population_data Data frame of population counts by country, sex and age group; typically `base_data_list$data_population`
#' @param structure_differentials Data frame of religious composition shares by country, age group and sex; typically `base_data_list$data_structure`
#' @param post_switch Logical; if FALSE (default), switched individuals remain in the main population pool and may switch again in subsequent steps; if TRUE, they are moved into separate post-switch columns and excluded from further switching
#' @returns Data frame containing adjusted structure data
#' @noRd

structure_data_adjustment <- function(population_data, structure_differentials, post_switch = FALSE) {
  # Calculating structure data by multiplying population data and structure differentials

  # Restrict population_data to the countries present in structure_differentials so
  # the population vector length matches the number of structure_differentials rows.
  country_codes <- unique(structure_differentials[[1]])
  population_data <- population_data[population_data[[2]] %in% country_codes, ]

  # Canonical sex sort key: 1 = male, 2 = female - works for both integer (1/2)
  # and string ("males"/"females") encodings.  Always puts males before females
  # so the population vector aligns with structure_differentials (males rows 1-20).
  sex_sort_key <- ifelse(as.character(population_data[[1]]) %in% c("1", "males"), 1L, 2L)
  population_data <- population_data[order(population_data[[2]], sex_sort_key), ]
  population <- c()
  for (i in 1:nrow(population_data)) {
    population <- c(
      population,
      as.numeric(population_data[i, 3:ncol(population_data)])
    )
  }
  structure_differentials <- structure_differentials[order(structure_differentials[[1]]), ]
  structure_data <- cbind(
    structure_differentials[, 1:3], population,
    structure_differentials[, 4:ncol(structure_differentials)]
  )
  structure_data[, 5:ncol(structure_data)] <- structure_data[[4]] * structure_data[, 5:ncol(structure_data)]
  structure_data <- structure_data[, -4]
  if (post_switch) {
    post_switch_cols <- as.data.frame(matrix(
      data = 0, nrow = nrow(structure_data),
      ncol = (ncol(structure_data) - 3)
    ))
    colnames(post_switch_cols) <- paste(colnames(structure_data)[4:ncol(structure_data)],
      "_post_switch",
      sep = ""
    )
    structure_data <- cbind(structure_data, post_switch_cols)
  }

  return(structure_data)
}


data_loader <- function(data_list) {
  # Creating adjusted data list from base_data_list by adjusting country info and structure data

  country_info <- country_info_adjustment(data_list[[10]])
  structure_data <- structure_data_adjustment(data_list[[6]], data_list[[7]])
  fertility_differentials_data <- data_list[[2]]
  survivability_data <- data_list[[8]]
  sex_ratio_data <- data_list[[5]]
  switching_data <- data_list[[9]]
  destination_data <- data_list[[3]]
  migration_rates_data <- data_list[[4]]
  asfr_data <- data_list[[1]]
  data_list <- list(
    country_info,
    structure_data,
    asfr_data,
    fertility_differentials_data,
    survivability_data,
    sex_ratio_data,
    switching_data,
    destination_data,
    migration_rates_data
  )
  return(data_list)
}

# Function for checking data for errors

#' @name error_check
#' @title Checking for errors
#' @description
#' Function for checking common errors in loaded data
#'
#' @param object Country_object; the object to validate for common data errors
#' @examples
#' c_list <- create_country_list()
#' error_check(object = c_list[[1]])
#' @noRd

error_check <- function(object) {
  # Calculating number of religions and age groups

  n_religions <- (ncol(object$structure_data[[1]]) / 2)
  n_age_groups <- nrow(object$structure_data[[1]])

  errors <- 0

  # Checking if mortality rates are in the correct format

  if (nrow(object$mortality_rates) != (n_age_groups + 2)) {
    print(paste("Error in ", as.character(object$code), ": wrong dimensions of matrix mortality_rates"))
    errors <- errors + 1
  }

  # Checking if fertility differentials are in the correct format

  if (ncol(object$fertility_differentials[[1]]) != n_religions & ncol(object$fertility_differentials[[1]]) != (n_religions * 2)) {
    print(paste("Error in ", as.character(object$code), ": wrong dimensions of matrix fertility_differentials"))
    errors <- errors + 1
  }

  # Checking if sex ratio are in the correct format

  for (i in seq_along(object$sex_ratio)) {
    if (object$sex_ratio[[i]] < 0 || object$sex_ratio[[i]] > 1) {
      print(paste("Error in ", as.character(object$code), ": value of variable sex_ratio is not between 0 and 1"))
      errors <- errors + 1
    }
  }

  # Checking if outmigration rates are in the correct format

  if (!(ncol(object$outmigration_rates[[1]]) != n_religions || ncol(object$outmigration_rates[[1]]) != (n_religions * 2) || nrow(object$outmigration_rates[[1]]) != n_age_groups)) {
    print(paste("Error in ", as.character(object$code), ": wrong dimensions of matrix outmigration_rates"))
    errors <- errors + 1
  }

  # Checking if destination matrix is in the correct format

  if (!(nrow(object$destination_matrix) != (n_religions * 2) || nrow(object$destination_matrix) != (n_religions * 4))) {
    print(paste("Error in ", as.character(object$code), ": wrong dimensions of matrix destination_matrix"))
    errors <- errors + 1
  }

  # Checking if starting fertility group is in the correct format

  if (object$start_fertility_group < 0) {
    print(paste("Error in ", as.character(object$code), ": negative value of variable start_fertility_group"))
    errors <- errors + 1
  }

  rs <- vapply(
    object$switching_matrices_list,
    function(m) max(abs(rowSums(m) - 1)), numeric(1)
  )
  if (any(rs > 1e-8)) {
    print(paste("Error in ", as.character(object$code), ": switching matrices rows don't sum to 1"))
    errors <- errors + 1
  }

  # Printing number of errors in the loaded data

  if (errors > 0) {
    print(paste("Encountered: ", as.character(errors), " errors in", as.character(object$code)))
    stop()
  }
  return(invisible(NULL))
}

# Functions for creating objects

#' @name object_loader
#' @title Creating a Country_object
#' @description
#' Function for creating a country object for a single country
#'
#' @param code Numeric; ISO 3166-1 code of the country to load
#' @param start_year Numeric; starting year of the projection (default 2020)
#' @param start_period Character; five-year period label matching start_year (e.g. "2020-2025"; default "2020-2025")
#' @param start_fertility_group Numeric; index of the first age group included in fertility calculations (default 3, corresponding to the 10-14 age group)
#' @param switching_pattern List of two numeric vectors; distribution of religious switching across sub-periods for each switching cohort (default `list(c(1/3, 1/3, 1/3), c(1/3, 1/3, 1/3))`)
#' @param post_switch Logical; if FALSE, switched individuals remain in the main population pool and may switch again in subsequent steps; if TRUE, they are moved into separate post-switch columns and excluded from further switching (no default - must be supplied)
#' @param asfr_data Data frame of age-specific fertility rates by country and period; typically `base_data_list$data_asfr`
#' @param fertility_differentials_data Data frame of religion-specific fertility differentials by country and age group; typically `base_data_list$data_fertility_differentials`
#' @param destination_data Data frame of migration destination shares by origin country, sex and religion; typically `base_data_list$data_migration_destination`
#' @param migration_rates_data Data frame of migration rates by country, sex, age and period; typically `base_data_list$data_migration_rates`
#' @param sex_ratio_data Data frame of the fraction of boys at birth by country and period; typically `base_data_list$data_births_ratio`
#' @param structure_data Matrix of population counts by religion, age group and sex for each country; produced by `structure_data_adjustment()`
#' @param survivability_data Data frame of survivability rates by country, sex and age; typically `base_data_list$data_survivability`
#' @param switching_data Data frame of religious switching retention rates by country, sex and religion; typically `base_data_list$data_switching`
#' @param country_info Data frame of country metadata including codes, names and projection variants; typically the output of `country_info_adjustment()`
#' @returns A single Country_object
#' @noRd
object_loader <- function(code,
                          start_year = 2020,
                          start_period = "2020-2025",
                          start_fertility_group = 3,
                          switching_pattern = list(c(1 / 3, 1 / 3, 1 / 3), c(1 / 3, 1 / 3, 1 / 3)),
                          post_switch,
                          asfr_data,
                          fertility_differentials_data,
                          destination_data,
                          migration_rates_data,
                          sex_ratio_data,
                          structure_data,
                          survivability_data,
                          switching_data,
                          country_info) {
  # Extracting specific country's data from data list

  # Filtering country info

  country_info <- as.data.frame(country_info[country_info[[2]] == code, ])

  # Filtering structure data info and adjusting row names

  structure_data <- as.data.frame(structure_data[structure_data[[1]] == code, ])
  age_groups <- unique(structure_data[[2]])
  sex_rn <- ifelse(as.character(structure_data[[3]]) %in% c("1", "males"), "males", "females")
  rownames(structure_data) <- paste(sex_rn, structure_data[[2]], sep = " ")
  structure_data <- as.matrix(structure_data[, -(1:3)])

  # Filtering asfr data and adjusting row names

  asfr_data <- as.data.frame(asfr_data[asfr_data[[1]] == code, ])
  rownames(asfr_data) <- asfr_data[[2]]
  asfr_data <- asfr_data[, -(1:2)]

  # Filtering fertility differentials and adjusting row names

  fertility_differentials_data <- as.data.frame(fertility_differentials_data[fertility_differentials_data[[1]] == code, ])
  fertility_differentials_data <- fertility_differentials_data[, -(1:2)]
  fertility_differentials_data_labels <- fertility_differentials_data[[2]]
  fertility_differentials_data <- as.matrix(fertility_differentials_data)
  rownames(fertility_differentials_data) <- fertility_differentials_data_labels

  # Filtering sex ratio and adjusting row names

  sex_ratio_data <- sex_ratio_data[sex_ratio_data[[1]] == code, ]
  sex_ratio_colnames <- colnames(sex_ratio_data)[-1]
  sex_ratio_data <- as.numeric(unlist(sex_ratio_data[, -1]))
  names(sex_ratio_data) <- sex_ratio_colnames

  # Filtering survivability data and adjusting row names

  survivability_data <- as.data.frame(survivability_data[survivability_data[[1]] == code, ])
  sex_rn <- ifelse(as.character(survivability_data[[2]]) %in% c("1", "males"), "males", "females")
  rownames(survivability_data) <- paste(sex_rn, as.character(survivability_data[[4]]))
  survivability_data <- survivability_data[, -(1:4)]

  # Filtering switching data and adjusting retention

  switching_data <- switching_data[switching_data[[1]] == code, ]
  switching_data <- switching_data[2:ncol(switching_data)]
  switching_data <- final_decomposition(
    switching_data, switching_pattern,
    structure_data, post_switch
  )

  # Filtering destination matrix

  destination_data <- as.data.frame(destination_data[destination_data[[1]] == code, ])
  sex_rn <- ifelse(as.character(destination_data[[2]]) %in% c("1", "males"), "males", "females")
  rownames(destination_data) <- paste(destination_data[[3]], sex_rn, sep = " ")
  destination_data <- as.matrix(destination_data[, -(1:3)])

  # Filtering outmigration rates

  migration_rates_data <- as.data.frame(migration_rates_data[migration_rates_data[[4]] == code, ])
  migration_rates_list <- list()
  for (year in unique(migration_rates_data[[1]])) {
    migration_rates_data_single <- migration_rates_data[migration_rates_data[[1]] == year, ]
    sex_rn <- ifelse(as.character(migration_rates_data_single[[2]]) %in% c("1", "males"), "males", "females")
    rownames(migration_rates_data_single) <- paste(sex_rn, migration_rates_data_single[[3]], sep = " ")
    migration_rates_list[[length(migration_rates_list) + 1]] <- as.matrix(migration_rates_data_single[, -(1:4)])
    names(migration_rates_list)[length(migration_rates_list)] <- year
  }

  # Creating Country_object object, a single country

  object <- Country_object$new(
    year = start_year,
    period = start_period,
    name = country_info[1, 1],
    code = country_info[1, 2],
    region = country_info[1, 3],
    structure_data = list(temp = structure_data),
    mortality_rates = as.matrix(survivability_data),
    age_specific_fertility_rates = as.matrix(asfr_data),
    fertility_differentials = list(temp = fertility_differentials_data),
    sex_ratio = sex_ratio_data,
    switching_matrices_list = switching_data,
    destination_matrix = as.matrix(destination_data),
    outmigration_rates = migration_rates_list,
    start_fertility_group = start_fertility_group,
    combined_fertility_factorization = TRUE,
    projection_owner = ""
  )
  names(object$fertility_differentials)[1] <- paste(as.character(start_year), as.character(start_year + 5), sep = "-")
  names(object$structure_data)[1] <- as.character(start_year)

  error_check(object)

  return(object)
}


#' @name object_list_creator
#' @title Creating list of Country_objects
#' @description
#' Function for creating a country objects list
#'
#' @param start_year Numeric; starting year of the projection (default 2020)
#' @param start_period Character; five-year period label of the starting period (default "2020-2025")
#' @param start_fertility_group Numeric; index of the first age group included in fertility calculations (default 3, corresponding to age group 10-14)
#' @param switching_pattern List; two numeric vectors specifying the distribution of religious switching across sub-periods for each switching cohort (default `list(c(1/3, 1/3, 1/3), c(1/3, 1/3, 1/3))`)
#' @param post_switch Logical; if FALSE, switched individuals remain in the main population pool and may switch again in subsequent steps; if TRUE, they are moved into separate post-switch columns and excluded from further switching
#' @param asfr_data Data frame of age-specific fertility rates by country and period; typically `base_data_list$data_asfr`
#' @param fertility_differentials_data Data frame of religion-specific fertility differentials by country and age group; typically `base_data_list$data_fertility_differentials`
#' @param destination_data Data frame of migration destination shares by origin country, sex and religion; typically `base_data_list$data_migration_destination`
#' @param migration_rates_data Data frame of migration rates by country, sex, age and period; typically `base_data_list$data_migration_rates`
#' @param sex_ratio_data Data frame of the fraction of boys at birth by country and period; typically `base_data_list$data_births_ratio`
#' @param structure_data Matrix of population counts by religion, age group and sex for each country; produced by `structure_data_adjustment()`
#' @param survivability_data Data frame of survivability rates by country, sex and age; typically `base_data_list$data_survivability`
#' @param switching_data Data frame of religious switching retention rates by country, sex and religion; typically `base_data_list$data_switching`
#' @param country_info Data frame of country metadata including codes, names and projection variants; typically the output of `country_info_adjustment()`
#' @param progress_bar Logical; whether to show a progress bar during loading (default TRUE)
#' @returns A list of Country_objects, one per country in country_info
#' @noRd
object_list_creator <- function(start_year = 2020,
                                start_period = "2020-2025",
                                start_fertility_group = 3,
                                switching_pattern = list(c(1 / 3, 1 / 3, 1 / 3), c(1 / 3, 1 / 3, 1 / 3)),
                                post_switch,
                                asfr_data,
                                fertility_differentials_data,
                                destination_data,
                                migration_rates_data,
                                sex_ratio_data,
                                structure_data,
                                survivability_data,
                                switching_data,
                                country_info,
                                progress_bar = TRUE) {
  # Specifying if progress bar should be shown and estimates the time needed for loading all of the countries

  if (progress_bar) {
    pb <- progress::progress_bar$new(
      format = "Loading :countryname [:bar] ETA :eta :percent",
      total = length(country_info[[2]]),
      width = 120,
      clear = FALSE
    )
  }

  # Creates list of Country_objects

  country_object_list <- list()
  for (country_code in country_info[[2]]) {
    if (progress_bar) {
      pb$tick(tokens = list(countryname = as.character(country_info[country_info$Country_code == country_code, 1])))
    }
    object <- object_loader(
      country_code,
      start_year,
      start_period,
      start_fertility_group,
      switching_pattern,
      post_switch,
      asfr_data,
      fertility_differentials_data,
      destination_data,
      migration_rates_data,
      sex_ratio_data,
      structure_data,
      survivability_data,
      switching_data,
      country_info
    )

    country_object_list <- append(country_object_list, object)
  }

  names(country_object_list) <- country_info[[4]]
  return(country_object_list)
}


#' @export create_country_list

#' @name create_country_list
#' @title Loading data and creating list of Country_objects
#' @description
#' Function for creating a country objects list
#'
#' @param start_year Numeric; starting year of the projection (default 2020).
#' @param start_fertility_group Numeric; index of the youngest age group for which fertility is applied. Default 3, corresponding to the 10-14 age group.
#' @param switching_pattern List of two numeric vectors; specifies for each switching cohort the distribution of religious switching across sub-periods. The first switchable age group is 15-19. Default `list(c(1/3, 1/3, 1/3), c(1/3, 1/3, 1/3))`, distributing switching uniformly across 15-19, 20-24 and 25-29.
#' @param data_list List; named list of data frames containing pre-loaded projection input data (default [base_data_list]).
#' @param progress_bar Logical; whether to show a progress bar and ETA during loading (default TRUE).
#' @param post_switch Logical; controls how religious switching is tracked across periods. If FALSE (default), individuals who have switched religion remain in the general population and may switch again in subsequent steps. If TRUE, those who have switched are moved into separate post-switch columns and excluded from further switching. Forwarded to internal country object creation.
#' @param on_country_mismatch Character; how to handle a mismatch between the number of countries in the migration destination matrix and `info_variants`. One of `"error"`, `"rescale"` (renormalise destination rows to sum to 1), or `"ignore"`. In interactive sessions without an explicit value the user is prompted.
#' @returns List of country objects, each containing demographic and model-specific data used in the MRC projection framework. Each element of the list represents a single country.
#' @seealso
#' \code{\link{create_projection_object}} to assemble a projection from this list,
#' \code{\link{variants_loader}} to validate the assembled object,
#' \code{\link{project}} to run the projection.
#' \code{vignette("conducting-projections")} for a complete worked example.
#' \code{vignette("inner-workings")} for the internal data-loading pipeline.
#' @examples
#' test_cl <- create_country_list(
#'   start_year = 2025,
#'   start_fertility_group = 4,
#'   switching_pattern = list(
#'     c(1 / 3, 1 / 3, 1 / 3),
#'     c(1 / 3, 1 / 3, 1 / 3)
#'   ),
#'   data_list = base_data_list,
#'   progress_bar = FALSE,
#'   post_switch = FALSE,
#'   on_country_mismatch = "error"
#' )
create_country_list <- function(start_year = 2020,
                                start_fertility_group = 3,
                                switching_pattern = list(c(1 / 3, 1 / 3, 1 / 3), c(1 / 3, 1 / 3, 1 / 3)),
                                data_list = base_data_list,
                                progress_bar = TRUE,
                                post_switch = FALSE,
                                on_country_mismatch =
                                  c("error", "rescale", "ignore")) {
  # Checking the correctness of migration data

  on_country_mismatch <- match.arg(on_country_mismatch)
  data_list <- migration_limit_check(data_list, on_country_mismatch)

  # Checking if data list exists

  if (is.null(data_list)) {
    return(NULL)
  }
  if (!exists("data_list")) {
    print("No data required for object creation!")
    return(NULL)
  }

  # Adjusting country info and structure data

  data_list[[12]] <- country_info_adjustment(data_list[[10]])
  data_list[[13]] <- structure_data_adjustment(data_list[[6]], data_list[[7]], post_switch)

  # Specifying if progress bar should be shown and estimates the time needed for loading all of the countries

  if (progress_bar) {
    pb <- progress::progress_bar$new(
      format = "Loading :countryname [:bar] ETA :eta :percent",
      total = length(data_list[[12]][[2]]),
      width = 120,
      clear = FALSE
    )
  }

  # Creating list of all country objects

  full_country_list <- list()

  for (country_code in data_list[[12]][[2]]) {
    if (progress_bar) {
      pb$tick(tokens = list(countryname = as.character(data_list[[12]][data_list[[12]]$Country_code == country_code, 1])))
    }
    object <- object_loader(
      code = country_code,
      start_year = start_year,
      start_period = paste(as.character(start_year), as.character(start_year + 5), sep = "-"),
      start_fertility_group = start_fertility_group,
      switching_pattern = switching_pattern,
      post_switch = post_switch,
      asfr_data = data_list[[1]],
      fertility_differentials_data = data_list[[2]],
      destination_data = data_list[[3]],
      migration_rates_data = data_list[[4]],
      sex_ratio_data = data_list[[5]],
      structure_data = data_list[[13]],
      survivability_data = data_list[[8]],
      switching_data = data_list[[9]],
      country_info = data_list[[12]]
    )
    full_country_list <- append(full_country_list, object)
  }

  names(full_country_list) <- data_list[[12]][[4]]

  return(full_country_list)
}

#' @export create_projection_object

#' @name create_projection_object
#' @title Creating projection_object
#' @description
#' Function for creating a projection object used in the MRC projection model.
#' Users can specify several parameters controlling the projection setup,
#' inclusion of migration and switching processes, and assumptions regarding
#' fertility differentials.
#'
#' @param name Character; name of the projection scenario - required.
#' @param country_object_list List; country objects created by `create_country_list()`. If omitted or not a list, `create_country_list(post_switch = post_switch)` is called automatically. The same list cannot be reused across multiple projections (no default - auto-created if missing).
#' @param region_object_list List; region objects created by `create_region_list()`. If omitted or not a list, `create_region_list()` is called automatically. Modify only if you are fully familiar with the internal structure of the package (no default - auto-created if missing).
#' @param steps Numeric; number of 5-year projection periods to simulate (default 10).
#' @param migration Logical; whether migration (emigration and immigration) is included in the projection (default TRUE).
#' @param switching Logical; whether religious switching is included in the projection (default TRUE).
#' @param switching_type Numeric; sequence of switching relative to demographic processes. Available options:
#' 1 - The population is divided into two groups. For the first group, switching rates are applied at the beginning of the period (before demographic processes); for the second group, switching occurs at the end of the period (after demographic processes).
#' 2 - Switching is applied entirely at the beginning of the period, before demographic processes.
#' (Default = 1).
#' @param no_diff Logical; if TRUE, fertility differentials by religion are ignored and all religions use the total ASFR (default FALSE - differentials are applied).
#' @param post_switch Logical; controls how religious switching is tracked across periods. If FALSE (default), individuals who have switched religion remain in the general population and may switch again in subsequent steps. If TRUE, those who have switched are moved into separate post-switch columns and excluded from further switching. Also forwarded to `create_country_list()` when called automatically.
#' @param light_migration Logical; if TRUE, migration output is stored in abbreviated form to reduce memory usage. Recommended when running multiple projections (default TRUE).
#' @param light_switching Logical; if TRUE, switching output is stored in abbreviated form to reduce memory usage. Recommended when running multiple projections (default TRUE).
#' @returns A single projection object
#' @seealso
#' \code{\link{create_country_list}} to create the required country list,
#' \code{\link{variants_loader}} to validate this object before projecting,
#' \code{\link{project}} to run the projection,
#' \code{\link{save_csv_all}} and \code{\link{save_plots_all}} to export results.
#' \code{vignette("conducting-projections")} for a full walkthrough.
#' @examples
#' test_po <- create_projection_object(name = "test", steps = 5)
create_projection_object <- function(name,
                                     country_object_list,
                                     region_object_list,
                                     steps = 10,
                                     migration = TRUE,
                                     switching = TRUE,
                                     switching_type = 1,
                                     no_diff = FALSE,
                                     post_switch = FALSE,
                                     light_migration = TRUE,
                                     light_switching = TRUE) {
  # Auto-create country_object_list if missing or not a list
  if (missing(country_object_list) || !is.list(country_object_list)) {
    country_object_list <- create_country_list(post_switch = post_switch, on_country_mismatch = "error")
  }
  ps_check <- grepl("_post_switch", colnames(country_object_list[[1]]$switching_matrices_list[[1]]))
  if (any(ps_check) & !post_switch) {
    stop("Mismatch in post_switch parameter between projection_object and country_objects")
  }

  # Auto-create region_object_list if missing or not a list
  if (missing(region_object_list) || !is.list(region_object_list)) {
    region_object_list <- create_region_list()
  }

  # Checking if country object list exists

  if (is.null(country_object_list)) {
    return(NULL)
  }

  # Guard against reusing the same R5 country objects in multiple projection objects.
  # R5 reference semantics mean both projection objects would share the same underlying
  # data; projecting one would silently corrupt the other.
  already_owned <- Filter(function(obj) nchar(obj$projection_owner) > 0, country_object_list)
  if (length(already_owned) > 0) {
    stop(
      "Cannot create projection '", name, "': ",
      length(already_owned), " country object(s) are already registered to projection '",
      already_owned[[1]]$projection_owner, "'.\n",
      "Countries: ", paste(sapply(already_owned, `[[`, "name"), collapse = ", "), "\n",
      "Each projection object requires its own country list - call create_country_list() again."
    )
  }
  for (obj in country_object_list) obj$projection_owner <- name

  # Creating projection object

  full_projection_object <- Projection_object$new(
    projection_name = name,
    country_object_list = country_object_list,
    region_object_list = region_object_list,
    steps = steps,
    migration = migration,
    switching = switching,
    switching_type = switching_type,
    no_diff = no_diff,
    post_switch = post_switch,
    resolved = FALSE,
    region_totals = FALSE,
    global_totals = FALSE,
    light_migration = light_migration,
    light_switching = light_switching,
    variant = FALSE
  )

  # Printing vital information about projection object

  print("Global starting parameters:")
  print(paste("Migration:", as.character(migration), sep = " "))
  if (migration) {
    print(paste("Light migration:", as.character(light_migration), sep = " "))
  }
  print(paste("Switching:", as.character(switching), sep = " "))
  if (switching) {
    print(paste("Light switching:", as.character(light_switching), sep = " "))
    if (switching_type == 1) {
      print("Switching type: split")
    } else {
      print("Switching type: single step")
    }
  }

  print(paste("Steps:", as.character(steps), sep = " "))
  print(paste("No fertility differentials:", as.character(no_diff), sep = " "))
  print(paste("Post switch separation:", as.character(post_switch), sep = " "))

  return(full_projection_object)
}

#' @export
#' @name create_region_list
#' @title Creating list of Region_objects
#' @description
#' Function for creating a list of Region_objects from a region-mapping data frame.
#' In most workflows this is called automatically by \code{\link{create_projection_object}};
#' call it directly only when you need to customise the region list before assembling
#' a projection.
#'
#' @param region_data Data frame; mapping region names to region identifiers.
#'   See \code{\link{data_regions}}. Defaults to the regions table stored in
#'   \code{\link{base_data_list}} (\code{base_data_list[[11]]}).
#' @returns List of Region_objects, one per row in \code{region_data}.
#' @seealso
#' \code{\link{create_projection_object}} which calls this automatically,
#' \code{\link{base_data_list}} for the default region mapping data.
#' @examples
#' create_region_list(region_data = base_data_list[[11]])
create_region_list <- function(region_data = base_data_list[[11]]) {
  # Creating list of region objects from region data

  region_list <- list()
  for (region in 1:nrow(region_data)) {
    object <- Region_object$new(
      name = as.character(region_data[region, 1]),
      region = as.character(region_data[region, 2])
    )
    region_list <- append(region_list, object)
  }
  names(region_list) <- region_data[[2]]
  return(region_list)
}
