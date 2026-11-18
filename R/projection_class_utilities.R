#' @include projection_class_base.R

Projection_object$methods(
  list(
    calculate_region_totals = function(progress_bar) {
      region_list <- region_object_list

      if (progress_bar) {
        n_regions <- length(region_list)
        ticks <- length(country_object_list[[1]]$structure_data) * n_regions
        ticks <- ticks + 4L * n_regions # mortality, fertility, exposure, asfr
        if (switching) ticks <- ticks + n_regions
        if (migration) ticks <- ticks + n_regions * 2
        pbins <- progress::progress_bar$new(
          format = "Calculating region totals [:bar] :percent Estimated time left: :eta",
          total = ticks, clear = FALSE, width = 120
        )
      }

      # Aggregating previous structure data (matrix-based, unchanged)

      for (year in names(country_object_list[[1]]$structure_data)) {
        for (region in region_list) {
          example <- country_object_list[[1]]$structure_data[[1]]
          m_output <- matrix(0L, nrow = nrow(example), ncol = ncol(example), dimnames = dimnames(example))
          for (country in country_object_list) {
            if (country$region != region$region) next
            m_output <- m_output + country$structure_data[[year]]
          }
          region$structure_data <- append(region$structure_data, list("placeholder" = m_output))
          names(region$structure_data)[length(region$structure_data)] <- year
          if (progress_bar) pbins$tick()
        }
      }

      # Local helpers -----------------------------------------------------------

      # rbind a list of flat data.tables, drop Country/Country_code/Region, group-sum
      aggregate_flat <- function(dt_list, by_cols) {
        combined <- data.table::rbindlist(dt_list, use.names = TRUE, fill = TRUE)
        rel_cols <- setdiff(names(combined), c("Country", "Country_code", "Region", by_cols))
        combined[, lapply(.SD, sum, na.rm = TRUE), by = by_cols, .SDcols = rel_cols]
      }

      # Attach region-level metadata and reorder columns
      attach_meta <- function(dt, region_obj, by_cols, name_col = "Country") {
        rel_cols <- setdiff(names(dt), by_cols)
        dt[, (name_col) := region_obj$name]
        dt[, Country_code := region_obj$region]
        dt[, Region := region_obj$region]
        setcolorder(dt, c(name_col, "Country_code", by_cols, "Region", rel_cols))
        dt
      }

      # Compute ASFR flat table from matched fertility and exposure flat tables
      compute_asfr <- function(dt_fert, dt_expo) {
        meta_cols <- c("Country", "Country_code", "Period", "Mother_age_group", "Structure", "Region")
        rel_cols <- setdiff(names(dt_fert), meta_cols)
        dt_f <- data.table::copy(dt_fert)
        dt_e <- data.table::copy(dt_expo)
        setkeyv(dt_f, c("Period", "Mother_age_group", "Structure"))
        setkeyv(dt_e, c("Period", "Mother_age_group", "Structure"))
        asfr_dt <- data.table::copy(dt_f)
        for (col in rel_cols) {
          vals <- dt_f[[col]] / dt_e[[col]]
          vals[is.nan(vals) | is.infinite(vals)] <- 0
          set(asfr_dt, j = col, value = vals)
        }
        tfr_dt <- asfr_dt[,
          lapply(.SD, sum, na.rm = TRUE),
          by = c("Country", "Country_code", "Period", "Structure", "Region"),
          .SDcols = rel_cols
        ]
        tfr_dt[, Mother_age_group := "TFR"]
        setcolorder(tfr_dt, names(asfr_dt))
        data.table::rbindlist(list(asfr_dt, tfr_dt), use.names = TRUE, fill = TRUE)
      }

      # -------------------------------------------------------------------------

      # Aggregating previous mortality

      for (region in region_list) {
        dts <- Filter(
          function(d) is.data.table(d) && nrow(d) > 0L,
          lapply(
            Filter(function(c) c$region == region$region, country_object_list),
            function(c) c$previous_mortality
          )
        )
        if (length(dts) > 0L) {
          region$previous_mortality <- attach_meta(
            aggregate_flat(dts, c("Period", "Sex", "Age_group", "Structure")),
            region, c("Period", "Sex", "Age_group", "Structure")
          )
        }
        if (progress_bar) pbins$tick()
      }

      # Aggregating previous fertility

      for (region in region_list) {
        dts <- Filter(
          function(d) is.data.table(d) && nrow(d) > 0L,
          lapply(
            Filter(function(c) c$region == region$region, country_object_list),
            function(c) c$previous_fertility
          )
        )
        if (length(dts) > 0L) {
          region$previous_fertility <- attach_meta(
            aggregate_flat(dts, c("Period", "Mother_age_group", "Structure")),
            region, c("Period", "Mother_age_group", "Structure")
          )
        }
        if (progress_bar) pbins$tick()
      }

      # Aggregating previous fertility exposure

      for (region in region_list) {
        dts <- Filter(
          function(d) is.data.table(d) && nrow(d) > 0L,
          lapply(
            Filter(function(c) c$region == region$region, country_object_list),
            function(c) c$previous_fertility_exposure
          )
        )
        if (length(dts) > 0L) {
          region$previous_fertility_exposure <- attach_meta(
            aggregate_flat(dts, c("Period", "Mother_age_group", "Structure")),
            region, c("Period", "Mother_age_group", "Structure")
          )
        }
        if (progress_bar) pbins$tick()
      }

      # Computing previous ASFR from aggregated fertility / exposure

      for (region in region_list) {
        if (is.data.table(region$previous_fertility) && nrow(region$previous_fertility) > 0L) {
          region$previous_asfr <- compute_asfr(
            region$previous_fertility,
            region$previous_fertility_exposure
          )
        }
        if (progress_bar) pbins$tick()
      }

      # Aggregating previous switching

      if (switching) {
        for (region in region_list) {
          dts <- Filter(
            function(d) is.data.table(d) && nrow(d) > 0L,
            lapply(
              Filter(function(c) c$region == region$region, country_object_list),
              function(c) c$previous_switching
            )
          )
          if (length(dts) > 0L) {
            has_sex <- "Sex" %in% names(dts[[1]])
            by_cols <- if (has_sex) {
              c("Period", "Sex", "Age_group", "Origin_religion", "Structure")
            } else {
              c("Period", "Origin_religion", "Structure")
            }
            region$previous_switching <- attach_meta(aggregate_flat(dts, by_cols), region, by_cols)
          }
          if (progress_bar) pbins$tick()
        }
      }

      # Aggregating previous emigration and immigration

      if (migration) {
        for (region in region_list) {
          dts <- Filter(
            function(d) is.data.table(d) && nrow(d) > 0L,
            lapply(
              Filter(function(c) c$region == region$region, country_object_list),
              function(c) c$previous_emigration
            )
          )
          if (length(dts) > 0L) {
            has_sex <- "Sex" %in% names(dts[[1]])
            by_cols <- if (has_sex) {
              c("Period", "Structure", "Destination", "Sex", "Age_group", "Region")
            } else {
              c("Period", "Structure", "Destination", "Region")
            }
            combined <- data.table::rbindlist(dts, use.names = TRUE, fill = TRUE)
            rel_cols <- setdiff(names(combined), c("Origin", "Country_code", by_cols))
            agg <- combined[, lapply(.SD, sum, na.rm = TRUE), by = by_cols, .SDcols = rel_cols]
            agg[, Origin := region$name]
            agg[, Country_code := region$region]
            setcolorder(agg, c("Origin", "Country_code", by_cols, rel_cols))
            region$previous_emigration <- agg
          }
          if (progress_bar) pbins$tick()
        }

        for (region in region_list) {
          dts <- Filter(
            function(d) is.data.table(d) && nrow(d) > 0L,
            lapply(
              Filter(function(c) c$region == region$region, country_object_list),
              function(c) c$previous_immigration
            )
          )
          if (length(dts) > 0L) {
            has_sex <- "Sex" %in% names(dts[[1]])
            by_cols <- if (has_sex) {
              c("Period", "Structure", "Origin", "Sex", "Age_group", "Region")
            } else {
              c("Period", "Structure", "Origin", "Region")
            }
            combined <- data.table::rbindlist(dts, use.names = TRUE, fill = TRUE)
            rel_cols <- setdiff(names(combined), c("Destination", "Country_code", by_cols))
            agg <- combined[, lapply(.SD, sum, na.rm = TRUE), by = by_cols, .SDcols = rel_cols]
            agg[, Destination := region$name]
            agg[, Country_code := region$region]
            setcolorder(agg, c("Destination", "Country_code", by_cols, rel_cols))
            region$previous_immigration <- agg
          }
          if (progress_bar) pbins$tick()
        }
      }

      region_object_list <<- region_list
      region_totals <<- TRUE
    },
    calculate_global_totals = function(progress_bar) {
      # Creating new "Global" object

      total <- Region_object$new(name = "Global", region = "Global")

      if (progress_bar) {
        ticks <- length(region_object_list[[1]]$structure_data)
        ticks <- ticks + 4L # mortality, fertility, exposure, asfr
        if (switching) ticks <- ticks + 1L
        if (migration) ticks <- ticks + 2L
        pbin <- progress::progress_bar$new(
          format = "Calculating global totals [:bar] :percent Estimated time left: :eta",
          total = ticks, clear = FALSE, width = 120
        )
      }

      # Aggregating previous structure data (matrix-based, unchanged)

      for (year in names(region_object_list[[1]]$structure_data)) {
        example <- region_object_list[[1]]$structure_data[[1]]
        m_output <- matrix(0L, nrow = nrow(example), ncol = ncol(example), dimnames = dimnames(example))
        for (region in region_object_list) m_output <- m_output + region$structure_data[[year]]
        total$structure_data <- append(total$structure_data, list("placeholder" = m_output))
        names(total$structure_data)[length(total$structure_data)] <- year
        if (progress_bar) pbin$tick()
      }

      # Local helpers (same pattern as calculate_region_totals) ----------------

      aggregate_flat <- function(dt_list, by_cols) {
        combined <- data.table::rbindlist(dt_list, use.names = TRUE, fill = TRUE)
        rel_cols <- setdiff(names(combined), c("Country", "Country_code", "Region", by_cols))
        combined[, lapply(.SD, sum, na.rm = TRUE), by = by_cols, .SDcols = rel_cols]
      }

      attach_global_meta <- function(dt, by_cols, name_col = "Country") {
        rel_cols <- setdiff(names(dt), by_cols)
        dt[, (name_col) := "Global"]
        dt[, Country_code := "Global"]
        dt[, Region := "Global"]
        setcolorder(dt, c(name_col, "Country_code", by_cols, "Region", rel_cols))
        dt
      }

      compute_asfr <- function(dt_fert, dt_expo) {
        meta_cols <- c("Country", "Country_code", "Period", "Mother_age_group", "Structure", "Region")
        rel_cols <- setdiff(names(dt_fert), meta_cols)
        dt_f <- data.table::copy(dt_fert)
        dt_e <- data.table::copy(dt_expo)
        setkeyv(dt_f, c("Period", "Mother_age_group", "Structure"))
        setkeyv(dt_e, c("Period", "Mother_age_group", "Structure"))
        asfr_dt <- data.table::copy(dt_f)
        for (col in rel_cols) {
          vals <- dt_f[[col]] / dt_e[[col]]
          vals[is.nan(vals) | is.infinite(vals)] <- 0
          set(asfr_dt, j = col, value = vals)
        }
        tfr_dt <- asfr_dt[,
          lapply(.SD, sum, na.rm = TRUE),
          by = c("Country", "Country_code", "Period", "Structure", "Region"),
          .SDcols = rel_cols
        ]
        tfr_dt[, Mother_age_group := "TFR"]
        setcolorder(tfr_dt, names(asfr_dt))
        data.table::rbindlist(list(asfr_dt, tfr_dt), use.names = TRUE, fill = TRUE)
      }

      # -------------------------------------------------------------------------

      # Aggregating previous mortality

      {
        dts <- Filter(
          function(d) is.data.table(d) && nrow(d) > 0L,
          lapply(region_object_list, function(r) r$previous_mortality)
        )
        if (length(dts) > 0L) {
          total$previous_mortality <- attach_global_meta(
            aggregate_flat(dts, c("Period", "Sex", "Age_group", "Structure")),
            c("Period", "Sex", "Age_group", "Structure")
          )
        }
        if (progress_bar) pbin$tick()
      }

      # Aggregating previous fertility

      {
        dts <- Filter(
          function(d) is.data.table(d) && nrow(d) > 0L,
          lapply(region_object_list, function(r) r$previous_fertility)
        )
        if (length(dts) > 0L) {
          total$previous_fertility <- attach_global_meta(
            aggregate_flat(dts, c("Period", "Mother_age_group", "Structure")),
            c("Period", "Mother_age_group", "Structure")
          )
        }
        if (progress_bar) pbin$tick()
      }

      # Aggregating previous fertility exposure

      {
        dts <- Filter(
          function(d) is.data.table(d) && nrow(d) > 0L,
          lapply(region_object_list, function(r) r$previous_fertility_exposure)
        )
        if (length(dts) > 0L) {
          total$previous_fertility_exposure <- attach_global_meta(
            aggregate_flat(dts, c("Period", "Mother_age_group", "Structure")),
            c("Period", "Mother_age_group", "Structure")
          )
        }
        if (progress_bar) pbin$tick()
      }

      # Computing previous ASFR

      total$previous_asfr <- compute_asfr(
        total$previous_fertility,
        total$previous_fertility_exposure
      )
      if (progress_bar) pbin$tick()

      # Aggregating previous switching

      if (switching) {
        dts <- Filter(
          function(d) is.data.table(d) && nrow(d) > 0L,
          lapply(region_object_list, function(r) r$previous_switching)
        )
        if (length(dts) > 0L) {
          has_sex <- "Sex" %in% names(dts[[1]])
          by_cols <- if (has_sex) {
            c("Period", "Sex", "Age_group", "Origin_religion", "Structure")
          } else {
            c("Period", "Origin_religion", "Structure")
          }
          total$previous_switching <- attach_global_meta(aggregate_flat(dts, by_cols), by_cols)
        }
        if (progress_bar) pbin$tick()
      }

      # Aggregating previous emigration and immigration

      if (migration) {
        dts_em <- Filter(
          function(d) is.data.table(d) && nrow(d) > 0L,
          lapply(region_object_list, function(r) r$previous_emigration)
        )
        if (length(dts_em) > 0L) {
          has_sex <- "Sex" %in% names(dts_em[[1]])
          by_cols <- if (has_sex) {
            c("Period", "Structure", "Destination", "Sex", "Age_group", "Region")
          } else {
            c("Period", "Structure", "Destination", "Region")
          }
          combined <- data.table::rbindlist(dts_em, use.names = TRUE, fill = TRUE)
          rel_cols <- setdiff(names(combined), c("Origin", "Country_code", by_cols))
          agg <- combined[, lapply(.SD, sum, na.rm = TRUE), by = by_cols, .SDcols = rel_cols]
          agg[, Origin := "Global"][, Country_code := "Global"]
          setcolorder(agg, c("Origin", "Country_code", by_cols, rel_cols))
          total$previous_emigration <- agg
        }
        if (progress_bar) pbin$tick()

        dts_im <- Filter(
          function(d) is.data.table(d) && nrow(d) > 0L,
          lapply(region_object_list, function(r) r$previous_immigration)
        )
        if (length(dts_im) > 0L) {
          has_sex <- "Sex" %in% names(dts_im[[1]])
          by_cols <- if (has_sex) {
            c("Period", "Structure", "Origin", "Sex", "Age_group", "Region")
          } else {
            c("Period", "Structure", "Origin", "Region")
          }
          combined <- data.table::rbindlist(dts_im, use.names = TRUE, fill = TRUE)
          rel_cols <- setdiff(names(combined), c("Destination", "Country_code", by_cols))
          agg <- combined[, lapply(.SD, sum, na.rm = TRUE), by = by_cols, .SDcols = rel_cols]
          agg[, Destination := "Global"][, Country_code := "Global"]
          setcolorder(agg, c("Destination", "Country_code", by_cols, rel_cols))
          total$previous_immigration <- agg
        }
        if (progress_bar) pbin$tick()
      }

      region_object_list <<- append(list("Global" = total), region_object_list)
      global_totals <<- TRUE
    },

    # Assigning immigration

    assign_immigration = function() {
      for (destination in country_object_list) {
        dc <- destination$code
        cur_period <- destination$period

        imm_rows <- list()
        for (origin in country_object_list) {
          em <- origin$previous_emigration
          if (is.null(em) || !is.data.table(em)) next

          # Rows from this origin destined for dc in the current period
          rows <- em[Period == cur_period & Destination == as.character(dc)]
          if (nrow(rows) == 0L) next

          # Transform emigration row to immigration perspective:
          #   emigration: Origin=source_name, Country_code=source_code, Destination=dest_code
          #   immigration: Destination=dest_name, Country_code=dest_code, Origin=source_code
          im_dt <- data.table::copy(rows)
          im_dt[, Origin := as.character(origin$code)]
          im_dt[, Destination := destination$name]
          im_dt[, Country_code := destination$code]

          imm_rows[[length(imm_rows) + 1L]] <- im_dt
        }

        if (length(imm_rows) > 0L) {
          imm_dt <- data.table::rbindlist(imm_rows, use.names = TRUE, fill = TRUE)

          # Enforce column order to match immigration flat-table layout
          has_sex <- "Sex" %in% names(imm_dt)
          meta_cols <- if (has_sex) {
            c(
              "Destination", "Country_code", "Period", "Structure",
              "Origin", "Sex", "Age_group", "Region"
            )
          } else {
            c("Destination", "Country_code", "Period", "Structure", "Origin", "Region")
          }
          rel_cols <- setdiff(names(imm_dt), meta_cols)
          setcolorder(imm_dt, c(meta_cols, rel_cols))

          if (!is.data.table(destination$previous_immigration)) {
            destination$previous_immigration <- imm_dt
          } else {
            destination$previous_immigration <- data.table::rbindlist(
              list(destination$previous_immigration, imm_dt),
              use.names = TRUE, fill = TRUE
            )
          }
        }
      }
    },

    # Ordering countries or regions in alphabetical order

    order_countries_alphabetical = function(return_id = TRUE, regions = FALSE) {
      codes <- c()
      names <- c()
      if (regions) {
        for (region in region_object_list) {
          if (region$name == "Global") {
            names <- c(names, "AAAA")
          } else {
            names <- c(names, region$name)
          }
        }
        if (return_id) {
          codes <- seq_along(region_object_list)
        } else {
          for (region in region_object_list) {
            codes <- c(codes, region$region)
          }
        }
        names(codes) <- names
      } else {
        for (country in country_object_list) {
          names <- c(names, country$name)
        }
        if (return_id) {
          codes <- seq_along(country_object_list)
        } else {
          for (country in country_object_list) {
            codes <- c(codes, country$code)
          }
        }
        names(codes) <- names
      }
      if (regions) {
        ordered <- sort_by(codes, names(codes))
        if (global_totals) {
          global <- ordered[names(ordered) == "Global"]
          ordered <- ordered[names(ordered) != "Global"]
          ordered <- c(global, ordered)
        }
        return(ordered)
      } else {
        return(sort_by(codes, names(codes)))
      }
    }
  )
)
