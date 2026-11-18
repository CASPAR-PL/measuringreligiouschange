library(readr)
library(dplyr)

# data_asfr: Country_code already correct
data_asfr <- read_csv("data-raw/data_asfr.csv")

# data_fertility_differentials: ratio-based differentials, columns already correct
data_fertility_differentials <- read_csv("data-raw/data_fertility_differentials.csv")

# data_migration_destination: drop extra columns (Country, Relig_code)
data_migration_destination <- read_csv("data-raw/data_migration_destination.csv") |>
  select(-Country, -Relig_code)

# data_migration_rates: drop extra columns (Age_gr, Country), ensure correct column order
data_migration_rates <- read_csv("data-raw/data_migration_rates.csv") |>
  select(Year, Sex, Age, Country_code, Christians, Muslims, Unaffiliated, Buddhists, Hindus, Jews, Other_Religions)

# info_variants: read early so it can be used to filter other tables
info_variants <- read_csv("data-raw/info_variants.csv")

# data_births_ratio: filter to the 201 countries in info_variants (CSV includes UN aggregate codes)
data_births_ratio <- read_csv("data-raw/data_births_ratio.csv") |>
  filter(Country_code %in% info_variants$Country_code)

# data_population: Country_code already correct
data_population <- read_csv("data-raw/data_population.csv")

# data_structure: drop extra columns (Country, Year, Age)
data_structure <- read_csv("data-raw/data_structure.csv") |>
  select(Country_code, Age_group, Sex, Christians, Muslims, Unaffiliated, Buddhists, Hindus, Jews, Other_Religions)

# data_survivability: Country_code already correct
data_survivability <- read_csv("data-raw/data_survivability.csv")

# data_switching: drop extra columns (Country, Region)
data_switching <- read_csv("data-raw/data_switching.csv") |>
  select(Country_code, Religion, Sex, Christians, Muslims, Unaffiliated, Buddhists, Hindus, Jews, Other_Religions)

# data_regions: stored as data_religions.csv
data_regions <- read_csv("data-raw/data_religions.csv")

base_data_list <- list(
  data_asfr                    = data_asfr,
  data_fertility_differentials = data_fertility_differentials,
  data_migration_destination   = data_migration_destination,
  data_migration_rates         = data_migration_rates,
  data_births_ratio            = data_births_ratio,
  data_population              = data_population,
  data_structure               = data_structure,
  data_survivability           = data_survivability,
  data_switching               = data_switching,
  info_variants                = info_variants,
  data_regions                 = data_regions
)

usethis::use_data(base_data_list, overwrite = TRUE)
