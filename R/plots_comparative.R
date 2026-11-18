#' @include plots_methods.R
#' @include region_base.R
#' @include projection_class_plots.R

# ---------------------------------------------------------------------------
# Module-level meta-column sets (shared by all comparative-plot functions)
# ---------------------------------------------------------------------------
.mort_meta <- c("Country", "Country_code", "Period", "Sex", "Age_group", "Structure", "Region")
.fert_meta <- c("Country", "Country_code", "Period", "Mother_age_group", "Structure", "Region", "Total")
.emig_meta <- c("Origin", "Country_code", "Period", "Structure", "Destination", "Region", "Sex", "Age_group")
.immig_meta <- c("Destination", "Country_code", "Period", "Structure", "Origin", "Region", "Sex", "Age_group")
.sw_meta <- c("Country", "Country_code", "Period", "Origin_religion", "Structure", "Region", "Sex", "Age_group")

# Extract religion (non-meta) column names from a data.table.
rel_cols_of <- function(dt, meta) setdiff(colnames(dt), meta)

# Unique ordered periods from a data.table.
periods_of <- function(dt) unique(dt$Period)

# Column sums of the religion columns of a data.table.
sum_rel <- function(dt, rel_cols) colSums(dt[, rel_cols, with = FALSE], na.rm = TRUE)

# Column sums matched to rel_cols by name (0 for columns missing from dt), so
# projections with different column sets line up correctly.
sum_rel_aligned <- function(dt, rel_cols) {
  present <- intersect(rel_cols, names(dt))
  vals <- setNames(numeric(length(rel_cols)), rel_cols)
  if (nrow(dt) > 0L && length(present)) vals[present] <- colSums(dt[, present, with = FALSE], na.rm = TRUE)
  vals
}

# Projection names from a list of projection objects.
get_proj_names <- function(projection_objects) sapply(projection_objects, `[[`, "projection_name")

# Conditionally fold a matrix only when the projection object is post_switch.
maybe_fold_ps <- function(mat, po) {
  if (isTRUE(po$post_switch)) fold_ps_mat(mat) else mat
}

# Number of base religions from a projection object's structure_data.
# obj_list: "country_object_list" or "region_object_list"
n_base_rels <- function(po, obj_list = "country_object_list") {
  sd1 <- po[[obj_list]][[1L]]$structure_data[[1L]]
  if (isTRUE(po$post_switch)) ncol(sd1) %/% 2L else ncol(sd1)
}

# Base religion column names from structure_data (strips _post_switch half).
# Uses the post_switch flag rather than column-count parity, so an even number
# of religions in a non-post_switch projection is handled correctly.
rel_names_from_structure <- function(po, obj_list, key) {
  sd <- po[[obj_list]][[key]]$structure_data[[1L]]
  nc <- ncol(sd)
  colnames(sd)[seq_len(if (isTRUE(po$post_switch)) nc %/% 2L else nc)]
}

# Line layer for comparative time series: one line per variant, or points
# (distinguished by shape) when there is only a single time point.
.layer_variant_line <- function(n_periods, color = NULL) {
  if (n_periods > 1L) {
    return(.layer_line_point(n_periods, color = color))
  }
  point_args <- list(mapping = ggplot2::aes(shape = .data$variant), size = 2.5)
  if (!is.null(color)) point_args$color <- color
  list(do.call(ggplot2::geom_point, point_args))
}

# Ensure an output directory exists, creating it if necessary.
ensure_dir <- function(path) {
  if (!dir.exists(path)) dir.create(path)
  invisible(path)
}

# Create a progress::progress_bar, or NULL when show = FALSE.
make_progress_bar <- function(show, total) {
  if (!show) {
    return(NULL)
  }
  progress::progress_bar$new(
    format = "Saving plots [:bar] :percent ETA: :eta",
    total = total, clear = FALSE, width = 100
  )
}

# Advance a progress bar only if one exists.
tick_pb <- function(pb) if (!is.null(pb)) pb$tick()

# Coerce show_post_switch to FALSE when any projection has post_switch = FALSE,
# because those objects lack _post_switch columns and cannot display them.
effective_show_ps <- function(show_post_switch, projection_objects) {
  if (!show_post_switch) {
    return(FALSE)
  }
  has_no_ps <- !vapply(projection_objects, function(po) isTRUE(po$post_switch), logical(1L))
  if (any(has_no_ps)) {
    message(
      "show_post_switch forced to FALSE: projection(s) ",
      paste(get_proj_names(projection_objects)[has_no_ps], collapse = ", "),
      " do not have post_switch enabled."
    )
    return(FALSE)
  }
  TRUE
}

# ggplot2 theme: 90-degree rotated x-axis labels.
theme_rotated_x <- function() ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust = 1))

