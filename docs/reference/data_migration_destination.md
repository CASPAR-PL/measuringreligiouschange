# Migration destination matrices dataset.

Data frame containing data on emigrant destinations by religion and sex
for 201 countries, used in the MRC projection models.

The dataset contains fractions of emigrants moving to each destination
country. Fractions were calculated based on two sources: Guy Abel's
bilateral international migration flow estimates (Version 8) and the
study "The Religious Composition of the World’s Migrants" by Pew
Research Center.

- Country_code. Code of country of origin \[standard ISO 3166-1\]
  (numeric)

- Sex. Name of sex \[1=males, 2=females\] (numeric)

- Religion. Name of religion (character)

- 201 variables with names representing Country_code of migrants’
  destination. Fraction of migrants (numeric)

## Format

Data frame with 2814 rows and 204 variables

## References

Pew-CASPAR Measuring Religious Change Project; Kramer, S., & Tong, Y.
(2024). The religious composition of the world’s migrants. Pew Research
Center; Abel, G. J. (2025). Bilateral international migration flow
estimates for 200 countries (Version 8). Retrieved from
<https://guyabel.com/publication/bilateral-migration-flow-sex/>

## See also

Other base_data: [`base_data_list`](base_data_list.md),
[`data_asfr`](data_asfr.md),
[`data_births_ratio`](data_births_ratio.md),
[`data_fertility_differentials`](data_fertility_differentials.md),
[`data_migration_rates`](data_migration_rates.md),
[`data_population`](data_population.md),
[`data_regions`](data_regions.md),
[`data_structure`](data_structure.md),
[`data_survivability`](data_survivability.md),
[`data_switching`](data_switching.md),
[`info_variants`](info_variants.md)

## Examples

``` r
head(base_data_list$data_migration_destination[, 1:6])
#> # A tibble: 6 × 6
#>   Country_code   Sex Religion       `4`   `8`  `12`
#>          <dbl> <dbl> <chr>        <dbl> <dbl> <dbl>
#> 1            4     1 Christians       0     0     0
#> 2            4     1 Muslims          0     0     0
#> 3            4     1 Unaffiliated     0     0     0
#> 4            4     1 Buddhists        0     0     0
#> 5            4     1 Hindus           0     0     0
#> 6            4     1 Jews             0     0     0
```
