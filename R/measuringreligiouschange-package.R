#' @importFrom grDevices dev.off pdf
#' @importFrom methods new setRefClass
#' @importFrom data.table ':=' '.SD' 'is.data.table' 'setcolorder' 'set' 'setkeyv'
#' @importFrom dplyr arrange desc pull
#' @importFrom ggplot2 aes coord_flip element_text facet_grid facet_wrap
#'   geom_bar geom_hline geom_line geom_point ggplot labs
#'   scale_color_manual scale_fill_manual scale_x_discrete scale_y_continuous theme
#'   .data
#' @importFrom grid grid.text gpar textGrob
#' @importFrom gridExtra tableGrob grid.arrange
#' @importFrom progress progress_bar
NULL

#' @docType package
#' @name measuringreligiouschange-package
#' @aliases measuringreligiouschange-package
#' @title Measuring Religious Change
#' @description
#' Tools for projecting religious-composition change using cohort-component
#' demographic models with religious switching, fertility differentials, and
#' migration.
#'
#' @section Vignettes:
#' The package ships four vignettes:
#' \describe{
#'   \item{\code{vignette("conducting-projections")}}{
#'     How to create a country list, assemble and run a projection, and export
#'     results to CSV using \code{\link{create_country_list}},
#'     \code{\link{create_projection_object}}, \code{\link{variants_loader}},
#'     and \code{\link{project}}.
#'   }
#'   \item{\code{vignette("visualising-projections")}}{
#'     How to save country-level and region-level plots using
#'     \code{\link{save_plots_all}} and \code{\link{save_plots_regions_all}},
#'     and how to compare two scenarios side-by-side with
#'     \code{\link{save_plots_comparative_all}}.
#'   }
#'   \item{\code{vignette("exporting-results")}}{
#'     Column-by-column description of every CSV output file produced by
#'     \code{\link{save_csv_all}}, including example rows for the United
#'     States (ISO 840).
#'   }
#'   \item{\code{vignette("inner-workings")}}{
#'     Internal architecture: \code{Country_object} and
#'     \code{Projection_object} field reference, the \code{Loader.R} pipeline,
#'     and flow diagrams for the main projection procedure, migration loop,
#'     switching decomposition, and fertility factorisation.
#'   }
#' }
## usethis namespace: start
## usethis namespace: end
utils::globalVariables("base_data_list")

#' @examples
#' # Quick one-step test projection (3 countries)
#' # Running a full projection is time-consuming.
#' # Wrapped in dontrun to avoid executing during documentation build.
#' \dontrun{
#' obj <- test_object_generator(object_name = "demo")
#' project(projection_object = obj, progress_bar = FALSE, save_totals = FALSE)
#' }
#' @keywords internal
"_PACKAGE"