# Private helper: fold _post_switch religion columns into their base
# counterparts, then drop the _post_switch columns.  No-op when the table
# has no _post_switch columns (i.e. non-post_switch objects).
fold_ps_dt <- function(dt, meta_cols) {
  if (!data.table::is.data.table(dt) || nrow(dt) == 0L) {
    return(dt)
  }
  rel <- setdiff(names(dt), meta_cols)
  ps <- grep("_post_switch$", rel, value = TRUE)
  if (length(ps) == 0L) {
    return(dt)
  }
  dt <- data.table::copy(dt)
  base <- sub("_post_switch$", "", ps)
  for (i in seq_along(ps)) data.table::set(dt, j = base[i], value = dt[[base[i]]] + dt[[ps[i]]])
  dt[, (ps) := NULL]
  dt
}

# Private helper: stop with an informative message if any projection object
# has not yet been resolved (i.e. project() has not been called on it).
check_all_resolved <- function(projection_objects) {
  unresolved <- !vapply(projection_objects, `[[`, logical(1L), "resolved")
  if (any(unresolved)) {
    nms <- vapply(projection_objects[unresolved], `[[`, character(1L), "projection_name")
    stop(
      "The following projection object(s) have not been resolved. ",
      "Call project() on each before plotting.\n",
      "  Unresolved: ", paste(nms, collapse = ", "),
      call. = FALSE
    )
  }
}

