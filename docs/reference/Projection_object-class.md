# A reference class containing data and parameters needed for projection.

Object containing technical information as well as demographic and
model-specific information for all countries included in projection.

A single object contains all the necessary information and functions
needed for calculating the projection allowing user to easily perform
calculations and visualize the results

## Details

Projection_object stores initial and projected data, specific options
and results of the MRC projection for each country

## Fields

- `projection_name`:

  Character; name of the projection scenario, used as the default output
  folder name

- `region_object_list`:

  List; Region_objects, one per region defined in \`data_regions\`

- `country_object_list`:

  List; Country_objects, one per country, created by
  \`create_country_list()\`

- `steps`:

  Numeric; number of 5-year projection periods to simulate

- `migration`:

  Logical; whether migration (emigration and immigration) is included in
  the projection

- `switching`:

  Logical; whether religious switching is included in the projection

- `switching_type`:

  Numeric; sequence of switching relative to demographic processes. 1 =
  split (pre/post demographic); 2 = all switching before demographic
  processes

- `no_diff`:

  Logical; if TRUE, fertility differentials by religion are ignored and
  all religions use the total ASFR

- `post_switch`:

  Logical; if FALSE (default), individuals who have switched religion
  remain in the general population and may switch again in subsequent
  steps; if TRUE, those who have switched are moved into separate
  post-switch columns and excluded from further switching

- `resolved`:

  Logical; TRUE once \`project()\` has been called successfully;
  prevents re-projection of the same object

- `region_totals`:

  Logical; whether region-level aggregated totals are computed and
  stored after projection

- `global_totals`:

  Logical; whether global totals are computed and stored after
  projection

- `light_migration`:

  Logical; if TRUE, migration output is stored in abbreviated form to
  reduce memory usage

- `light_switching`:

  Logical; if TRUE, switching output is stored in abbreviated form to
  reduce memory usage

## Examples

``` r
# Running a full projection is time-consuming.
# Wrapped in dontrun to avoid executing during documentation build.
if (FALSE) { # \dontrun{
obj <- test_object_generator(object_name = "example")
obj$projection_name # "example"
obj$steps # 1
obj$resolved # FALSE (before project())
project(projection_object = obj, progress_bar = FALSE, save_totals = FALSE)
obj$resolved # TRUE
length(obj$country_object_list) # 3
} # }
```
