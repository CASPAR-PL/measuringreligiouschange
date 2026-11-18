# Generate a 3-country test projection

Function for creating unresolved projection-objects limited to Poland
(616), United Kingdom (826) and United States (840) with a single
projection step

## Usage

``` r
test_object_generator(
  object_name,
  post_switch = FALSE,
  migration = TRUE,
  switching = TRUE,
  switching_type = 1L,
  light_migration = TRUE,
  light_switching = TRUE,
  no_diff = FALSE,
  progress_bar = FALSE
)
```

## Arguments

- object_name:

  Character; name of the projection scenario — required

- post_switch:

  Logical; controls how religious switching is tracked across periods.
  If FALSE (default), individuals who have switched religion remain in
  the general population and may switch again in subsequent steps. If
  TRUE, those who have switched are moved into separate post-switch
  columns and excluded from further switching. Forwarded to both
  \`create_country_list()\` and \`create_projection_object()\`.

- migration:

  Logical; if TRUE, migration (emigration and immigration) is included
  in the projection (default TRUE)

- switching:

  Logical; if TRUE, religious switching is included in the projection
  (default TRUE)

- switching_type:

  Numeric; switching sequence type passed to
  \`create_projection_object()\` (default 1)

- light_migration:

  Logical; if TRUE, migration output is stored in abbreviated form to
  reduce memory usage (default TRUE)

- light_switching:

  Logical; if TRUE, switching output is stored in abbreviated form to
  reduce memory usage (default TRUE)

- no_diff:

  Logical; if TRUE, fertility differentials are ignored and all
  religions use the total ASFR (default FALSE)

- progress_bar:

  Logical; if TRUE, shows a progress bar during country loading (default
  FALSE)

## Value

A single projection object

## See also

[`base_object_generator`](https://caspar-pl.github.io/measuringreligiouschange/reference/base_object_generator.md)
for a full 201-country projection,
[`project`](https://caspar-pl.github.io/measuringreligiouschange/reference/project.md)
to run the returned object,
[`save_csv_all`](https://caspar-pl.github.io/measuringreligiouschange/reference/save_csv_all.md)
and
[`save_plots_all`](https://caspar-pl.github.io/measuringreligiouschange/reference/save_plots_all.md)
to export results.
[`vignette("conducting-projections")`](https://caspar-pl.github.io/measuringreligiouschange/articles/conducting-projections.md)
for the full projection workflow.

## Examples

``` r
# Running a full projection is time-consuming.
# Wrapped in dontrun to avoid executing during documentation build.
if (FALSE) { # \dontrun{
obj <- test_object_generator(object_name = "my_test")
project(projection_object = obj, progress_bar = FALSE, save_totals = FALSE)
} # }
```
