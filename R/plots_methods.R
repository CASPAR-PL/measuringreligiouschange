# ---------------------------------------------------------------------------
# Helpers shared with plots_comparative.R
# ---------------------------------------------------------------------------

# "YYYY-YYYY" year-range string from a named structure_data list.
year_range <- function(sd) paste0(names(sd)[[1L]], "-", names(sd)[[length(sd)]])

# Factorize one or more columns of a data.frame by first-appearance order.
factor_cols <- function(df, cols) {
  for (j in cols) df[[j]] <- factor(df[[j]], levels = unique(df[[j]]))
  df
}

# Fold post-switch matrix: sum base and _post_switch column halves.
fold_ps_mat <- function(mat) {
  nc <- ncol(mat)
  mat[, 1:(nc / 2L)] + mat[, ((nc / 2L) + 1L):nc]
}

# ggplot2 theme: centred plot title.
theme_centred_title <- function() ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))

# Sum a flat output table over all rows of each period, per religion column.
# fold = TRUE merges X_post_switch columns into X first (counts only, not rates).
.period_religion_totals <- function(dt, meta_cols, fold, value_name) {
  if (fold) dt <- fold_ps_dt(dt, meta_cols)
  rel_cols <- setdiff(names(dt), meta_cols)
  periods <- unique(dt$Period)
  vals <- vapply(periods, function(p) {
    colSums(dt[dt$Period == p, rel_cols, with = FALSE])
  }, numeric(length(rel_cols)))
  out <- data.frame(
    year = rep(periods, each = length(rel_cols)),
    religion = rep(rel_cols, length(periods))
  )
  out[[value_name]] <- as.numeric(vals)
  factor_cols(out, 2L)
}

# Fold post_switch ASFR into base religions as a true average:
# (births X + births X_post_switch) / (exposure X + exposure X_post_switch),
# using the "total" structure rows. Falls back to the base-religion rate when
# the combined exposure is zero. Returns age rows plus recomputed TFR rows.
.fold_asfr <- function(asfr, fert, expo) {
  meta <- c("Country", "Country_code", "Period", "Mother_age_group", "Structure", "Region")
  rel <- setdiff(names(asfr), meta)
  ps <- grep("_post_switch$", rel, value = TRUE)
  out <- data.table::copy(asfr[asfr$Structure == "total" & asfr$Mother_age_group != "TFR", ])
  if (length(ps) == 0L) {
    return(asfr)
  }
  base <- sub("_post_switch$", "", ps)

  key <- function(d) paste(d$Period, d$Mother_age_group)
  f <- fert[fert$Structure == "total", ]
  e <- expo[expo$Structure == "total", ]
  f <- f[match(key(out), key(f)), ]
  e <- e[match(key(out), key(e)), ]

  for (i in seq_along(ps)) {
    births <- f[[base[i]]] + f[[ps[i]]]
    exposure <- e[[base[i]]] + e[[ps[i]]]
    rate <- ifelse(!is.na(exposure) & exposure > 0, births / exposure, out[[base[i]]])
    data.table::set(out, j = base[i], value = rate)
  }
  out[, (ps) := NULL]

  rel_out <- setdiff(names(out), meta)
  tfr <- out[, lapply(.SD, sum), by = c("Country", "Country_code", "Period", "Structure", "Region"), .SDcols = rel_out]
  data.table::set(tfr, j = "Mother_age_group", value = "TFR")
  data.table::rbindlist(list(out, tfr), use.names = TRUE)
}

