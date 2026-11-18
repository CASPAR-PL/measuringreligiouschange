#' @include projection_class_plots.R


#' @name project
#' @title Conducting MRC projection
#' @description
#' Main method for a projection object. It is used to run the MRC projection - multi-state projection of population by age, sex and religious affiliation.
#' Calling this method executes the MRC projection using parameters stored in the projection_object and input data stored in country_object_list.
#'
#' The method performs the full projection workflow according to the settings contained in projection_object (e.g. number of steps, inclusion of migration and switching, switching sequence, fertility differentials). Input data for all countries must be supplied via country_object_list prior to running.
#'
#' @param projection_object Projection_object; an unresolved projection object to run.
#' @param progress_bar Logical; whether to show a progress bar and ETA during the projection (default TRUE).
#' @param save_totals Logical; whether to compute and store region and global totals after projection (default TRUE).
#' @returns Progress bar and time of execution, modifies projection object
#' @seealso
#' \code{\link{create_country_list}}, \code{\link{create_projection_object}},
#' \code{\link{variants_loader}} to set up a projection before calling this function.
#' \code{\link{save_csv_all}} and \code{\link{save_plots_all}} to export results afterwards.
#' \code{vignette("conducting-projections")} for a full walkthrough.
#' \code{vignette("inner-workings")} for the internal projection algorithm.
#' @examples
#' # Running a full projection is time-consuming.
#' # Wrapped in dontrun to avoid executing during documentation build.
#' \dontrun{
#' p_object <- create_projection_object(name = "test")
#' p_object$project()
#'
#' p_object <- create_projection_object(name = "test")
#' project(projection_object = p_object)
#' }
#' @export
project <- function(projection_object, progress_bar = TRUE, save_totals = TRUE) {
  projection_object$project(progress_bar, save_totals)
  return(invisible(NULL))
}

#' @name save_csv_all
#' @title Saving projection results to CSV files
#' @description
#' Method for exporting all projection results to a set of .csv files. Each type of output data (e.g., population, fertility, mortality, migration, switching) is written to a separate file.
#'
#' The export process can take up to an hour to complete, depending on dataset size—particularly for projections that include religious switching and migration, which generate large output files.
#'
#' If switching or migration is disabled in the projection settings, the corresponding .csv files are skipped automatically.
#'
#' @param projection_object Projection_object; a resolved (already projected) projection object.
#' @param objects Character vector specifying which objects to export: `"countries"`, `"regions"`, or both. Default exports both where applicable — regions omit switching matrices and fertility differentials (character).
#' @param filenames_vector Character vector of length 10 containing output file names, in order: structure data, births, ASFRs, fertility exposure, fertility differentials, deaths, emigration, immigration, switching matrices, switchers (character vector).
#' @param folder Name of folder in which results should be saved. Defaults to projection_object's name (character).
#' @param demographic_files Logical; if TRUE, saves structure data, fertility data, mortality data, ASFRs and women population data used in fertility calculations (default TRUE).
#' @param switching_files Logical; if TRUE, saves switching matrices and switching data. Defaults to the projection's switching setting. Will error if TRUE when no switching was calculated.
#' @param migration_files Logical; if TRUE, saves migration data. Defaults to the projection's migration setting (logical).
#' @param order_by_name Logical; if TRUE, countries are ordered alphabetically by name. If FALSE, countries are ordered by ISO 3166-1 code (default FALSE).
#' @param progress_bar Logical; whether to show a progress bar and ETA (default TRUE).
#' @returns Progress bar and time of execution.
#' @seealso
#' \code{\link{project}} to run the projection before exporting.
#' \code{\link{save_plots_all}} to export visualisations instead of raw data.
#' \code{vignette("exporting-results")} for a column-by-column description of
#' every output file including example rows.
#' @examples
#' # Running a full projection is time-consuming.
#' # Wrapped in dontrun to avoid executing during documentation build.
#' \dontrun{
#' p_object <- create_projection_object(name = "test")
#' p_object$project()
#' p_object$save_csv_all()
#'
#' p_object <- create_projection_object(name = "test")
#' project(projection_object = p_object)
#' save_csv_all(projection_object = p_object)
#' }
#' @export
save_csv_all <- function(projection_object,
                         objects = list("countries", "regions"),
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
                         ),
                         folder,
                         demographic_files = TRUE,
                         switching_files,
                         migration_files,
                         order_by_name = FALSE,
                         progress_bar = TRUE) {
  if (missing(switching_files)) {
    switching_files <- projection_object$switching
  }
  if (missing(migration_files)) {
    migration_files <- projection_object$migration
  }
  if (missing(folder)) {
    folder <- projection_object$projection_name
  }
  projection_object$save_csv_all(
    objects = objects,
    filenames_vector = filenames_vector,
    folder = folder,
    demographic_files = demographic_files,
    switching_files = switching_files,
    migration_files = migration_files,
    order_by_name = order_by_name,
    progress_bar = progress_bar
  )
  return("Done!")
}


