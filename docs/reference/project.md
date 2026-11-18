# Conducting MRC projection

Main method for a projection object. It is used to run the MRC
projection - multi-state projection of population by age, sex and
religious affiliation. Calling this method executes the MRC projection
using parameters stored in the projection_object and input data stored
in country_object_list.

The method performs the full projection workflow according to the
settings contained in projection_object (e.g. number of steps, inclusion
of migration and switching, switching sequence, fertility
differentials). Input data for all countries must be supplied via
country_object_list prior to running.

## Usage

``` r
project(projection_object, progress_bar = TRUE, save_totals = TRUE)
```

## Arguments

- projection_object:

  Projection_object; an unresolved projection object to run.

- progress_bar:

  Logical; whether to show a progress bar and ETA during the projection
  (default TRUE).

- save_totals:

  Logical; whether to compute and store region and global totals after
  projection (default TRUE).

## Value

Progress bar and time of execution, modifies projection object

## See also

[`create_country_list`](create_country_list.md),
[`create_projection_object`](create_projection_object.md),
[`variants_loader`](variants_loader.md) to set up a projection before
calling this function. [`save_csv_all`](save_csv_all.md) and
[`save_plots_all`](save_plots_all.md) to export results afterwards.
[`vignette("conducting-projections")`](../articles/conducting-projections.md)
for a full walkthrough.
[`vignette("inner-workings")`](../articles/inner-workings.md) for the
internal projection algorithm.

## Examples

``` r
# Running a full projection is time-consuming.
# Wrapped in dontrun to avoid executing during documentation build.
if (FALSE) { # \dontrun{
p_object <- create_projection_object(name = "test")
p_object$project()

p_object <- create_projection_object(name = "test")
project(projection_object = p_object)
} # }
```
