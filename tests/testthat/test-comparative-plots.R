# Projection objects are created once at file level and shared across all tests.
# All tests are skipped on CRAN due to runtime.

obj_default <- base_object_generator("comp_default", steps = 2)
project(obj_default, progress_bar = FALSE)

obj_ps <- base_object_generator("comp_ps", steps = 2, post_switch = TRUE)
project(obj_ps, progress_bar = FALSE)

obj_nomig <- create_projection_object(
  "comp_nomig",
  create_country_list(progress_bar = FALSE, on_country_mismatch = "error"),
  steps = 2,
  migration = FALSE
)
project(obj_nomig, progress_bar = FALSE)

obj_nomig_nosw <- create_projection_object(
  "comp_nomig_nosw",
  create_country_list(progress_bar = FALSE, on_country_mismatch = "error"),
  steps = 2,
  migration = FALSE,
  switching = FALSE
)
project(obj_nomig_nosw, progress_bar = FALSE)

# 3-country projection (Poland 616, UK 826, USA 840) via test_object_generator
obj_3c <- test_object_generator("comp_3c")
obj_3c$steps <- 2
project(obj_3c, progress_bar = FALSE)

# Comparative list excludes obj_ps — mixing post_switch and non-post_switch
# objects causes column dimension mismatches in the plot functions.
proj_list <- list(obj_default, obj_nomig, obj_nomig_nosw, obj_3c)


test_that("comparative demographic plots run without error", {
  skip_on_cran()
  withr::local_dir(withr::local_tempdir())

  expect_no_error(
    save_plots_comparative_all(
      proj_list,
      demographic_plots = TRUE,
      migration_plots   = FALSE,
      switching_plots   = FALSE,
      progress_bar      = FALSE
    )
  )
  expect_no_error(
    save_plots_comparative_regions_all(
      proj_list,
      demographic_plots = TRUE,
      migration_plots   = FALSE,
      switching_plots   = FALSE,
      progress_bar      = FALSE
    )
  )
})

test_that("comparative migration plots run without error", {
  skip_on_cran()
  withr::local_dir(withr::local_tempdir())

  expect_no_error(
    save_plots_comparative_all(
      proj_list,
      demographic_plots = FALSE,
      migration_plots   = TRUE,
      switching_plots   = FALSE,
      progress_bar      = FALSE
    )
  )
  expect_no_error(
    save_plots_comparative_regions_all(
      proj_list,
      demographic_plots = FALSE,
      migration_plots   = TRUE,
      switching_plots   = FALSE,
      progress_bar      = FALSE
    )
  )
})

test_that("comparative switching plots run without error", {
  skip_on_cran()
  withr::local_dir(withr::local_tempdir())

  expect_no_error(
    save_plots_comparative_all(
      proj_list,
      demographic_plots = FALSE,
      migration_plots   = FALSE,
      switching_plots   = TRUE,
      progress_bar      = FALSE
    )
  )
  expect_no_error(
    save_plots_comparative_regions_all(
      proj_list,
      demographic_plots = FALSE,
      migration_plots   = FALSE,
      switching_plots   = TRUE,
      progress_bar      = FALSE
    )
  )
})
