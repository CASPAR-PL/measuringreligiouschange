#' @name base_data_list
#' @title default data list
#' @description
#' List of eleven datasets used for projections. The default dataset in the MRC projection framework. Includes data for 201 countries and 7 religious groups over the period 2020–2100.
#' \itemize{
#'  \item [data_asfr]. Dataset containing age specific fertility rates
#'  \item [data_fertility_differentials]. Dataset containing fertility differentials
#'  \item [data_migration_destination]. Dataset containing migrants destination data
#'  \item [data_migration_rates]. Dataset containing outmigration rates
#'  \item [data_births_ratio]. Dataset containing fractions of boys at birth
#'  \item [data_population]. Dataset containing population size data
#'  \item [data_structure]. Dataset containing religion structure of populations data
#'  \item [data_survivability]. Dataset containing survival rates
#'  \item [data_switching]. Dataset containing religion switching rates
#'  \item [info_variants]. Dataset containing variants settings
#'  \item [data_regions]. Dataset containing regional codes and names.
#' }
#'
#' @family base_data
#' @docType data
#' @keywords datasets
#' @usage base_data_list
#' @examples
#' length(base_data_list) # 11 datasets
#' @format list of data frames
"base_data_list"
#' @name data_asfr
#' @title Age-Specific Fertility Rates dataset
#' @description
#' Data frame containing age-specific fertility rates (ASFR) for 201 countries, used in the MRC projections. Data cover the period 2020–2100.
#'
#' Unit is children born per 1000 women per 5 years.
#'
#' ASFR values are based on data from the United Nations 'World Population Prospects 2024 Revision' (medium variant), recalculated into 5-year periods.
#' \itemize{
#'  \item Country_code. Code of country [standard ISO 3166-1] (numeric)
#'  \item Period. Period for which the data is presented (character)
#'  \item 10-14. ASFR for 10-14 age groups (numeric)
#'  \item 15-19. ASFR for 15-19 age groups (numeric)
#'  \item 20-24. ASFR for 20-24 age groups (numeric)
#'  \item 25-29. ASFR for 25-29 age groups (numeric)
#'  \item 30-34. ASFR for 30-34 age groups (numeric)
#'  \item 35-39. ASFR for 35-39 age groups (numeric)
#'  \item 40-44. ASFR for 40-44 age groups (numeric)
#'  \item 45-49. ASFR for 45-49 age groups (numeric)
#'  \item 50-54. ASFR for 50-54 age groups (numeric)
#' }
#'
#' @family base_data
#' @docType data
#' @keywords datasets
#' @examples
#' head(base_data_list$data_asfr)
#' @format Data frame with 3216 rows and 11 variables
#' @references United Nations, Department of Economic and Social Affairs, Population Division (2024). World Population Prospects 2024, Online Edition (Rev. 1). Available at: \url{https://population.un.org/wpp/}
NULL
#' @name data_fertility_differentials
#' @title Fertility differentials dataset
#' @description
#' Data frame containing fertility differentials by religion for 201 countries, used in the MRC projection models.
#'
#' The differentials represent the ratio of the age-specific fertility rate (ASFR) for a particular religion to the ASFR for the total population. Ratios were calculated in the MRC project based on data from censuses, registers, and surveys.
#'
#' ASFR values for the total population were derived from the United Nations 'World Population Prospects 2024 Revision'.
#' \itemize{
#'  \item Country_code. Code of country [standard ISO 3166-1] (numeric)
#'  \item Age_group. Name of age group (character)
#'  \item Christians. Fertility differentials for Christians (numeric)
#'  \item Muslims. Fertility differentials for Muslims (numeric)
#'  \item Unaffiliated. Fertility differentials for Unaffiliated (numeric)
#'  \item Buddhists. Fertility differentials for Buddhists (numeric)
#'  \item Hindus. Fertility differentials for Hindus (numeric)
#'  \item Jews. Fertility differentials for Jews (numeric)
#'  \item Other_Religions. Fertility differentials for Other Religionists (numeric)
#' }
#'
#' @family base_data
#' @docType data
#' @keywords datasets
#' @examples
#' head(base_data_list$data_fertility_differentials)
#' @format Data frame with 1809 rows and 9 variables
#' @references Pew-CASPAR Measuring Religious Change Project
NULL
#' @name data_migration_destination
#' @title Migration destination matrices dataset.
#' @description
#' Data frame containing data on emigrant destinations by religion and sex for 201 countries, used in the MRC projection models.
#'
#' The dataset contains fractions of emigrants moving to each destination country.
#' Fractions were calculated based on two sources: Guy Abel's bilateral international migration flow estimates (Version 8) and the study "The Religious Composition of the World’s Migrants" by Pew Research Center.
#' \itemize{
#'  \item Country_code. Code of country of origin [standard ISO 3166-1] (numeric)
#'  \item Sex. Name of sex [1=males, 2=females] (numeric)
#'  \item Religion. Name of religion (character)
#'  \item 201 variables with names representing Country_code of migrants’ destination. Fraction of migrants (numeric)
#' }
#'
#' @family base_data
#' @docType data
#' @keywords datasets
#' @examples
#' head(base_data_list$data_migration_destination[, 1:6])
#' @format Data frame with 2814 rows and 204 variables
#' @references Pew-CASPAR Measuring Religious Change Project; Kramer, S., & Tong, Y. (2024). The religious composition of the world’s migrants. Pew Research Center; Abel, G. J. (2025). Bilateral international migration flow estimates for 200 countries (Version 8). Retrieved from \url{https://guyabel.com/publication/bilateral-migration-flow-sex/}
NULL
#' @name data_migration_rates
#' @title Out-migration rates dataset
#' @description
#' Data frame containing emigration (out-migration) rates by age, sex, and religion for 201 countries, used in the MRC projection models.
#'
#' Rates were calculated based on two sources: Guy Abel's bilateral international migration flow estimates (Version 8) and the study "The Religious Composition of the World’s Migrants" by Pew Research Center.
#' \itemize{
#'  \item Year. Year of beginning of a period for which the data is presented (numeric)
#'  \item Sex. Name of sex [1=males, 2=females] (numeric)
#'  \item Age_group. Names of age groups (character)
#'  \item Country_code. Code of country of origin [standard ISO 3166-1] (numeric)
#'  \item Christians. Emigration rates for Christians (numeric)
#'  \item Muslims. Emigration rates for Muslims (numeric)
#'  \item Unaffiliated. Emigration rates for Unaffiliated (numeric)
#'  \item Buddhists. Emigration rates for Buddhists (numeric)
#'  \item Hindus. Emigration rates for Hindus (numeric)
#'  \item Jews. Emigration rates for Jews (numeric)
#'  \item Other_Religions. Emigration rates for Other Religionists (numeric)
#' }
#'
#' @family base_data
#' @docType data
#' @keywords datasets
#' @examples
#' head(base_data_list$data_migration_rates)
#' @format Data frame with 8040 rows and 11 variables
#' @references Pew-CASPAR Measuring Religious Change Project; Kramer, S., & Tong, Y. (2024). The religious composition of the world’s migrants. Pew Research Center; Abel, G. J. (2025). Bilateral international migration flow estimates for 200 countries (Version 8). Retrieved from \url{https://guyabel.com/publication/bilateral-migration-flow-sex/}
NULL
#' @name data_births_ratio
#' @title Sex ratio at birth dataset
#' @description
#' Data frame containing the fractions of male births for 201 countries, used in the MRC projection models. Data cover the period 2020–2100. Fractions were derived from sex ratio at birth data published in the United Nations 'World Population Prospects 2024 Revision' (medium variant), recalculated into 5-year periods.
#' \itemize{
#'  \item Country_code. Code of country [standard ISO 3166-1] (numeric)
#'  \item 2020-2025. fractions of boys at birth for 2020-2025 period (numeric)
#'  \item 2025-2030. fractions of boys at birth for 2025-2030 period (numeric)
#'  \item 2030-2035. fractions of boys at birth for 2030-2035 period (numeric)
#'  \item 2035-2040. fractions of boys at birth for 2035-2040 period (numeric)
#'  \item 2040-2045. fractions of boys at birth for 2040-2045 period (numeric)
#'  \item 2045-2050. fractions of boys at birth for 2045-2050 period (numeric)
#'  \item 2050-2055. fractions of boys at birth for 2050-2055 period (numeric)
#'  \item 2055-2060. fractions of boys at birth for 2055-2060 period (numeric)
#'  \item 2060-2065. fractions of boys at birth for 2060-2065 period (numeric)
#'  \item 2065-2070. fractions of boys at birth for 2065-2070 period (numeric)
#'  \item 2070-2075. fractions of boys at birth for 2070-2075 period (numeric)
#'  \item 2075-2080. fractions of boys at birth for 2075-2080 period (numeric)
#'  \item 2080-2085. fractions of boys at birth for 2080-2085 period (numeric)
#'  \item 2085-2090. fractions of boys at birth for 2085-2090 period (numeric)
#'  \item 2090-2095. fractions of boys at birth for 2090-2095 period (numeric)
#'  \item 2095-2100. fractions of boys at birth for 2095-2100 period (numeric)
#' }
#'
#' @family base_data
#' @docType data
#' @keywords datasets
#' @examples
#' head(base_data_list$data_births_ratio)
#' @format Data frame with 201 rows and 17 variables
#' @references United Nations, Department of Economic and Social Affairs, Population Division (2024). World Population Prospects 2024, Online Edition (Rev. 1). Available at: \url{https://population.un.org/wpp/}
NULL
#' @name data_population
#' @title Population dataset
#' @description
#' Data frame containing population size by age and sex for 201 countries, used in the MRC projections. The dataset corresponds to the year 2020.
#' Population counts come from estimates published in the United Nations 'World Population Prospects 2024 Revision'
#'
#' Population is in thousands.
#' \itemize{
#'  \item Sex. Name of sex [1=males, 2=females] (numeric)
#'  \item Country_code. Code of country [standard ISO 3166-1] (numeric)
#'  \item 20 variables representing each five-year age group used in projection from 0-4 to 95+. Population size (numeric)
#' }
#'
#' @family base_data
#' @docType data
#' @keywords datasets
#' @examples
#' head(base_data_list$data_population)
#' @format Data frame with 402 rows and 22 variables
#' @references United Nations, Department of Economic and Social Affairs, Population Division (2024). World Population Prospects 2024, Online Edition (Rev. 1). Available at: \url{https://population.un.org/wpp/}
NULL
#' @name data_structure
#' @title Population structure dataset
#' @description
#' Data frame containing the religious composition of specific age and sex groups in the population of 201 countries, used in the MRC projections The dataset corresponds to the year 2020.
#'
#' The values represent the proportion of a particular religious group within a specific age group (5-year intervals) and sex, relative to the total population of that age group and sex. Shares were calculated in the MRC project based on data from censuses, registers, and surveys.
#' \itemize{
#'  \item Country_code. Code of country [standard ISO 3166-1] (numeric)
#'  \item Age_group. Name of age group (character)
#'  \item Sex. Name of sex [1=males, 2=females] (numeric)
#'  \item Christians. Share of Christians in a specific age and sex group (numeric)
#'  \item Muslims. Share of Muslims in a specific age and sex group (numeric)
#'  \item Unaffiliated. Share of Unaffiliated in a specific age and sex group (numeric)
#'  \item Buddhists. Share of Buddhists in a specific age and sex group (numeric)
#'  \item Hindus. Share of Hindus in a specific age and sex group (numeric)
#'  \item Jews. Share of Jews in a specific age and sex group (numeric)
#'  \item Other_Religions. Share of Other Religionists in a specific age and sex group (numeric)
#' }
#'
#' @family base_data
#' @docType data
#' @keywords datasets
#' @examples
#' head(base_data_list$data_structure)
#' @format Data frame with 8040 rows and 10 variables
#' @references Pew-CASPAR Measuring Religious Change Project
NULL
#' @name data_survivability
#' @title Survival rates (nSx) dataset
#' @description
#' Data frame containing survival rates by age and sex for 201 countries, used in the MRC projection models. Dataset covers the period 2020–2100. Survival rates (Sx) come from the abridged life tables from the United Nations 'World Population Prospects 2024 Revision' (medium variant), recalculated into 5-year periods.
#' \itemize{
#'  \item Country_code. Code of country [standard ISO 3166-1] (numeric)
#'  \item Sex. Name of sex [1=males, 2=females] (numeric)
#'  \item Age. Number of age_group (from 0 (age 0) to 20 (age 95+)) (numeric)
#'  \item Age_name. Age representing lower limit of age group (e.g. 10 for age group 10-14) (numeric)
#'  \item 2020-2025. Survival rates for 2020-2025 period (numeric)
#'  \item 2025-2030. Survival rates for 2025-2030 period (numeric)
#'  \item 2030-2035. Survival rates for 2030-2035 period (numeric)
#'  \item 2035-2040. Survival rates for 2035-2040 period (numeric)
#'  \item 2040-2045. Survival rates for 2040-2045 period (numeric)
#'  \item 2045-2050. Survival rates for 2045-2050 period (numeric)
#'  \item 2050-2055. Survival rates for 2050-2055 period (numeric)
#'  \item 2055-2060. Survival rates for 2055-2060 period (numeric)
#'  \item 2060-2065. Survival rates for 2060-2065 period (numeric)
#'  \item 2065-2070. Survival rates for 2065-2070 period (numeric)
#'  \item 2070-2075. Survival rates for 2070-2075 period (numeric)
#'  \item 2075-2080. Survival rates for 2075-2080 period (numeric)
#'  \item 2080-2085. Survival rates for 2080-2085 period (numeric)
#'  \item 2085-2090. Survival rates for 2085-2090 period (numeric)
#'  \item 2090-2095. Survival rates for 2090-2095 period (numeric)
#'  \item 2095-2100. Survival rates for 2095-2100 period (numeric)
#' }
#'
#' @family base_data
#' @docType data
#' @keywords datasets
#' @examples
#' head(base_data_list$data_survivability)
#' @format Data frame with 8442 rows and 20 variables
#' @references United Nations, Department of Economic and Social Affairs, Population Division (2024). World Population Prospects 2024, Online Edition (Rev. 1). Available at: \url{https://population.un.org/wpp/}
NULL
#' @name data_switching
#' @title religion switching dataset
#' @description
#' Data frame containing the religious composition of cohorts after the “switching period” of a specific religion, for 201 countries, used in the MRC projection models.
#'
#' The switching period is the age range during which individuals in a cohort may change their religion. It is defined by the user in the MRC projection model. For example, if the switching period is defined as ages 15–30 for religion group A, the dataset shows the religious composition of the same cohort at ages 30–34 that had religion A at ages 10–14.
#'
#' The compositions were calculated in the MRC project based on survey data containing retrospective questions on religious affiliation.
#' \itemize{
#'  \item Country_code. Code of country [standard ISO 3166-1] (numeric)
#'  \item Religion. Name of religion before switching period (character)
#'  \item Sex. Name of sex [1=males, 2=females] (numeric)
#'  \item Christians. Share of Christians after switching period (numeric)
#'  \item Muslims. Share of Muslims after switching period (numeric)
#'  \item Unaffiliated. Share of Unaffiliated after switching period (numeric)
#'  \item Buddhists. Share of Buddhists after switching period (numeric)
#'  \item Hindus. Share of Hindus after switching period (numeric)
#'  \item Jews. Share of Jews after switching period (numeric)
#'  \item Other_Religions. Share of Other Religions after switching period (numeric)
#' }
#'
#' @family base_data
#' @docType data
#' @keywords datasets
#' @examples
#' head(base_data_list$data_switching)
#' @format Data frame with 2814 rows and 10 variables
#' @references Pew-CASPAR Measuring Religious Change Project
NULL
#' @name data_regions
#' @title Regions dataset
#' @description
#' Data frame containing the names and codes of geographic regions used in the MRC projection models. Each row defines one region to which countries can be assigned.
#' \itemize{
#'  \item Name. Full name of the region (character)
#'  \item Region. Short region code used internally as an identifier (character)
#' }
#'
#' @family base_data
#' @docType data
#' @keywords datasets
#' @examples
#' head(base_data_list[[11]])
#' @format Data frame with 6 rows and 2 variables
NULL
#' @name info_variants
#' @title Scenario variants settings dataset
#' @description
#' Data frame containing scenario variant settings that can be applied in the MRC projection models. Users can modify assumptions related to fertility and migration for each country without altering the input data.
#'
#' Fertility.
#' Users can adjust the level of the total fertility rate (TFR) for each country by specifying a multiplier of the input TFR in the column `percentage_fertility` (predefined level = 1).
#'
#' Optional bounds can be set for the modified TFR using:
#'   • `bottom_fertility_cap`: minimum allowed TFR (predefined = NA)
#'   • `upper_fertility_cap`: maximum allowed TFR  (predefined = NA)
#' If the adjusted TFR falls outside these limits, it is replaced with the nearest boundary value.
#'
#' A constant TFR change across the entire projection period can be applied by setting `flat_fertility` (predefined = 0). This will not change fertility profile.
#'
#' Users can also specify convergence of religion-specific TFRs toward the country-level TFR by setting the number of periods to full convergence in `convergence_steps` (predefined = 16, meaning convergence finishing in 2100).
#'
#' Migration.
#' Users can modify the level of out-migration rates for each country by specifying a multiplier of the input migration data in the column `percentage_migration` (predefined level = 1).
#' \itemize{
#'  \item Country. Name of country (character)
#'  \item Country_code. Code of country [standard ISO 3166-1] (numeric)
#'  \item Region_name. Name of the country region (character)
#'  \item percentage_fertility. Fraction by which the fertility should be modified (numeric)
#'  \item flat_fertility. Number by which the fertility should be modified (numeric)
#'  \item bottom_fertility_cap. Min value of modified fertility (numeric)
#'  \item upper_fertility_cap. Max value of modified fertility (numeric)
#'  \item percentage_migration. Fraction by which the migration should be modified (numeric)
#'  \item convergence_steps. Number of steps after which a full fertility convergence should be done (numeric) Numbers other than natural may lead to unexpected errors.
#'  \item fertility_factorization. Settings for equalising fertility after calculating fertility differentials. 1 equalise all age groups together, 2 equalise each age group separately. Using setting 1 may result in inconsistent ASFRs if fertility differentials are of different magnitude between age groups. (numeric)
#' }
#'
#' @family base_data
#' @docType data
#' @keywords datasets
#' @examples
#' head(base_data_list$info_variants)
#' @format Data frame with 201 rows and 10 variables
NULL
