# Loading data and creating list of Country_objects

Function for creating a country objects list

## Usage

``` r
create_country_list(
  start_year = 2020,
  start_fertility_group = 3,
  switching_pattern = list(c(1/3, 1/3, 1/3), c(1/3, 1/3, 1/3)),
  data_list = base_data_list,
  progress_bar = TRUE,
  post_switch = FALSE,
  on_country_mismatch = c("error", "rescale", "ignore")
)
```

## Arguments

- start_year:

  Numeric; starting year of the projection (default 2020).

- start_fertility_group:

  Numeric; index of the youngest age group for which fertility is
  applied. Default 3, corresponding to the 10-14 age group.

- switching_pattern:

  List of two numeric vectors; specifies for each switching cohort the
  distribution of religious switching across sub-periods. The first
  switchable age group is 15-19. Default \`list(c(1/3, 1/3, 1/3), c(1/3,
  1/3, 1/3))\`, distributing switching uniformly across 15-19, 20-24 and
  25-29.

- data_list:

  List; named list of data frames containing pre-loaded projection input
  data (default \[base_data_list\]).

- progress_bar:

  Logical; whether to show a progress bar and ETA during loading
  (default TRUE).

- post_switch:

  Logical; controls how religious switching is tracked across periods.
  If FALSE (default), individuals who have switched religion remain in
  the general population and may switch again in subsequent steps. If
  TRUE, those who have switched are moved into separate post-switch
  columns and excluded from further switching. Forwarded to internal
  country object creation.

- on_country_mismatch:

  Character; how to handle a mismatch between the number of countries in
  the migration destination matrix and \`info_variants\`. One of
  \`"error"\`, \`"rescale"\` (renormalise destination rows to sum to 1),
  or \`"ignore"\`. In interactive sessions without an explicit value the
  user is prompted.

## Value

List of country objects, each containing demographic and model-specific
data used in the MRC projection framework. Each element of the list
represents a single country.

## See also

[`create_projection_object`](https://caspar-pl.github.io/measuringreligiouschange/reference/create_projection_object.md)
to assemble a projection from this list,
[`variants_loader`](https://caspar-pl.github.io/measuringreligiouschange/reference/variants_loader.md)
to validate the assembled object,
[`project`](https://caspar-pl.github.io/measuringreligiouschange/reference/project.md)
to run the projection.
[`vignette("conducting-projections")`](https://caspar-pl.github.io/measuringreligiouschange/articles/conducting-projections.md)
for a complete worked example.
[`vignette("inner-workings")`](https://caspar-pl.github.io/measuringreligiouschange/articles/inner-workings.md)
for the internal data-loading pipeline.

## Examples

``` r
test_cl <- create_country_list(
  start_year = 2025,
  start_fertility_group = 4,
  switching_pattern = list(
    c(1 / 3, 1 / 3, 1 / 3),
    c(1 / 3, 1 / 3, 1 / 3)
  ),
  data_list = base_data_list,
  progress_bar = FALSE,
  post_switch = FALSE,
  on_country_mismatch = "error"
)
```
