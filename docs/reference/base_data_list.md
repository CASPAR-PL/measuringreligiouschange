# default data list

List of eleven datasets used for projections. The default dataset in the
MRC projection framework. Includes data for 201 countries and 7
religious groups over the period 2020–2100.

- \[data_asfr\]. Dataset containing age specific fertility rates

- \[data_fertility_differentials\]. Dataset containing fertility
  differentials

- \[data_migration_destination\]. Dataset containing migrants
  destination data

- \[data_migration_rates\]. Dataset containing outmigration rates

- \[data_births_ratio\]. Dataset containing fractions of boys at birth

- \[data_population\]. Dataset containing population size data

- \[data_structure\]. Dataset containing religion structure of
  populations data

- \[data_survivability\]. Dataset containing survival rates

- \[data_switching\]. Dataset containing religion switching rates

- \[info_variants\]. Dataset containing variants settings

- \[data_regions\]. Dataset containing regional codes and names.

## Usage

``` r
base_data_list
```

## Format

list of data frames

## See also

Other base_data:
[`data_asfr`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_asfr.md),
[`data_births_ratio`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_births_ratio.md),
[`data_fertility_differentials`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_fertility_differentials.md),
[`data_migration_destination`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_migration_destination.md),
[`data_migration_rates`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_migration_rates.md),
[`data_population`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_population.md),
[`data_regions`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_regions.md),
[`data_structure`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_structure.md),
[`data_survivability`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_survivability.md),
[`data_switching`](https://caspar-pl.github.io/measuringreligiouschange/reference/data_switching.md),
[`info_variants`](https://caspar-pl.github.io/measuringreligiouschange/reference/info_variants.md)

## Examples

``` r
length(base_data_list) # 11 datasets
#> [1] 11
```
