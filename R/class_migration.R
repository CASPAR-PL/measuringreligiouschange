#' @include class_utilities.R

#' @name Country_object
Country_object$methods(
  #' @name Country_object$separate_migrants
  #' @title Separating migrants
  #' @description
  #' Function for calculating and separating migrant population
  #' @noRd
  separate_migrants = function(post_switch) {
    # Calculating size of migrant population and separating it from the main population

    if (length(outmigration_rates) >= length(structure_data) - 1) {
      if (post_switch) {
        migrant_sum <<- structure_data[[length(structure_data)]] * cbind(outmigration_rates[[length(structure_data) - 1]], outmigration_rates[[length(structure_data) - 1]])
      } else {
        migrant_sum <<- structure_data[[length(structure_data)]] * outmigration_rates[[length(structure_data) - 1]]
      }
    } else {
      if (post_switch) {
        migrant_sum <<- structure_data[[length(structure_data)]] * cbind(outmigration_rates[[length(outmigration_rates)]], outmigration_rates[[length(outmigration_rates)]])
      } else {
        migrant_sum <<- structure_data[[length(structure_data)]] * outmigration_rates[[length(outmigration_rates)]]
      }
    }
    structure_data[[length(structure_data)]] <<- structure_data[[length(structure_data)]] - migrant_sum
  },

  #' @name Country_object$destination_processed_migrants
  #' @title Dividing migrant population
  #' @description
  #' Function for dividing migrant population by destination
  #' @param light_migration Determines if migration data is saved in its light version (logical)
  #' @noRd
  destination_processed_migrants = function(light_migration = TRUE) {
    # Dividing migrant population by destination

    dmatrix <- destination_matrix
    for (row in 1:nrow(dmatrix)) {
      if (sum(dmatrix[row, ]) != 0) {
        dmatrix[row, ] <- dmatrix[row, ] / sum(dmatrix[row, ])
      }
    }
    e_list <- vector("list", 999)
    for (col in colnames(dmatrix)) {
      single_dest <- dmatrix[, col]
      single_dest_male <- c(single_dest[1:(length(single_dest) / 2)], single_dest[1:(length(single_dest) / 2)])
      single_dest_female <- c(single_dest[(length(single_dest) / 2 + 1):length(single_dest)], single_dest[(length(single_dest) / 2 + 1):length(single_dest)])
      mig_male <- t(t(migrant_sum[1:20, ] / 2) * single_dest_male)
      mig_female <- t(t(migrant_sum[21:40, ] / 2) * single_dest_female)
      e_list[[as.numeric(col)]] <- rbind(mig_male, mig_female)
    }
    emigration_list <<- e_list

    if (light_migration) {
      for (i in seq_along(e_list)) {
        if (is.matrix(e_list[[i]])) {
          sums <- colSums(e_list[[i]])
          output <- matrix(data = sums, ncol = ncol(e_list[[i]]), nrow = 1)
          colnames(output) <- colnames(e_list[[i]])
          rownames(output) <- c("Total")
          e_list[[i]] <- output
        }
      }
    }

    em_rows <- list()
    for (i in seq_along(e_list)) {
      if (!is.matrix(e_list[[i]])) next
      mat <- e_list[[i]]
      n <- nrow(mat)
      if (n == 1L) {
        meta <- data.table::data.table(
          Origin = name, Country_code = code, Period = period,
          Structure = "destination_processed", Destination = as.character(i), Region = region
        )
      } else {
        meta <- data.table::data.table(
          Origin = rep(name, n), Country_code = rep(code, n), Period = rep(period, n),
          Structure = rep("destination_processed", n), Destination = rep(as.character(i), n),
          Sex = c(rep(1L, 20L), rep(2L, 20L)), Age_group = rep(age_vector, 2L),
          Region = rep(region, n)
        )
      }
      em_rows[[length(em_rows) + 1L]] <- cbind(meta, data.table::as.data.table(mat))
    }
    if (length(em_rows) > 0L) {
      em_dt <- data.table::rbindlist(em_rows, use.names = TRUE, fill = TRUE)
      if (!is.data.table(previous_emigration)) {
        previous_emigration <<- em_dt
      } else {
        previous_emigration <<- data.table::rbindlist(list(previous_emigration, em_dt),
          use.names = TRUE, fill = TRUE
        )
      }
    }
  },

  #' @name Country_object$origin_processed_migrants
  #' @title Projecting migrant population
  #' @description
  #' Function for calculating switching, fertility and mortality of migrant population and dividing it by destination
  #' @param switching Determines if projection should include switching (logical)
  #' @param switching_type Determines which type of switching should be used in projection (numeric)
  #' @param no_diff Determines if asfr should be differentiated by religion (logical)
  #' @param post_switch Determines if post_switch population is saved in separate columnds (logical)
  #' @param light_migration Determines if migration data is saved in its light version (logical)
  #' @param light_switching Determines if switching data is saved in its light version (logical)
  #' @noRd

  origin_processed_migrants = function(switching = TRUE, switching_type = 1, no_diff = FALSE, post_switch, light_migration = TRUE, light_switching = TRUE) {
    # Choosing migrant population

    dmatrix <- destination_matrix
    for (row in 1:nrow(dmatrix)) {
      if (sum(dmatrix[row, ]) != 0) {
        dmatrix[row, ] <- dmatrix[row, ] / sum(dmatrix[row, ])
      }
    }

    # Calculating fertility, mortality and switching of part of migrant population with country of origin values

    if (switching) {
      if (switching_type == 1) {
        # Dividing migrant population into four parts

        temp[["sw_first_migrants"]] <<- migrant_sum / 4
        temp[["sw_second_migrants"]] <<- migrant_sum / 4

        # Applying switching, mortality and fertility to the first quarter of the population

        switching_step(target = "sw_first_migrants", post_switch = post_switch, light_switching)
        mortality_step(target = "sw_first_migrants")
        fertility_step(target = "sw_first_migrants", no_diff, post_switch = post_switch)

        # Applying mortality, fertility and switching to the first quarter of the population

        mortality_step(target = "sw_second_migrants")
        fertility_step(target = "sw_second_migrants", no_diff, post_switch = post_switch)
        switching_step(target = "sw_second_migrants", post_switch = post_switch, light_switching)

        # Joining two quarters of the migrant population

        mig_sum <- temp[["sw_first_migrants"]] + temp[["sw_second_migrants"]]
      } else {
        # Dividing migrant population into two halves

        temp[["migrants"]] <<- migrant_sum / 2

        # Applying switching, mortality and fertility to the first half of the migrant population

        switching_step(target = "migrants", post_switch = post_switch, light_switching)
        mortality_step(target = "migrants")
        fertility_step(target = "migrants", no_diff = no_diff, post_switch = post_switch)

        mig_sum <- temp[["migrants"]]
      }
    } else {
      # Dividing migrant population into two halves

      temp[["migrants"]] <<- migrant_sum / 2

      # Applying mortality and fertility to the first half of the migrant population

      mortality_step(target = "migrants")
      fertility_step(target = "migrants", no_diff = no_diff, post_switch = post_switch)
      mig_sum <- temp[["migrants"]]
    }


    e_list <- vector("list", 999)

    for (col in colnames(dmatrix)) {
      single_dest <- dmatrix[, col]
      single_dest_male <- c(single_dest[1:(length(single_dest) / 2)], single_dest[1:(length(single_dest) / 2)])
      single_dest_female <- c(single_dest[(length(single_dest) / 2 + 1):length(single_dest)], single_dest[(length(single_dest) / 2 + 1):length(single_dest)])
      mig_male <- t(t(mig_sum[1:20, ]) * single_dest_male)
      mig_female <- t(t(mig_sum[21:40, ]) * single_dest_female)
      e_list[[as.numeric(col)]] <- rbind(mig_male, mig_female)
    }
    emigration_list <<- e_list

    if (light_migration) {
      for (i in seq_along(e_list)) {
        if (is.matrix(e_list[[i]])) {
          sums <- colSums(e_list[[i]])
          output <- matrix(data = sums, ncol = ncol(e_list[[i]]), nrow = 1)
          colnames(output) <- colnames(e_list[[i]])
          rownames(output) <- c("Total")
          e_list[[i]] <- output
        }
      }
    }

    em_rows <- list()
    for (i in seq_along(e_list)) {
      if (!is.matrix(e_list[[i]])) next
      mat <- e_list[[i]]
      n <- nrow(mat)
      if (n == 1L) {
        meta <- data.table::data.table(
          Origin = name, Country_code = code, Period = period,
          Structure = "origin_processed", Destination = as.character(i), Region = region
        )
      } else {
        meta <- data.table::data.table(
          Origin = rep(name, n), Country_code = rep(code, n), Period = rep(period, n),
          Structure = rep("origin_processed", n), Destination = rep(as.character(i), n),
          Sex = c(rep(1L, 20L), rep(2L, 20L)), Age_group = rep(age_vector, 2L),
          Region = rep(region, n)
        )
      }
      em_rows[[length(em_rows) + 1L]] <- cbind(meta, data.table::as.data.table(mat))
    }
    if (length(em_rows) > 0L) {
      em_dt <- data.table::rbindlist(em_rows, use.names = TRUE, fill = TRUE)
      previous_emigration <<- data.table::rbindlist(list(previous_emigration, em_dt),
        use.names = TRUE, fill = TRUE
      )
    }
  }
)
