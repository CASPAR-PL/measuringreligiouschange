#' @include plots_methods.R

#' @title Reference Class representing a region as Region_object
#' @description
#' Object representing demographic and model-specific information for a single region.
#'
#' Each region object contains information fields as well as calculated results of countries projections aggregated to respective regions allowing user to easily perform calculations and visualize the results on projection results for regions.
#'
#' @details
#' Region_object stores results of projection aggregated to regions.
#' @examples
#' # Running a full projection is time-consuming.
#' # Wrapped in dontrun to avoid executing during documentation build.
#' \dontrun{
#' obj <- test_object_generator(object_name = "example")
#' project(projection_object = obj, progress_bar = FALSE, save_totals = TRUE)
#' # Access a region object by name
#' reg <- obj$region_object_list[["NOAM"]]
#' reg$name # "NOAM"
#' length(reg$structure_data) # one entry per projection period
#' }
#'
#' @export
Region_object <- methods::setRefClass("Region_object",

  #' @field name Character; name of the region e.g. "North America"
  #' @field region Character; region code identifying which countries belong to this region e.g. "NOAM"
  #' @field structure_data List; aggregated population structure matrices indexed by year label, summed across all countries in the region
  #' @field previous_mortality data.table; aggregated mortality output for the region. Columns: Country, Country_code, Period, Sex (integer 1/2), Age_group, Structure, Region, then one column per religion
  #' @field previous_fertility data.table; aggregated fertility (births) output for the region. Columns: Country, Country_code, Period, Mother_age_group, Structure, Region, Total, then one column per religion
  #' @field previous_asfr data.table; aggregated age-specific fertility rate output for the region. Columns: Country, Country_code, Period, Mother_age_group, Structure, Region, Total, then one column per religion; rows with Mother_age_group == "TFR" contain period totals
  #' @field previous_fertility_exposure data.table; aggregated women-population exposure for the region. Columns: Country, Country_code, Period, Mother_age_group, Structure, Region, Total, then one column per religion
  #' @field previous_switching data.table; aggregated switching output for the region. Columns: Country, Country_code, Period, Origin_religion, Structure, Region (light mode) or additionally Sex, Age_group (full mode), then one column per destination religion
  #' @field previous_immigration data.table; aggregated immigration output for the region. Columns: Destination, Country_code, Period, Structure, Origin, Region (light mode) or additionally Sex, Age_group (full mode), then one column per religion
  #' @field previous_emigration data.table; aggregated emigration output for the region. Columns: Origin, Country_code, Period, Structure, Destination, Region (light mode) or additionally Sex, Age_group (full mode), then one column per religion
  fields = list(
    # Information fields
    name = "character",
    region = "character",
    # Output data — structure_data remains a list of matrices (one per projection year)
    structure_data = "list",
    previous_mortality = "ANY",
    previous_fertility = "ANY",
    previous_asfr = "ANY",
    previous_fertility_exposure = "ANY",
    previous_switching = "ANY",
    previous_immigration = "ANY",
    previous_emigration = "ANY"
  )
)

Region_object$methods(
  #' @name Region_object$plot
  #' @title Creating plots
  #' @description
  #' Function for creating ggplot2-style plots of projected population
  #' @param variant Numeric; type of plot to generate. Variants are listed by calling `Country_object$plot(variant = 0)` (no default)
  #' @param period Numeric; index of the projection period for which the plot should be generated; used only in period-specific plot types (no default)
  #' @param show_post_switch Logical; if TRUE, post-switch populations are visualized separately in the plots (no default)
  #' @param switching_religion Numeric; index of the religion for which switching plots should be generated; used only in switching-specific plot types (no default)
  #' @param plot_colors Character vector; colors used for each original religion in the plots (no default)
  #' @param plot_switching_colors Character vector; colors used for original and post-switch religions in the plots (no default)
  #' @return A ggplot2 plot object for the selected variant and region.
  #' @noRd
  plot = function(variant, period = 0, show_post_switch, switching_religion = 0,
                  plot_colors, plot_switching_colors, light_mig, light_sw, post_switch) {
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
    } else if (variant == 13) {
      df <- previous_switching
      df_e <- structure_data
      df_i <- 0
    } else if (variant == 14) {
      df <- structure_data
      df_e <- 0
      df_i <- 0
    } else if (variant == 15) {
      df <- structure_data
      df_e <- previous_emigration
      df_i <- previous_immigration
    } else if (variant == 16) {
      df_e <- previous_emigration
      df <- structure_data
      df_i <- 0
    }

    # Executing mrc_plot function which generates a single plot

    plotplot <- mrc_plot(
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
    return(plotplot)
  },

  # Extension of plot() function; allows generating table containing population religious structure across years

  save_plot = function(variant, period = 0, show_post_switch, switching_religion = 0,
                       plot_colors, plot_switching_colors, light_mig, light_sw, post_switch) {
    if (variant == 14) {
      # Part of function generating the table

      title <- grid::textGrob(paste("Population structure in ", name, " in ", as.character(names(structure_data)[[1]]), "-", as.character(names(structure_data)[[length(structure_data)]]),
        sep = ""
      ), gp = grid::gpar(fontsize = 14, fontface = "bold"))
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

  generate_plots = function(dem, switch, mig, show_post_switch, plot_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40"), plot_switching_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40", "darkblue", "darkgreen", "red4", "yellow4", "orange4", "purple4", "grey30"), global, light_mig, light_sw, post_switch) {
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
      save_plot(
        variant = 6,
        period = round(median(seq_len(length(unique(previous_asfr[[3L]]))))),
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
        period = length(unique(previous_asfr[[3L]])),
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
      if (global) {
        save_plot(
          variant = 15,
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
          variant = 16,
          period = 0,
          show_post_switch = show_post_switch,
          switching_religion = 0,
          plot_colors = plot_colors,
          plot_switching_colors = plot_switching_colors,
          light_mig,
          light_sw,
          post_switch
        )
      } else {
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
    }
    if (post_switch) {
      number_of_rels <- ncol(structure_data[[1]]) / 2
    } else {
      number_of_rels <- ncol(structure_data[[1]])
    }
    if (switch) {
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
