#' @description
#' Function for calculating product of vector elements
#'
#' @param vector Numeric vector; the elements to multiply together
#' @returns product of vector elements
#' @examples
#' multvector(vector = c(1, 2, 3))
#' @noRd

multvector <- function(vector) {
  i <- 1
  for (number in vector) {
    i <- i * number
  }
  return(i)
}

#' @description
#' Function for clearing NA values by replacing them with appropriate retention
#'
#' @param retention_data Data frame; switching retention data with origin religion in column 1, sex in column 2, and destination religion retention rates in remaining columns
#' @returns Data frame clear from NA values
#' @examples
#' clear_na(retention_data = retention)
#' @noRd

clear_na <- function(retention_data) {
  # Checking if retention data exists

  if (nrow(retention_data) == 0) {
    return(retention_data)
  }

  # Checking retention data fo NA values and filtering them out

  remove_keep <- rep(TRUE, nrow(retention_data))
  for (i in 1:nrow(retention_data)) {
    if (sum(is.na(retention_data[i, 3:ncol(retention_data)])) == 0) {
      next
    }
    if (sum(is.na(retention_data[i, 3:ncol(retention_data)])) == 1) {
      for (k in 3:ncol(retention_data)) {
        if (is.na(retention_data[i, k])) {
          print("Found NA at:")
          print(paste("  country_code:", retention_data[i, 1]))
          print(paste("  Origin_religion:", retention_data[i, 2]))
          print(paste("  Sex:", retention_data[i, 3]))
          print(paste("  Switching_religion:", colnames(retention_data)[k]))
          retention_data[i, k] <- 1 - sum(
            retention_data[
              i,
              3:ncol(retention_data)
            ],
            na.rm = TRUE
          )
          print(paste("Single NA in row calculated as", retention_data[i, k]))
        }
      }
      next
    }
    print("Found multiple NAs at:")
    print(paste("  country_code:", retention_data[i, 1]))
    print(paste("  Origin_religion:", retention_data[i, 2]))
    print(paste("  Sex:", retention_data[i, 3]))
    print("Dropping row")
    remove_keep[i] <- FALSE
  }
  return(retention_data[remove_keep, ])
}

#' @description
#' Function for creating all possible combinations of age group, sex and religion at birth
#'
#' @param retention_data Data frame containing retention data; first column is origin religion, second is sex, remaining columns are destination religions
#' @param sex_labels Integer vector of sex codes present in the data (default c(1L, 2L) for males and females)
#' @returns Data frame with added combinations
#' @examples
#' ras_combination_creator(retention_data = retention, sex_labels = c(1L, 2L))
#' @noRd

ras_combination_creator <- function(retention_data, sex_labels = c(1L, 2L)) {
  # Checking if retention data exists

  empty <- FALSE
  if (nrow(retention_data) == 0) {
    empty <- TRUE
  }

  # Creating every possible religion, age group and sex combination which does not already exist

  for (re in names(retention_data[3:ncol(retention_data)])) {
    for (se in sex_labels) {
      if (!empty) {
        if (nrow(retention_data[(retention_data[[1]] == re &
          retention_data[[2]] == se), ]) != 0) {
          next
        }
      }
      reps <- length(colnames(retention_data)) - 2
      tibble <- as.data.frame(matrix(
        data =
          append(
            list(re, se),
            as.list(rep(
              0,
              reps
            ))
          ),
        nrow = 1, ncol = length(colnames(retention_data))
      ))
      colnames(tibble) <- colnames(retention_data)
      tibble[1:2] <- sapply(tibble[1:2], as.character)
      tibble[3:ncol(tibble)] <- sapply(tibble[3:ncol(tibble)], as.numeric)

      retention_data <- rbind(retention_data, tibble)
    }
  }
  return(retention_data)
}