# Switching flows for one religion from a previous_switching table.
# fold = TRUE merges X_post_switch into X for destination columns and origin rows.
# Moves between X and X_post_switch count as retention, not switching.
# Returns the religion name, destination columns, "in" origins, periods, and
# out (destinations x periods) / inflow (origins x periods) matrices.
.switching_flows <- function(sw, religion, fold) {
  sw <- sw[sw$Structure == "total", ]
  if (fold) {
    sw <- fold_ps_dt(sw, .sw_meta)
    sw$Origin_religion <- sub("_post_switch$", "", sw$Origin_religion)
  }
  dest_cols <- rel_cols_of(sw, .sw_meta)
  base_names <- dest_cols[!grepl("_post_switch$", dest_cols)]
  if (is.character(religion)) religion <- match(religion, base_names)
  sw_rel_name <- base_names[religion]
  own <- intersect(c(sw_rel_name, paste0(sw_rel_name, "_post_switch")), dest_cols)
  in_origins <- setdiff(dest_cols, own)
  periods <- unique(sw$Period)

  out <- matrix(vapply(periods, function(p) {
    vals <- colSums(sw[sw$Period == p & sw$Origin_religion %in% own, dest_cols, with = FALSE])
    vals[own] <- 0
    vals
  }, numeric(length(dest_cols))), nrow = length(dest_cols))

  inflow <- matrix(vapply(periods, function(p) {
    rows <- sw[sw$Period == p, ]
    vapply(in_origins, function(o) {
      sum(rows[rows$Origin_religion == o, own, with = FALSE])
    }, numeric(1L))
  }, numeric(length(in_origins))), nrow = length(in_origins))

  list(
    name = sw_rel_name, dest_cols = dest_cols, in_origins = in_origins,
    periods = periods, out = out, inflow = inflow
  )
}

# 7-colour palette for base religions, 14-colour palette when post_switch is shown.
.palette_for <- function(n, plot_colors, plot_switching_colors) {
  if (n > length(plot_colors)) plot_switching_colors else plot_colors
}

# ---------------------------------------------------------------------------
# Shared ggplot2 layer helpers (used by mrc_plot and .plot_comparative_core)
# ---------------------------------------------------------------------------

# Group A: line + point time-series layers.
# n_periods: line when >= 2 time-points, single point when 1.
# color: optional fixed colour (for single-religion comparative plots).
.layer_line_point <- function(n_periods = 2L, linewidth = 1, pt_size = 1.5, color = NULL) {
  line_args <- list(linewidth = linewidth)
  point_args <- list(size = pt_size)
  if (!is.null(color)) {
    line_args$color <- color
    point_args$color <- color
  }
  if (n_periods > 1L) {
    list(do.call(ggplot2::geom_line, line_args))
  } else {
    list(do.call(ggplot2::geom_point, point_args))
  }
}

# Group B: proportional stacked bar + fill colour scale.
.layer_fill_bar <- function(fill_values) {
  list(
    ggplot2::geom_bar(position = "fill", stat = "identity"),
    ggplot2::scale_fill_manual(values = fill_values)
  )
}

# Group C: pos/neg bar + zero-line + fill colour scale (switching chart).
.layer_switch_bar <- function(fill_values) {
  list(
    ggplot2::geom_bar(stat = "identity"),
    ggplot2::geom_hline(yintercept = 0),
    ggplot2::scale_fill_manual(values = fill_values)
  )
}

# Function creating plots; foundation of all of the further plot-generating methods

