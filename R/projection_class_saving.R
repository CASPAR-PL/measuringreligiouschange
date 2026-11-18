#' @include projection_class_project.R

Projection_object$methods(
  list(
    #' @name Projection_object$save_csv_structure
    #' @title Saving structure data
    #' @description
    #' Function for saving structure_data to .csv file
    #' @param filename Character; name of the .csv file in which data should be saved (no default)
    #' @param folder Character; name of the directory in which the .csv file should be saved (no default)
    #' @param order_by_name Logical; if TRUE, countries are sorted alphabetically by name in the saved file (no default)
    #' @param progress_bar Logical; whether to show a progress bar during saving (no default)
    #' @return Called for its side effects. Writes population structure data to a CSV file in `folder`.
    #' @noRd
    save_csv_structure_helper = function(objects,
                                         filename,
                                         folder,
                                         order_by_name,
                                         progress_bar) {
      dir.create(folder, showWarnings = FALSE)
      print("Saving structure data to csv")

      # Choosing correct object_list (countries or regions)

      if (objects == "countries") {
        object_list <- country_object_list
      } else {
        object_list <- region_object_list
      }

      # Specifying if progress bar should be shown and estimates the time needed for saving all of the matrices

      if (progress_bar) {
        matrices <- length(object_list) * length(object_list[[1]]$structure_data)
        pb <- progress::progress_bar$new(
          format = paste(
            "Saving structure data to .csv [:bar] :percent Estimated time left: :eta Total matrices: ",
            as.character(matrices),
            sep = ""
          ),
          total = matrices, clear = FALSE, width = 120
        )
      }

      # creating dataframe for saving

      dtcsv <- data.table::data.table(matrix(data = NA, nrow = 0, ncol = (5 + ncol(object_list[[1]]$structure_data[[1]]))))
      colnames(dtcsv) <- c("Country", "Country_code", "Year", "Sex", "Age_group", colnames(object_list[[1]]$structure_data[[1]]))
      if (objects == "regions") {
        colnames(dtcsv)[2] <- "Region_code"
      }
      for (j in c(1L, 4L, 5L)) set(dtcsv, j = j, value = character(0))
      for (j in c(2L, 3L, seq.int(6L, ncol(dtcsv)))) set(dtcsv, j = j, value = numeric(0))
      nrows <- nrow(object_list[[1]]$structure_data[[1]])

      if (order_by_name) {
        if (objects == "countries") {
          order <- order_countries_alphabetical()
        } else {
          order <- order_countries_alphabetical(regions = TRUE)
        }
      } else {
        order <- seq_along(object_list)
      }

      for (id in order) {
        country <- object_list[[id]]

        for (year in seq_along(country$structure_data)) {
          country_vector <- rep(country$name, nrows)
          if (objects == "countries") {
            country_code_vector <- rep(country$code, nrows)
          } else {
            country_code_vector <- rep(country$region, nrows)
          }

          year_vector <- rep(as.numeric(names(country$structure_data)[year]), nrows)
          structure_data <- data.table::data.table(country$structure_data[[year]])
          rownames(structure_data) <- NULL

          dt <- data.table::data.table(Country = country_vector, Country_code = country_code_vector, Year = year_vector, Sex = sex_vector, Age_group = age_vector)
          if (objects == "regions") {
            colnames(dt)[2] <- "Region_code"
          }
          dt <- cbind(dt, structure_data)

          dtcsv <- data.table::rbindlist(list(dtcsv, dt))
          if (progress_bar) {
            pb$tick()
          }
        }
      }

      # saving dataframe to .csv

      if (objects == "countries") {
        write.csv(dtcsv, paste(folder, filename, sep = "/"), row.names = FALSE)
      } else {
        write.csv(dtcsv, paste(folder, paste("regions", filename, sep = "_"), sep = "/"), row.names = FALSE)
      }

      print("Data saved")
    },
    save_csv_structure = function(objects = list("countries", "regions"),
                                  filename = "projection_structure_data.csv",
                                  folder = projection_name,
                                  order_by_name = FALSE,
                                  progress_bar = TRUE) {
      # Checking the chosen object_list and executing the saving process

      if ("countries" %in% objects) {
        save_csv_structure_helper(
          "countries",
          filename,
          folder,
          order_by_name,
          progress_bar
        )
      }

      if ("regions" %in% objects) {
        save_csv_structure_helper(
          "regions",
          filename,
          folder,
          order_by_name,
          progress_bar
        )
      }

      if (!"countries" %in% objects & !"regions" %in% objects) {
        print("Incorrect objects")
      }
    },


    #' @name Projection_object$save_csv_births
    #' @title Saving fertility data
    #' @description
    #' Function for saving previous_fertility to .csv file
    #' @param filename Character; name of the .csv file in which data should be saved (no default)
    #' @param folder Character; name of the directory in which the .csv file should be saved (no default)
    #' @param order_by_name Logical; if TRUE, countries are sorted alphabetically by name in the saved file (no default)
    #' @param progress_bar Logical; whether to show a progress bar during saving (no default)
    #' @return Called for its side effects. Writes fertility (births) data to a CSV file in `folder`.
    #' @noRd

    save_csv_births_helper = function(objects,
                                      filename,
                                      folder,
                                      order_by_name,
                                      progress_bar) {
      dir.create(folder, showWarnings = FALSE)
      print("Saving fertility data to csv")

      if (objects == "countries") {
        object_list <- country_object_list
      } else {
        object_list <- region_object_list
      }

      if (order_by_name) {
        if (objects == "countries") {
          order <- order_countries_alphabetical()
        } else {
          order <- order_countries_alphabetical(regions = TRUE)
        }
      } else {
        order <- seq_along(object_list)
      }

      if (progress_bar) {
        pb <- progress::progress_bar$new(
          format = paste("Saving fertility data to .csv [:bar] :percent Estimated time left: :eta Total countries: ",
            length(order),
            sep = ""
          ),
          total = length(order), clear = FALSE, width = 120
        )
      }

      dtcsv <- NULL

      for (id in order) {
        country <- object_list[[id]]
        dt <- data.table::copy(country$previous_fertility)
        if (!is.null(dt) && is.data.table(dt) && nrow(dt) > 0L) {
          if (objects == "regions") {
            dt[, Country_code := country$region]
            data.table::setnames(dt, "Country_code", "Region_code")
          }
          dtcsv <- if (is.null(dtcsv)) dt else data.table::rbindlist(list(dtcsv, dt), use.names = TRUE, fill = TRUE)
        }
        if (progress_bar) pb$tick()
      }

      if (objects == "countries") {
        write.csv(dtcsv, paste(folder, filename, sep = "/"), row.names = FALSE)
      } else {
        write.csv(dtcsv, paste(folder, paste("regions", filename, sep = "_"), sep = "/"), row.names = FALSE)
      }

      print("Data saved")
    },
    save_csv_births = function(objects = list("countries", "regions"),
                               filename = "projection_births_data.csv",
                               folder = projection_name,
                               order_by_name = FALSE,
                               progress_bar = TRUE) {
      # Checking the chosen object_list and executing the saving process

      if ("countries" %in% objects) {
        save_csv_births_helper(
          "countries",
          filename,
          folder,
          order_by_name,
          progress_bar
        )
      }

      if ("regions" %in% objects) {
        save_csv_births_helper(
          "regions",
          filename,
          folder,
          order_by_name,
          progress_bar
        )
      }

      if (!"countries" %in% objects & !"regions" %in% objects) {
        print("Incorrect objects")
      }
    },

    #' @name Projection_object$save_csv_deaths
    #' @title Saving mortality data
    #' @description
    #' Function for saving previous_mortality to .csv file
    #' @param filename Character; name of the .csv file in which data should be saved (no default)
    #' @param folder Character; name of the directory in which the .csv file should be saved (no default)
    #' @param order_by_name Logical; if TRUE, countries are sorted alphabetically by name in the saved file (no default)
    #' @param progress_bar Logical; whether to show a progress bar during saving (no default)
    #' @return Called for its side effects. Writes mortality data to a CSV file in `folder`.
    #' @noRd

    save_csv_deaths_helper = function(objects,
                                      filename,
                                      folder,
                                      order_by_name,
                                      progress_bar) {
      dir.create(folder, showWarnings = FALSE)
      print("Saving mortality data to csv")

      if (objects == "countries") {
        object_list <- country_object_list
      } else {
        object_list <- region_object_list
      }

      if (order_by_name) {
        if (objects == "countries") {
          order <- order_countries_alphabetical()
        } else {
          order <- order_countries_alphabetical(regions = TRUE)
        }
      } else {
        order <- seq_along(object_list)
      }

      if (progress_bar) {
        pb <- progress::progress_bar$new(
          format = paste("Saving deaths data to .csv [:bar] :percent Estimated time left: :eta Total countries: ",
            length(order),
            sep = ""
          ),
          total = length(order), clear = FALSE, width = 120
        )
      }

      dtcsv <- NULL

      for (id in order) {
        country <- object_list[[id]]
        dt <- data.table::copy(country$previous_mortality)
        if (!is.null(dt) && is.data.table(dt) && nrow(dt) > 0L) {
          if (objects == "regions") {
            dt[, Country_code := country$region]
            data.table::setnames(dt, "Country_code", "Region_code")
          }
          dtcsv <- if (is.null(dtcsv)) dt else data.table::rbindlist(list(dtcsv, dt), use.names = TRUE, fill = TRUE)
        }
        if (progress_bar) pb$tick()
      }

      if (objects == "countries") {
        write.csv(dtcsv, paste(folder, filename, sep = "/"), row.names = FALSE)
      } else {
        write.csv(dtcsv, paste(folder, paste("regions", filename, sep = "_"), sep = "/"), row.names = FALSE)
      }

      print("Data saved")
    },
    save_csv_deaths = function(objects = list("countries", "regions"),
                               filename = "projection_deaths_data.csv",
                               folder = projection_name,
                               order_by_name = FALSE,
                               progress_bar = TRUE) {
      # Checking the chosen object_list and executing the saving process

      if ("countries" %in% objects) {
        save_csv_deaths_helper(
          "countries",
          filename,
          folder,
          order_by_name,
          progress_bar
        )
      }

      if ("regions" %in% objects) {
        save_csv_deaths_helper(
          "regions",
          filename,
          folder,
          order_by_name,
          progress_bar
        )
      }

      if (!"countries" %in% objects & !"regions" %in% objects) {
        print("Incorrect objects")
      }
    },

    #' @name Projection_object$save_csv_asfr
    #' @title Saving asfr data
    #' @description
    #' Function for saving previous_asfr to .csv file
    #' @param filename Character; name of the .csv file in which data should be saved (no default)
    #' @param folder Character; name of the directory in which the .csv file should be saved (no default)
    #' @param order_by_name Logical; if TRUE, countries are sorted alphabetically by name in the saved file (no default)
    #' @param progress_bar Logical; whether to show a progress bar during saving (no default)
    #' @return Called for its side effects. Writes age-specific fertility rate data to a CSV file in `folder`.
    #' @noRd

    save_csv_asfr_helper = function(objects,
                                    filename,
                                    folder,
                                    order_by_name,
                                    progress_bar) {
      dir.create(folder, showWarnings = FALSE)
      print("Saving ASFR data to csv")

      if (objects == "countries") {
        object_list <- country_object_list
      } else {
        object_list <- region_object_list
      }

      if (order_by_name) {
        if (objects == "countries") {
          order <- order_countries_alphabetical()
        } else {
          order <- order_countries_alphabetical(regions = TRUE)
        }
      } else {
        order <- seq_along(object_list)
      }

      if (progress_bar) {
        pb <- progress::progress_bar$new(
          format = paste("Saving ASFR data to .csv [:bar] :percent Estimated time left: :eta Total countries: ",
            length(order),
            sep = ""
          ),
          total = length(order), clear = FALSE, width = 120
        )
      }

      dtcsv <- NULL

      for (id in order) {
        country <- object_list[[id]]
        dt <- data.table::copy(country$previous_asfr)
        if (!is.null(dt) && is.data.table(dt) && nrow(dt) > 0L) {
          if (objects == "regions") {
            dt[, Country_code := country$region]
            data.table::setnames(dt, "Country_code", "Region_code")
          }
          dtcsv <- if (is.null(dtcsv)) dt else data.table::rbindlist(list(dtcsv, dt), use.names = TRUE, fill = TRUE)
        }
        if (progress_bar) pb$tick()
      }

      if (objects == "countries") {
        write.csv(dtcsv, paste(folder, filename, sep = "/"), row.names = FALSE)
      } else {
        write.csv(dtcsv, paste(folder, paste("regions", filename, sep = "_"), sep = "/"), row.names = FALSE)
      }

      print("Data saved")
    },
    save_csv_asfr = function(objects = list("countries", "regions"),
                             filename = "projection_asfr_data.csv",
                             folder = projection_name,
                             order_by_name = FALSE,
                             progress_bar = TRUE) {
      # Checking the chosen object_list and executing the saving process

      if ("countries" %in% objects) {
        save_csv_asfr_helper(
          "countries",
          filename,
          folder,
          order_by_name,
          progress_bar
        )
      }

      if ("regions" %in% objects) {
        save_csv_asfr_helper(
          "regions",
          filename,
          folder,
          order_by_name,
          progress_bar
        )
      }

      if (!"countries" %in% objects & !"regions" %in% objects) {
        print("Incorrect objects")
      }
    },

    #' @name Projection_object$save_csv_fertility_exposure
    #' @title Saving women population data
    #' @description
    #' Function for saving previous_fertility_exposure to .csv file
    #' @param filename Character; name of the .csv file in which data should be saved (no default)
    #' @param folder Character; name of the directory in which the .csv file should be saved (no default)
    #' @param order_by_name Logical; if TRUE, countries are sorted alphabetically by name in the saved file (no default)
    #' @param progress_bar Logical; whether to show a progress bar during saving (no default)
    #' @return Called for its side effects. Writes fertile women population exposure data to a CSV file in `folder`.
    #' @noRd

    save_csv_fertility_exposure_helper = function(objects,
                                                  filename,
                                                  folder,
                                                  order_by_name,
                                                  progress_bar) {
      dir.create(folder, showWarnings = FALSE)
      print("Saving fertile women population data to csv")

      if (objects == "countries") {
        object_list <- country_object_list
      } else {
        object_list <- region_object_list
      }

      if (order_by_name) {
        if (objects == "countries") {
          order <- order_countries_alphabetical()
        } else {
          order <- order_countries_alphabetical(regions = TRUE)
        }
      } else {
        order <- seq_along(object_list)
      }

      if (progress_bar) {
        pb <- progress::progress_bar$new(
          format = paste("Saving fertility exposure data to .csv [:bar] :percent Estimated time left: :eta Total countries: ",
            length(order),
            sep = ""
          ),
          total = length(order), clear = FALSE, width = 120
        )
      }

      dtcsv <- NULL

      for (id in order) {
        country <- object_list[[id]]
        dt <- data.table::copy(country$previous_fertility_exposure)
        if (!is.null(dt) && is.data.table(dt) && nrow(dt) > 0L) {
          if (objects == "regions") {
            dt[, Country_code := country$region]
            data.table::setnames(dt, "Country_code", "Region_code")
          }
          dtcsv <- if (is.null(dtcsv)) dt else data.table::rbindlist(list(dtcsv, dt), use.names = TRUE, fill = TRUE)
        }
        if (progress_bar) pb$tick()
      }

      if (objects == "countries") {
        write.csv(dtcsv, paste(folder, filename, sep = "/"), row.names = FALSE)
      } else {
        write.csv(dtcsv, paste(folder, paste("regions", filename, sep = "_"), sep = "/"), row.names = FALSE)
      }

      print("Data saved")
    },
    save_csv_fertility_exposure = function(objects = list("countries", "regions"),
                                           filename = "projection_fertility_exposure_data.csv",
                                           folder = projection_name,
                                           order_by_name = FALSE,
                                           progress_bar = TRUE) {
      # Checking the chosen object_list and executing the saving process

      if ("countries" %in% objects) {
        save_csv_fertility_exposure_helper(
          "countries",
          filename,
          folder,
          order_by_name,
          progress_bar
        )
      }

      if ("regions" %in% objects) {
        save_csv_fertility_exposure_helper(
          "regions",
          filename,
          folder,
          order_by_name,
          progress_bar
        )
      }

      if (!"countries" %in% objects & !"regions" %in% objects) {
        print("Incorrect objects")
      }
    },

    #' @name Projection_object$save_csv_fertility_differentials
    #' @title Saving fertility differentials data
    #' @description
    #' Function for saving fertility_differentials to .csv file
    #' @param filename Character; name of the .csv file in which data should be saved (no default)
    #' @param folder Character; name of the directory in which the .csv file should be saved (no default)
    #' @param order_by_name Logical; if TRUE, countries are sorted alphabetically by name in the saved file (no default)
    #' @param progress_bar Logical; whether to show a progress bar during saving (no default)
    #' @return Called for its side effects. Writes fertility differentials data to a CSV file in `folder`.
    #' @noRd

    save_csv_fertility_differentials = function(filename = "projection_fertility_differentials.csv",
                                                folder = projection_name,
                                                order_by_name = FALSE,
                                                progress_bar = TRUE) {
      dir.create(folder, showWarnings = FALSE)
      print("Saving fertility differentials to csv")

      # Specifying if progress bar should be shown and estimates the time needed for saving all of the matrices


      if (progress_bar) {
        matrices <- length(country_object_list) * length(country_object_list[[1]]$fertility_differentials)
        pb <- progress::progress_bar$new(
          format = paste(
            "Saving fertility differentials to .csv [:bar] :percent Estimated time left: :eta Total matrices: ",
            as.character(matrices),
            sep = ""
          ),
          total = matrices, clear = FALSE, width = 120
        )
      }

      # creating dataframe for saving

      dtcsv <- data.table::data.table(matrix(data = NA, nrow = 0, ncol = (4 + ncol(country_object_list[[1]]$fertility_differentials[[1]]))))
      colnames(dtcsv) <- c("Country", "Country_code", "Period", "Age_group", colnames(country_object_list[[1]]$fertility_differentials[[1]]))
      for (j in c(1L, 3L, 4L)) set(dtcsv, j = j, value = character(0))
      for (j in c(2L, seq.int(5L, ncol(dtcsv)))) set(dtcsv, j = j, value = numeric(0))

      if (order_by_name) {
        order <- order_countries_alphabetical()
      } else {
        order <- seq_along(country_object_list)
      }

      nrows <- nrow(country_object_list[[1]]$fertility_differentials[[1]])

      for (id in order) {
        country <- country_object_list[[id]]

        for (period in seq_along(country$fertility_differentials)) {
          country_vector <- rep(country$name, nrows)
          country_code_vector <- rep(country$code, nrows)

          year_vector <- rep(names(country$fertility_differentials)[period], nrows)
          fertility_differentials <- data.table::data.table(country$fertility_differentials[[period]])
          rownames(fertility_differentials) <- NULL

          dt <- data.table::data.table(Country = country_vector, Country_code = country_code_vector, Period = year_vector, Age_group = age_vector_women_population)
          dt <- cbind(dt, fertility_differentials)

          dtcsv <- data.table::rbindlist(list(dtcsv, dt))
          if (progress_bar) {
            pb$tick()
          }
        }
      }

      # saving dataframe to .csv

      write.csv(dtcsv, paste(folder, filename, sep = "/"), row.names = FALSE)
      print("Data saved")
    },

    #' @name Projection_object$save_csv_switching_matrices
    #' @title Saving switching matrices
    #' @description
    #' Function for saving switching_matrices_list to .csv file
    #' @param filename Character; name of the .csv file in which data should be saved (no default)
    #' @param folder Character; name of the directory in which the .csv file should be saved (no default)
    #' @param order_by_name Logical; if TRUE, countries are sorted alphabetically by name in the saved file (no default)
    #' @param progress_bar Logical; whether to show a progress bar during saving (no default)
    #' @return Called for its side effects. Writes switching probability matrices to a CSV file in `folder`.
    #' @noRd

    save_csv_switching_matrices = function(filename = "projection_switching_matrices.csv",
                                           folder = projection_name,
                                           order_by_name = FALSE,
                                           progress_bar = TRUE) {
      dir.create(folder, showWarnings = FALSE)
      print("Saving switching matrices to csv")

      if (order_by_name) {
        order <- order_countries_alphabetical()
      } else {
        order <- seq_along(country_object_list)
      }

      if (progress_bar) {
        pb <- progress::progress_bar$new(
          format = paste("Saving switching matrices to .csv [:bar] :percent Estimated time left: :eta Total countries: ",
            length(order),
            sep = ""
          ),
          total = length(order), clear = FALSE, width = 120
        )
      }

      dtcsv <- NULL

      for (id in order) {
        country <- country_object_list[[id]]
        sw_list <- country$switching_matrices_list
        if (length(sw_list) == 0L) {
          if (progress_bar) pb$tick()
          next
        }

        n <- nrow(sw_list[[1]])
        sw_names <- names(sw_list)

        country_rows <- lapply(seq_along(sw_list), function(r) {
          mat <- sw_list[[r]]
          meta <- data.table::data.table(
            Country         = rep(country$name, n),
            Country_code    = rep(country$code, n),
            Sex             = sex_vector[1:n],
            Age_group       = age_vector[1:n],
            Origin_religion = rep(sw_names[r], n)
          )
          cbind(meta, data.table::as.data.table(mat))
        })

        country_dt <- data.table::rbindlist(country_rows, use.names = TRUE, fill = TRUE)
        dtcsv <- if (is.null(dtcsv)) {
          country_dt
        } else {
          data.table::rbindlist(list(dtcsv, country_dt), use.names = TRUE, fill = TRUE)
        }
        if (progress_bar) pb$tick()
      }

      write.csv(dtcsv, paste(folder, filename, sep = "/"), row.names = FALSE)
      print("Data saved")
    },

    #' @name Projection_object$save_csv_switchers
    #' @title Saving switching data
    #' @description
    #' Function for saving previous_switching to .csv file
    #' @param filename Character; name of the .csv file in which data should be saved (no default)
    #' @param folder Character; name of the directory in which the .csv file should be saved (no default)
    #' @param order_by_name Logical; if TRUE, countries are sorted alphabetically by name in the saved file (no default)
    #' @param progress_bar Logical; whether to show a progress bar during saving (no default)
    #' @return Called for its side effects. Writes religious switching (switchers) data to a CSV file in `folder`.
    #' @noRd

    save_csv_switchers_helper = function(objects,
                                         filename = "projection_switchers_data.csv",
                                         folder = projection_name,
                                         order_by_name = FALSE,
                                         progress_bar = TRUE) {
      dir.create(folder, showWarnings = FALSE)
      print("Saving switching data to csv")

      if (objects == "countries") {
        object_list <- country_object_list
      } else {
        object_list <- region_object_list
      }

      if (order_by_name) {
        if (objects == "countries") {
          order <- order_countries_alphabetical()
        } else {
          order <- order_countries_alphabetical(regions = TRUE)
        }
      } else {
        order <- seq_along(object_list)
      }

      if (progress_bar) {
        pb <- progress::progress_bar$new(
          format = paste("Saving switching data to .csv [:bar] :percent Estimated time left: :eta Total countries: ",
            length(order),
            sep = ""
          ),
          total = length(order), clear = FALSE, width = 120
        )
      }

      dtcsv <- NULL

      for (id in order) {
        country <- object_list[[id]]
        dt <- data.table::copy(country$previous_switching)
        if (!is.null(dt) && is.data.table(dt) && nrow(dt) > 0L) {
          if (objects == "regions") {
            dt[, Country_code := country$region]
            data.table::setnames(dt, "Country_code", "Region_code")
          }
          dtcsv <- if (is.null(dtcsv)) dt else data.table::rbindlist(list(dtcsv, dt), use.names = TRUE, fill = TRUE)
        }
        if (progress_bar) pb$tick()
      }

      if (objects == "countries") {
        write.csv(dtcsv, paste(folder, filename, sep = "/"), row.names = FALSE)
      } else {
        write.csv(dtcsv, paste(folder, paste("regions", filename, sep = "_"), sep = "/"), row.names = FALSE)
      }

      print("Data saved")
    },
    save_csv_switchers = function(objects = list("countries", "regions"),
                                  filename = "projection_switchers_data.csv",
                                  folder = projection_name,
                                  order_by_name = FALSE,
                                  progress_bar = TRUE) {
      # Checking the chosen object_list and executing the saving process

      if ("countries" %in% objects) {
        save_csv_switchers_helper(
          "countries",
          filename,
          folder,
          order_by_name,
          progress_bar
        )
      }

      if ("regions" %in% objects) {
        save_csv_switchers_helper(
          "regions",
          filename,
          folder,
          order_by_name,
          progress_bar
        )
      }

      if (!"countries" %in% objects & !"regions" %in% objects) {
        print("Incorrect objects")
      }
    },

    #' @name Projection_object$save_csv_emigration
    #' @title Saving emigration data
    #' @description
    #' Function for saving previous_emigration to .csv file
    #' @param filename Character; name of the .csv file in which data should be saved (no default)
    #' @param folder Character; name of the directory in which the .csv file should be saved (no default)
    #' @param order_by_name Logical; if TRUE, countries are sorted alphabetically by name in the saved file (no default)
    #' @param progress_bar Logical; whether to show a progress bar during saving (no default)
    #' @return Called for its side effects. Writes emigration data to a CSV file in `folder`.
    #' @noRd

    save_csv_emigration_helper = function(objects,
                                          filename,
                                          folder,
                                          order_by_name,
                                          progress_bar) {
      dir.create(folder, showWarnings = FALSE)
      print("Saving emigration data to csv")

      if (objects == "countries") {
        object_list <- country_object_list
      } else {
        object_list <- region_object_list
      }

      if (order_by_name) {
        if (objects == "countries") {
          order <- order_countries_alphabetical()
        } else {
          order <- order_countries_alphabetical(regions = TRUE)
        }
      } else {
        order <- seq_along(object_list)
      }

      if (progress_bar) {
        pb <- progress::progress_bar$new(
          format = paste("Saving emigration data to .csv [:bar] :percent Estimated time left: :eta Total countries: ",
            length(order),
            sep = ""
          ),
          total = length(order), clear = FALSE, width = 120
        )
      }

      dtcsv <- NULL

      for (id in order) {
        country <- object_list[[id]]
        dt <- data.table::copy(country$previous_emigration)
        if (!is.null(dt) && is.data.table(dt) && nrow(dt) > 0L) {
          if (objects == "regions") {
            dt[, Country_code := country$region]
            data.table::setnames(dt, "Country_code", "Region_code")
          }
          dtcsv <- if (is.null(dtcsv)) dt else data.table::rbindlist(list(dtcsv, dt), use.names = TRUE, fill = TRUE)
        }
        if (progress_bar) pb$tick()
      }

      if (objects == "countries") {
        write.csv(dtcsv, paste(folder, filename, sep = "/"), row.names = FALSE)
      } else {
        write.csv(dtcsv, paste(folder, paste("regions", filename, sep = "_"), sep = "/"), row.names = FALSE)
      }

      print("Data saved")
    },
    save_csv_emigration = function(objects = list("countries", "regions"),
                                   filename = "projection_emigration_data.csv",
                                   folder = projection_name,
                                   order_by_name = FALSE,
                                   progress_bar = TRUE) {
      # Checking the chosen object_list and executing the saving process

      if ("countries" %in% objects) {
        save_csv_emigration_helper(
          "countries",
          filename,
          folder,
          order_by_name,
          progress_bar
        )
      }

      if ("regions" %in% objects) {
        save_csv_emigration_helper(
          "regions",
          filename,
          folder,
          order_by_name,
          progress_bar
        )
      }

      if (!"countries" %in% objects & !"regions" %in% objects) {
        print("Incorrect objects")
      }
    },

    #' @name Projection_object$save_csv_immigration
    #' @title Saving immigration data
    #' @description
    #' Function for saving previous_immigration to .csv file
    #' @param filename Character; name of the .csv file in which data should be saved (no default)
    #' @param folder Character; name of the directory in which the .csv file should be saved (no default)
    #' @param order_by_name Logical; if TRUE, countries are sorted alphabetically by name in the saved file (no default)
    #' @param progress_bar Logical; whether to show a progress bar during saving (no default)
    #' @return Called for its side effects. Writes immigration data to a CSV file in `folder`.
    #' @noRd

    save_csv_immigration_helper = function(objects,
                                           filename = "projection_immigration_data.csv",
                                           folder = projection_name,
                                           order_by_name = FALSE,
                                           progress_bar = TRUE) {
      dir.create(folder, showWarnings = FALSE)
      print("Saving immigration data to csv")

      if (objects == "countries") {
        object_list <- country_object_list
      } else {
        object_list <- region_object_list
      }

      if (order_by_name) {
        if (objects == "countries") {
          order <- order_countries_alphabetical()
        } else {
          order <- order_countries_alphabetical(regions = TRUE)
        }
      } else {
        order <- seq_along(object_list)
      }

      if (progress_bar) {
        pb <- progress::progress_bar$new(
          format = paste("Saving immigration data to .csv [:bar] :percent Estimated time left: :eta Total countries: ",
            length(order),
            sep = ""
          ),
          total = length(order), clear = FALSE, width = 120
        )
      }

      dtcsv <- NULL

      for (id in order) {
        country <- object_list[[id]]
        dt <- data.table::copy(country$previous_immigration)
        if (!is.null(dt) && is.data.table(dt) && nrow(dt) > 0L) {
          if (objects == "regions") {
            dt[, Country_code := country$region]
            data.table::setnames(dt, "Country_code", "Region_code")
          }
          dtcsv <- if (is.null(dtcsv)) dt else data.table::rbindlist(list(dtcsv, dt), use.names = TRUE, fill = TRUE)
        }
        if (progress_bar) pb$tick()
      }

      if (objects == "countries") {
        write.csv(dtcsv, paste(folder, filename, sep = "/"), row.names = FALSE)
      } else {
        write.csv(dtcsv, paste(folder, paste("regions", filename, sep = "_"), sep = "/"), row.names = FALSE)
      }

      print("Data saved")
    },
    save_csv_immigration = function(objects = list("countries", "regions"),
                                    filename = "projection_immigration_data.csv",
                                    folder = projection_name,
                                    order_by_name = FALSE,
                                    progress_bar = TRUE) {
      # Checking the chosen object_list and executing the saving process

      if ("countries" %in% objects) {
        save_csv_immigration_helper(
          "countries",
          filename,
          folder,
          order_by_name,
          progress_bar
        )
      }

      if ("regions" %in% objects) {
        save_csv_immigration_helper(
          "regions",
          filename,
          folder,
          order_by_name,
          progress_bar
        )
      }

      if (!"countries" %in% objects & !"regions" %in% objects) {
        print("Incorrect objects")
      }
    },

    #' @name Projection_object$save_csv_all
    #' @title Saving all projection data to .csv files
    #' @description
    #' Function for saving data from projection to .csv files
    #' @param filenames_vector Character vector of length 10; output file names in order: structure data, fertility, ASFRs, fertility exposure, fertility differentials, deaths, emigration, immigration, switching matrices, switchers (no default)
    #' @param folder Character; name of the directory in which files should be saved (no default)
    #' @param demographic_files Logical; if TRUE, saves structure, fertility, mortality, ASFR and women-population data (no default)
    #' @param switching_files Logical; if TRUE, saves switching matrices and switcher data (no default)
    #' @param migration_files Logical; if TRUE, saves emigration and immigration data (defaults to the object's `migration` flag)
    #' @param order_by_name Logical; if TRUE, countries are sorted alphabetically by name in the saved files (no default)
    #' @param progress_bar Logical; whether to show a progress bar during saving (no default)
    #' @param light_mig Logical; if TRUE, saves migration data in abbreviated form (no default)
    #' @return Called for its side effects. Writes all selected projection outputs to CSV files in `folder` and prints the total time taken.

    save_csv_all = function(objects = list("countries", "regions"),
                            filenames_vector = c(
                              "projection_structure_data.csv",
                              "projection_births_data.csv",
                              "projection_asfr_data.csv",
                              "projection_fertility_exposure_data.csv",
                              "projection_fertility_differentials.csv",
                              "projection_deaths_data.csv",
                              "projection_emigration_data.csv",
                              "projection_immigration_data.csv",
                              "projection_switching_matrices.csv",
                              "projection_switchers_data.csv"
                            ), folder = projection_name,
                            demographic_files = TRUE,
                            switching_files = switching,
                            migration_files = migration,
                            order_by_name = FALSE,
                            progress_bar = TRUE,
                            light_mig = TRUE) {
      # Starts counting time of saving

      start_time <- proc.time()

      # Saving demographic files

      if (demographic_files) {
        save_csv_structure(objects, filenames_vector[1], folder, order_by_name, progress_bar)
        save_csv_births(objects, filenames_vector[2], folder, order_by_name, progress_bar)
        save_csv_asfr(objects, filenames_vector[3], folder, order_by_name, progress_bar)
        save_csv_fertility_exposure(objects, filenames_vector[4], folder, order_by_name, progress_bar)
        if ("countries" %in% objects) {
          save_csv_fertility_differentials(filenames_vector[5], folder, order_by_name, progress_bar)
        }
        save_csv_deaths(objects, filenames_vector[6], folder, order_by_name, progress_bar)
      }

      # Saving migration files

      if (migration_files) {
        save_csv_emigration(objects, filenames_vector[7], folder, order_by_name, progress_bar)
        save_csv_immigration(objects, filenames_vector[8], folder, order_by_name, progress_bar)
      }


      # Saving switching files

      if (switching_files) {
        if ("countries" %in% objects) {
          save_csv_switching_matrices(filenames_vector[9], folder, order_by_name, progress_bar)
        }
        save_csv_switchers(objects, filenames_vector[10], folder, order_by_name, progress_bar)
      }

      # Printing time length of saving the data

      end_time <- proc.time()
      print("Data saved in:")
      print(end_time - start_time)
    }
  )
)
