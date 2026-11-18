# Generate main Pew scenarios

Function for creating unresolved projection-objects

## Usage

``` r
base_object_generator(
  object_name,
  steps = 10,
  light_migration = TRUE,
  light_switching = TRUE,
  post_switch = FALSE
)
```

## Arguments

- object_name:

  Character; name of the projection scenario — required

- steps:

  Numeric; number of 5-year projection periods to simulate (default 10)

- light_migration:

  Logical; if TRUE, migration output is stored in abbreviated form to
  reduce memory usage. Recommended when running multiple projections
  (default TRUE)

- light_switching:

  Logical; if TRUE, switching output is stored in abbreviated form to
  reduce memory usage. Recommended when running multiple projections
  (default TRUE)

- post_switch:

  Logical; controls how religious switching is tracked across periods.
  If FALSE (default), individuals who have switched religion remain in
  the general population and may switch again in subsequent steps. If
  TRUE, those who have switched are moved into separate post-switch
  columns and excluded from further switching. Forwarded to both
  \`create_country_list()\` and \`create_projection_object()\`.

## Value

A single projection object

## See also

[`test_object_generator`](test_object_generator.md) for a lightweight
3-country 1-step variant, [`project`](project.md) to run the returned
object, [`save_csv_all`](save_csv_all.md) and
[`save_plots_all`](save_plots_all.md) to export results.
[`vignette("conducting-projections")`](../articles/conducting-projections.md)
for the full projection workflow.

## Examples

``` r
Main_1 <- base_object_generator(object_name = "SC1",
  steps = 10,
  light_migration = TRUE,
  light_switching = TRUE
)
#> [1] "Global starting parameters:"
#> [1] "Migration: TRUE"
#> [1] "Light migration: TRUE"
#> [1] "Switching: TRUE"
#> [1] "Light switching: TRUE"
#> [1] "Switching type: split"
#> [1] "Steps: 10"
#> [1] "No fertility differentials: FALSE"
#> [1] "Post switch separation: FALSE"
#> [1] "Variant successfully loaded."
```
