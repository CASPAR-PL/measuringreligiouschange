# Regions dataset

Data frame containing the names and codes of geographic regions used in
the MRC projection models. Each row defines one region to which
countries can be assigned.

- Name. Full name of the region (character)

- Region. Short region code used internally as an identifier (character)

## Format

Data frame with 6 rows and 2 variables

## See also

Other base_data: [`base_data_list`](base_data_list.md),
[`data_asfr`](data_asfr.md),
[`data_births_ratio`](data_births_ratio.md),
[`data_fertility_differentials`](data_fertility_differentials.md),
[`data_migration_destination`](data_migration_destination.md),
[`data_migration_rates`](data_migration_rates.md),
[`data_population`](data_population.md),
[`data_structure`](data_structure.md),
[`data_survivability`](data_survivability.md),
[`data_switching`](data_switching.md),
[`info_variants`](info_variants.md)

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