# ---------------------------------------------------------------------------
# Core implementation shared by plot_comparative and plot_comparative_regions.
# obj_list: "country_object_list" | "region_object_list"
# key:      country key or region key used to index obj_list
# ---------------------------------------------------------------------------
.plot_comparative_core <- function(projection_objects, key, type, religion,
                                   plot_colors, show_post_switch, obj_list) {
  check_all_resolved(projection_objects)
  show_post_switch <- effective_show_ps(show_post_switch, projection_objects)

  objects_names <- get_proj_names(projection_objects)
  ref_obj <- projection_objects[[1]][[obj_list]][[key]]

  if (type == 1) {
    ref_sd <- ref_obj$structure_data
    ref_years <- names(ref_sd)
    year_vector <- rep(ref_years, length(projection_objects))
    variant_vector <- rep(objects_names, each = length(ref_years))
    population_vector <- unlist(lapply(projection_objects, function(po) {
      sd <- po[[obj_list]][[key]]$structure_data
      vapply(ref_years, function(yr) {
        mat <- sd[[yr]]
        if (is.null(mat)) 0 else sum(mat)
      }, numeric(1L))
    }))

    plot_data_frame <- factor_cols(
      data.frame(year = year_vector, variant = variant_vector, population = population_vector),
      2L
    )

    return(
      ggplot2::ggplot(plot_data_frame, ggplot2::aes(x = .data$year, y = .data$population, group = .data$variant, linetype = .data$variant)) +
        .layer_variant_line(length(ref_years)) +
        ggplot2::labs(
          x = "Year", y = "Population (in thousands)", linetype = "Variant", shape = "Variant",
          title = paste0("Population of ", ref_obj$name, " in ", year_range(ref_sd))
        ) +
        theme_centred_title()
    )
  } else if (type == 2) {
    # Always shows the full religion (X + X_post_switch), regardless of
    # show_post_switch: the plot compares one religion's size across variants.
    ref_sd <- ref_obj$structure_data
    ref_years <- names(ref_sd)
    year_vector <- rep(ref_years, length(projection_objects))
    variant_vector <- rep(objects_names, each = length(ref_years))
    population_vector <- unlist(lapply(projection_objects, function(po) {
      sd <- po[[obj_list]][[key]]$structure_data
      vapply(ref_years, function(yr) {
        mat <- sd[[yr]]
        if (is.null(mat)) 0 else sum(maybe_fold_ps(mat, po)[, religion])
      }, numeric(1L))
    }))

    plot_data_frame <- factor_cols(
      data.frame(year = year_vector, variant = variant_vector, population = population_vector),
      2L
    )

    rel_name <- rel_names_from_structure(projection_objects[[1]], obj_list, key)[[religion]]
    return(
      ggplot2::ggplot(plot_data_frame, ggplot2::aes(x = .data$year, y = .data$population, group = .data$variant, linetype = .data$variant)) +
        .layer_variant_line(length(ref_years), color = plot_colors[[religion]]) +
        ggplot2::labs(
          x = "Year", y = "Population (in thousands)", linetype = "Variant", shape = "Variant",
          title = paste0("Population of ", rel_name, " in ", ref_obj$name, " in ", year_range(ref_sd))
        ) +
        theme_centred_title()
    )
  } else if (type == 3) {
    ref_asfr <- ref_obj$previous_asfr
    periods <- periods_of(ref_asfr)
    base_names <- rel_names_from_structure(projection_objects[[1]], obj_list, key)
    if (is.character(religion)) religion <- match(religion, base_names)
    rel_name <- base_names[[religion]]
    # With show_post_switch, X and X_post_switch are drawn as separate series
    # (all projections have post_switch columns, see effective_show_ps).
    series <- if (show_post_switch) c(rel_name, paste0(rel_name, "_post_switch")) else rel_name
    series_colors <- setNames(
      if (show_post_switch) plot_colors[c(religion, religion + length(base_names))] else plot_colors[[religion]],
      series
    )

    tfr_vector <- unlist(lapply(projection_objects, function(po) {
      obj <- po[[obj_list]][[key]]
      asfr <- obj$previous_asfr
      if (!is.data.table(asfr) || nrow(asfr) == 0L) {
        return(rep(NA_real_, length(periods) * length(series)))
      }
      # Folded TFR is the births/exposure average over X and X_post_switch
      # (no-op for objects without post_switch columns).
      if (!show_post_switch) asfr <- .fold_asfr(asfr, obj$previous_fertility, obj$previous_fertility_exposure)
      tfr_rows <- asfr[asfr$Structure == "total" & asfr$Mother_age_group == "TFR", ]
      unlist(lapply(series, function(col) {
        vapply(periods, function(period) {
          val <- tfr_rows[[col]][tfr_rows$Period == period]
          if (length(val) > 0L) as.numeric(val[[1L]]) else NA_real_
        }, numeric(1L))
      }))
    }))

    plot_data_frame <- factor_cols(
      data.frame(
        period  = rep(periods, length(series) * length(projection_objects)),
        variant = rep(objects_names, each = length(periods) * length(series)),
        series  = rep(rep(series, each = length(periods)), length(projection_objects)),
        tfr     = tfr_vector
      ),
      2:3
    )

    p <- ggplot2::ggplot(plot_data_frame, ggplot2::aes(
      x = .data$period, y = .data$tfr, group = interaction(.data$series, .data$variant), linetype = .data$variant
    ))
    p <- if (show_post_switch) {
      p + ggplot2::aes(color = .data$series) +
        .layer_variant_line(length(periods)) +
        ggplot2::scale_color_manual(values = series_colors)
    } else {
      p + .layer_variant_line(length(periods), color = series_colors[[1L]])
    }
    return(
      p +
        ggplot2::labs(
          x = "Period", y = "TFR (number of children per woman)", linetype = "Variant",
          shape = "Variant", color = "Religion",
          title = paste0("TFR of ", rel_name, " in ", ref_obj$name, " in ", year_range(ref_obj$structure_data))
        ) +
        theme_centred_title()
    )
  } else if (type == 4) {
    ref_mort <- ref_obj$previous_mortality
    periods <- periods_of(ref_mort)

    mortality_vector <- unlist(lapply(projection_objects, function(po) {
      mort <- po[[obj_list]][[key]]$previous_mortality
      if (!is.data.table(mort) || nrow(mort) == 0L) {
        return(rep(0, length(periods)))
      }
      po_rel_cols <- rel_cols_of(mort, .mort_meta)
      vapply(periods, function(period) {
        rows <- mort[mort$Period == period & mort$Structure == "total", ]
        sum(rows[, po_rel_cols, with = FALSE], na.rm = TRUE)
      }, numeric(1L))
    }))

    plot_data_frame <- factor_cols(
      data.frame(
        period    = rep(periods, length(projection_objects)),
        variant   = rep(objects_names, each = length(periods)),
        mortality = mortality_vector
      ),
      2L
    )

    return(
      ggplot2::ggplot(plot_data_frame, ggplot2::aes(x = .data$period, y = .data$mortality, group = .data$variant, linetype = .data$variant)) +
        .layer_variant_line(length(periods)) +
        ggplot2::labs(
          x = "Period", y = "Number of deaths (in thousands)", linetype = "Variant", shape = "Variant",
          title = paste0("Deaths in ", ref_obj$name, " in ", year_range(ref_obj$structure_data))
        ) +
        theme_centred_title()
    )
  } else if (type == 5) {
    ref_sd <- ref_obj$structure_data
    # Like types 6/8/9: post_switch groups are shown separately when
    # show_post_switch is TRUE (all projections then have them), else folded.
    rel_cols <- if (show_post_switch) {
      colnames(ref_sd[[1L]])
    } else {
      rel_names_from_structure(projection_objects[[1]], obj_list, key)
    }
    periods <- names(ref_sd)
    n_rel <- length(rel_cols)

    population_vector <- unlist(lapply(projection_objects, function(po) {
      sd <- po[[obj_list]][[key]]$structure_data
      unlist(lapply(periods, function(yr) {
        mat <- sd[[yr]]
        if (is.null(mat)) {
          rep(0, n_rel)
        } else if (show_post_switch) {
          colSums(mat)
        } else {
          colSums(maybe_fold_ps(mat, po))
        }
      }))
    }))

    plot_data_frame <- factor_cols(
      data.frame(
        year       = rep(rep(periods, each = n_rel), length(projection_objects)),
        variant    = rep(objects_names, each = length(periods) * n_rel),
        religion   = rep(rep(rel_cols, length(periods)), length(projection_objects)),
        population = population_vector
      ),
      c(2L, 3L)
    )

    return(
      ggplot2::ggplot(plot_data_frame, ggplot2::aes(x = .data$variant, y = .data$population, fill = .data$religion)) +
        .layer_fill_bar(plot_colors) +
        theme_rotated_x() +
        ggplot2::facet_grid(~year) +
        ggplot2::labs(
          x = "Variant", y = "Structure", fill = "Religion",
          title = paste0("Population structure by religion in ", ref_obj$name, " in ", year_range(ref_sd))
        ) +
        theme_centred_title()
    )
  } else if (type == 6) {
    ref_fert <- ref_obj$previous_fertility
    if (!show_post_switch) ref_fert <- fold_ps_dt(ref_fert, .fert_meta)
    rel_cols <- rel_cols_of(ref_fert, .fert_meta)
    periods <- periods_of(ref_fert)
    n_rel <- length(rel_cols)

    population_vector <- unlist(lapply(projection_objects, function(po) {
      fert <- po[[obj_list]][[key]]$previous_fertility
      if (!is.data.table(fert) || nrow(fert) == 0L) {
        return(rep(0, length(periods) * n_rel))
      }
      if (!show_post_switch) fert <- fold_ps_dt(fert, .fert_meta)
      unlist(lapply(periods, function(period) {
        rows <- fert[fert$Period == period & fert$Structure == "total", ]
        sum_rel_aligned(rows, rel_cols)
      }))
    }))

    plot_data_frame <- factor_cols(
      data.frame(
        year       = rep(rep(periods, each = n_rel), length(projection_objects)),
        variant    = rep(objects_names, each = length(periods) * n_rel),
        religion   = rep(rep(rel_cols, length(periods)), length(projection_objects)),
        population = population_vector
      ),
      c(2L, 3L)
    )

    return(
      ggplot2::ggplot(plot_data_frame, ggplot2::aes(x = .data$variant, y = .data$population, fill = .data$religion)) +
        .layer_fill_bar(plot_colors) +
        theme_rotated_x() +
        ggplot2::facet_grid(~year) +
        ggplot2::labs(
          x = "Variant", y = "Structure", fill = "Religion",
          title = paste0("Structure of births by religion in ", ref_obj$name, " in ", year_range(ref_obj$structure_data))
        ) +
        theme_centred_title()
    )
  } else if (type %in% c(7L, 8L, 9L, 11L, 12L)) {
    pos <- Filter(function(o) isTRUE(o$migration), projection_objects)
    nms <- get_proj_names(pos)
    if (length(pos) == 0L) {
      return(NULL)
    }

    ref_em <- pos[[1]][[obj_list]][[key]]$previous_emigration
    periods <- periods_of(ref_em)
    entity_name <- pos[[1]][[obj_list]][[key]]$name
    sd_ref <- pos[[1]][[obj_list]][[key]]$structure_data

    # Shared migration structure bar-chart helper (types 8, 9, 12).
    mig_structure_helper <- function(pos, nms, field, meta, direction_label) {
      ref_dt <- pos[[1]][[obj_list]][[key]][[field]]
      if (!show_post_switch) ref_dt <- fold_ps_dt(ref_dt, meta)
      rel_cols <- rel_cols_of(ref_dt, meta)
      periods_h <- periods_of(ref_dt)
      n_rel <- length(rel_cols)

      migration_vector <- unlist(lapply(pos, function(po) {
        dt <- po[[obj_list]][[key]][[field]]
        if (!is.data.table(dt) || nrow(dt) == 0L) {
          return(rep(0, length(periods_h) * n_rel))
        }
        if (!show_post_switch) dt <- fold_ps_dt(dt, meta)
        unlist(lapply(periods_h, function(period) {
          rows <- dt[dt$Period == period & dt$Structure == "total", ]
          sum_rel_aligned(rows, rel_cols)
        }))
      }))

      plot_data_frame <- factor_cols(
        data.frame(
          year      = rep(rep(periods_h, each = n_rel), length(pos)),
          variant   = as.character(rep(nms, each = length(periods_h) * n_rel)),
          religion  = rep(rep(rel_cols, length(periods_h)), length(pos)),
          migration = migration_vector
        ),
        c(2L, 3L)
      )

      p <- ggplot2::ggplot(plot_data_frame, ggplot2::aes(x = .data$variant, y = .data$migration, fill = .data$religion))
      if (sum(plot_data_frame[, 4L]) > 0L) {
        p <- p + ggplot2::geom_bar(position = "fill", stat = "identity")
      } else {
        p <- p + ggplot2::geom_bar(stat = "identity")
      }
      p + theme_rotated_x() +
        ggplot2::scale_fill_manual(values = plot_colors) +
        ggplot2::facet_grid(~year) +
        ggplot2::labs(
          x = "Variant", y = "Structure", fill = "Religion",
          title = paste0(
            "Structure of migrants (", direction_label, ") by religion in ",
            pos[[1]][[obj_list]][[key]]$name, " in ", year_range(pos[[1]][[obj_list]][[key]]$structure_data)
          )
        ) +
        theme_centred_title()
    }

    if (type == 7) {
      em_v <- unlist(lapply(pos, function(po) {
        em <- po[[obj_list]][[key]]$previous_emigration
        if (!is.data.table(em) || nrow(em) == 0L) {
          return(rep(0, length(periods)))
        }
        vapply(periods, function(p) {
          sum(em[em$Period == p & em$Structure == "total", rel_cols_of(em, .emig_meta), with = FALSE], na.rm = TRUE)
        }, numeric(1L))
      }))
      im_v <- unlist(lapply(pos, function(po) {
        im <- po[[obj_list]][[key]]$previous_immigration
        if (!is.data.table(im) || nrow(im) == 0L) {
          return(rep(0, length(periods)))
        }
        vapply(periods, function(p) {
          sum(im[im$Period == p & im$Structure == "total", rel_cols_of(im, .immig_meta), with = FALSE], na.rm = TRUE)
        }, numeric(1L))
      }))

      plot_data_frame <- factor_cols(
        data.frame(
          year      = rep(rep(periods, length(nms)), 2L),
          variant   = as.character(rep(rep(nms, each = length(periods)), 2L)),
          type      = rep(c("Out", "In"), each = length(em_v)),
          migration = c(em_v, im_v)
        ),
        2L
      )

      return(
        ggplot2::ggplot(plot_data_frame, ggplot2::aes(
          x = .data$year, y = .data$migration, group = interaction(.data$type, .data$variant),
          color = .data$type, linetype = .data$variant
        )) +
          .layer_variant_line(length(periods)) +
          ggplot2::scale_color_manual(values = c("green4", "red4")) +
          ggplot2::labs(
            x = "Period", y = "Number of migrants (in thousands)", color = "Type",
            linetype = "Variant", shape = "Variant",
            title = paste0("Migration (In/Out) in ", entity_name, " in ", year_range(sd_ref))
          ) +
          theme_centred_title()
      )
    }

    if (type == 8) {
      return(mig_structure_helper(pos, nms, "previous_emigration", .emig_meta, "out"))
    }

    if (type == 9) {
      return(mig_structure_helper(pos, nms, "previous_immigration", .immig_meta, "in"))
    }

    # Types 11/12: region-level total or structure emigration (no immigration counterpart).
    if (type == 11) {
      em_v <- unlist(lapply(pos, function(po) {
        em <- po[[obj_list]][[key]]$previous_emigration
        if (!is.data.table(em) || nrow(em) == 0L) {
          return(rep(0, length(periods)))
        }
        vapply(periods, function(p) {
          sum(em[em$Period == p & em$Structure == "total", rel_cols_of(em, .emig_meta), with = FALSE], na.rm = TRUE)
        }, numeric(1L))
      }))

      plot_data_frame <- factor_cols(
        data.frame(
          year      = rep(periods, length(pos)),
          variant   = as.character(rep(nms, each = length(periods))),
          migration = em_v
        ),
        2L
      )

      return(
        ggplot2::ggplot(plot_data_frame, ggplot2::aes(x = .data$year, y = .data$migration, group = .data$variant, linetype = .data$variant)) +
          .layer_variant_line(length(periods)) +
          ggplot2::labs(
            x = "Period", y = "Number of migrants (in thousands)", linetype = "Variant", shape = "Variant",
            title = paste0("Emigration in ", entity_name, " in ", year_range(sd_ref))
          ) +
          theme_centred_title()
      )
    }

    if (type == 12) {
      return(mig_structure_helper(pos, nms, "previous_emigration", .emig_meta, "out"))
    }
  } else if (type == 10) {
    pos_sw <- Filter(function(o) isTRUE(o$switching), projection_objects)
    nms_sw <- get_proj_names(pos_sw)
    if (length(pos_sw) == 0L) {
      return(NULL)
    }

    # Same flow definition as the single-projection switching plot (variant 13).
    # show_post_switch is already forced to FALSE if any projection lacks
    # post_switch, so all projections share the same religion columns.
    flows <- lapply(pos_sw, function(po) {
      .switching_flows(po[[obj_list]][[key]]$previous_switching, religion, fold = !show_post_switch)
    })
    rel_name <- flows[[1]]$name
    dest_levels <- flows[[1]]$dest_cols

    plot_data_frame <- do.call(rbind, Map(function(fl, nm) {
      data.frame(
        year = c(rep(fl$periods, each = length(fl$in_origins)), rep(fl$periods, each = length(fl$dest_cols))),
        variant = nm,
        religion = c(rep(fl$in_origins, length(fl$periods)), rep(fl$dest_cols, length(fl$periods))),
        post_switch = c(as.numeric(fl$inflow), as.numeric(fl$out)),
        type_sw = rep(c("In", "Out"), c(length(fl$inflow), length(fl$out)))
      )
    }, flows, as.character(nms_sw)))
    plot_data_frame$variant <- factor(plot_data_frame$variant, levels = unique(as.character(nms_sw)))
    plot_data_frame$religion <- factor(plot_data_frame$religion, levels = dest_levels)
    plot_data_frame$type_sw <- factor(plot_data_frame$type_sw, levels = c("In", "Out"))

    return(
      ggplot2::ggplot(
        plot_data_frame,
        ggplot2::aes(
          x = .data$variant,
          y = ifelse(.data$type_sw == "Out", -.data$post_switch, .data$post_switch),
          group = .data$religion, fill = .data$religion
        )
      ) +
        .layer_switch_bar(plot_colors) +
        theme_rotated_x() +
        ggplot2::facet_grid(~year) +
        ggplot2::labs(
          x = "Variant", y = "Switching (in thousands)", fill = "Religion",
          title = paste0(
            "Switching of ", rel_name, " in ",
            pos_sw[[1]][[obj_list]][[key]]$name, " in ",
            year_range(pos_sw[[1]][[obj_list]][[key]]$structure_data)
          )
        ) +
        theme_centred_title()
    )
  }
}

