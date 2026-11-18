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

Other base_data: [`base_data_list`](base_data_list.md),
[`data_asfr`](data_asfr.md),
[`data_births_ratio`](data_births_ratio.md),
[`data_fertility_differentials`](data_fertility_differentials.md),
[`data_migration_destination`](data_migration_destination.md),
[`data_migration_rates`](data_migration_rates.md),
[`data_population`](data_population.md),
[`data_regions`](data_regions.md),
[`data_survivability`](data_survivability.md),
[`data_switching`](data_switching.md),
[`info_variants`](info_variants.md)

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
