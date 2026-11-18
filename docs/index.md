# measuringreligiouschange

measuringreligiouschange is a package developed by Center for Advanced
Studies of Population And Religion for Pew Research Center designed to
create religious structure projections. It calculates 4 demographic
processes: - fertility - mortality - switching - migration

For fertility differences it uses calculated differentials which can be
subject to convergence.

## Vignettes

| Vignette | Description |
|----|----|
| [`vignette("conducting-projections")`](articles/conducting-projections.md) | Create a country list, assemble and run a projection, export results to CSV |
| [`vignette("visualising-projections")`](articles/visualising-projections.md) | Save country- and region-level plots; compare two scenarios side-by-side |
| [`vignette("exporting-results")`](articles/exporting-results.md) | Column-by-column description of every CSV output file |
| [`vignette("inner-workings")`](articles/inner-workings.md) | Internal architecture, class field reference, and projection flow diagrams |

## Installation

You can install the latest version of measuringreligiouschange from
GitHub:

``` r

# install.packages("pak")
pak::pak("CASPAR-PL/measuringreligiouschange")
```

## Example

This is a basic example which shows you how to create and run a
projection:

``` r

library(measuringreligiouschange)
cl  <- create_country_list(post_switch = FALSE)
obj <- variants_loader(create_projection_object(
  name        = "MRC Projection",
  cl,
  steps       = 5L,
  migration   = FALSE,
  post_switch = FALSE
))
project(obj, progress_bar = FALSE)
```

Additionally it exports all data into .csv files and creates plots for
each country:

``` r

save_csv_all(obj)
save_plots_all(obj)
```