# ---------------------------------------------------------------------------
# Public wrappers — thin delegates to .plot_comparative_core
# ---------------------------------------------------------------------------

#' @name plot_comparative
#' @title Create a single comparative plot
#' @description
#' Generates one ggplot2 plot overlaying results from two or more resolved
#' projection objects for a specified country and indicator type.  The returned
#' object can be printed, further customised, or saved with
#' \code{\link[ggplot2]{ggsave}}.
#' @param projection_objects List; two or more resolved \code{Projection_object}
#'   instances to compare. Legend labels are taken from each object's
#'   \code{projection_name} field.
#' @param country Integer; index into \code{country_object_list} identifying the
#'   country to plot.
#' @param type Integer (1–10); plot type. Mirrors the variant numbering used by
#'   \code{\link{save_plots_all}} — see \code{vignette("visualising-projections")}
#'   for the full list.
#' @param religion Integer or character; religion index or name used by
#'   type-specific plots (types 2, 3, 10). Ignored by types that aggregate all
#'   religions.
#' @param plot_colors Character vector; 14-element colour palette — 7 colours
#'   for the base religions followed by 7 for their post-switch counterparts.
#' @returns A \code{ggplot2} object.
#' @seealso
#' \code{\link{save_plots_comparative_all}} to batch-save all types for every
#' country.
#' \code{\link{save_plots_all}} for single-scenario country plots.
#' \code{vignette("visualising-projections")} for type descriptions and example
#' output.
#' @noRd
plot_comparative <- function(projection_objects, country, type, religion,
                             plot_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40", "darkblue", "darkgreen", "red4", "yellow4", "orange4", "purple4", "grey30"),
                             show_post_switch = TRUE) {
  .plot_comparative_core(
    projection_objects = projection_objects,
    key                = country,
    type               = type,
    religion           = religion,
    plot_colors        = plot_colors,
    show_post_switch   = show_post_switch,
    obj_list           = "country_object_list"
  )
}

