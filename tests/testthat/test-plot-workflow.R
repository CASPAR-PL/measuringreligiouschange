test_that("base_object_generator creates projection without error", {
  expect_no_error(base_object_generator("test", steps = 1))
})

test_that("ASFR plot (variant 6) titles with the selected period and rejects out-of-range periods", {
  asfr <- data.table::data.table(
    Country = "Testland", Country_code = 1L,
    Period = rep(c("2020-2025", "2025-2030"), each = 3),
    Mother_age_group = rep(c("15-19", "20-24", "TFR"), 2),
    Structure = "total", Region = "Test",
    Total = c(0.1, 0.2, 1.5, 0.1, 0.2, 1.4),
    Christians = c(0.1, 0.3, 2.0, 0.1, 0.3, 1.9)
  )
  plot_asfr <- function(period) {
    mrc_plot(
      variant = 6, df = asfr, df_e = 0, df_i = 0, name = "Testland",
      period = period, show_post_switch = FALSE,
      plot_colors = "blue3", plot_switching_colors = "blue3",
      regions = FALSE, light_mig = FALSE, light_sw = FALSE, post_switch = FALSE
    )
  }

  p <- plot_asfr(2)
  expect_equal(p$labels$title, "ASFR by religion in Testland in 2025-2030")
  expect_equal(nrow(p$data), 4)
  expect_error(plot_asfr(3), "between 1 and 2")
  expect_error(plot_asfr(0), "between 1 and 2")
})

test_that("save_plots_all runs without error", {
  skip_on_cran()
  withr::local_dir(withr::local_tempdir())

  obj <- base_object_generator("test", steps = 1)
  project(obj, progress_bar = FALSE)
  expect_no_error(save_plots_all(obj, migration_plots = TRUE, progress_bar = FALSE))
})

test_that("save_plots_regions_all runs without error", {
  skip_on_cran()
  withr::local_dir(withr::local_tempdir())

  obj <- base_object_generator("test", steps = 1)
  project(obj, progress_bar = FALSE)
  expect_no_error(save_plots_regions_all(obj, migration_plots = TRUE, progress_bar = FALSE))
})

test_that("post-switch save_plots_all runs without error", {
  skip_on_cran()
  withr::local_dir(withr::local_tempdir())

  obj_ps <- base_object_generator("test_ps", steps = 1, post_switch = TRUE)
  project(obj_ps, progress_bar = FALSE)
  expect_no_error(save_plots_all(obj_ps, migration_plots = TRUE, progress_bar = FALSE))
})

test_that("post-switch save_plots_regions_all runs without error", {
  skip_on_cran()
  withr::local_dir(withr::local_tempdir())

  obj_ps <- base_object_generator("test_ps", steps = 1, post_switch = TRUE)
  project(obj_ps, progress_bar = FALSE)
  expect_no_error(save_plots_regions_all(obj_ps, migration_plots = TRUE, progress_bar = FALSE))
})