#' @description
#' Function for adjusting switching probability by setting probability to 1 for childhood religion
#'
#' @param retention_data Data frame; switching retention data (see `clear_na()` for column structure)
#' @returns Data frame with adjusted probability
#' @examples
#' switch_prob_adjustment(retention_data = retention)
#' @noRd

switch_prob_adjustment <- function(retention_data) {
  # Changing probability to 1 if it equals 0

  for (i in 1:nrow(retention_data)) {
    if (sum(retention_data[i, 3:ncol(retention_data)]) != 0) {
      next
    } else {
      retention_data[i, unlist(retention_data[i, 1])] <- 1
    }
  }
  return(retention_data)
}

#' @description
#' Function for sorting retention data by religions, sex and age groups
#'
#' @param retention_data Data frame; switching retention data (see `clear_na()` for column structure)
#' @returns Data frame with sorted data
#' @examples
#' sorting(retention_data = retention)
#' @noRd

sorting <- function(retention_data) {
  # Sorting the retention data by sex and age groups

  if (is.numeric(retention_data$Sex)) {
    retention_data <- dplyr::arrange(retention_data, retention_data$Religion, retention_data$Sex, retention_data$Age)
  } else {
    retention_data <- dplyr::arrange(retention_data, retention_data$Religion, dplyr::desc(retention_data$Sex), retention_data$Age)
  }
  return(retention_data)
}

#' @description
#' Function for sorting retention data by religions (columns order), sex and age groups
#'
#' @param retention_data Data frame; switching retention data (see `clear_na()` for column structure)
#' @returns Data frame with sorted data
#' @examples
#' sorting_colorder_religions(retention_data = retention)
#' @noRd

sorting_colorder_religions <- function(retention_data, post_switch) {
  # Extracting religion names
  if (post_switch) {
    religion_names <- c(
      colnames(retention_data[3:ncol(retention_data)]),
      sapply(colnames(retention_data[3:ncol(retention_data)]),
        paste, "_post_switch",
        sep = ""
      )
    )
  } else {
    religion_names <- colnames(retention_data[3:ncol(retention_data)])
  }

  # Sorting the retention data by religion in order of columns

  for (i in 1:nrow(retention_data)) {
    retention_data[i, 1] <- as.character(which(religion_names ==
      unlist(retention_data[i, 1])))
  }
  class(retention_data[[1]]) <- "double"
  retention_data <- sorting(retention_data)
  vec <- c()
  for (i in 1:nrow(retention_data)) {
    vec <- c(vec, religion_names[unlist(retention_data[i, 1])])
  }
  retention_data[[1]] <- as.numeric(retention_data[[1]])
  return(retention_data)
}

# function for adjusting input retention data
#' @description
#' Function for adjusting raw retention data for further calculations
#'
#' @param retention_data Data frame; switching retention data (see `clear_na()` for column structure)
#' @returns Data frame with adjusted data
#' @examples
#' retention_data_adjustment(retention_data = retention)
#' @noRd

retention_data_adjustment <- function(retention_data, post_switch) {
  # Applying all of the functions above to the retention data

  retention_data <- as.data.frame(retention_data)
  retention_data <- clear_na(retention_data)
  retention_data <- ras_combination_creator(retention_data)
  retention_data <- switch_prob_adjustment(retention_data)
  retention_data <- sorting_colorder_religions(retention_data, post_switch)
  return(retention_data)
}

################################################################################

# decompose retention vector for one religion using distribution vector
#' @description
#' Formats retention into length of distribution by finding base X and creating a vector equal to X^distribution - after multiplying them we will get base retention value
#' @param retention Numeric; retention rate for the whole age group (value between 0 and 1)
#' @param distribution Numeric vector; exponents used to decompose the retention into sub-periods via base^distribution
#' @returns Numeric vector of sub-period retention values
#' @noRd

decomposition <- function(retention, distribution) {
  base <- retention^(1 / sum(distribution))
  result <- c()
  for (i in seq_along(distribution)) {
    result <- c(result, base^distribution[i])
  }
  return(result)
}

