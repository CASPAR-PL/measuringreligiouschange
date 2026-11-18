# Scenario variants settings dataset

Data frame containing scenario variant settings that can be applied in
the MRC projection models. Users can modify assumptions related to
fertility and migration for each country without altering the input
data.

Fertility. Users can adjust the level of the total fertility rate (TFR)
for each country by specifying a multiplier of the input TFR in the
column \`percentage_fertility\` (predefined level = 1).

Optional bounds can be set for the modified TFR using: •
\`bottom_fertility_cap\`: minimum allowed TFR (predefined = NA) •
\`upper_fertility_cap\`: maximum allowed TFR (predefined = NA) If the
adjusted TFR falls outside these limits, it is replaced with the nearest
boundary value.

A constant TFR change across the entire projection period can be applied
by setting \`flat_fertility\` (predefined = 0). This will not change
fertility profile.

Users can also specify convergence of religion-specific TFRs toward the
country-level TFR by setting the number of periods to full convergence
in \`convergence_steps\` (predefined = 16, meaning convergence finishing
in 2100).

Migration. Users can modify the level of out-migration rates for each
country by specifying a multiplier of the input migration data in the
column \`percentage_migration\` (predefined level = 1).

- Country. Name of country (character)

- Country_code. Code of country \[standard ISO 3166-1\] (numeric)

- Region_name. Name of the country region (character)

- percentage_fertility. Fraction by which the fertility should be
  modified (numeric)

- flat_fertility. Number by which the fertility should be modified
  (numeric)

- bottom_fertility_cap. Min value of modified fertility (numeric)

- upper_fertility_cap. Max value of modified fertility (numeric)

- percentage_migration. Fraction by which the migration should be
  modified (numeric)

- convergence_steps. Number of steps after which a full fertility
  convergence should be done (numeric) Numbers other than natural may
  lead to unexpected errors.

- fertility_factorization. Settings for equalising fertility after
  calculating fertility differentials. 1 equalise all age groups
  together, 2 equalise each age group separately. Using setting 1 may
  result in inconsistent ASFRs if fertility differentials are of
  different magnitude between age groups. (numeric)

## Format

Data frame with 201 rows and 10 variables

## See also

Other base_data:
[`base_data_list`](https://caspar-pl.github.io/measuringreligiouschange/reference/base_data_list.md),
[`data_asfr`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_asfr.md),
[`data_births_ratio`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_births_ratio.md),
[`data_fertility_differentials`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_fertility_differentials.md),
[`data_migration_destination`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_migration_destination.md),
[`data_migration_rates`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_migration_rates.md),
[`data_population`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_population.md),
[`data_regions`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_regions.md),
[`data_structure`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_structure.md),
[`data_survivability`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_survivability.md),
[`data_switching`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_switching.md)

## Examples

``` r
head(base_data_list$info_variants)
#> # A tibble: 6 × 10
#>   Country    Country_code Region_name percentage_fertility flat_fertility
#>   <chr>             <dbl> <chr>                      <dbl>          <dbl>
#> 1 Albania               8 EURO                           1              0
#> 2 Algeria              12 MENA                           1              0
#> 3 Angola               24 SSAF                           1              0
#> 4 Azerbaijan           31 ASPA                           1              0
#> 5 Argentina            32 LACA                           1              0
#> 6 Australia            36 ASPA                           1              0
#> # ℹ 5 more variables: bottom_fertility_cap <lgl>, upper_fertility_cap <lgl>,
#> #   percentage_migration <dbl>, convergence_steps <dbl>,
#> #   fertility_factorization <dbl>
```
