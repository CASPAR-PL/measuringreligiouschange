# Age-Specific Fertility Rates dataset

Data frame containing age-specific fertility rates (ASFR) for 201
countries, used in the MRC projections. Data cover the period 2020–2100.

Unit is children born per 1000 women per 5 years.

ASFR values are based on data from the United Nations 'World Population
Prospects 2024 Revision' (medium variant), recalculated into 5-year
periods.

- Country_code. Code of country \[standard ISO 3166-1\] (numeric)

- Period. Period for which the data is presented (character)

- 10-14. ASFR for 10-14 age groups (numeric)

- 15-19. ASFR for 15-19 age groups (numeric)

- 20-24. ASFR for 20-24 age groups (numeric)

- 25-29. ASFR for 25-29 age groups (numeric)

- 30-34. ASFR for 30-34 age groups (numeric)

- 35-39. ASFR for 35-39 age groups (numeric)

- 40-44. ASFR for 40-44 age groups (numeric)

- 45-49. ASFR for 45-49 age groups (numeric)

- 50-54. ASFR for 50-54 age groups (numeric)

## Format

Data frame with 3216 rows and 11 variables

## References

United Nations, Department of Economic and Social Affairs, Population
Division (2024). World Population Prospects 2024, Online Edition (Rev.
1). Available at: <https://population.un.org/wpp/>

## See also

Other base_data: [`base_data_list`](base_data_list.md),
[`data_births_ratio`](data_births_ratio.md),
[`data_fertility_differentials`](data_fertility_differentials.md),
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
head(base_data_list$data_asfr)
#> # A tibble: 6 × 11
#>   Country_code Period    `10-14` `15-19` `20-24` `25-29` `30-34` `35-39` `40-44`
#>          <dbl> <chr>       <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
#> 1            4 2020-2025   5.59     321.    885.   1244.   1112.    802.    409.
#> 2            4 2025-2030   3.79     264.    744.   1144.   1032.    756.    389.
#> 3            4 2030-2035   2.54     216.    617.   1052.    964.    720.    374.
#> 4            4 2035-2040   1.75     179.    521.    972.    906.    687.    358.
#> 5            4 2040-2045   1.24     148.    443.    899.    850.    654.    339.
#> 6            4 2045-2050   0.897    126.    386.    844.    810.    631.    324.
#> # ℹ 2 more variables: `45-49` <dbl>, `50-54` <dbl>
```
