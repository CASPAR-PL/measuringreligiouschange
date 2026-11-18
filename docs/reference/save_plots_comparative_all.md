# Saving country comparative plots to .pdf file(s)

Function for generating and saving side-by-side comparative plots of MRC
projection results for all countries across two or more scenarios.
Outputs can be saved either as a single combined PDF file or as separate
PDF files per country.

## Usage

``` r
save_plots_comparative_all(
  projection_objects,
  single_file = TRUE,
  folder = "comparative",
  demographic_plots = TRUE,
  switching_plots,
  migration_plots,
  show_post_switch = TRUE,
  plot_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40",
    "darkblue", "darkgreen", "red4", "yellow4", "orange4", "purple4", "grey30"),
  progress_bar = TRUE
)
```

## Arguments

- projection_objects:

  List; resolved projection objects to compare against each other

- single_file:

  Logical; if TRUE, saves all country plots into a single .pdf file
  (default TRUE)

- folder:

  Character; name of folder in which plots should be saved (default
  "comparative")

- demographic_plots:

  Logical; if FALSE, skips creation of fertility and mortality plots
  (default TRUE)

- switching_plots:

  Logical; if FALSE, skips creation of switching plots. Defaults to the
  first projection object's switching status

- migration_plots:

  Logical; if FALSE, skips creation of migration plots. Defaults to the
  first projection object's migration status

- show_post_switch:

  Logical; if TRUE, post-switch populations are visualized separately.
  Forced to FALSE if any projection has post_switch disabled. The
  per-religion population plots always show the full religion (base plus
  post-switch) (default TRUE)

- plot_colors:

  Character vector; colors used for each religion in the plots
  (recommended to leave unchanged unless the number of religions has
  changed)

- progress_bar:

  Logical; whether to show a progress bar during saving (default TRUE)

## Value

Called for its side effects. Saves comparative country plots as PDF
file(s) to \`folder\` and prints a completion message.

## See also

[`save_plots_all`](https://caspar-pl.github.io/measuringreligiouschange/reference/save_plots_all.md)
for single-scenario country plots.
[`save_plots_comparative_regions_all`](https://caspar-pl.github.io/measuringreligiouschange/reference/save_plots_comparative_regions_all.md)
for the region-level equivalent.
[`vignette("visualising-projections")`](https://caspar-pl.github.io/measuringreligiouschange/articles/visualising-projections.md)
for a guide to all comparative plot types and how the content flags map
to type numbers.

## Examples

``` r
# Running a full projection is time-consuming.
# Wrapped in dontrun to avoid executing during documentation build.
if (FALSE) { # \dontrun{
projection_dsm <- create_projection_object(name = "dsm", switching = TRUE)
projection_dm <- create_projection_object(name = "dm", switching = FALSE)
project(projection_object = projection_dsm)
project(projection_object = projection_dm)
save_plots_comparative_all(
  projection_objects = list(projection_dsm, projection_dm),
  folder = tempdir(),
  progress_bar = FALSE
)
} # }
```
