# Measuring Religious Change

Tools for projecting religious-composition change using cohort-component
demographic models with religious switching, fertility differentials,
and migration.

Measuringreligiouschange is a package developed by the Center for
Advanced Studies of Population and Religion (CASPAR) for a joint project
with the Pew Research Center as part of the Pew-Templeton Global
Religious Futures project. The software package can generate religious
group population projections at the global, regional and national level
resulting from initial age-sex composition of populations, demographic
processes (fertility, mortality and migration) and religious processes
(transmission of religion between generations and religious switching).
The package is a flexible tool that can be used to numerically reproduce
the projections presented in the Pew Research Center report “The Future
of World Religions: Population Growth Projections, 2020-2070”, generate
other projection variants based on the included input data, or create
projections from user-supplied input data and adjustments to demographic
and religious processes. This package may be most useful for users with
training in demographic analysis and some experience using and
programming in R. For inquiries, please contact: caspar@uek.krakow.pl.

## Vignettes

The package ships four vignettes:

- [`vignette("conducting-projections")`](../articles/conducting-projections.md):

  How to create a country list, assemble and run a projection, and
  export results to CSV using
  [`create_country_list`](create_country_list.md),
  [`create_projection_object`](create_projection_object.md),
  [`variants_loader`](variants_loader.md), and [`project`](project.md).

- [`vignette("visualising-projections")`](../articles/visualising-projections.md):

  How to save country-level and region-level plots using
  [`save_plots_all`](save_plots_all.md) and
  [`save_plots_regions_all`](save_plots_regions_all.md), and how to
  compare two scenarios side-by-side with
  [`save_plots_comparative_all`](save_plots_comparative_all.md).

- [`vignette("exporting-results")`](../articles/exporting-results.md):

  Column-by-column description of every CSV output file produced by
  [`save_csv_all`](save_csv_all.md), including example rows for the
  United States (ISO 840).

- [`vignette("inner-workings")`](../articles/inner-workings.md):

  Internal architecture: `Country_object` and `Projection_object` field
  reference, the `Loader.R` pipeline, and flow diagrams for the main
  projection procedure, migration loop, switching decomposition, and
  fertility factorisation.

## See also

Useful links:

- <https://github.com/CASPAR-PL/measuringreligiouschange>

- Report bugs at
  <https://github.com/CASPAR-PL/measuringreligiouschange/issues>

## Author

**Maintainer**: Michał Bożek <mbozek@uek.krakow.pl>

Authors:

- Michał Bożek <mbozek@uek.krakow.pl>

- Krzysztof Kiecoń <kieconk@uek.krakow.pl>

- Marcin Stonawski <stonawsm@uek.krakow.pl>

## Examples

``` r
# Quick one-step test projection (3 countries)
# Running a full projection is time-consuming.
# Wrapped in dontrun to avoid executing during documentation build.
if (FALSE) { # \dontrun{
obj <- test_object_generator(object_name = "demo")
project(projection_object = obj, progress_bar = FALSE, save_totals = FALSE)
} # }
```
