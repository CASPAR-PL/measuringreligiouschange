# Fertility differentials dataset

Data frame containing fertility differentials by religion for 201
countries, used in the MRC projection models.

The differentials represent the ratio of the age-specific fertility rate
(ASFR) for a particular religion to the ASFR for the total population.
Ratios were calculated in the MRC project based on data from censuses,
registers, and surveys.

ASFR values for the total population were derived from the United
Nations 'World Population Prospects 2024 Revision'.

- Country_code. Code of country \[standard ISO 3166-1\] (numeric)

- Age_group. Name of age group (character)

- Christians. Fertility differentials for Christians (numeric)

- Muslims. Fertility differentials for Muslims (numeric)

- Unaffiliated. Fertility differentials for Unaffiliated (numeric)

- Buddhists. Fertility differentials for Buddhists (numeric)

- Hindus. Fertility differentials for Hindus (numeric)

- Jews. Fertility differentials for Jews (numeric)

- Other_Religions. Fertility differentials for Other Religionists
  (numeric)

## Format

Data frame with 1809 rows and 9 variables

## References

Pew-CASPAR Measuring Religious Change Project

## See also

Other base_data: [`base_data_list`](base_data_list.md),
[`data_asfr`](data_asfr.md),
[`data_births_ratio`](data_births_ratio.md),
[`data_migration_destination`](data_migration_destination.md),
[`data_migration_rates`](data_migration_rates.md),
[`data_population`](data_population.md),
[`data_regions`](data_regions.md),
[`data_structure`](data_structure.md),
[`data_survivability`](data_survivability.md),
[`data_switching`](data_switching.md),
[`info_variants`](info_variants.md)

## Examples

``` r
head(base_data_list$data_fertility_differentials)
#> # A tibble: 6 × 9
#>   Country_code Age_group Christians Muslims Unaffiliated Buddhists Hindus  Jews
#>          <dbl> <chr>          <dbl>   <dbl>        <dbl>     <dbl>  <dbl> <dbl>
#> 1            4 10-14              1       1            1         1      1     1
#> 2            4 15-19              1       1            1         1      1     1
#> 3            4 20-24              1       1            1         1      1     1
#> 4            4 25-29              1       1            1         1      1     1
#> 5            4 30-34              1       1            1         1      1     1
#> 6            4 35-39              1       1            1         1      1     1
#> # ℹ 1 more variable: Other_Religions <dbl>
```
