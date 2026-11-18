#' @include class_plots.R

sex_vector <- c(rep(1L, 20), rep(2L, 20))
sex_vector_mortality <- c(rep(1L, 21), rep(2L, 21))
age_vector <- rep(c("0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85-89", "90-94", "95+"), 2)
age_vector_mortality <- rep(c("0", "1-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85-89", "90-94", "95+"), 2)
age_vector_fertility <- c("10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54")
age_vector_asfr <- c("10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "TFR")
age_vector_women_population <- c("10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54")


#' @title A reference class containing data and parameters needed for projection.
#' @description
#' Object containing technical information as well as demographic and model-specific information for all countries included in projection.
#'
#' A single object contains all the necessary information and functions needed for calculating the projection allowing user to easily perform calculations and visualize the results
#'
#' @details
#' Projection_object stores initial and projected data, specific options and results of the MRC projection for each country
#' @examples
#' # Running a full projection is time-consuming.
#' # Wrapped in dontrun to avoid executing during documentation build.
#' \dontrun{
#' obj <- test_object_generator(object_name = "example")
#' obj$projection_name # "example"
#' obj$steps # 1
#' obj$resolved # FALSE (before project())
#' project(projection_object = obj, progress_bar = FALSE, save_totals = FALSE)
#' obj$resolved # TRUE
#' length(obj$country_object_list) # 3
#' }
#'
#' @export
Projection_object <- methods::setRefClass(
  "Projection_object",

  #' @field projection_name Character; name of the projection scenario, used as the default output folder name
  #' @field region_object_list List; Region_objects, one per region defined in `data_regions`
  #' @field country_object_list List; Country_objects, one per country, created by `create_country_list()`
  #' @field steps Numeric; number of 5-year projection periods to simulate
  #' @field migration Logical; whether migration (emigration and immigration) is included in the projection
  #' @field switching Logical; whether religious switching is included in the projection
  #' @field switching_type Numeric; sequence of switching relative to demographic processes. 1 = split (pre/post demographic); 2 = all switching before demographic processes
  #' @field no_diff Logical; if TRUE, fertility differentials by religion are ignored and all religions use the total ASFR
  #' @field post_switch Logical; if FALSE (default), individuals who have switched religion remain in the general population and may switch again in subsequent steps; if TRUE, those who have switched are moved into separate post-switch columns and excluded from further switching
  #' @field resolved Logical; TRUE once `project()` has been called successfully; prevents re-projection of the same object
  #' @field region_totals Logical; whether region-level aggregated totals are computed and stored after projection
  #' @field global_totals Logical; whether global totals are computed and stored after projection
  #' @field light_migration Logical; if TRUE, migration output is stored in abbreviated form to reduce memory usage
  #' @field light_switching Logical; if TRUE, switching output is stored in abbreviated form to reduce memory usage
  fields = list(
    projection_name = "character",
    region_object_list = "list",
    country_object_list = "list",
    steps = "numeric",
    migration = "logical",
    switching = "logical",
    switching_type = "numeric",
    no_diff = "logical",
    post_switch = "logical",
    resolved = "logical",
    region_totals = "logical",
    global_totals = "logical",
    light_migration = "logical",
    light_switching = "logical",
    variant = "logical"
  )
)