# decompose retention vector for one religion using any distribution
#' @description
#' Formats retention into length of distribution where switching follows given distribution
#' @param retention Numeric retention rate for the whole age group (value between 0 and 1)
#' @param vector Numeric vector containing the distribution of switching across sub-periods; values must be between 0 and 1 and sum to at most 1
#' @param iterations Integer; number of binary-search iterations used to find the decomposition factor (default 1000)
#' @returns Retention vector of wanted distribution
#' @noRd

anydistdecomposition <- function(retention, vector, iterations = 1000) {
  check <- (vector > 1 | vector < 0)
  if (sum(check) > 0 || sum(vector) > 1) {
    stop(paste("Wrong distribution vector: c(", paste(vector, collapse = ", "), ")", sep = ""))
  }
  max <- 1 / max(vector)
  factor <- max / 2
  min <- 0
  for (i in 1:iterations) {
    factored_vector <- factor * vector
    if (multvector(1 - factored_vector) > retention) {
      min <- factor
      factor <- (max + min) / 2
    } else if (multvector(1 - factored_vector) < retention) {
      max <- factor
      factor <- (max + min) / 2
    } else {
      return(1 - factored_vector)
    }
  }
  return(1 - factored_vector)
}


# decompose retention
#' @description Wraps around decomposition and anydistdecomposition functions to additionally calculate resulting switching rates
#'
#' @param retentionvector Numeric vector; retention values for the current religion across all age groups and destination religions
#' @param distribution Numeric vector; switching distribution across sub-periods (values between 0 and 1, summing to at most 1). See `anydistdecomposition()`.
#' @param religion Character; name of the origin religion being decomposed
#' @param exponentials Logical; if TRUE uses exponential decomposition (`decomposition()`), if FALSE uses any-distribution decomposition (`anydistdecomposition()`) (default FALSE)
#' @returns Retention vector of wanted distribution
#' @noRd

decomposition_vector <- function(retentionvector, distribution,
                                 religion, exponentials = FALSE) {
  result <- data.frame(matrix(
    data = 0, nrow = length(distribution),
    ncol = length(retentionvector)
  ))
  retentionvector <- retentionvector / sum(retentionvector)
  if (exponentials) {
    colrel <- data.frame(decomposition(
      retentionvector[religion],
      distribution
    ))
  } else {
    colrel <- data.frame(anydistdecomposition(
      retentionvector[religion],
      distribution
    ))
  }
  for (i in seq_along(distribution)) {
    result[i, religion] <- colrel[1, i]
  }
  for (i in seq_along(retentionvector)) {
    if (i == religion) {
      next
    }
    if (retentionvector[i] == 0) {
      next
    }
    for (k in 1:nrow(result)) {
      result[k, i] <- (1 - result[k, religion]) * retentionvector[i] /
        (1 - retentionvector[religion])
    }
  }
  return(result)
}


# final function for decomposing retention data
# nosw_start and nosw_end must be adjusted to original age groups,
# for 15-54 we include 3 first and 9 last age groups
# that are not included in retention
#' @noRd

