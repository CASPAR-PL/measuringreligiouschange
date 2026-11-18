# Regression test: the age-0 (newborn) mortality patch in fertility_step must
# only update rows of the current period. Previously it lacked a Period filter,
# so every step overwrote the age-0 rows of all earlier periods with the latest
# period's values.

.make_two_step_obj <- function(label) {
  td <- base_data_list
  td[[10L]] <- base_data_list[[10L]][base_data_list[[10L]][[2L]] %in% 616L, ]
  cl <- create_country_list(
    data_list           = td,
    post_switch         = FALSE,
    progress_bar        = FALSE,
    on_country_mismatch = "rescale"
  )
  variants_loader(create_projection_object(label, cl,
    steps          = 2L,
    migration      = FALSE,
    switching      = TRUE,
    switching_type = 1L,
    post_switch    = FALSE
  ))
}

test_that("newborn deaths are stored per period and not overwritten by later steps", {
  skip_on_cran()

  obj <- .make_two_step_obj("newborn_mortality_test")
  project(obj, progress_bar = FALSE, save_totals = FALSE)
  co <- obj$country_object_list[[1]]

  pm <- co$previous_mortality
  pf <- co$previous_fertility
  rel_cols <- colnames(co$structure_data[[1]])
  periods <- unique(pf$Period)
  expect_length(periods, 2L)

  structures <- setdiff(unique(pf$Structure), "total")
  expect_true(length(structures) > 0L)

  for (s in structures) {
    for (p_idx in seq_along(periods)) {
      p <- periods[p_idx]
      births <- sum(as.matrix(pf[Period == p & Structure == s, rel_cols, with = FALSE]))
      boys <- co$sex_ratio[p_idx]
      expected <- unname(c(
        births * boys * (1 - co$mortality_rates[1, p_idx]),
        births * (1 - boys) * (1 - co$mortality_rates[22, p_idx])
      ))
      observed <- c(
        sum(as.matrix(pm[Period == p & Structure == s & Sex == 1L & Age_group == "0", rel_cols, with = FALSE])),
        sum(as.matrix(pm[Period == p & Structure == s & Sex == 2L & Age_group == "0", rel_cols, with = FALSE]))
      )
      expect_equal(observed, expected,
        tolerance = 1e-8,
        label = paste("age-0 deaths, structure", s, "period", p)
      )
    }
  }
})