#' @name save_plots_all
#' @title Creating and saving projection results plots to PDF files
#' @description
#' Method for generating and saving plots of MRC projection results for all countries.
#' Outputs can be saved either as:
#' (a) a single combined PDF file containing all countries, or
#' (b) separate PDF files for each country.
#'
#' @param projection_object Projection_object; a resolved projection object containing completed results to visualize.
#' @param single_file Logical; if TRUE, saves all country plots into a single .pdf file (default FALSE).
#' @param order_by_name Logical; if TRUE, countries are ordered alphabetically by name; if FALSE, ordered by ISO 3166-1 code (default FALSE).
#' @param show_post_switch Logical; if FALSE, combines post-switch and non-switch populations into a single category in the plots (default TRUE).
#' @param folder Character; name of the folder in which results should be saved. Defaults to projection_object's name.
#' @param demographic_plots Logical; if FALSE, skips creation of fertility and mortality plots (default TRUE).
#' @param switching_plots Logical; if FALSE, skips creation of switching plots. Defaults to the projection's switching status.
#' @param migration_plots Logical; if FALSE, skips creation of migration plots. Defaults to the projection's migration status.
#' @param plot_colors Character vector; colors used for each religion in the plots (default: 7-color palette).
#' @param plot_switching_colors Character vector; colors used for post-switch religious groups in the plots (default: 14-color palette).
#' @param progress_bar Logical; whether to show a progress bar and ETA (default TRUE).
#' @returns Called for its side effects. Saves country plots as PDF file(s) to `folder` and prints a completion message.
#' @seealso
#' \code{\link{save_plots_regions_all}} for region-level plots,
#' \code{\link{save_plots_comparative_all}} to compare two scenarios side by side.
#' \code{vignette("visualising-projections")} for a complete guide to all plot
#' variants and the \code{demographic_plots}, \code{migration_plots}, and
#' \code{switching_plots} flags.
#' @examples
#' # Running a full projection is time-consuming.
#' # Wrapped in dontrun to avoid executing during documentation build.
#' \dontrun{
#' obj <- test_object_generator(object_name = "example")
#' project(projection_object = obj, progress_bar = FALSE, save_totals = FALSE)
#' save_plots_all(projection_object = obj, folder = tempdir(), progress_bar = FALSE)
#' }
#' @export
save_plots_all <- function(projection_object,
                           single_file = FALSE,
                           order_by_name = FALSE,
                           show_post_switch = TRUE,
                           folder,
                           demographic_plots = TRUE,
                           switching_plots,
                           migration_plots,
                           plot_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40"),
                           plot_switching_colors = c(
                             "blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40",
                             "darkblue", "darkgreen", "red4", "yellow4", "orange4", "purple4", "grey30"
                           ),
                           progress_bar = TRUE) {
  if (missing(folder)) {
    folder <- projection_object$projection_name
  }
  if (missing(switching_plots)) {
    switching_plots <- projection_object$switching
  }
  if (missing(migration_plots)) {
    migration_plots <- projection_object$migration
  }
  projection_object$save_plots_all(single_file, order_by_name, show_post_switch, folder, demographic_plots, switching_plots, migration_plots, plot_colors, plot_switching_colors, progress_bar = progress_bar)
  return(invisible(NULL))
}


#' @name save_plots_regions_all
#' @title Creating and saving region projection results plots to PDF files
#' @description
#' Method for generating and saving plots of MRC projection results for all regions.
#' Outputs can be saved either as:
#' (a) a single combined PDF file containing all regions, or
#' (b) separate PDF files for each region.
#'
#' @param projection_object Projection_object; a resolved projection object containing completed results to visualize.
#' @param single_file Logical; if TRUE, saves all region plots into a single .pdf file (default FALSE).
#' @param order_by_name Logical; if TRUE, regions are ordered alphabetically by name; if FALSE, by code (default FALSE).
#' @param show_post_switch Logical; if FALSE, combines post-switch and non-switch populations into a single category in the plots (default TRUE).
#' @param folder Character; name of the folder in which results should be saved. Defaults to projection_object's name.
#' @param demographic_plots Logical; if FALSE, skips creation of fertility and mortality plots (default TRUE).
#' @param switching_plots Logical; if FALSE, skips creation of switching plots. Defaults to the projection's switching status.
#' @param migration_plots Logical; if FALSE, skips creation of migration plots. Defaults to the projection's migration status.
#' @param plot_colors Character vector; colors used for each religion in the plots (default: 7-color palette).
#' @param plot_switching_colors Character vector; colors used for post-switch religious groups in the plots (default: 14-color palette).
#' @param progress_bar Logical; whether to show a progress bar and ETA (default TRUE).
#' @returns Called for its side effects. Saves region plots as PDF file(s) to `folder` and prints a completion message.
#' @seealso
#' \code{\link{save_plots_all}} for country-level plots,
#' \code{\link{save_plots_comparative_all}} to compare scenarios.
#' \code{vignette("visualising-projections")} for a complete guide including
#' which variants each flag controls.
#' @examples
#' # Running a full projection is time-consuming.
#' # Wrapped in dontrun to avoid executing during documentation build.
#' \dontrun{
#' obj <- test_object_generator(object_name = "example")
#' project(projection_object = obj, progress_bar = FALSE, save_totals = TRUE)
#' save_plots_regions_all(projection_object = obj, folder = tempdir(), progress_bar = FALSE)
#' }
#' @export
save_plots_regions_all <- function(projection_object,
                                   single_file = FALSE,
                                   order_by_name = FALSE,
                                   show_post_switch = TRUE,
                                   folder,
                                   demographic_plots = TRUE,
                                   switching_plots,
                                   migration_plots,
                                   plot_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40"),
                                   plot_switching_colors = c(
                                     "blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40",
                                     "darkblue", "darkgreen", "red4", "yellow4", "orange4", "purple4", "grey30"
                                   ),
                                   progress_bar = TRUE) {
  if (missing(folder)) {
    folder <- projection_object$projection_name
  }
  if (missing(switching_plots)) {
    switching_plots <- projection_object$switching
  }
  if (missing(migration_plots)) {
    migration_plots <- projection_object$migration
  }
  projection_object$save_plots_regions_all(single_file, show_post_switch, folder, demographic_plots, switching_plots, migration_plots, plot_colors, plot_switching_colors, progress_bar = progress_bar)
  return(invisible(NULL))
}