switching_matrix_full <- function(retention_data, switching_pattern, religion,
                                  differencial = FALSE, nosw_start = 3,
                                  nosw_end = 14, total_rows = NULL) {
  retcol <- ncol(retention_data)
  distlen <- length(switching_pattern)

  # Compute middle buffer dynamically so total rows always matches total_rows,
  # regardless of the length of vectors in switching_pattern.
  total_switching <- sum(sapply(switching_pattern, length))
  if (is.null(total_rows)) {
    nosw_mid <- nosw_start + nosw_end
  } else {
    nosw_mid <- total_rows - nosw_start - total_switching - nosw_end
  }

  result <- matrix(data = 0, nrow = nosw_start, ncol = retcol * 2)
  result[, religion] <- 1
  for (i in 1:(distlen / 2)) {
    dist <- length(switching_pattern[[i]])
    colrel <- anydistdecomposition(retention_data[i, religion], switching_pattern[[i]])
    chunk <- matrix(data = 0, nrow = dist, ncol = retcol * 2)
    chunk[, religion] <- colrel
    for (n in 1:retcol) {
      if (retention_data[i, religion] == 1) {
        next
      }
      if (n == religion) {
        next
      }
      mult <- retention_data[i, n] / (1 - retention_data[i, religion])
      for (k in 1:dist) {
        chunk[k, n] <- (1 - chunk[k, religion]) * mult
      }
    }
    result <- rbind(result, chunk)
  }
  buffer <- matrix(data = 0, nrow = nosw_mid, ncol = retcol * 2)
  buffer[, religion] <- 1
  result <- rbind(result, buffer)
  for (i in (distlen / 2 + 1):distlen) {
    dist <- length(switching_pattern[[i]])
    colrel <- anydistdecomposition(retention_data[i, religion], switching_pattern[[i]])
    chunk <- matrix(data = 0, nrow = dist, ncol = retcol * 2)
    chunk[, religion] <- colrel
    for (n in 1:retcol) {
      if (retention_data[i, religion] == 1) {
        next
      }
      if (n == religion) {
        next
      }
      mult <- retention_data[i, n] / (1 - retention_data[i, religion])
      for (k in 1:dist) {
        chunk[k, n] <- (1 - chunk[k, religion]) * mult
      }
    }
    result <- rbind(result, chunk)
  }
  buffer <- matrix(data = 0, nrow = nosw_end, ncol = retcol * 2)
  buffer[, religion] <- 1
  result <- rbind(result, buffer)
  if (differencial) {
    for (i in 1:(ncol(result) / 2)) {
      if (i == religion) {
        result[, i + (ncol(result) / 2)] <- 0
        next
      }
      result[, i + (ncol(result) / 2)] <- result[, i]
      result[, i] <- 0
    }
  } else {
    result <- result[, 1:(ncol(result) / 2)]
  }
  return(result)
}


#' function for decomposing the retention data
#' @noRd

dataframe_decomposition <- function(retention_data_adjusted, switching_pattern,
                                    post_switch = FALSE, total_rows = NULL) {
  retention_full_data <- list()

  for (i in 3:ncol(retention_data_adjusted)) {
    little_matrix <- retention_data_adjusted[
      seq_along(switching_pattern),
      3:ncol(retention_data_adjusted)
    ]
    working_matrix <- switching_matrix_full(
      little_matrix, switching_pattern,
      i - 2, post_switch,
      total_rows = total_rows
    )
    retention_full_data[[i - 2]] <- data.matrix(working_matrix)
    retention_data_adjusted <- retention_data_adjusted[-c(seq_along(switching_pattern)), ]
  }
  if (post_switch) {
    len <- length(retention_full_data)
    for (i in (len + 1):(2 * len)) {
      temp <- matrix(
        data = 0, nrow = nrow(retention_full_data[[1]]),
        ncol = ncol(retention_full_data[[1]])
      )
      temp[, i] <- 1
      retention_full_data[[i]] <- temp
    }

    cnames <- c(
      colnames(retention_data_adjusted)[3:ncol(retention_data_adjusted)],
      sapply(colnames(retention_data_adjusted)[3:ncol(retention_data_adjusted)],
        paste, "_post_switch",
        sep = ""
      )
    )
    for (i in seq_along(retention_full_data)) {
      colnames(retention_full_data[[i]]) <- cnames
    }
    names(retention_full_data) <- cnames
  } else {
    cnames <- colnames(retention_data_adjusted)[3:ncol(retention_data_adjusted)]
    for (i in seq_along(retention_full_data)) {
      colnames(retention_full_data[[i]]) <- cnames
    }
    names(retention_full_data) <- cnames
  }
  return(retention_full_data)
}

# Labeling the decomposed data

