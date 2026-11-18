# Sex ratio at birth dataset

Data frame containing the fractions of male births for 201 countries,
used in the MRC projection models. Data cover the period 2020–2100.
Fractions were derived from sex ratio at birth data published in the
United Nations 'World Population Prospects 2024 Revision' (medium
variant), recalculated into 5-year periods.

- Country_code. Code of country \[standard ISO 3166-1\] (numeric)

- 2020-2025. fractions of boys at birth for 2020-2025 period (numeric)

- 2025-2030. fractions of boys at birth for 2025-2030 period (numeric)

- 2030-2035. fractions of boys at birth for 2030-2035 period (numeric)

- 2035-2040. fractions of boys at birth for 2035-2040 period (numeric)

- 2040-2045. fractions of boys at birth for 2040-2045 period (numeric)

- 2045-2050. fractions of boys at birth for 2045-2050 period (numeric)

- 2050-2055. fractions of boys at birth for 2050-2055 period (numeric)

- 2055-2060. fractions of boys at birth for 2055-2060 period (numeric)

- 2060-2065. fractions of boys at birth for 2060-2065 period (numeric)

- 2065-2070. fractions of boys at birth for 2065-2070 period (numeric)

- 2070-2075. fractions of boys at birth for 2070-2075 period (numeric)

- 2075-2080. fractions of boys at birth for 2075-2080 period (numeric)

- 2080-2085. fractions of boys at birth for 2080-2085 period (numeric)

- 2085-2090. fractions of boys at birth for 2085-2090 period (numeric)

- 2090-2095. fractions of boys at birth for 2090-2095 period (numeric)

- 2095-2100. fractions of boys at birth for 2095-2100 period (numeric)

## Format

Data frame with 201 rows and 17 variables

## References

United Nations, Department of Economic and Social Affairs, Population
Division (2024). World Population Prospects 2024, Online Edition (Rev.
1). Available at: <https://population.un.org/wpp/>

## See also

Other base_data: [`base_data_list`](base_data_list.md),
[`data_asfr`](data_asfr.md),
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
head(base_data_list$data_births_ratio)
#> # A tibble: 6 × 17
#>   Country_code `2020-2025` `2025-2030` `2030-2035` `2035-2040` `2040-2045`
#>          <dbl>       <dbl>       <dbl>       <dbl>       <dbl>       <dbl>
#> 1            4       0.513       0.512       0.512       0.512       0.512
#> 2            8       0.517       0.515       0.515       0.514       0.514
#> 3           12       0.511       0.511       0.511       0.511       0.511
#> 4           24       0.507       0.507       0.507       0.507       0.507
#> 5           31       0.528       0.524       0.520       0.517       0.516
#> 6           32       0.513       0.512       0.512       0.512       0.512
#> # ℹ 11 more variables: `2045-2050` <dbl>, `2050-2055` <dbl>, `2055-2060` <dbl>,
#> #   `2060-2065` <dbl>, `2065-2070` <dbl>, `2070-2075` <dbl>, `2075-2080` <dbl>,
#> #   `2080-2085` <dbl>, `2085-2090` <dbl>, `2090-2095` <dbl>, `2095-2100` <dbl>
```
