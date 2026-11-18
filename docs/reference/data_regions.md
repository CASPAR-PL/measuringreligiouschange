# Regions dataset

Data frame containing the names and codes of geographic regions used in
the MRC projection models. Each row defines one region to which
countries can be assigned.

- Name. Full name of the region (character)

- Region. Short region code used internally as an identifier (character)

## Format

Data frame with 6 rows and 2 variables

## See also

Other base_data:
[`base_data_list`](https://caspar-pl.github.io/measuringreligiouschange/reference/base_data_list.md),
[`data_asfr`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_asfr.md),
[`data_births_ratio`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_births_ratio.md),
[`data_fertility_differentials`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_fertility_differentials.md),
[`data_migration_destination`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_migration_destination.md),
[`data_migration_rates`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_migration_rates.md),
[`data_population`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_population.md),
[`data_structure`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_structure.md),
[`data_survivability`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_survivability.md),
[`data_switching`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_switching.md),
[`info_variants`](https://caspar-pl.github.io/measuringreligiouschange/reference/info_variants.md)

## Examples

``` r
head(base_data_list[[11]])
#> # A tibble: 6 × 2
#>   Name                     Region
#>   <chr>                    <chr> 
#> 1 Europe                   EURO  
#> 2 Middle East North Africa MENA  
#> 3 Sub-Saharan Africa       SSAF  
#> 4 Asia Pacific             ASPA  
#> 5 Latin America Caribbean  LACA  
#> 6 North America            NOAM  
```