plot_comparative_regions <- function(projection_objects, region, type, religion,
                                     plot_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40", "darkblue", "darkgreen", "red4", "yellow4", "orange4", "purple4", "grey30"),
                                     show_post_switch = TRUE) {
  .plot_comparative_core(
    projection_objects = projection_objects,
    key                = region,
    type               = type,
    religion           = religion,
    plot_colors        = plot_colors,
    show_post_switch   = show_post_switch,
    obj_list           = "region_object_list"
  )
}

# ---------------------------------------------------------------------------
# Core save loop shared by save_plots_comparative_all and
# save_plots_comparative_regions_all.
#
# migration_types_fn: function(key) returning integer vector of type numbers
#   to emit for migration plots for entity `key`.  This encapsulates the
#   global/region split without any logic inside the loop body.
# ---------------------------------------------------------------------------
.save_plots_comparative_core <- function(projection_objects,
                                         single_file,
                                         folder,
                                         output_file_name,
                                         demographic_plots,
                                         switching_plots,
                                         migration_plots,
                                         show_post_switch,
                                         plot_colors,
                                         progress_bar,
                                         obj_list,
                                         plot_fn,
                                         migration_types_fn) {
  check_all_resolved(projection_objects)
  show_post_switch <- effective_show_ps(show_post_switch, projection_objects)

  common_keys <- Reduce(intersect, lapply(projection_objects, function(o) names(o[[obj_list]])))
  pb <- make_progress_bar(progress_bar, length(common_keys))

  ensure_dir(folder)
  if (single_file) pdf(file = file.path(folder, output_file_name), paper = "a4r", width = 10)

  number_of_rels <- n_base_rels(projection_objects[[1]], obj_list)

  for (ri in seq_along(common_keys)) {
    key <- common_keys[ri]
    if (!single_file) pdf(file = file.path(folder, paste0(key, ".pdf")), paper = "a4r", width = 10)

    cp <- function(type, rel = 1L) {
      print(plot_fn(projection_objects, key, type, rel, plot_colors, show_post_switch))
    }

    # Plot order is fixed: demographic → migration → switching.
    if (demographic_plots) {
      cp(1)
      for (i in seq_len(number_of_rels)) cp(2, i)
      cp(5)
      for (i in seq_len(number_of_rels)) cp(3, i)
      cp(6)
      cp(4)
    }
    if (migration_plots) {
      for (mt in migration_types_fn(key)) cp(mt)
    }
    if (switching_plots) for (i in seq_len(number_of_rels)) cp(10, i)

    if (!single_file) dev.off()
    tick_pb(pb)
  }

  if (single_file) dev.off()
  message("Plots saved")
  return(invisible(NULL))
}

