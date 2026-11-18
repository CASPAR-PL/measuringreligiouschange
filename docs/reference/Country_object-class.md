# Reference Class representing a country as Country_object

Object representing demographic and model-specific information for a
single country used in the MRC projection framework.

Each country object contains demographic inputs and parameters that
define fertility, mortality, migration, and religious switching
dynamics, as well as country-specific settings used for scenario
projections.

## Details

Country_object stores initial and projected data, specific options and
results of the MRC projection for each country.

## Fields

- `year`:

  Numeric; current projection year, advances by 5 at each step

- `period`:

  Character; current five-year period label used in previous\_\* output
  tables (e.g. "2020-2025")

- `name`:

  Character; name of the country

- `code`:

  Numeric; ISO 3166-1 country code

- `region`:

  Character; name of the region to which the country belongs

- `structure_data`:

  List; population structure matrices indexed by year label. Before
  \`project()\` is called, contains only the starting period

- `mortality_rates`:

  Matrix; age- and sex-specific survival rates for each projection
  period (rows = sex-age groups, cols = periods)

- `age_specific_fertility_rates`:

  Matrix; total population ASFRs for each projection period (rows =
  periods, cols = age groups)

- `fertility_differentials`:

  List; religion-specific fertility differential matrices indexed by
  period label (values are ratios relative to total ASFR)

- `sex_ratio`:

  Numeric vector; fraction of boys at birth for each projection period

- `switching_matrices_list`:

  List; decomposed switching probability matrices, one per origin
  religion

- `outmigration_rates`:

  List; outmigration rate matrices by period (rows = sex-age groups,
  cols = religions)

- `destination_matrix`:

  Matrix; share of emigrants directed to each destination country, by
  sex and religion (rows = sex-religion combos, cols = destination
  country codes)

- `start_fertility_group`:

  Numeric; index of the first age group included in fertility
  calculations (default 3, corresponding to 10-14)

- `combined_fertility_factorization`:

  Logical; if TRUE (default), a single global factor is applied across
  all fertile age groups; if FALSE, each age group's fertility births
  are normalised independently to match the total ASFR for that age
  group

- `previous_mortality`:

  data.table; mortality output. Columns: Country, Country_code, Period,
  Sex (integer 1/2), Age_group, Structure, Region, then one column per
  religion

- `previous_fertility`:

  data.table; fertility (births) output. Columns: Country, Country_code,
  Period, Mother_age_group, Structure, Region, Total, then one column
  per religion

- `previous_asfr`:

  data.table; age-specific fertility rate output. Columns: Country,
  Country_code, Period, Mother_age_group, Structure, Region, Total
  (realised rate: births / exposure), then one column per religion; rows
  with Mother_age_group == "TFR" contain period totals. Religion columns
  of individual structures hold the applied rates and are reported even
  without exposure; Total and the "total" structure hold realised rates
  and are 0 where exposure is 0 (except \*\_post_switch columns, which
  show the mean applied rate)

- `previous_fertility_exposure`:

  data.table; women-population exposure used in ASFR calculation.
  Columns: Country, Country_code, Period, Mother_age_group, Structure,
  Region, Total, then one column per religion

- `old_fertility_factors`:

  Matrix; scaling factors applied to births to reconcile
  religion-specific fertility with total ASFR; one row per age group,
  one column per period

- `previous_switching`:

  data.table; switching output. Columns: Country, Country_code, Period,
  Origin_religion, Region (light mode) or additionally Sex, Age_group,
  Structure (full mode), then one column per destination religion

- `previous_immigration`:

  data.table; immigration output. Columns: Destination, Country_code,
  Period, Structure, Origin, Region (light mode) or additionally Sex,
  Age_group (full mode), then one column per religion

- `previous_emigration`:

  data.table; emigration output. Columns: Origin, Country_code, Period,
  Structure, Destination, Region (light mode) or additionally Sex,
  Age_group (full mode), then one column per religion

- `migration_list`:

  List; internal buffer accumulating immigration flows during a
  projection step

- `emigration_list`:

  List; internal buffer accumulating emigration flows during a
  projection step

- `migrant_sum`:

  Matrix; running total of emigrant counts by religion used to balance
  destination shares within a step

- `temp`:

  List; internal scratch space used during projection calculations; not
  intended for direct access

- `projection_owner`:

  Character; name of the Projection_object that has claimed this country
  object. Empty string (\`""\`) if unclaimed. Prevents the same country
  list from being reused across multiple projections

## Examples

``` r
if (FALSE) { # \dontrun{
obj <- test_object_generator(object_name = "example")
# Access a country object by its c-prefixed ISO key
co <- obj$country_object_list[["c840"]]
co$name # "USA"
co$code # 840
dim(co$structure_data[[1]]) # 40 x 7
} # }
```
