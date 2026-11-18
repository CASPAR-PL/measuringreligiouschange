#' @include projection_class_utilities.R

Projection_object$methods(
  list(
    project = function(progress_bar = TRUE, save_totals = TRUE) {
      if (resolved) {
        return("Projection was already calculated!")
      }
      start_time <- proc.time()

      if (progress_bar) {
        if (migration) {
          pb <- progress::progress_bar$new(
            format = paste("Projection of ", as.character(steps), " steps [:bar] :percent Estimated time left: :eta", sep = ""),
            total = steps * length(country_object_list) * 5, clear = FALSE, width = 120
          )
        } else {
          pb <- progress::progress_bar$new(
            format = paste("Projection of ", as.character(steps), " steps [:bar] :percent Estimated time left: :eta", sep = ""),
            total = steps * length(country_object_list), clear = FALSE, width = 120
          )
        }
      }

      # Build code -> country lookup (O(1) dest lookup in push_immigration)
      country_by_code <- vector("list", 999L)
      country_idx_by_code <- integer(999L)
      for (.k in seq_along(country_object_list)) {
        .co <- country_object_list[[.k]]
        country_by_code[[.co$code]] <- .co
        country_idx_by_code[[as.integer(.co$code)]] <- .k
      }

      push_immigration <- function(structure_label) {
        for (origin in country_object_list) {
          em_list <- origin$emigration_list
          origin_code <- origin$code

          for (dest_code in seq_along(em_list)) {
            if (!is.matrix(em_list[[dest_code]])) next
            ki <- country_idx_by_code[[dest_code]]
            if (ki == 0L) next
            destination <- country_object_list[[ki]]

            mig_data <- em_list[[dest_code]]

            n_sd <- length(destination$structure_data)
            destination$structure_data[[n_sd]] <- destination$structure_data[[n_sd]] + mig_data

            if (light_migration) {
              mig_data <- matrix(
                colSums(mig_data), 1L, ncol(mig_data),
                dimnames = list("Total", colnames(mig_data))
              )
            }

            n <- nrow(mig_data)
            if (n == 1L) {
              meta <- data.table::data.table(
                Destination  = destination$name,
                Country_code = destination$code,
                Period       = destination$period,
                Structure    = structure_label,
                Origin       = as.character(origin_code),
                Region       = destination$region
              )
            } else {
              meta <- data.table::data.table(
                Destination  = rep(destination$name, n),
                Country_code = rep(destination$code, n),
                Period       = rep(destination$period, n),
                Structure    = rep(structure_label, n),
                Origin       = rep(as.character(origin_code), n),
                Sex          = c(rep(1L, 20L), rep(2L, 20L)),
                Age_group    = rep(age_vector, 2L),
                Region       = rep(destination$region, n)
              )
            }
            im_row <- cbind(meta, data.table::as.data.table(mig_data))
            if (!is.data.table(destination$previous_immigration)) {
              destination$previous_immigration <- im_row
            } else {
              destination$previous_immigration <- data.table::rbindlist(
                list(destination$previous_immigration, im_row),
                use.names = TRUE, fill = TRUE
              )
            }
          }
        }
      }

      if (migration) {
        for (i in 1:steps) {
          for (country in country_object_list) {
            country$dem_proj_migration(1, switching, switching_type, no_diff, post_switch, light_migration, light_switching)
            if (progress_bar) pb$tick()
          }
          push_immigration("destination_processed")
          if (progress_bar) pb$tick()
          for (country in country_object_list) {
            country$dem_proj_migration(2, switching, switching_type, no_diff, post_switch, light_migration, light_switching)
            if (progress_bar) pb$tick()
          }
          push_immigration("origin_processed")
          for (country in country_object_list) {
            country$dem_proj_migration(3, switching, switching_type, no_diff, post_switch, light_migration, light_switching)
            if (progress_bar) pb$tick()
          }
        }
      } else {
        for (i in 1:steps) {
          for (country in country_object_list) {
            country$dem_proj_no_mig(switching, switching_type, no_diff, post_switch, light_switching)
            if (progress_bar) pb$tick()
          }
        }
      }

      if (save_totals) {
        calculate_region_totals(progress_bar)
        calculate_global_totals(progress_bar)
      }

      end_time <- proc.time()
      print("Projection completed in:")
      print(end_time - start_time)

      resolved <<- TRUE
    }
  )
)
