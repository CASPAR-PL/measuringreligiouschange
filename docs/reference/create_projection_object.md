# Creating projection_object

Function for creating a projection object used in the MRC projection
model. Users can specify several parameters controlling the projection
setup, inclusion of migration and switching processes, and assumptions
regarding fertility differentials.

## Usage

``` r
create_projection_object(
  name,
  country_object_list,
  region_object_list,
  steps = 10,
  migration = TRUE,
  switching = TRUE,
  switching_type = 1,
  no_diff = FALSE,
  post_switch = FALSE,
  light_migration = TRUE,
  light_switching = TRUE
)
```

## Arguments

- name:

  Character; name of the projection scenario - required.

- country_object_list:

  List; country objects created by \`create_country_list()\`. If omitted
  or not a list, \`create_country_list(post_switch = post_switch)\` is
  called automatically. The same list cannot be reused across multiple
  projections (no default - auto-created if missing).

- region_object_list:

  List; region objects created by \`create_region_list()\`. If omitted
  or not a list, \`create_region_list()\` is called automatically.
  Modify only if you are fully familiar with the internal structure of
  the package (no default - auto-created if missing).

- steps:

  Numeric; number of 5-year projection periods to simulate (default 10).

- migration:

  Logical; whether migration (emigration and immigration) is included in
  the projection (default TRUE).

- switching:

  Logical; whether religious switching is included in the projection
  (default TRUE).

- switching_type:

  Numeric; sequence of switching relative to demographic processes.
  Available options: 1 - The population is divided into two groups. For
  the first group, switching rates are applied at the beginning of the
  period (before demographic processes); for the second group, switching
  occurs at the end of the period (after demographic processes). 2 -
  Switching is applied entirely at the beginning of the period, before
  demographic processes. (Default = 1).

- no_diff:

  Logical; if TRUE, fertility differentials by religion are ignored and
  all religions use the total ASFR (default FALSE - differentials are
  applied).

- post_switch:

  Logical; controls how religious switching is tracked across periods.
  If FALSE (default), individuals who have switched religion remain in
  the general population and may switch again in subsequent steps. If
  TRUE, those who have switched are moved into separate post-switch
  columns and excluded from further switching. Also forwarded to
  \`create_country_list()\` when called automatically.

- light_migration:

  Logical; if TRUE, migration output is stored in abbreviated form to
  reduce memory usage. Recommended when running multiple projections
  (default TRUE).

- light_switching:

  Logical; if TRUE, switching output is stored in abbreviated form to
  reduce memory usage. Recommended when running multiple projections
  (default TRUE).

## Value

A single projection object

## See also

[`create_country_list`](create_country_list.md) to create the required
country list, [`variants_loader`](variants_loader.md) to validate this
object before projecting, [`project`](project.md) to run the projection,
[`save_csv_all`](save_csv_all.md) and
[`save_plots_all`](save_plots_all.md) to export results.
[`vignette("conducting-projections")`](../articles/conducting-projections.md)
for a full walkthrough.

## Examples

``` r
test_po <- create_projection_object(name = "test", steps = 5)
#> [1] "Global starting parameters:"
#> [1] "Migration: TRUE"
#> [1] "Light migration: TRUE"
#> [1] "Switching: TRUE"
#> [1] "Light switching: TRUE"
#> [1] "Switching type: split"
#> [1] "Steps: 5"
#> [1] "No fertility differentials: FALSE"
#> [1] "Post switch separation: FALSE"
```
