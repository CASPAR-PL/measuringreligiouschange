# Saving projection results to CSV files

Method for exporting all projection results to a set of .csv files. Each
type of output data (e.g., population, fertility, mortality, migration,
switching) is written to a separate file.

The export process can take up to an hour to complete, depending on
dataset size—particularly for projections that include religious
switching and migration, which generate large output files.

If switching or migration is disabled in the projection settings, the
corresponding .csv files are skipped automatically.

## Usage

``` r
save_csv_all(
  projection_object,
  objects = list("countries", "regions"),
  filenames_vector = c("projection_structure_data.csv", "projection_births_data.csv",
    "projection_asfr_data.csv", "projection_fertility_exposure_data.csv",
    "projection_fertility_differentials.csv", "projection_deaths_data.csv",
    "projection_emigration_data.csv", "projection_immigration_data.csv",
    "projection_switching_matrices.csv", "projection_switchers_data.csv"),
  folder,
  demographic_files = TRUE,
  switching_files,
  migration_files,
  order_by_name = FALSE,
  progress_bar = TRUE
)
```

## Arguments

- projection_object:

  Projection_object; a resolved (already projected) projection object.

- objects:

  Character vector specifying which objects to export: \`"countries"\`,
  \`"regions"\`, or both. Default exports both where applicable —
  regions omit switching matrices and fertility differentials
  (character).

- filenames_vector:

  Character vector of length 10 containing output file names, in order:
  structure data, births, ASFRs, fertility exposure, fertility
  differentials, deaths, emigration, immigration, switching matrices,
  switchers (character vector).

- folder:

  Name of folder in which results should be saved. Defaults to
  projection_object's name (character).

- demographic_files:

  Logical; if TRUE, saves structure data, fertility data, mortality
  data, ASFRs and women population data used in fertility calculations
  (default TRUE).

- switching_files:

  Logical; if TRUE, saves switching matrices and switching data.
  Defaults to the projection's switching setting. Will error if TRUE
  when no switching was calculated.

- migration_files:

  Logical; if TRUE, saves migration data. Defaults to the projection's
  migration setting (logical).

- order_by_name:

  Logical; if TRUE, countries are ordered alphabetically by name. If
  FALSE, countries are ordered by ISO 3166-1 code (default FALSE).

- progress_bar:

  Logical; whether to show a progress bar and ETA (default TRUE).

## Value

Progress bar and time of execution.

## See also

[`project`](https://caspar-pl.github.io/measuringreligiouschange/reference/project.md)
to run the projection before exporting.
[`save_plots_all`](https://caspar-pl.github.io/measuringreligiouschange/reference/save_plots_all.md)
to export visualisations instead of raw data.
[`vignette("exporting-results")`](https://caspar-pl.github.io/measuringreligiouschange/articles/exporting-results.md)
for a column-by-column description of every output file including
example rows.

## Examples

``` r
# Running a full projection is time-consuming.
# Wrapped in dontrun to avoid executing during documentation build.
if (FALSE) { # \dontrun{
p_object <- create_projection_object(name = "test")
p_object$project()
p_object$save_csv_all()

p_object <- create_projection_object(name = "test")
project(projection_object = p_object)
save_csv_all(projection_object = p_object)
} # }
```