# ---------------------------------------------------------------------------
# Public save wrappers
# ---------------------------------------------------------------------------

#' @name save_plots_comparative_all
#' @title Saving country comparative plots to .pdf file(s)
#' @description
#' Function for generating and saving side-by-side comparative plots of MRC
#' projection results for all countries across two or more scenarios.
#' Outputs can be saved either as a single combined PDF file or as separate
#' PDF files per country.
#' @param projection_objects List; resolved projection objects to compare against each other
#' @param single_file Logical; if TRUE, saves all country plots into a single .pdf file (default TRUE)
#' @param folder Character; name of folder in which plots should be saved (default "comparative")
#' @param demographic_plots Logical; if FALSE, skips creation of fertility and mortality plots (default TRUE)
#' @param switching_plots Logical; if FALSE, skips creation of switching plots. Defaults to the first projection object's switching status
#' @param migration_plots Logical; if FALSE, skips creation of migration plots. Defaults to the first projection object's migration status
#' @param show_post_switch Logical; if TRUE, post-switch populations are visualized separately. Forced to FALSE if any projection has post_switch disabled. The per-religion population plots always show the full religion (base plus post-switch) (default TRUE)
#' @param plot_colors Character vector; colors used for each religion in the plots (recommended to leave unchanged unless the number of religions has changed)
#' @param progress_bar Logical; whether to show a progress bar during saving (default TRUE)
#' @returns Called for its side effects. Saves comparative country plots as PDF file(s) to `folder` and prints a completion message.
#' @seealso
#' \code{\link{save_plots_all}} for single-scenario country plots.
#' \code{\link{save_plots_comparative_regions_all}} for the region-level equivalent.
#' \code{vignette("visualising-projections")} for a guide to all comparative
#' plot types and how the content flags map to type numbers.
#' @examples
#' # Running a full projection is time-consuming.
#' # Wrapped in dontrun to avoid executing during documentation build.
#' \dontrun{
#' projection_dsm <- create_projection_object(name = "dsm", switching = TRUE)
#' projection_dm <- create_projection_object(name = "dm", switching = FALSE)
#' project(projection_object = projection_dsm)
#' project(projection_object = projection_dm)
#' save_plots_comparative_all(
#'   projection_objects = list(projection_dsm, projection_dm),
#'   folder = tempdir(),
#'   progress_bar = FALSE
#' )
#' }
#' @export
save_plots_comparative_all <- function(projection_objects,
                                       single_file = TRUE,
                                       folder = "comparative",
                                       demographic_plots = TRUE,
                                       switching_plots,
                                       migration_plots,
                                       show_post_switch = TRUE,
                                       plot_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40", "darkblue", "darkgreen", "red4", "yellow4", "orange4", "purple4", "grey30"),
                                       progress_bar = TRUE) {
  if (missing(switching_plots)) switching_plots <- all(vapply(projection_objects, function(po) isTRUE(po$switching), logical(1L)))
  if (missing(migration_plots)) migration_plots <- all(vapply(projection_objects, function(po) isTRUE(po$migration), logical(1L)))

  .save_plots_comparative_core(
    projection_objects = projection_objects,
    single_file        = single_file,
    folder             = folder,
    output_file_name   = "all_countries_comparative.pdf",
    demographic_plots  = demographic_plots,
    switching_plots    = switching_plots,
    migration_plots    = migration_plots,
    show_post_switch   = show_post_switch,
    plot_colors        = plot_colors,
    progress_bar       = progress_bar,
    obj_list           = "country_object_list",
    plot_fn            = plot_comparative,
    migration_types_fn = function(key) c(7L, 8L, 9L)
  )
}