labeling <- function(retention_data_decomposed, religion_data) {
  for (i in seq_along(retention_data_decomposed)) {
    rownames(retention_data_decomposed[[i]]) <- rownames(religion_data)
  }
  names(retention_data_decomposed) <- colnames(religion_data)[seq_along(names(retention_data_decomposed))]
  return(retention_data_decomposed)
}


# function for joining decomposed data with labels
#' @noRd

final_decomposition <- function(retention_data, switching_pattern,
                                religion_data, post_switch = FALSE) {
  # Applying retention data adjustment

  retention_data_adjusted <- retention_data_adjustment(retention_data, post_switch)
  retention_data_decomposed <- dataframe_decomposition(
    retention_data_adjusted,
    switching_pattern,
    post_switch,
    total_rows = nrow(religion_data)
  )

  # Labeling the decomposed data

  retention_data_decomposed <- labeling(
    retention_data_decomposed,
    religion_data
  )
  return(retention_data_decomposed)
}

################################################################################

#' @name survivability_adjustment_country
#' @title Adjusting survivability data
#' @description
#' Function for adjusting raw survivability data
#'
#' @param mortality_full_data Data frame; survivability data in the format of `base_data_list$data_survivability`
#' @param code Numeric or character; ISO 3166-1 country code to process, or `"blank"` to process all countries at once (default "blank")
#' @returns Data frame with adjusted data
#' @examples
#' survivability_adjustment_country(mortality_full_data = survivability, code = 4)
#' @noRd

survivability_adjustment_country <- function(mortality_full_data, code = "blank") {
  # Checking if adjustment should be conducted for a single country or for all the countries

  if (code != "blank") {
    mortality_full_data <- mortality_full_data[mortality_full_data[[1]] == code, ]
  }

  # Sorting the survivability data

  mortality_full_data <- dplyr::arrange(mortality_full_data, mortality_full_data[[3]])

  # Changing column names of the survivability data

  colnames <- c("Country_code", "Sex", unique(mortality_full_data[[3]]))

  # Changing the original format of the survivability data to the correct format used in the package

  data_frame_mortality <- data.frame(matrix(data = 0, nrow = 0, ncol = 16))
  timeslist <- unique(mortality_full_data[[3]])
  for (c in unique(mortality_full_data[[1]])) {
    working_matrix <- data.frame(matrix(data = 0, nrow = 42, ncol = 0))
    c_code <- mortality_full_data[1:42, 1]
    sex_vec <- rep(unique(mortality_full_data[[4]]), each = 21)
    for (i in timeslist) {
      if (mortality_full_data[1, 1] == c) {
        vector_mortality <- unlist(c(mortality_full_data[1:21, 7], mortality_full_data[23:43, 7]))
        working_matrix <- cbind(working_matrix, vector_mortality)
        mortality_full_data <- mortality_full_data[-(1:44), ]
      } else {
        working_matrix <- cbind(working_matrix, data.frame(matrix(data = 0, nrow = 42, ncol = 1)))
      }
    }
    working_matrix <- cbind(c_code, sex_vec, working_matrix)
    data_frame_mortality <- rbind(data_frame_mortality, working_matrix)
  }
  colnames(data_frame_mortality) <- colnames
  return(data_frame_mortality)
}

#' @name survivability_adjustment
#' @title Adjusting survivability data
#' @description
#' Function for adjusting raw survivability data with every country calculated separately for better performance
#'
#' @param survivability_data Data frame containing age- and sex-specific survivability rates by country; typically `base_data_list$data_survivability`
#' @returns Data frame with adjusted data
#' @examples
#' survivability_adjustment(survivability_data = survivability)
#' @noRd

survivability_adjustment <- function(survivability_data) {
  # idea 9: lapply + do.call(rbind) — O(n) instead of O(n^2) incremental rbind

  codes <- unique(survivability_data[[1]])
  results <- lapply(codes, survivability_adjustment_country,
    mortality_full_data = survivability_data
  )
  return(do.call(rbind, results))
}
