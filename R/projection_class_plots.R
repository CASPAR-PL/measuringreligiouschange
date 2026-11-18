#' @include projection_class_saving.R


Projection_object$methods(
  list(
    #' @name Projection_object$save_plots_all
    #' @title Saving country plots to .pdf file(s)
    #' @description
    #' Function for saving country plots to .pdf file or files
    #' @param single_file Logical; if TRUE, saves all plots into a single .pdf file (no default)
    #' @param order_by_name Logical; if TRUE, countries are sorted alphabetically in the output (no default)
    #' @param dem Logical; if TRUE, generates structure, fertility and mortality plots (no default)
    #' @param folder Character; name of folder in which plots should be saved (no default)
    #' @param show_post_switch Logical; if TRUE, post-switch populations are visualized separately in the plots (no default)
    #' @param plot_colors Character vector; colors used for each original religion in the plots (no default)
    #' @param plot_switching_colors Character vector; colors used for original and post-switch religions in the plots (no default)
    #' @param switch Logical; if TRUE, generates switching plots (no default)
    #' @param mig Logical; if TRUE, generates migration plots (no default)
    #' @param progress_bar Logical; whether to show a progress bar during saving (no default)
    #' @return Called for its side effects. Saves country plots to PDF file(s) in `folder` and prints a completion message.
    #' @noRd
    save_plots_all = function(single_file = TRUE,
                              order_by_name = FALSE,
                              show_post_switch = FALSE,
                              folder = projection_name,
                              dem = TRUE,
                              switch = switching,
                              mig = migration,
                              plot_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40"),
                              plot_switching_colors = c(
                                "blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40",
                                "darkblue", "darkgreen", "red4", "yellow4", "orange4", "purple4", "grey30"
                              ),
                              progress_bar = TRUE) {
      # Specifying folder in which the plots should be saved

      output_dir <- folder
      if (!dir.exists(output_dir)) {
        dir.create(output_dir)
      }

      # Specifying if progress bar should be shown and estimates the time needed for saving all of the plots

      if (progress_bar) {
        pb <- progress::progress_bar$new(
          format = "Saving plots [:bar] :percent ETA: :eta",
          total = length(country_object_list), clear = FALSE, width = 100
        )
      }

      # Specifying if plots for all the countries should be saved into single file

      if (single_file) {
        pdf(file = file.path(output_dir, paste(projection_name, "all_countries.pdf", sep = "_")), paper = "a4r", width = 10)
      }

      # Specifying if countries should be order alphabetically by name

      if (order_by_name) {
        order <- order_countries_alphabetical()
      } else {
        order <- seq_along(country_object_list)
      }

      # Creating and saving plots to .pdf file(s)

      for (id in order) {
        country_c_code <- names(country_object_list)[id]
        country <- country_object_list[[id]]
        if (!single_file) {
          if (order_by_name) {
            pdf(file = file.path(output_dir, paste0(country_object_list[[id]]$name, " - ", country_c_code, ".pdf")), paper = "a4r", width = 10)
          } else {
            pdf(file = file.path(output_dir, paste0(country_c_code, " - ", country_object_list[[id]]$name, ".pdf")), paper = "a4r", width = 10)
          }
        }

        # Generating a single plot for every country to start the saving process - the plot is not saved into .pdf file, but the line is essential for proper working of the function

        country$plot(1, 0, FALSE, 1, plot_colors, plot_switching_colors, light_mig = light_migration, light_sw = light_switching, post_switch = post_switch)

        # Generating proper plots

        country$generate_plots(dem, switch, mig, show_post_switch, plot_colors, plot_switching_colors, light_mig = light_migration, light_sw = light_switching, post_switch = post_switch)
        if (!single_file) {
          dev.off()
        }
        if (progress_bar) {
          pb$tick()
        }
      }
      if (single_file) {
        dev.off()
      }
      print("Plots saved", console = FALSE)
    },

    #' @name Projection_object$save_plots_regions_all
    #' @title Saving region plots to .pdf file(s)
    #' @description
    #' Function for saving region plots to .pdf file or files
    #' @param single_file Logical; if TRUE, saves all plots into a single .pdf file (no default)
    #' @param order_by_name Logical; if TRUE, countries are sorted alphabetically in the output (no default)
    #' @param dem Logical; if TRUE, generates structure, fertility and mortality plots (no default)
    #' @param folder Character; name of folder in which plots should be saved (no default)
    #' @param show_post_switch Logical; if TRUE, post-switch populations are visualized separately in the plots (no default)
    #' @param plot_colors Character vector; colors used for each original religion in the plots (no default)
    #' @param plot_switching_colors Character vector; colors used for original and post-switch religions in the plots (no default)
    #' @param switch Logical; if TRUE, generates switching plots (no default)
    #' @param mig Logical; if TRUE, generates migration plots (no default)
    #' @param progress_bar Logical; whether to show a progress bar during saving (no default)
    #' @return Called for its side effects. Saves region plots to PDF file(s) in `folder` and prints a completion message.
    #' @noRd

    save_plots_regions_all = function(single_file = TRUE,
                                      show_post_switch = FALSE,
                                      folder = projection_name,
                                      dem = TRUE,
                                      switch = switching,
                                      mig = migration,
                                      plot_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40"),
                                      plot_switching_colors = c(
                                        "blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40",
                                        "darkblue", "darkgreen", "red4", "yellow4", "orange4", "purple4", "grey30"
                                      ),
                                      progress_bar = TRUE) {
      # Checking if data for regions is existing

      if (region_totals == FALSE) {
        print("No region totals found, aborting save_plots_regions_all.")
        return(NULL)
      }

      # Specifying folder in which the plots should be saved

      output_dir <- folder
      if (!dir.exists(output_dir)) {
        dir.create(output_dir)
      }

      # Specifying if progress bar should be shown and estimates the time needed for saving all of the plots

      if (progress_bar) {
        pb <- progress::progress_bar$new(
          format = "Saving plots [:bar] :percent ETA: :eta",
          total = length(region_object_list), clear = FALSE, width = 100
        )
      }

      # Specifying if plots for all the regions should be saved into single file

      if (single_file) {
        pdf(file = file.path(output_dir, paste(projection_name, "all_regions.pdf", sep = "_")), paper = "a4r", width = 10)
      }

      # Creating and saving plots to .pdf file(s)

      for (i in seq_along(region_object_list)) {
        region_name <- names(region_object_list)[i]
        region <- region_object_list[[i]]
        if (!single_file) {
          pdf(file = file.path(output_dir, paste0(region_name, ".pdf")), paper = "a4r", width = 10)
        }

        # Checking if the global data is existing and if it is being currently generated - region and global data structures differ slightly so they have slightly different saving methods

        if (identical(region_name, "Global")) {
          # Generating a single plot for global to start the saving process - the plot is not saved into .pdf file, but the line is essential for proper working of the function

          region$plot(variant = 1, period = 0, show_post_switch = FALSE, switching_religion = 1, plot_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40"), plot_switching_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40", "darkblue", "darkgreen", "red4", "yellow4", "orange4", "purple4", "grey30"), light_mig = light_migration, light_sw = light_switching, post_switch = post_switch)

          # Generating proper plots

          region$generate_plots(dem, switch, mig, show_post_switch, plot_colors, plot_switching_colors, global = TRUE, light_mig = light_migration, light_sw = light_switching, post_switch = post_switch)
        } else {
          # Generating a single plot for every region to start the saving process - the plot is not saved into .pdf file, but the line is essential for proper working of the function

          region$plot(variant = 1, period = 0, show_post_switch = FALSE, switching_religion = 1, plot_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40"), plot_switching_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40", "darkblue", "darkgreen", "red4", "yellow4", "orange4", "purple4", "grey30"), light_mig = light_migration, light_sw = light_switching, post_switch = post_switch)

          # Creating and saving plots to .pdf file(s)

          region$generate_plots(dem, switch, mig, show_post_switch, plot_colors, plot_switching_colors, global = FALSE, light_mig = light_migration, light_sw = light_switching, post_switch = post_switch)
        }

        if (!single_file) {
          dev.off()
        }
        if (progress_bar) {
          pb$tick()
        }
      }
      if (single_file) {
        dev.off()
      }
      print("Plots saved", console = FALSE)
    }
  )
)
