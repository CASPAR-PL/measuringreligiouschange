# Reference Class representing a region as Region_object

Object representing demographic and model-specific information for a
single region.

Each region object contains information fields as well as calculated
results of countries projections aggregated to respective regions
allowing user to easily perform calculations and visualize the results
on projection results for regions.

## Details

Region_object stores results of projection aggregated to regions.

## Fields

- `name`:

  Character; name of the region e.g. "North America"

- `region`:

  Character; region code identifying which countries belong to this
  region e.g. "NOAM"

- `structure_data`:

  List; aggregated population structure matrices indexed by year label,
  summed across all countries in the region

- `previous_mortality`:

  data.table; aggregated mortality output for the region. Columns:
  Country, Country_code, Period, Sex (integer 1/2), Age_group,
  Structure, Region, then one column per religion

- `previous_fertility`:

  data.table; aggregated fertility (births) output for the region.
  Columns: Country, Country_code, Period, Mother_age_group, Structure,
  Region, Total, then one column per religion

- `previous_asfr`:

  data.table; aggregated age-specific fertility rate output for the
  region. Columns: Country, Country_code, Period, Mother_age_group,
  Structure, Region, Total, then one column per religion; rows with
  Mother_age_group == "TFR" contain period totals

- `previous_fertility_exposure`:

  data.table; aggregated women-population exposure for the region.
  Columns: Country, Country_code, Period, Mother_age_group, Structure,
  Region, Total, then one column per religion

- `previous_switching`:

  data.table; aggregated switching output for the region. Columns:
  Country, Country_code, Period, Origin_religion, Structure, Region
  (light mode) or additionally Sex, Age_group (full mode), then one
  column per destination religion

- `previous_immigration`:

  data.table; aggregated immigration output for the region. Columns:
  Destination, Country_code, Period, Structure, Origin, Region (light
  mode) or additionally Sex, Age_group (full mode), then one column per
  religion

- `previous_emigration`:

  data.table; aggregated emigration output for the region. Columns:
  Origin, Country_code, Period, Structure, Destination, Region (light
  mode) or additionally Sex, Age_group (full mode), then one column per
  religion

## Examples

``` r
# Running a full projection is time-consuming.
# Wrapped in dontrun to avoid executing during documentation build.
if (FALSE) { # \dontrun{
obj <- test_object_generator(object_name = "example")
project(projection_object = obj, progress_bar = FALSE, save_totals = TRUE)
# Access a region object by name
reg <- obj$region_object_list[["NOAM"]]
reg$name # "NOAM"
length(reg$structure_data) # one entry per projection period
} # }
```
