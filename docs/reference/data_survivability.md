# Survival rates (nSx) dataset

Data frame containing survival rates by age and sex for 201 countries,
used in the MRC projection models. Dataset covers the period 2020–2100.
Survival rates (Sx) come from the abridged life tables from the United
Nations 'World Population Prospects 2024 Revision' (medium variant),
recalculated into 5-year periods.

- Country_code. Code of country \[standard ISO 3166-1\] (numeric)

- Sex. Name of sex \[1=males, 2=females\] (numeric)

- Age. Number of age_group (from 0 (age 0) to 20 (age 95+)) (numeric)

- Age_name. Age representing lower limit of age group (e.g. 10 for age
  group 10-14) (numeric)

- 2020-2025. Survival rates for 2020-2025 period (numeric)

- 2025-2030. Survival rates for 2025-2030 period (numeric)

- 2030-2035. Survival rates for 2030-2035 period (numeric)

- 2035-2040. Survival rates for 2035-2040 period (numeric)

- 2040-2045. Survival rates for 2040-2045 period (numeric)

- 2045-2050. Survival rates for 2045-2050 period (numeric)

- 2050-2055. Survival rates for 2050-2055 period (numeric)

- 2055-2060. Survival rates for 2055-2060 period (numeric)

- 2060-2065. Survival rates for 2060-2065 period (numeric)

- 2065-2070. Survival rates for 2065-2070 period (numeric)

- 2070-2075. Survival rates for 2070-2075 period (numeric)

- 2075-2080. Survival rates for 2075-2080 period (numeric)

- 2080-2085. Survival rates for 2080-2085 period (numeric)

- 2085-2090. Survival rates for 2085-2090 period (numeric)

- 2090-2095. Survival rates for 2090-2095 period (numeric)

- 2095-2100. Survival rates for 2095-2100 period (numeric)

## Format

Data frame with 8442 rows and 20 variables

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
[`data_population`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_population.md),
[`data_regions`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_regions.md),
[`data_structure`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_structure.md),
[`data_switching`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_switching.md),
[`info_variants`](https://caspar-pl.github.io/measuringreligiouschange/reference/info_variants.md)

## Examples

``` r
head(base_data_list$data_survivability)
#> # A tibble: 6 × 20
#>   Country_code   Sex   Age Age_name `2020-2025` `2025-2030` `2030-2035`
#>          <dbl> <dbl> <dbl>    <dbl>       <dbl>       <dbl>       <dbl>
#> 1            4     1     0        0       0.947       0.954       0.960
#> 2            4     1     1        1       0.988       0.990       0.991
#> 3            4     1     2        5       0.995       0.996       0.996
#> 4            4     1     3       10       0.993       0.995       0.995
#> 5            4     1     4       15       0.986       0.991       0.992
#> 6            4     1     5       20       0.982       0.989       0.990
#> # ℹ 13 more variables: `2035-2040` <dbl>, `2040-2045` <dbl>, `2045-2050` <dbl>,
#> #   `2050-2055` <dbl>, `2055-2060` <dbl>, `2060-2065` <dbl>, `2065-2070` <dbl>,
#> #   `2070-2075` <dbl>, `2075-2080` <dbl>, `2080-2085` <dbl>, `2085-2090` <dbl>,
#> #   `2090-2095` <dbl>, `2095-2100` <dbl>
```
