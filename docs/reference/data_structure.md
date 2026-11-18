# Population structure dataset

Data frame containing the religious composition of specific age and sex
groups in the population of 201 countries, used in the MRC projections
The dataset corresponds to the year 2020.

The values represent the proportion of a particular religious group
within a specific age group (5-year intervals) and sex, relative to the
total population of that age group and sex. Shares were calculated in
the MRC project based on data from censuses, registers, and surveys.

- Country_code. Code of country \[standard ISO 3166-1\] (numeric)

- Age_group. Name of age group (character)

- Sex. Name of sex \[1=males, 2=females\] (numeric)

- Christians. Share of Christians in a specific age and sex group
  (numeric)

- Muslims. Share of Muslims in a specific age and sex group (numeric)

- Unaffiliated. Share of Unaffiliated in a specific age and sex group
  (numeric)

- Buddhists. Share of Buddhists in a specific age and sex group
  (numeric)

- Hindus. Share of Hindus in a specific age and sex group (numeric)

- Jews. Share of Jews in a specific age and sex group (numeric)

- Other_Religions. Share of Other Religionists in a specific age and sex
  group (numeric)

## Format

Data frame with 8040 rows and 10 variables

## References

Pew-CASPAR Measuring Religious Change Project

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
[`data_survivability`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_survivability.md),
[`data_switching`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_switching.md),
[`info_variants`](https://caspar-pl.github.io/measuringreligiouschange/reference/info_variants.md)

## Examples

``` r
head(base_data_list$data_structure)
#> # A tibble: 6 × 10
#>   Country_code Age_group   Sex Christians Muslims Unaffiliated Buddhists  Hindus
#>          <dbl> <chr>     <dbl>      <dbl>   <dbl>        <dbl>     <dbl>   <dbl>
#> 1            4 0-4           1   0.000194   0.999    0.0000846  0.000200 1.28e-6
#> 2            4 5-9           1   0.000194   0.999    0.0000846  0.000200 1.28e-6
#> 3            4 10-14         1   0.000194   0.999    0.0000846  0.000200 1.28e-6
#> 4            4 15-19         1   0.000194   0.999    0.0000846  0.000200 1.28e-6
#> 5            4 20-24         1   0.000194   0.999    0.0000846  0.000200 1.28e-6
#> 6            4 25-29         1   0.000194   0.999    0.0000846  0.000200 1.28e-6
#> # ℹ 2 more variables: Jews <dbl>, Other_Religions <dbl>
```
