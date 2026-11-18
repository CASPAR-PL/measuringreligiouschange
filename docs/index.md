# measuringreligiouschange

measuringreligiouschange is a package developed by the Center for
Advanced Studies of Population and Religion (CASPAR) for a joint project
with the Pew Research Center as part of the Pew-Templeton Global
Religious Futures project.

The software package can generate religious group population projections
at the global, regional and national level resulting from initial
age-sex composition of populations, demographic processes (fertility,
mortality and migration) and religious processes (transmission of
religion between generations and religious switching). The package is a
flexible tool that can be used to numerically reproduce the projections
presented in the Pew Research Center report “The Future of World
Religions: Population Growth Projections, 2020-2070”, generate other
projection variants based on the included input data, or create
projections from user-supplied input data and adjustments to demographic
and religious processes.

This package may be most useful for users with training in demographic
analysis and some experience using and programming in R.

For inquiries, please contact: <caspar@uek.krakow.pl>.

## Vignettes

| Vignette | Description |
|----|----|
| [`vignette("conducting-projections")`](https://caspar-pl.github.io/measuringreligiouschange/articles/conducting-projections.md) | Create a country list, assemble and run a projection, export results to CSV |
| [`vignette("visualising-projections")`](https://caspar-pl.github.io/measuringreligiouschange/articles/visualising-projections.md) | Save country- and region-level plots; compare two scenarios side-by-side |
| [`vignette("exporting-results")`](https://caspar-pl.github.io/measuringreligiouschange/articles/exporting-results.md) | Column-by-column description of every CSV output file |
| [`vignette("inner-workings")`](https://caspar-pl.github.io/measuringreligiouschange/articles/inner-workings.md) | Internal architecture, class field reference, and projection flow diagrams |

## Installation

You can install the latest version of measuringreligiouschange from
GitHub:

``` r

# install.packages("pak")
pak::pak("CASPAR-PL/measuringreligiouschange")
```

### Installation troubleshooting

If
[`devtools::install_github()`](https://devtools.r-lib.org/reference/install-deprecated.html)
or
[`remotes::install_github()`](https://remotes.r-lib.org/reference/install_github.html)
fails with `HTTP error 401. Bad credentials`, R is sending an expired or
invalid GitHub token. The repository is public, so no token is needed.
Either install with pak as shown above (recent versions fall back to
anonymous access), or remove the token for the current session:

``` r

Sys.unsetenv(c("GITHUB_PAT", "GITHUB_TOKEN"))
```

To make this permanent, delete the `GITHUB_PAT` (or `GITHUB_TOKEN`) line
from your `.Renviron` file (open it with
[`usethis::edit_r_environ()`](https://usethis.r-lib.org/reference/edit.html))
and restart R.

## User manual

📖 [Measuring Religious Change – User Manual (v1.0.2,
PDF)](https://caspar-pl.github.io/measuringreligiouschange/MRC_manual_V1.0.2.pdf)

The manual explains how to install and use the package step by step. It
describes the MRC model and its input data (population structures,
religious affiliation, fertility, mortality, migration and religious
switching), and shows how to run projections, set up scenarios, modify
input data, and save output files and plots.

## Example

A full projection for all countries using the included input data. Each
projection object needs its own country list, and `post_switch` must
match in both calls:

``` r

library(measuringreligiouschange)

cl <- create_country_list(post_switch = FALSE)

obj <- variants_loader(create_projection_object(
  name                = "my_projection",
  country_object_list = cl,
  steps               = 10L, # 5-year steps: 2020-2070
  migration           = TRUE,
  switching           = TRUE,
  light_migration     = TRUE,
  light_switching     = TRUE,
  post_switch         = FALSE
))

# save_totals = TRUE also computes regional and global aggregates
project(obj, progress_bar = TRUE, save_totals = TRUE)
```

[`base_object_generator()`](https://caspar-pl.github.io/measuringreligiouschange/reference/base_object_generator.md)
does the same thing in one call. It creates a fresh country list and
returns a validated, unresolved projection object with the main scenario
settings (migration and switching on, religion-specific fertility
differentials):

``` r

obj <- base_object_generator(
  object_name     = "SC1",
  steps           = 10L,
  light_migration = TRUE,
  light_switching = TRUE,
  post_switch     = FALSE
)
project(obj, progress_bar = TRUE, save_totals = TRUE)
```

Results can be exported to .csv files and plotted for each country. By
default, output is written to a folder named after the projection:

``` r

save_csv_all(obj)
save_plots_all(obj)
save_plots_regions_all(obj)
```

A full projection takes a while to run. For a quick check,
[`test_object_generator()`](https://caspar-pl.github.io/measuringreligiouschange/reference/test_object_generator.md)
creates a one-step projection for three countries (Poland, the United
Kingdom and the United States):

``` r

obj_test <- test_object_generator("my_test")
project(obj_test, progress_bar = FALSE, save_totals = FALSE)
save_csv_all(obj_test, objects = list("countries"))
```

See
[`vignette("conducting-projections")`](https://caspar-pl.github.io/measuringreligiouschange/articles/conducting-projections.md)
for a description of all settings.
