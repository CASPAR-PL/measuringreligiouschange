#' @include projection_class_project.R


#' @name test_object_generator
#' @title Generate a 3-country test projection
#' @description
#' Function for creating unresolved projection-objects limited to Poland (616), United Kingdom (826) and United States (840) with a single projection step
#'
#' @param object_name Character; name of the projection scenario — required
#' @param post_switch Logical; controls how religious switching is tracked across periods. If FALSE (default), individuals who have switched religion remain in the general population and may switch again in subsequent steps. If TRUE, those who have switched are moved into separate post-switch columns and excluded from further switching. Forwarded to both `create_country_list()` and `create_projection_object()`.
#' @param migration Logical; if TRUE, migration (emigration and immigration) is included in the projection (default TRUE)
#' @param switching Logical; if TRUE, religious switching is included in the projection (default TRUE)
#' @param switching_type Numeric; switching sequence type passed to `create_projection_object()` (default 1)
#' @param light_migration Logical; if TRUE, migration output is stored in abbreviated form to reduce memory usage (default TRUE)
#' @param light_switching Logical; if TRUE, switching output is stored in abbreviated form to reduce memory usage (default TRUE)
#' @param no_diff Logical; if TRUE, fertility differentials are ignored and all religions use the total ASFR (default FALSE)
#' @param progress_bar Logical; if TRUE, shows a progress bar during country loading (default FALSE)
#' @returns A single projection object
#' @seealso
#' \code{\link{base_object_generator}} for a full 201-country projection,
#' \code{\link{project}} to run the returned object,
#' \code{\link{save_csv_all}} and \code{\link{save_plots_all}} to export results.
#' \code{vignette("conducting-projections")} for the full projection workflow.
#' @examples
#' # Running a full projection is time-consuming.
#' # Wrapped in dontrun to avoid executing during documentation build.
#' \dontrun{
#' obj <- test_object_generator(object_name = "my_test")
#' project(projection_object = obj, progress_bar = FALSE, save_totals = FALSE)
#' }
#' @export
test_object_generator <- function(object_name,
                                  post_switch = FALSE,
                                  migration = TRUE,
                                  switching = TRUE,
                                  switching_type = 1L,
                                  light_migration = TRUE,
                                  light_switching = TRUE,
                                  no_diff = FALSE,
                                  progress_bar = FALSE) {
  td <- base_data_list
  td[[10L]] <- base_data_list[[10L]][
    base_data_list[[10L]][[2L]] %in% c(616L, 826L, 840L),
  ]

  cl <- create_country_list(
    data_list           = td,
    post_switch         = post_switch,
    progress_bar        = progress_bar,
    on_country_mismatch = "ignore"
  )

  p_object <- variants_loader(create_projection_object(
    object_name,
    cl,
    steps           = 1L,
    migration       = migration,
    switching       = switching,
    switching_type  = switching_type,
    light_migration = light_migration,
    light_switching = light_switching,
    no_diff         = no_diff,
    post_switch     = post_switch
  ))
  return(p_object)
}


#' @name base_object_generator
#' @title Generate main Pew scenarios
#' @description
#' Function for creating unresolved projection-objects
#'
#' @param object_name Character; name of the projection scenario — required
#' @param steps Numeric; number of 5-year projection periods to simulate (default 10)
#' @param light_migration Logical; if TRUE, migration output is stored in abbreviated form to reduce memory usage. Recommended when running multiple projections (default TRUE)
#' @param light_switching Logical; if TRUE, switching output is stored in abbreviated form to reduce memory usage. Recommended when running multiple projections (default TRUE)
#' @param post_switch Logical; controls how religious switching is tracked across periods. If FALSE (default), individuals who have switched religion remain in the general population and may switch again in subsequent steps. If TRUE, those who have switched are moved into separate post-switch columns and excluded from further switching. Forwarded to both `create_country_list()` and `create_projection_object()`.
#' @returns A single projection object
#' @seealso
#' \code{\link{test_object_generator}} for a lightweight 3-country 1-step variant,
#' \code{\link{project}} to run the returned object,
#' \code{\link{save_csv_all}} and \code{\link{save_plots_all}} to export results.
#' \code{vignette("conducting-projections")} for the full projection workflow.
#' @examples
#' Main_1 <- base_object_generator(object_name = "SC1",
#'   steps = 10,
#'   light_migration = TRUE,
#'   light_switching = TRUE
#' )
#' @export
base_object_generator <- function(object_name, steps = 10, light_migration = TRUE, light_switching = TRUE, post_switch = FALSE) {
  # Creating main scenario - basic projection_object with applied convergence

  p_object <- variants_loader(create_projection_object(object_name, create_country_list(post_switch = post_switch), migration = TRUE, switching = TRUE, switching_type = 1, steps = steps, light_migration = light_migration, light_switching = light_switching, post_switch = post_switch))
  return(p_object)
}
