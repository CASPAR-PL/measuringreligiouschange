# Regression test — runs a one-step (2020-2025) projection for all 201 countries
# and compares it with the first step of the archived 06MAY2026/SC1 run.
#
# The baseline (testdata/may2026_step1.rds) holds the 2020-2025 rows of the May
# output, already harmonised to the current format (Period column, Sex as 1/2,
# Mother_age_group, ASFR structure "average" renamed to "total", no
# *_post_switch columns). For ASFR only the Total column (realised births /
# exposure) is stored.
#
# All 201 countries are needed because migration links them; a reduced country
# set cannot reproduce the May results. Skipped on CRAN due to runtime.

skip_on_cran()

RELIGIONS <- c(
  "Christians", "Muslims", "Unaffiliated", "Buddhists",
  "Hindus", "Jews", "Other_Religions"
)
TOLERANCE <- 1e-6

baseline <- readRDS(testthat::test_path("testdata", "may2026_step1.rds"))

# ---------------------------------------------------------------------------
# Run the fresh one-step projection once at file level and save to temp dir
# ---------------------------------------------------------------------------

fresh_obj <- base_object_generator("regression_may2026", steps = 1)
project(fresh_obj, progress_bar = FALSE, save_totals = TRUE)

fresh_dir <- file.path(tempdir(), "regression_may2026")
dir.create(fresh_dir, showWarnings = FALSE)
save_csv_all(fresh_obj, folder = fresh_dir, progress_bar = FALSE)

load_fresh <- function(filename) {
  data.table::fread(file.path(fresh_dir, filename))
}

# ---------------------------------------------------------------------------
# Helper: match rows on `keys` and compare value columns (religions by default)
# ---------------------------------------------------------------------------

expect_matches_may <- function(fresh, may, keys, label, cols = RELIGIONS) {
  merged <- merge(
    may[, c(keys, cols), with = FALSE],
    fresh[, c(keys, cols), with = FALSE],
    by = keys, all.x = TRUE, suffixes = c(".may", ".fresh")
  )
  may_vals <- as.matrix(merged[, paste0(cols, ".may"), with = FALSE])
  fresh_vals <- as.matrix(merged[, paste0(cols, ".fresh"), with = FALSE])

  expect_equal(sum(!stats::complete.cases(fresh_vals)), 0L,
    label = paste(label, "- baseline rows missing from fresh output")
  )
  rel_diff <- abs(fresh_vals - may_vals) / pmax(1, abs(may_vals))
  expect_lt(max(rel_diff, na.rm = TRUE), TOLERANCE,
    label = paste(label, "- max relative difference")
  )
}

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

test_that("regression (May 2026, step 1): population structure", {
  expect_matches_may(
    load_fresh("projection_structure_data.csv"), baseline$structure,
    keys = c("Country_code", "Year", "Sex", "Age_group"),
    label = "structure"
  )
})

test_that("regression (May 2026, step 1): deaths", {
  expect_matches_may(
    load_fresh("projection_deaths_data.csv"), baseline$deaths,
    keys = c("Country_code", "Period", "Sex", "Age_group", "Structure"),
    label = "deaths"
  )
})

test_that("regression (May 2026, step 1): births", {
  expect_matches_may(
    load_fresh("projection_births_data.csv"), baseline$births,
    keys = c("Country_code", "Period", "Mother_age_group", "Structure"),
    label = "births"
  )
})

# The May migration and switchers files have no Structure column; they
# correspond to the "total" structure of the current output.
test_that("regression (May 2026, step 1): emigration", {
  fresh <- load_fresh("projection_emigration_data.csv")[Structure == "total"]
  expect_matches_may(fresh, baseline$emigration,
    keys = c("Country_code", "Period", "Destination"),
    label = "emigration"
  )
})

test_that("regression (May 2026, step 1): immigration", {
  fresh <- load_fresh("projection_immigration_data.csv")[Structure == "total"]
  expect_matches_may(fresh, baseline$immigration,
    keys = c("Country_code", "Period", "Origin"),
    label = "immigration"
  )
})

test_that("regression (May 2026, step 1): switchers", {
  fresh <- load_fresh("projection_switchers_data.csv")[Structure == "total"]
  expect_matches_may(fresh, baseline$switchers,
    keys = c("Country_code", "Period", "Origin_religion"),
    label = "switchers"
  )
})

# Total ASFR must be the realised rate (births / exposure), incl. TFR rows
test_that("regression (May 2026, step 1): total ASFR", {
  expect_matches_may(
    load_fresh("projection_asfr_data.csv"), baseline$asfr,
    keys = c("Country_code", "Period", "Mother_age_group", "Structure"),
    label = "total ASFR", cols = "Total"
  )
})

test_that("regression (May 2026, step 1): region total ASFR", {
  expect_matches_may(
    load_fresh("regions_projection_asfr_data.csv"), baseline$regions_asfr,
    keys = c("Country", "Period", "Mother_age_group", "Structure"),
    label = "region total ASFR", cols = "Total"
  )
})

test_that("regression (May 2026, step 1): region structure", {
  expect_matches_may(
    load_fresh("regions_projection_structure_data.csv"), baseline$regions_structure,
    keys = c("Country", "Year", "Sex", "Age_group"),
    label = "region structure"
  )
})