mrc_plot <- function(variant,
                     df,
                     df_e,
                     df_i,
                     name,
                     period = 0,
                     show_post_switch,
                     switching_religion = 0,
                     plot_colors,
                     plot_switching_colors,
                     regions,
                     light_mig,
                     light_sw,
                     post_switch) {
  # Variant "0" allows user to see what plots are possible to be generated

  if (variant == 0) {
    print("Variant types:")
    print("1 - Population by years")
    print("2 - Population by years and religions")
    print("3 - Population structure by years and religions")
    print("4 - Population pyramid by religions")
    print("5 - TFR by years and religions")
    print("6 - ASFR by age_groups and religions")
    print("7 - Structure of births by religions")
    print("8 - Mortality by years")
    print("9 - Migration (In/Out) by years")
    print("10 - Structure of migrants (Out) by years and religions")
    print("11 - Structure of migrants (In) by years and religions")
    print("12 - Retention of religions by sex")
    print("13 - Retention of religion by years")
    print("14 - Table cotaining population religion structure by years")
    print("15 - Emigration by years - used only for global")
    print("16 - Structure of migrants (Out) by years and religions - used only for global")
  } else if (variant == 1) {
    # Preparing data vectors to be in suitable format for plot generation

    population_vector <- c()
    for (i in seq_along(df)) {
      population_vector <- c(population_vector, sum(df[[i]]))
    }
    years <- names(df)

    # Creating data_frame from which the plot will be generated

    plot_data_frame <- data.frame(
      year = years,
      population = population_vector
    )

    # Creating plot using ggplot2 package and data_frame constructed above

    plot <- ggplot2::ggplot(plot_data_frame, ggplot2::aes(
      x = .data$year,
      y = .data$population,
      group = 1
    )) +
      .layer_line_point(length(unique(plot_data_frame$year))) +
      ggplot2::labs(
        x = "Year",
        y = "Population (in thousands)",
        title = paste0("Population of ", name, " in ", year_range(df))
      ) +
      theme_centred_title()
  } else if (variant == 2) {
    # Depending on whether or not the "show_post_switch" option is on there are two different ways of data preparation and visualization

    if (show_post_switch | !post_switch) {
      # Preparing data vectors to be in suitable format for plot generation

      population_vector <- c()
      for (i in seq_along(df)) {
        population_vector <- c(population_vector, colSums(df[[i]]))
      }
      years <- rep(names(df), each = ncol(df[[1]]))
      religions <- rep(colnames(df[[1]]), length(df))

      # Creating data_frame from which the plot will be generated

      plot_data_frame <- data.frame(
        year = years,
        religion = religions,
        population = population_vector
      )

      plot_data_frame <- factor_cols(plot_data_frame, 2L)

      # Creating plot using ggplot2 package and data_frame constructed above

      plot <- ggplot2::ggplot(plot_data_frame, ggplot2::aes(
        x = .data$year,
        y = .data$population,
        group = .data$religion,
        color = .data$religion
      )) +
        .layer_line_point(length(unique(plot_data_frame$year))) +
        ggplot2::scale_color_manual(values = plot_switching_colors) +
        ggplot2::labs(
          x = "Year",
          y = "Population (in thousands)",
          color = "Religion",
          title = paste0("Population by religion in ", name, " in ", year_range(df))
        ) +
        theme_centred_title()
    } else {
      # Preparing data vectors to be in suitable format for plot generation

      population_vector <- c()
      for (i in seq_along(df)) {
        df_sum <- fold_ps_mat(df[[i]])
        population_vector <- c(population_vector, colSums(df_sum))
      }
      years <- rep(names(df), each = ncol(df[[1]][, 1:(ncol(df[[i]]) / 2)]))
      religions <- rep(colnames(df[[1]][, 1:(ncol(df[[i]]) / 2)]), length(df))

      # Creating data_frame from which the plot will be generated

      plot_data_frame <- data.frame(
        year = years,
        religion = religions,
        population = population_vector
      )
      plot_data_frame <- factor_cols(plot_data_frame, 2L)

      # Creating plot using ggplot2 package and data_frame constructed above

      plot <- ggplot2::ggplot(plot_data_frame, ggplot2::aes(
        x = .data$year,
        y = .data$population,
        group = .data$religion,
        color = .data$religion
      )) +
        .layer_line_point(length(unique(plot_data_frame$year))) +
        ggplot2::scale_color_manual(values = plot_colors) +
        ggplot2::labs(
          x = "Year",
          y = "Population (in thousands)",
          color = "Religion",
          title = paste0("Population by religion in ", name, " in ", year_range(df))
        ) +
        theme_centred_title()
    }
  } else if (variant == 3) {
    # Depending on whether or not the "show_post_switch" option is on there are two different ways of data preparation and visualization

    if (show_post_switch | !post_switch) {
      # Preparing data vectors to be in suitable format for plot generation

      population_vector <- c()
      for (i in seq_along(df)) {
        population_vector <- c(population_vector, colSums(df[[i]]))
      }
      years <- rep(names(df), each = ncol(df[[1]]))
      religions <- rep(colnames(df[[1]]), length(df))

      # Creating data_frame from which the plot will be generated

      plot_data_frame <- data.frame(
        year = years, religion = religions,
        population = population_vector
      )
      plot_data_frame <- factor_cols(plot_data_frame, 2L)

      # Creating plot using ggplot2 package and data_frame constructed above

      plot <- ggplot2::ggplot(plot_data_frame, ggplot2::aes(
        x = .data$year,
        y = .data$population,
        fill = .data$religion
      )) +
        .layer_fill_bar(plot_switching_colors) +
        ggplot2::labs(
          x = "Year",
          y = "Structure",
          fill = "Religion",
          title = paste0("Population structure by religion in ", name, " in ", year_range(df))
        ) +
        theme_centred_title()
    } else {
      # Preparing data vectors to be in suitable format for plot generation

      population_vector <- c()
      for (i in seq_along(df)) {
        df_sum <- fold_ps_mat(df[[i]])
        population_vector <- c(population_vector, colSums(df_sum))
      }
      years <- rep(names(df), each = ncol(df[[1]][, 1:(ncol(df[[i]]) / 2)]))
      religions <- rep(colnames(df[[1]][, 1:(ncol(df[[i]]) / 2)]), length(df))

      # Creating data_frame from which the plot will be generated

      plot_data_frame <- data.frame(
        year = years,
        religion = religions,
        population = population_vector
      )
      plot_data_frame <- factor_cols(plot_data_frame, 2L)

      # Creating plot using ggplot2 package and data_frame constructed above

      plot <- ggplot2::ggplot(plot_data_frame, ggplot2::aes(
        x = .data$year,
        y = .data$population,
        fill = .data$religion
      )) +
        .layer_fill_bar(plot_colors) +
        ggplot2::labs(
          x = "Year",
          y = "Structure",
          fill = "Religion",
          title = paste0("Population structure by religion in ", name, " in ", year_range(df))
        ) +
        theme_centred_title()
    }
  } else if (variant == 4) {
    # Calculating limits for x axis of population pyramid plot

    df_temp <- df
    rows <- c()

    for (year in seq_along(df)) {
      rows <- c(rows, rowSums(df[[year]]))
    }

    max_population <- max(rows) * 1.1

    # Depending on whether or not the "show_post_switch" option is on there are two different ways of data preparation and visualization

    if (show_post_switch | !post_switch) {
      # Preparing data vectors to be in suitable format for plot generation

      df <- df_temp[[period]]
      total_population <- c()
      sex <- rep(c(rep(1L, 20), rep(2L, 20)), ncol(df))
      age_groups <- c(
        "0-4", "5-9", "10-14", "15-19", "20-24", "25-29",
        "30-34", "35-39", "40-44", "45-49", "50-54", "55-59",
        "60-64", "65-69", "70-74", "75-79", "80-84", "85-89",
        "90-94", "95+"
      )
      age <- c(rep(1:20, (2 * ncol(df))))
      religions <- rep(colnames(df), each = nrow(df))
      for (i in 1:ncol(df)) {
        total_population <- c(total_population, df[, i])
      }

      # Creating data_frame from which the plot will be generated

      population <- data.frame(
        age_group = factor(age),
        sex = sex,
        religion = religions,
        population = total_population
      )
      population <- factor_cols(population, 3L)

      # Creating plot using ggplot2 package and data_frame constructed above

      plot <- ggplot2::ggplot(population, ggplot2::aes(
        x = .data$age_group,
        y = ifelse(test = .data$sex == 1L,
          yes = -.data$population,
          no = .data$population
        ),
        fill = .data$religion
      )) +
        ggplot2::geom_bar(stat = "identity") +
        ggplot2::geom_hline(yintercept = 0) +
        ggplot2::scale_y_continuous(labels = abs, limits = c(
          -1 * max_population,
          max_population
        )) +
        ggplot2::scale_x_discrete(labels = age_groups) +
        ggplot2::coord_flip() +
        ggplot2::scale_fill_manual(values = plot_switching_colors) +
        ggplot2::labs(
          x = "Age",
          y = "Population",
          fill = "Religion",
          title = paste(
            "Population pyramid of", name, "for",
            as.character(names(df_temp)[period]),
            "with religions"
          )
        ) +
        theme_centred_title()
    } else {
      # Preparing data vectors to be in suitable format for plot generation

      df <- fold_ps_mat(df_temp[[period]])
      colnames(df) <- colnames(df_temp[[period]])[1:(ncol(df_temp[[period]]) / 2)]
      row_population <- rowSums(df)
      total_population <- c()
      sex <- rep(c(rep(1L, 20), rep(2L, 20)), ncol(df))
      age_groups <- c(
        "0-4", "5-9", "10-14", "15-19", "20-24", "25-29",
        "30-34", "35-39", "40-44", "45-49", "50-54", "55-59",
        "60-64", "65-69", "70-74", "75-79", "80-84", "85-89",
        "90-94", "95+"
      )
      age <- c(rep(1:20, (2 * ncol(df))))
      religions <- rep(colnames(df), each = nrow(df))
      for (i in 1:ncol(df)) {
        total_population <- c(total_population, df[, i])
      }

      # Creating data_frame from which the plot will be generated

      population <- data.frame(
        age_group = factor(age),
        sex = sex,
        religion = religions,
        population = total_population
      )
      population <- factor_cols(population, 3L)

      # Creating plot using ggplot2 package and data_frame constructed above

      plot <- ggplot2::ggplot(population, ggplot2::aes(
        x = .data$age_group,
        y = ifelse(test = .data$sex == 1L,
          yes = -.data$population,
          no = .data$population
        ),
        fill = .data$religion
      )) +
        ggplot2::geom_bar(stat = "identity") +
        ggplot2::geom_hline(yintercept = 0) +
        ggplot2::scale_y_continuous(labels = abs, limits = c(
          -1 * max_population,
          max_population
        )) +
        ggplot2::scale_x_discrete(labels = age_groups) +
        ggplot2::coord_flip() +
        ggplot2::scale_fill_manual(values = plot_colors) +
        ggplot2::labs(
          x = "Age",
          y = "Population",
          fill = "Religion",
          title = paste(
            "Population pyramid of", name, "for",
            as.character(names(df_temp)[period]),
            "with religions"
          )
        ) +
        theme_centred_title()
    }
    return(plot)
  } else if (variant == 5) {
    sd <- df_e
    if (post_switch && !show_post_switch) df <- .fold_asfr(df, df_i$fert, df_i$expo)
    df <- df[df$Mother_age_group == "TFR" & df$Structure == "total", ]
    rel_cols <- setdiff(colnames(df), c("Country", "Country_code", "Period", "Mother_age_group", "Structure", "Region"))

    plot_data_frame <- data.frame(
      year = rep(df$Period, each = length(rel_cols)),
      religion = rep(rel_cols, nrow(df)),
      tfr = as.numeric(t(as.matrix(df[, rel_cols, with = FALSE])))
    )
    plot_data_frame <- factor_cols(plot_data_frame, 2L)

    # First colour is for the "Total" column
    palette <- if (length(rel_cols) - 1L > length(plot_colors)) plot_switching_colors else plot_colors

    plot <- ggplot2::ggplot(plot_data_frame, ggplot2::aes(
      x = .data$year,
      y = .data$tfr,
      group = .data$religion,
      color = .data$religion
    )) +
      .layer_line_point(length(unique(plot_data_frame$year))) +
      ggplot2::scale_color_manual(values = c("deeppink1", palette)) +
      ggplot2::labs(
        x = "Period",
        y = "TFR (number of children per woman)",
        color = "Religion",
        title = paste0("TFR by religion in ", name, " in ", year_range(sd))
      ) +
      theme_centred_title()
  } else if (variant == 6) {
    asfr_periods <- unique(df$Period)
    if (length(period) != 1L || is.na(period) || period < 1 || period > length(asfr_periods)) {
      stop(
        "`period` must be between 1 and ", length(asfr_periods),
        " for ASFR plots (available: ", paste(asfr_periods, collapse = ", "), ").",
        call. = FALSE
      )
    }
    period_name <- asfr_periods[period]
    if (post_switch && !show_post_switch) df <- .fold_asfr(df, df_i$fert, df_i$expo)
    df <- df[df$Period == period_name & df$Structure == "total" & df$Mother_age_group != "TFR", ]
    rel_cols <- setdiff(colnames(df), c("Country", "Country_code", "Period", "Mother_age_group", "Structure", "Region"))

    plot_data_frame <- data.frame(
      age = rep(df$Mother_age_group, length(rel_cols)),
      religion = rep(rel_cols, each = nrow(df)),
      asfr = unlist(df[, rel_cols, with = FALSE], use.names = FALSE)
    )
    plot_data_frame <- factor_cols(plot_data_frame, 2L)

    # First colour is for the "Total" column
    palette <- if (length(rel_cols) - 1L > length(plot_colors)) plot_switching_colors else plot_colors

    plot <- ggplot2::ggplot(plot_data_frame, ggplot2::aes(
      x = .data$age,
      y = .data$asfr,
      group = .data$religion,
      color = .data$religion
    )) +
      .layer_line_point() +
      ggplot2::scale_color_manual(values = c("deeppink1", palette)) +
      ggplot2::labs(
        x = "Age",
        y = "ASFR",
        color = "Religion",
        title = paste0("ASFR by religion in ", name, " in ", period_name)
      ) +
      theme_centred_title()
  } else if (variant == 7) {
    sd <- df_e
    plot_data_frame <- .period_religion_totals(
      df[df$Structure == "total", ], .fert_meta,
      fold = post_switch && !show_post_switch, value_name = "births"
    )

    plot <- ggplot2::ggplot(plot_data_frame, ggplot2::aes(
      x = .data$year,
      y = .data$births,
      fill = .data$religion
    )) +
      .layer_fill_bar(.palette_for(nlevels(plot_data_frame$religion), plot_colors, plot_switching_colors)) +
      ggplot2::labs(
        x = "Period",
        y = "Structure",
        fill = "Religion",
        title = paste0("Structure of births by religion in ", name, " in ", year_range(sd))
      ) +
      theme_centred_title()
  } else if (variant == 8) {
    # Preparing data vectors to be in suitable format for plot generation

    sd <- df_e

    df <- df[df$Structure == "total", ]
    rel_cols <- rel_cols_of(df, .mort_meta)
    years <- unique(df$Period)
    mortality <- vapply(years, function(p) {
      sum(df[df$Period == p, rel_cols, with = FALSE], na.rm = TRUE)
    }, numeric(1L))

    # Creating data_frame from which the plot will be generated

    plot_data_frame <- data.frame(
      year = years,
      mortality = mortality
    )

    # Creating plot using ggplot2 package and data_frame constructed above

    plot <- ggplot2::ggplot(plot_data_frame, ggplot2::aes(
      x = .data$year,
      y = .data$mortality,
      group = 1
    )) +
      .layer_line_point(length(unique(plot_data_frame$year))) +
      ggplot2::labs(
        x = "Period",
        y = "Number of deaths (in thousands)",
        title = paste0("Deaths in ", name, " in ", year_range(sd))
      ) +
      theme_centred_title()
  } else if (variant == 9) {
    # Preparing data vectors to be in suitable format for plot generation

    sd <- df

    # Religion columns selected by name: light and full migration tables have
    # different numbers of meta columns (no Sex/Age_group in light mode).
    periods <- unique(df_e$Period)
    period_totals <- function(dt, meta) {
      rel_cols <- rel_cols_of(dt, meta)
      vapply(periods, function(p) {
        sum(dt[dt$Period == p & dt$Structure == "total", rel_cols, with = FALSE], na.rm = TRUE)
      }, numeric(1L))
    }
    migrations <- c(period_totals(df_e, .emig_meta), period_totals(df_i, .immig_meta))
    types <- rep(c("Out", "In"), each = length(periods))
    years <- rep(periods, 2)

    # Creating data_frame from which the plot will be generated

    plot_data_frame <- data.frame(
      year = years,
      type = types,
      migration = migrations
    )

    # Creating plot using ggplot2 package and data_frame constructed above

    plot <- ggplot2::ggplot(plot_data_frame, ggplot2::aes(
      x = .data$year,
      y = .data$migration,
      group = .data$type,
      color = .data$type
    )) +
      .layer_line_point(length(unique(plot_data_frame$year))) +
      ggplot2::scale_color_manual(values = c("green4", "red4")) +
      ggplot2::labs(
        x = "Period",
        y = "Number of migrants (in thousands)",
        color = "Type",
        title = paste0("Migration (In/Out) in ", name, " in ", year_range(sd))
      ) +
      theme_centred_title()
  } else if (variant %in% c(10, 11, 16)) {
    # 10 / 16: emigrants (16 is the global entry); 11: immigrants.
    sd <- df
    mig <- if (variant == 11) df_i else df_e
    plot_data_frame <- .period_religion_totals(
      mig[mig$Structure == "total", ], if (variant == 11) .immig_meta else .emig_meta,
      fold = post_switch && !show_post_switch, value_name = "migrants"
    )

    plot <- ggplot2::ggplot(plot_data_frame, ggplot2::aes(
      x = .data$year,
      y = .data$migrants,
      group = .data$religion,
      fill = .data$religion
    )) +
      .layer_fill_bar(.palette_for(nlevels(plot_data_frame$religion), plot_colors, plot_switching_colors)) +
      ggplot2::labs(
        x = "Period",
        y = "Structure",
        fill = "Religion",
        title = paste0(
          "Structure of migrants (", if (variant == 11) "in" else "out", ") by religion in ",
          name, " in ", year_range(sd)
        )
      ) +
      theme_centred_title()
  } else if (variant == 12) {
    n_rel <- length(df)
    is_doubled <- ncol(df[[1]]) > n_rel
    dest_start <- if (is_doubled) n_rel + 1L else 1L
    dest_end <- ncol(df[[1]])
    n_dest <- dest_end - dest_start + 1L # always equals n_rel

    origin_names <- colnames(df[[1]])[1:n_rel]
    # When post_switch is folded, only base-religion origins are plotted.
    origins <- if (show_post_switch) seq_len(n_rel) else which(!grepl("_post_switch$", origin_names))

    sw <- c()
    for (i in origins) {
      df_temp <- df[[i]]
      n_half <- as.integer(nrow(df_temp) / 2)
      df_males <- df_temp[1:n_half, ]
      or_male <- Reduce("*", df_males[, i])
      sr_m <- colSums(df_males[, dest_start:dest_end])
      sr_m <- sr_m / sum(sr_m)
      sr_m <- sr_m * (1 - or_male)
      if (!is_doubled) sr_m[[i]] <- or_male # non-ps: diagonal holds retention
      sw <- c(sw, sr_m)

      df_females <- df_temp[(n_half + 1L):nrow(df_temp), ]
      or_fem <- Reduce("*", df_females[, i])
      sr_f <- colSums(df_females[, dest_start:dest_end])
      sr_f <- sr_f / sum(sr_f)
      sr_f <- sr_f * (1 - or_fem)
      if (!is_doubled) sr_f[[i]] <- or_fem
      sw <- c(sw, sr_f)
    }
    origin_religion <- rep(origin_names[origins], each = n_dest * 2L)
    dest_names <- colnames(df[[1]])[dest_start:dest_end]
    # Switchers land in X_post_switch columns; label them as X when folded so
    # they share a fill with X.
    if (!show_post_switch) dest_names <- sub("_post_switch$", "", dest_names)
    switching_religion <- rep(dest_names, length(origins) * 2L)
    sex <- factor(
      rep(rep(c(1L, 2L), each = n_dest), length(origins)),
      levels = c(1L, 2L),
      labels = c("Males", "Females")
    )

    # Creating data_frame from which the plot will be generated

    plot_data_frame <- data.frame(
      origin_religion = origin_religion,
      switching_religion = switching_religion,
      sex = sex,
      switching = sw
    )
    plot_data_frame <- factor_cols(plot_data_frame, c(2L, 1L))
    plot_data_frame[is.na(plot_data_frame)] <- 0

    # Creating plot using ggplot2 package and data_frame constructed above

    plot <- ggplot2::ggplot(plot_data_frame, ggplot2::aes(
      x = .data$origin_religion,
      y = .data$switching,
      fill = .data$switching_religion
    )) +
      .layer_fill_bar(.palette_for(nlevels(plot_data_frame$switching_religion), plot_colors, plot_switching_colors)) +
      ggplot2::facet_wrap(~sex, nrow = 2) +
      ggplot2::labs(
        x = "Origin religion",
        y = "Retention & switching (share)",
        fill = "New religion",
        title = paste("Retention & switching by religion in", name)
      ) +
      theme_centred_title()
  } else if (variant == 13) {
    sd <- df_e # structure_data (passed as df_e for variant 13)
    fl <- .switching_flows(df, switching_religion, fold = post_switch && !show_post_switch)
    sw_rel_name <- fl$name

    plot_data_frame <- data.frame(
      year = c(rep(fl$periods, each = length(fl$dest_cols)), rep(fl$periods, each = length(fl$in_origins))),
      religion = factor(
        c(rep(fl$dest_cols, length(fl$periods)), rep(fl$in_origins, length(fl$periods))),
        levels = fl$dest_cols
      ),
      type = rep(c("out", "in"), c(length(fl$out), length(fl$inflow))),
      switching = c(as.numeric(fl$out), as.numeric(fl$inflow))
    )

    palette <- .palette_for(length(fl$dest_cols), plot_colors, plot_switching_colors)

    plot <- ggplot2::ggplot(plot_data_frame, ggplot2::aes(
      x = .data$year,
      y = ifelse(test = .data$type == "out", yes = -.data$switching, no = .data$switching),
      group = .data$religion,
      fill = .data$religion
    )) +
      .layer_switch_bar(palette) +
      ggplot2::labs(
        x = "Period",
        y = "Switching (in thousands)",
        fill = "Religion",
        title = paste0("Switching of ", sw_rel_name, " in ", name, " in ", year_range(sd))
      ) +
      theme_centred_title()
  } else if (variant == 14) {
    if (post_switch) {
      table_df <- data.frame(data = matrix(data = 0, nrow = 0, ncol = (ncol(df[[1]]) / 2)))
      for (year in seq_along(df)) {
        table_df <- rbind(table_df, colSums(fold_ps_mat(df[[year]])))
      }
    } else {
      table_df <- data.frame(data = matrix(data = 0, nrow = 0, ncol = ncol(df[[1]])))
      for (year in seq_along(df)) {
        table_df <- rbind(table_df, colSums(df[[year]]))
      }
    }
    table_sum <- rowSums(table_df)
    table_df <- table_df / table_sum
    table_df <- round(table_df, 4) * 100
    for (r in 1:nrow(table_df)) {
      for (c in 1:ncol(table_df)) {
        table_df[r, c] <- paste(table_df[r, c], "%", sep = "")
      }
    }
    year_vector <- names(df)
    table_df <- cbind(year_vector, (table_sum * 1000), table_df)
    n_rel_cols <- if (post_switch) as.integer(ncol(df[[1]]) / 2) else ncol(df[[1]])
    colnames(table_df) <- c("Year", "Total", colnames(df[[1]])[1:n_rel_cols])
    return(table_df)
  } else if (variant == 15) {
    # Preparing data vectors to be in suitable format for plot generation

    sd <- df
    df <- df_e
    rel_cols <- rel_cols_of(df, .emig_meta)
    years <- unique(df$Period)
    migrations <- vapply(years, function(p) {
      sum(df[df$Period == p & df$Structure == "total", rel_cols, with = FALSE], na.rm = TRUE)
    }, numeric(1L))

    # Creating data_frame from which the plot will be generated

    plot_data_frame <- data.frame(
      year = years,
      migration = migrations
    )

    # Creating plot using ggplot2 package and data_frame constructed above

    plot <- ggplot2::ggplot(plot_data_frame, ggplot2::aes(
      x = .data$year,
      y = .data$migration,
      group = 1
    )) +
      .layer_line_point(length(unique(plot_data_frame$year))) +
      ggplot2::labs(
        x = "Period",
        y = "Number of migrants (in thousands)",
        title = paste0("Emigration in ", name, " in ", year_range(sd))
      ) +
      theme_centred_title()
  } else {
    warning(paste("mrc_plot: unknown variant:", variant))
    return(invisible(NULL))
  }
  plot
}
