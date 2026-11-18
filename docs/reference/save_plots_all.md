# Creating and saving projection results plots to PDF files

Method for generating and saving plots of MRC projection results for all
countries. Outputs can be saved either as: (a) a single combined PDF
file containing all countries, or (b) separate PDF files for each
country.

## Usage

``` r
save_plots_all(
  projection_object,
  single_file = FALSE,
  order_by_name = FALSE,
  show_post_switch = TRUE,
  folder,
  demographic_plots = TRUE,
  switching_plots,
  migration_plots,
  plot_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3", "grey40"),
  plot_switching_colors = c("blue3", "green4", "red3", "yellow3", "orange3", "purple3",
    "grey40", "darkblue", "darkgreen", "red4", "yellow4", "orange4", "purple4", "grey30"),
  progress_bar = TRUE
)
```

## Arguments

- projection_object:

  Projection_object; a resolved projection object containing completed
  results to visualize.

- single_file:

  Logical; if TRUE, saves all country plots into a single .pdf file
  (default FALSE).

- order_by_name:

  Logical; if TRUE, countries are ordered alphabetically by name; if
  FALSE, ordered by ISO 3166-1 code (default FALSE).

- show_post_switch:

  Logical; if FALSE, combines post-switch and non-switch populations
  into a single category in the plots (default TRUE).

- folder:

  Character; name of the folder in which results should be saved.
  Defaults to projection_object's name.

- demographic_plots:

  Logical; if FALSE, skips creation of fertility and mortality plots
  (default TRUE).

- switching_plots:

  Logical; if FALSE, skips creation of switching plots. Defaults to the
  projection's switching status.

- migration_plots:

  Logical; if FALSE, skips creation of migration plots. Defaults to the
  projection's migration status.

- plot_colors:

  Character vector; colors used for each religion in the plots (default:
  7-color palette).

- plot_switching_colors:

  Character vector; colors used for post-switch religious groups in the
  plots (default: 14-color palette).

- progress_bar:

  Logical; whether to show a progress bar and ETA (default TRUE).

## Value

Called for its side effects. Saves country plots as PDF file(s) to
\`folder\` and prints a completion message.

## See also

[`save_plots_regions_all`](save_plots_regions_all.md) for region-level
plots, [`save_plots_comparative_all`](save_plots_comparative_all.md) to
compare two scenarios side by side.
[`vignette("visualising-projections")`](../articles/visualising-projections.md)
for a complete guide to all plot variants and the `demographic_plots`,
`migration_plots`, and `switching_plots` flags.

## Examples

``` r
# Running a full projection is time-consuming.
# Wrapped in dontrun to avoid executing during documentation build.
if (FALSE) { # \dontrun{
obj <- test_object_generator(object_name = "example")
project(projection_object = obj, progress_bar = FALSE, save_totals = FALSE)
save_plots_all(projection_object = obj, folder = tempdir(), progress_bar = FALSE)
} # }
```
