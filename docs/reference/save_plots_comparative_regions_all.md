# Saving region comparative plots to .pdf file(s)

Function for generating and saving side-by-side comparative plots of MRC
projection results for all regions across two or more scenarios. Outputs
can be saved either as a single combined PDF file or as separate PDF
files per region.

## Usage

``` r
save_plots_comparative_regions_all(
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

  List of resolved projection objects (list)

- single_file:

  Logical; if TRUE, saves all region plots into a single .pdf file
  (default TRUE)

- folder:

  Name of folder in which plots should be saved (character)

- demographic_plots:

  Logical; if FALSE, skips creation of fertility and mortality plots
  (default TRUE)

- switching_plots:

  Logical; if FALSE, skips creation of switching plots. Defaults to
  projection_object's switching status (logical)

- migration_plots:

  Logical; if FALSE, skips creation of migration plots. Defaults to
  projection_object's migration status (logical)

- show_post_switch:

  Logical; if TRUE, post-switch populations are visualized separately.
  Forced to FALSE if any projection has post_switch disabled. The
  per-religion population plots always show the full religion (base plus
  post-switch) (default TRUE)

- plot_colors:

  Character vector defining the colors used for each religion in the
  plots (recommended to leave unchanged unless the number of religions
  has changed)

- progress_bar:

  Logical; whether to show a progress bar during saving (default TRUE)

## Value

Called for its side effects. Saves comparative region plots as PDF
file(s) to \`folder\` and prints a completion message.

## See also

[`save_plots_regions_all`](https://caspar-pl.github.io/measuringreligiouschange/reference/save_plots_regions_all.md)
for single-scenario region plots.
[`save_plots_comparative_all`](https://caspar-pl.github.io/measuringreligiouschange/reference/save_plots_comparative_all.md)
for the country-level equivalent.
[`vignette("visualising-projections")`](https://caspar-pl.github.io/measuringreligiouschange/articles/visualising-projections.md)
for a guide to all comparative plot types and how the content flags map
to type numbers.

## Examples

``` r
# Running a full projection is time-consuming.
# Wrapped in dontrun to avoid executing during documentation build.
if (FALSE) { # \dontrun{
obj1 <- test_object_generator(object_name = "sc1")
obj2 <- test_object_generator(object_name = "sc2", no_diff = TRUE)
project(projection_object = obj1, progress_bar = FALSE, save_totals = TRUE)
project(projection_object = obj2, progress_bar = FALSE, save_totals = TRUE)
save_plots_comparative_regions_all(
  projection_objects = list(obj1, obj2),
  folder = tempdir(),
  progress_bar = FALSE
)
} # }
```
