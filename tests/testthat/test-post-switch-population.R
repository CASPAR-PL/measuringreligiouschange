# Two one-step projections — one with post_switch on, one off — built with
# test_object_generator (Poland 616, United Kingdom 826, United States 840).
# Tests are skipped on CRAN due to runtime.

obj_normal <- test_object_generator(
  "ps_test_normal",
  post_switch = FALSE,
  migration   = FALSE
)

obj_ps <- test_object_generator(
  "ps_test_ps",
  post_switch = TRUE,
  migration   = FALSE
)

project(obj_normal, progress_bar = FALSE, save_totals = FALSE)
project(obj_ps, progress_bar = FALSE, save_totals = FALSE)

# ---------------------------------------------------------------------------

test_that("post_switch and non-post_switch yield identical row totals after one step", {
  skip_on_cran()

  country_keys <- names(obj_normal$country_object_list)

  for (key in country_keys) {
    sd_normal <- obj_normal$country_object_list[[key]]$structure_data[[2]]
    sd_ps <- obj_ps$country_object_list[[key]]$structure_data[[2]]

    # post_switch matrix has 2n columns; rowSums must still equal the n-column case
    expect_equal(
      rowSums(sd_normal),
      rowSums(sd_ps),
      tolerance = 1e-6,
      label = paste("rowSums mismatch for country", key)
    )
  }
})

test_that("post_switch matrix has exactly twice as many columns as non-post_switch", {
  skip_on_cran()

  country_keys <- names(obj_normal$country_object_list)

  for (key in country_keys) {
    sd_normal <- obj_normal$country_object_list[[key]]$structure_data[[2]]
    sd_ps <- obj_ps$country_object_list[[key]]$structure_data[[2]]

    expect_equal(
      ncol(sd_ps),
      2L * ncol(sd_normal),
      label = paste("column count for country", key)
    )
  }
})
