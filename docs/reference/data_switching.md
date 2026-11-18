# religion switching dataset

Data frame containing the religious composition of cohorts after the
“switching period” of a specific religion, for 201 countries, used in
the MRC projection models.

The switching period is the age range during which individuals in a
cohort may change their religion. It is defined by the user in the MRC
projection model. For example, if the switching period is defined as
ages 15–30 for religion group A, the dataset shows the religious
composition of the same cohort at ages 30–34 that had religion A at ages
10–14.

The compositions were calculated in the MRC project based on survey data
containing retrospective questions on religious affiliation.

- Country_code. Code of country \[standard ISO 3166-1\] (numeric)

- Religion. Name of religion before switching period (character)

- Sex. Name of sex \[1=males, 2=females\] (numeric)

- Christians. Share of Christians after switching period (numeric)

- Muslims. Share of Muslims after switching period (numeric)

- Unaffiliated. Share of Unaffiliated after switching period (numeric)

- Buddhists. Share of Buddhists after switching period (numeric)

- Hindus. Share of Hindus after switching period (numeric)

- Jews. Share of Jews after switching period (numeric)

- Other_Religions. Share of Other Religions after switching period
  (numeric)

## Format

Data frame with 2814 rows and 10 variables

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
[`data_structure`](data_structure.md),
[`data_survivability`](data_survivability.md),
[`info_variants`](info_variants.md)

## Examples

``` r
head(base_data_list$data_switching)
#> # A tibble: 6 × 10
#>   Country_code Religion     Sex Christians Muslims Unaffiliated Buddhists Hindus
#>          <dbl> <chr>      <dbl>      <dbl>   <dbl>        <dbl>     <dbl>  <dbl>
#> 1            4 Christians     1          1       0            0         0      0
#> 2            4 Muslims        1          0       1            0         0      0
#> 3            4 Unaffilia…     1          0       0            1         0      0
#> 4            4 Buddhists      1          0       0            0         1      0
#> 5            4 Hindus         1          0       0            0         0      1
#> 6            4 Jews           1          0       0            0         0      0
#> # ℹ 2 more variables: Jews <dbl>, Other_Religions <dbl>
```