#' @name save_plots_comparative_regions_all
#' @title Saving region comparative plots to .pdf file(s)
#' @description
#' Function for generating and saving side-by-side comparative plots of MRC
#' projection results for all regions across two or more scenarios.
#' Outputs can be saved either as a single combined PDF file or as separate
#' PDF files per region.
#' @param projection_objects List of resolved projection objects (list)
#' @param single_file Logical; if TRUE, saves all region plots into a single .pdf file (default TRUE)
#' @param folder Name of folder in which plots should be saved (character)
#' @param demographic_plots Logical; if FALSE, skips creation of fertility and mortality plots (default TRUE)
#' @param switching_plots Logical; if FALSE, skips creation of switching plots. Defaults to projection_object's switching status (logical)
#' @param migration_plots Logical; if FALSE, skips creation of migration plots. Defaults to projection_object's migration status (logical)
#' @param show_post_switch Logical; if TRUE, post-switch populations are visualized separately. Forced to FALSE if any projection has post_switch disabled. The per-religion population plots always show the full religion (base plus post-switch) (default TRUE)
#' @param plot_colors Character vector defining the colors used for each religion in the plots (recommended to leave unchanged unless the number of religions has changed)
#' @param progress_bar Logical; whether to show a progress bar during saving (default TRUE)
#' @returns Called for its side effects. Saves comparative region plots as PDF file(s) to `folder` and prints a completion message.
#' @seealso
#' \code{\link{save_plots_regions_all}} for single-scenario region plots.
#' \code{\link{save_plots_comparative_all}} for the country-level equivalent.
#' \code{vignette("visualising-projections")} for a guide to all comparative
#' plot types and how the content flags map to type numbers.
#' @examples
#' # Running a full projection is time-consuming.
#' # Wrapped in dontrun to avoid executing during documentation build.
#' \dontrun{
#' obj1 <- test_object_generator(object_name = "sc1")
#' obj2 <- test_object_generator(object_name = "sc2", no_diff = TRUE)
#' project(projection_object = obj1, progress_bar = FALSE, save_totals = TRUE)
#' project(projection_object = obj2, progress_bar = FALSE, save_totals = TRUE)
#' save_plots_comparative_regions_all(
#'   projection_objects = list(obj1, obj2),
#'   folder = tempdir(),
#'   progress_bar = FALSE
#' )
#' }
#' @export
save_plots_comparative_regions_all <- function(projection_objects,
                                               single_file = TRUE,
                                               folder = "comparative",
                                               demographic_plots = TRUE,
                                               switching_plots,
                                               migration_plots,
                                               show_post_switch = TRUE,
                                               plot_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40", "darkblue", "darkgreen", "red4", "yellow4", "orange4", "purple4", "grey30"),
                                               progress_bar = TRUE) {
  if (missing(switching_plots)) switching_plots <- all(vapply(projection_objects, function(po) isTRUE(po$switching), logical(1L)))
  if (missing(migration_plots)) migration_plots <- all(vapply(projection_objects, function(po) isTRUE(po$migration), logical(1L)))

  .save_plots_comparative_core(
    projection_objects = projection_objects,
    single_file        = single_file,
    folder             = folder,
    output_file_name   = "all_regions_comparative.pdf",
    demographic_plots  = demographic_plots,
    switching_plots    = switching_plots,
    migration_plots    = migration_plots,
    show_post_switch   = show_post_switch,
    plot_colors        = plot_colors,
    progress_bar       = progress_bar,
    obj_list           = "region_object_list",
    plot_fn            = plot_comparative_regions,
    # Global entry (added by calculate_global_totals): emigration-only types
    # (11, 12); regions: in/out (7, 8, 9).
    migration_types_fn = function(key) if (identical(key, "Global")) c(11L, 12L) else c(7L, 8L, 9L)
  )
}
