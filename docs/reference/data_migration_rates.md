# Out-migration rates dataset

Data frame containing emigration (out-migration) rates by age, sex, and
religion for 201 countries, used in the MRC projection models.

Rates were calculated based on two sources: Guy Abel's bilateral
international migration flow estimates (Version 8) and the study "The
Religious Composition of the World’s Migrants" by Pew Research Center.

- Year. Year of beginning of a period for which the data is presented
  (numeric)

- Sex. Name of sex \[1=males, 2=females\] (numeric)

- Age_group. Names of age groups (character)

- Country_code. Code of country of origin \[standard ISO 3166-1\]
  (numeric)

- Christians. Emigration rates for Christians (numeric)

- Muslims. Emigration rates for Muslims (numeric)

- Unaffiliated. Emigration rates for Unaffiliated (numeric)

- Buddhists. Emigration rates for Buddhists (numeric)

- Hindus. Emigration rates for Hindus (numeric)

- Jews. Emigration rates for Jews (numeric)

- Other_Religions. Emigration rates for Other Religionists (numeric)

## Format

Data frame with 8040 rows and 11 variables

## References

Pew-CASPAR Measuring Religious Change Project; Kramer, S., & Tong, Y.
(2024). The religious composition of the world’s migrants. Pew Research
Center; Abel, G. J. (2025). Bilateral international migration flow
estimates for 200 countries (Version 8). Retrieved from
<https://guyabel.com/publication/bilateral-migration-flow-sex/>

## See also

Other base_data:
[`base_data_list`](https://caspar-pl.github.io/measuringreligiouschange/reference/base_data_list.md),
[`data_asfr`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_asfr.md),
[`data_births_ratio`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_births_ratio.md),
[`data_fertility_differentials`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_fertility_differentials.md),
[`data_migration_destination`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_migration_destination.md),
[`data_population`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_population.md),
[`data_regions`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_regions.md),
[`data_structure`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_structure.md),
[`data_survivability`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_survivability.md),
[`data_switching`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_switching.md),
[`info_variants`](https://caspar-pl.github.io/measuringreligiouschange/reference/info_variants.md)

## Examples

``` r
head(base_data_list$data_migration_rates)
#> # A tibble: 6 × 11
#>    Year   Sex Age   Country_code Christians Muslims Unaffiliated Buddhists
#>   <dbl> <dbl> <chr>        <dbl>      <dbl>   <dbl>        <dbl>     <dbl>
#> 1  2020     1 0-4              4     0.146  0.0145        0.146     0.146 
#> 2  2020     1 5-9              4     0.102  0.0101        0.102     0.102 
#> 3  2020     1 10-14            4     0.0752 0.00744       0.0752    0.0752
#> 4  2020     1 15-19            4     0.0756 0.0120        0.0756    0.0756
#> 5  2020     1 20-24            4     0.194  0.0307        0.194     0.194 
#> 6  2020     1 25-29            4     0.210  0.0332        0.210     0.210 
#> # ℹ 3 more variables: Hindus <dbl>, Jews <dbl>, Other_Religions <dbl>
```
