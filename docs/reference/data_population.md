# Population dataset

Data frame containing population size by age and sex for 201 countries,
used in the MRC projections. The dataset corresponds to the year 2020.
Population counts come from estimates published in the United Nations
'World Population Prospects 2024 Revision'

Population is in thousands.

- Sex. Name of sex \[1=males, 2=females\] (numeric)

- Country_code. Code of country \[standard ISO 3166-1\] (numeric)

- 20 variables representing each five-year age group used in projection
  from 0-4 to 95+. Population size (numeric)

## Format

Data frame with 402 rows and 22 variables

## References

United Nations, Department of Economic and Social Affairs, Population
Division (2024). World Population Prospects 2024, Online Edition (Rev.
1). Available at: <https://population.un.org/wpp/>

## See also

Other base_data:
[`base_data_list`](https://caspar-pl.github.io/measuringreligiouschange/reference/base_data_list.md),
[`data_asfr`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_asfr.md),
[`data_births_ratio`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_births_ratio.md),
[`data_fertility_differentials`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_fertility_differentials.md),
[`data_migration_destination`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_migration_destination.md),
[`data_migration_rates`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_migration_rates.md),
[`data_regions`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_regions.md),
[`data_structure`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_structure.md),
[`data_survivability`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_survivability.md),
[`data_switching`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_switching.md),
[`info_variants`](https://caspar-pl.github.io/measuringreligiouschange/reference/info_variants.md)

## Examples

``` r
head(base_data_list$data_population)
#> # A tibble: 6 × 22
#>     Sex Country_code  `0-4`  `5-9` `10-14` `15-19` `20-24` `25-29` `30-34`
#>   <dbl>        <dbl>  <dbl>  <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
#> 1     1            4 3312.  2942.   2590.   2329.    1983.   1577.   1203.
#> 2     2            4 3167.  2805.   2462.   2218.    1914.   1541.   1180.
#> 3     1            8   82.5   92.2    87.9   101.     118.    125.    112.
#> 4     2            8   76.0   84.0    80.7    93.6    114.    123.    103.
#> 5     1           12 2558.  2402.   1976.   1538.    1525.   1783.   1906.
#> 6     2           12 2456.  2304.   1888.   1474.    1446.   1665.   1802.
#> # ℹ 13 more variables: `35-39` <dbl>, `40-44` <dbl>, `45-49` <dbl>,
#> #   `50-54` <dbl>, `55-59` <dbl>, `60-64` <dbl>, `65-69` <dbl>, `70-74` <dbl>,
#> #   `75-79` <dbl>, `80-84` <dbl>, `85-89` <dbl>, `90-94` <dbl>, `95+` <dbl>
```
