#' @include class_projection.R
#' @include region_base.R
#' @include plots_methods.R

Country_object$methods(
  #' @name Country_object$plot
  #' @title Creating plots
  #' @description
  #' Function for creating ggplot2-style plots of projected population
  #' @param variant Type of generated plot; variants are described by using Country_object$plot(variant = 0) (numeric)
  #' @param period Number of period of projection for which plot should be generated; only in specific types of plots (numeric)
  #' @param show_post_switch Specifies if show_post_switch population should be visualized separately (logical)
  #' @param switching_religion Number of religion for which plot should be generated; only in specific type of plots (numeric)
  #' @param plot_colors Colors of visualized religions; only for original religions (character vector)
  #' @param plot_switching_colors Colors of visualized religions; for original religions and show_post_switch religions (character vector)
  #' @param light_mig Determines if migration data is saved in its light version (logical)
  #' @param light_sw Determines if switching data is saved in its light version (logical)
  #' @param post_switch Determines if post_switch population is saved in separate columnds (logical)
  #' @return A ggplot2 plot object for the selected variant, a data frame for variant 14 (population structure table), or `NULL` invisibly when `variant == 0` (prints available variant descriptions to the console).
  #' @noRd
  plot = function(variant,
                  period = 0,
                  show_post_switch,
                  switching_religion = 0,
                  plot_colors,
                  plot_switching_colors,
                  light_mig,
                  light_sw,
                  post_switch) {
    # Checking if plot_colors and plot_switching_colors given by user are in the correct form

    # if (ncol(structure_data[[1]]) != length(plot_switching_colors) &&
    #   show_post_switch == TRUE) {
    #   print("Wrong length of plot_switching_colors")
    #   return()
    # } else if ((ncol(structure_data[[1]]) / 2) != length(plot_colors) &&
    #   show_post_switch == FALSE) {
    #   print("Wrong length of plot_colors")
    #   return()
    # }

    # Checking variant chose by user and selecting correct data for further calculations

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
    } else if (variant %in% c(1:4)) {
      df <- structure_data
      df_e <- 0
      df_i <- 0
    } else if (variant %in% c(5, 6)) {
      # Births and exposure are needed to fold post_switch rates into base religions.
      df <- previous_asfr
      df_e <- structure_data
      df_i <- list(fert = previous_fertility, expo = previous_fertility_exposure)
    } else if (variant == 7) {
      df <- previous_fertility
      df_e <- structure_data
      df_i <- 0
    } else if (variant == 8) {
      df <- previous_mortality
      df_e <- structure_data
      df_i <- 0
    } else if (variant == 9) {
      df <- structure_data
      df_e <- previous_emigration
      df_i <- previous_immigration
    } else if (variant == 10) {
      df_e <- previous_emigration
      df <- structure_data
      df_i <- 0
    } else if (variant == 11) {
      df_i <- previous_immigration
      df <- structure_data
      df_e <- 0
    } else if (variant == 12) {
      df <- switching_matrices_list
      df_e <- structure_data
      df_i <- 0
    } else if (variant == 13) {
      df <- previous_switching
      df_e <- structure_data
      df_i <- 0
    } else if (variant == 14) {
      df <- structure_data
      df_e <- 0
      df_i <- 0
    } else {
      print("wrong plot variant")
      return(NULL)
    }

    # Executing mrc_plot function which generates a single plot

    mrc_plot(
      variant,
      df,
      df_e,
      df_i,
      name,
      period,
      show_post_switch,
      switching_religion,
      plot_colors,
      plot_switching_colors,
      FALSE,
      light_mig,
      light_sw,
      post_switch
    )
  },

  # Extension of plot() function; allows generating table containing population religious structure across years

  save_plot = function(variant, period = 0, show_post_switch, switching_religion = 0,
                       plot_colors, plot_switching_colors, light_mig, light_sw, post_switch) {
    # Part of function generating the table

    if (variant == 14) {
      title <- grid::grid.text(paste("Population structure in ", name, " in ", as.character(names(structure_data)[[1]]), "-", as.character(names(structure_data)[[length(structure_data)]]),
        sep = ""
      ), gp = grid::gpar(fontsize = 14, fontface = "bold"), draw = FALSE)
      tab <- gridExtra::tableGrob(plot(
        variant, period, show_post_switch, switching_religion,
        plot_colors, plot_switching_colors, light_mig, light_sw, post_switch
      ), rows = NULL)
      gridExtra::grid.arrange(title, tab, ncol = 1, heights = c(0.1, 1))
    } else {
      # Part of function generating plots via plot() function

      plot <- plot(
        variant,
        period,
        show_post_switch,
        switching_religion,
        plot_colors,
        plot_switching_colors,
        light_mig,
        light_sw,
        post_switch
      )
      print(plot)
    }
    return(invisible(NULL))
  },

  # Extension of save_plot() function; allows specifying which plots should be created by dividing them into three groups - demographic, switching and migration

  generate_plots = function(dem, switch, mig, show_post_switch, plot_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40"), plot_switching_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40", "darkblue", "darkgreen", "red4", "yellow4", "orange4", "purple4", "grey30"), light_mig, light_sw, post_switch) {
    if (dem) {
      save_plot(
        variant = 14,
        period = 0,
        show_post_switch = show_post_switch,
        switching_religion = 0,
        plot_colors = plot_colors,
        plot_switching_colors = plot_switching_colors,
        light_mig,
        light_sw,
        post_switch
      )
      save_plot(
        variant = 1,
        period = 0,
        show_post_switch = show_post_switch,
        switching_religion = 0,
        plot_colors = plot_colors,
        plot_switching_colors = plot_switching_colors,
        light_mig,
        light_sw,
        post_switch
      )
      save_plot(
        variant = 2,
        period = 0,
        show_post_switch = show_post_switch,
        switching_religion = 0,
        plot_colors = plot_colors,
        plot_switching_colors = plot_switching_colors,
        light_mig,
        light_sw,
        post_switch
      )
      save_plot(
        variant = 3,
        period = 0,
        show_post_switch = show_post_switch,
        switching_religion = 0,
        plot_colors = plot_colors,
        plot_switching_colors = plot_switching_colors,
        light_mig,
        light_sw,
        post_switch
      )
      save_plot(
        variant = 4,
        period = 1,
        show_post_switch = show_post_switch,
        switching_religion = 0,
        plot_colors = plot_colors,
        plot_switching_colors = plot_switching_colors,
        light_mig,
        light_sw,
        post_switch
      )
      save_plot(
        variant = 4,
        period = round(median(seq_along(structure_data))),
        show_post_switch = show_post_switch,
        switching_religion = 0,
        plot_colors = plot_colors,
        plot_switching_colors = plot_switching_colors,
        light_mig,
        light_sw,
        post_switch
      )
      save_plot(
        variant = 4,
        period = length(structure_data),
        show_post_switch = show_post_switch,
        switching_religion = 0,
        plot_colors = plot_colors,
        plot_switching_colors = plot_switching_colors,
        light_mig,
        light_sw,
        post_switch
      )
      save_plot(
        variant = 5,
        period = 0,
        show_post_switch = show_post_switch,
        switching_religion = 0,
        plot_colors = plot_colors,
        plot_switching_colors = plot_switching_colors,
        light_mig,
        light_sw,
        post_switch
      )
      save_plot(
        variant = 6,
        period = 1,
        show_post_switch = show_post_switch,
        switching_religion = 0,
        plot_colors = plot_colors,
        plot_switching_colors = plot_switching_colors,
        light_mig,
        light_sw,
        post_switch
      )
      n_asfr_periods <- length(unique(previous_asfr[[3]]))
      save_plot(
        variant = 6,
        period = round(median(seq_len(n_asfr_periods))),
        show_post_switch = show_post_switch,
        switching_religion = 0,
        plot_colors = plot_colors,
        plot_switching_colors = plot_switching_colors,
        light_mig,
        light_sw,
        post_switch
      )
      save_plot(
        variant = 6,
        period = n_asfr_periods,
        show_post_switch = show_post_switch,
        switching_religion = 0,
        plot_colors = plot_colors,
        plot_switching_colors = plot_switching_colors,
        light_mig,
        light_sw,
        post_switch
      )
      save_plot(
        variant = 7,
        period = 0,
        show_post_switch = show_post_switch,
        switching_religion = 0,
        plot_colors = plot_colors,
        plot_switching_colors = plot_switching_colors,
        light_mig,
        light_sw,
        post_switch
      )
      save_plot(
        variant = 8,
        period = 0,
        show_post_switch = show_post_switch,
        switching_religion = 0,
        plot_colors = plot_colors,
        plot_switching_colors = plot_switching_colors,
        light_mig,
        light_sw,
        post_switch
      )
    }

    if (mig) {
      save_plot(
        variant = 9,
        period = 0,
        show_post_switch = show_post_switch,
        switching_religion = 0,
        plot_colors = plot_colors,
        plot_switching_colors = plot_switching_colors,
        light_mig,
        light_sw,
        post_switch
      )
      save_plot(
        variant = 10,
        period = 0,
        show_post_switch = show_post_switch,
        switching_religion = 0,
        plot_colors = plot_colors,
        plot_switching_colors = plot_switching_colors,
        light_mig,
        light_sw,
        post_switch
      )
      save_plot(
        variant = 11,
        period = 0,
        show_post_switch = show_post_switch,
        switching_religion = 0,
        plot_colors = plot_colors,
        plot_switching_colors = plot_switching_colors,
        light_mig,
        light_sw,
        post_switch
      )
    }

    if (post_switch) {
      number_of_rels <- ncol(structure_data[[1]]) / 2
    } else {
      number_of_rels <- ncol(structure_data[[1]])
    }

    if (switch) {
      save_plot(
        variant = 12,
        period = 0,
        show_post_switch = show_post_switch,
        switching_religion = 0,
        plot_colors = plot_colors,
        plot_switching_colors = plot_switching_colors,
        light_mig,
        light_sw,
        post_switch
      )

      for (religion in 1:number_of_rels) {
        save_plot(
          variant = 13,
          period = 0,
          show_post_switch = show_post_switch,
          switching_religion = religion,
          plot_colors = plot_colors,
          plot_switching_colors = plot_switching_colors,
          light_mig,
          light_sw,
          post_switch
        )
      }
    }
    return(invisible(NULL))
  }
)
