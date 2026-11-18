# tests/testthat/test-steps.R
#
# Unit tests for the one-step demographic update (Tests A – G).
# Each test isolates one demographic process and verifies that numerical
# output matches the analytic formula implied by the model.
#
# Tests A – E and G run dem_proj_no_mig() directly on a single country
# (Poland, ISO 616) loaded from base_data_list, overriding only the fields
# under test.  Test F uses a two-country (Poland + UK) projection.

# ---------------------------------------------------------------------------
# File-level helpers
# ---------------------------------------------------------------------------

.make_obj <- function(label, codes = 616L,
                      migration = FALSE) {
  td <- base_data_list
  td[[10L]] <- base_data_list[[10L]][base_data_list[[10L]][[2L]] %in% codes, ]
  cl <- create_country_list(
    data_list           = td,
    post_switch         = FALSE,
    progress_bar        = FALSE,
    on_country_mismatch = "rescale"
  )
  variants_loader(create_projection_object(label, cl,
    steps          = 1L,
    migration      = migration,
    switching      = TRUE,
    switching_type = 1L,
    post_switch    = FALSE
  ))
}

# Run one no-migration step.  switching_type = 1 (split-mode) is the default.
.run <- function(co, switching = FALSE) {
  co$dem_proj_no_mig(
    switching       = switching,
    switching_type  = 1L,
    no_diff         = FALSE,
    post_switch     = FALSE,
    light_switching = FALSE
  )
}

# Religion column names (excludes the "Total" summary column in output tables)
.rel_cols <- function(co) colnames(co$structure_data[[1L]])

# ---------------------------------------------------------------------------
# A: no demographic processes
# ---------------------------------------------------------------------------

test_that("A: survival=1, fertility=0, switching=identity — exact cohort advance and total conservation", {
  skip_on_cran()

  obj <- .make_obj("step_A")
  co <- obj$country_object_list[[1L]]

  # 100 % survival everywhere
  co$mortality_rates <- matrix(1,
    nrow = nrow(co$mortality_rates),
    ncol = ncol(co$mortality_rates),
    dimnames = dimnames(co$mortality_rates)
  )
  # No births
  co$age_specific_fertility_rates[] <- 0

  # Identity switching: everyone stays in their own religion
  n_rel <- length(co$switching_matrices_list)
  for (i in seq_len(n_rel)) {
    m <- co$switching_matrices_list[[i]]
    m[] <- 0
    m[, i] <- 1
    co$switching_matrices_list[[i]] <- m
  }

  sd1 <- co$structure_data[[1L]]
  .run(co, switching = TRUE)
  sd2 <- co$structure_data[[2L]]

  # Male cohorts 0-4 … 85-89 each advance exactly one group
  expect_equal(sd2[2:19, ], sd1[1:18, ],
    tolerance = 1e-9, ignore_attr = TRUE,
    label = "males rows 2-19: each cohort advances one age group"
  )
  # Males: 90-94 and 95+ fold into a single open-ended 95+ group
  expect_equal(sd2[20, ], sd1[19, ] + sd1[20, ],
    tolerance = 1e-9, ignore_attr = TRUE,
    label = "males row 20: 90-94 + 95+ fold into 95+"
  )
  # Female cohorts advance identically
  expect_equal(sd2[22:39, ], sd1[21:38, ],
    tolerance = 1e-9, ignore_attr = TRUE,
    label = "females rows 22-39: each cohort advances one age group"
  )
  expect_equal(sd2[40, ], sd1[39, ] + sd1[40, ],
    tolerance = 1e-9, ignore_attr = TRUE,
    label = "females row 40: 90-94 + 95+ fold into 95+"
  )
  # Age 0-4 rows are zero (fertility = 0)
  expect_equal(sd2[1, ], rep(0, ncol(sd2)),
    tolerance = 1e-9, ignore_attr = TRUE,
    label = "male age 0-4 = 0 (no births)"
  )
  expect_equal(sd2[21, ], rep(0, ncol(sd2)),
    tolerance = 1e-9, ignore_attr = TRUE,
    label = "female age 0-4 = 0 (no births)"
  )
  # Total population is conserved
  expect_equal(sum(sd2), sum(sd1),
    tolerance = 1e-6, ignore_attr = TRUE,
    label = "total population conserved"
  )
})

# ---------------------------------------------------------------------------
# B: mortality only
# ---------------------------------------------------------------------------

test_that("B: survival=0.9, fertility=0 — Nx+5 = Nx * S and Dx = Nx * (1-S)", {
  skip_on_cran()

  S <- 0.9
  obj <- .make_obj("step_B")
  co <- obj$country_object_list[[1L]]

  co$mortality_rates <- matrix(S,
    nrow = nrow(co$mortality_rates),
    ncol = ncol(co$mortality_rates),
    dimnames = dimnames(co$mortality_rates)
  )
  co$age_specific_fertility_rates[] <- 0

  sd1 <- co$structure_data[[1L]]
  .run(co)
  sd2 <- co$structure_data[[2L]]

  # Nx+5 = Nx * S for non-top male cohorts
  expect_equal(sd2[2:19, ], sd1[1:18, ] * S,
    tolerance = 1e-9, ignore_attr = TRUE,
    label = "males rows 2-19: Nx+5 = Nx * S"
  )
  # Top male group: both top cohorts survive and merge
  expect_equal(sd2[20, ], (sd1[19, ] + sd1[20, ]) * S,
    tolerance = 1e-9, ignore_attr = TRUE,
    label = "males row 20: (N90-94 + N95+) * S"
  )
  # Same for females
  expect_equal(sd2[22:39, ], sd1[21:38, ] * S,
    tolerance = 1e-9, ignore_attr = TRUE,
    label = "females rows 22-39: Nx+5 = Nx * S"
  )
  expect_equal(sd2[40, ], (sd1[39, ] + sd1[40, ]) * S,
    tolerance = 1e-9, ignore_attr = TRUE,
    label = "females row 40: (N90-94 + N95+) * S"
  )
  # Deaths inferred from adjacent rows: Dx = Nx * (1 - S)
  expect_equal(sd1[1, ] - sd2[2, ], sd1[1, ] * (1 - S),
    tolerance = 1e-9, ignore_attr = TRUE,
    label = "male 0-4 cohort: deaths = N * (1-S)"
  )
  expect_equal(sd1[21, ] - sd2[22, ], sd1[21, ] * (1 - S),
    tolerance = 1e-9, ignore_attr = TRUE,
    label = "female 0-4 cohort: deaths = N * (1-S)"
  )
})

# ---------------------------------------------------------------------------
# C: fertility only
# ---------------------------------------------------------------------------

test_that("C: survival=1, constant ASFR, no differentials — births = exposure * rate; male+female = total", {
  skip_on_cran()

  r <- 0.05
  obj <- .make_obj("step_C")
  co <- obj$country_object_list[[1L]]

  co$mortality_rates <- matrix(1,
    nrow = nrow(co$mortality_rates),
    ncol = ncol(co$mortality_rates),
    dimnames = dimnames(co$mortality_rates)
  )
  co$age_specific_fertility_rates[] <- r

  # Uniform differentials (no religion-specific adjustment)
  for (i in seq_along(co$fertility_differentials)) {
    fd <- co$fertility_differentials[[i]]
    if (is.matrix(fd) && nrow(fd) > 0L) co$fertility_differentials[[i]][] <- 1
  }

  .run(co)
  sd2 <- co$structure_data[[2L]]

  male_births <- sd2[1L, ] # survived male newborns
  female_births <- sd2[21L, ] # survived female newborns

  # Births are positive (population is non-zero and rate > 0)
  expect_gt(sum(male_births), 0, label = "male births > 0")
  expect_gt(sum(female_births), 0, label = "female births > 0")

  # Total births in sd2 = sum over fertility exposure table * rate * newborn survival
  # (Structure == "switching first" when switching = FALSE)
  pfe <- co$previous_fertility_exposure[Structure == "switching first"]
  nb_surv <- mean(co$mortality_rates[c(1L, 22L), 1L]) # average newborn survival
  exp_total <- sum(pfe[["Total"]])
  expected_births <- exp_total * r * nb_surv

  expect_equal(sum(male_births) + sum(female_births), expected_births,
    tolerance = 1e-5, ignore_attr = TRUE,
    label = "total births = exposure * ASFR * newborn survival"
  )

  # Male / (male + female) births matches the sex ratio
  sex_r <- co$sex_ratio[[1L]]
  male_surv <- co$mortality_rates[1L, 1L]
  female_surv <- co$mortality_rates[22L, 1L]
  expected_male_fraction <- (sex_r * male_surv) /
    (sex_r * male_surv + (1 - sex_r) * female_surv)

  expect_equal(
    sum(male_births) / (sum(male_births) + sum(female_births)),
    expected_male_fraction,
    tolerance = 1e-6, ignore_attr = TRUE,
    label = "fraction of male births matches sex ratio after newborn mortality"
  )
})

# ---------------------------------------------------------------------------
# D: fertility differentials
# ---------------------------------------------------------------------------

test_that("D: fertility differentials — relative births proportional to differential; aggregate preserved", {
  skip_on_cran()

  d1 <- 1.5 # religion 1: 50 % higher fertility
  d2 <- 0.5 # religion 2: 50 % lower fertility
  r <- 0.05

  obj <- .make_obj("step_D")
  co <- obj$country_object_list[[1L]]

  co$mortality_rates <- matrix(1,
    nrow = nrow(co$mortality_rates),
    ncol = ncol(co$mortality_rates),
    dimnames = dimnames(co$mortality_rates)
  )
  co$age_specific_fertility_rates[] <- r

  # Override differentials: d1 for religion 1, d2 for religion 2, 1 elsewhere
  n_rel <- ncol(co$structure_data[[1L]])
  n_ages_f <- ncol(co$age_specific_fertility_rates)
  for (i in seq_along(co$fertility_differentials)) {
    fd <- matrix(1, nrow = n_ages_f, ncol = n_rel)
    fd[, 1] <- d1
    fd[, 2] <- d2
    co$fertility_differentials[[i]] <- fd
  }

  .run(co)

  pf <- co$previous_fertility[Structure == "switching first"]
  pfe <- co$previous_fertility_exposure[Structure == "switching first"]
  rel <- .rel_cols(co)

  births_1 <- sum(pf[[rel[1L]]])
  births_2 <- sum(pf[[rel[2L]]])
  exp_1 <- sum(pfe[[rel[1L]]])
  exp_2 <- sum(pfe[[rel[2L]]])

  # Relative births are proportional to (exposure × differential)
  expect_equal(births_1 / births_2, (exp_1 * d1) / (exp_2 * d2),
    tolerance = 1e-2, ignore_attr = TRUE,
    label = "births ratio = (exp1 * d1) / (exp2 * d2)"
  )

  # Aggregate births equal uniform-ASFR expectation (factorisation preserves total)
  total_births <- sum(pf[["Total"]])
  total_exp <- sum(pfe[["Total"]])
  expect_equal(total_births, total_exp * r,
    tolerance = 1e-5, ignore_attr = TRUE,
    label = "total births = total exposure * ASFR (aggregate preserved)"
  )
})

# ---------------------------------------------------------------------------
# E: switching only
# ---------------------------------------------------------------------------

test_that("E: switching S=[[0.9,0.1],[0.2,0.8]] — exact post-switch populations, total conserved", {
  skip_on_cran()

  obj <- .make_obj("step_E")
  co <- obj$country_object_list[[1L]]

  co$mortality_rates <- matrix(1,
    nrow = nrow(co$mortality_rates),
    ncol = ncol(co$mortality_rates),
    dimnames = dimnames(co$mortality_rates)
  )
  co$age_specific_fertility_rates[] <- 0

  # Zero out religions 3+ to test only religions 1 and 2
  n_rel <- ncol(co$structure_data[[1L]])
  co$structure_data[[1L]][, seq(3L, n_rel)] <- 0

  # Set switching matrices:
  #   Religion 1: 90 % stay, 10 % switch to religion 2
  #   Religion 2: 20 % switch to religion 1, 80 % stay
  #   Others:     identity (all stay in own religion)
  for (i in seq_len(n_rel)) {
    m <- co$switching_matrices_list[[i]]
    m[] <- 0
    m[, i] <- 1
    if (i == 1L) {
      m[, 1L] <- 0.9
      m[, 2L] <- 0.1
    }
    if (i == 2L) {
      m[, 1L] <- 0.2
      m[, 2L] <- 0.8
    }
    co$switching_matrices_list[[i]] <- m
  }

  sd1 <- co$structure_data[[1L]]
  .run(co, switching = TRUE)
  sd2 <- co$structure_data[[2L]]

  # Expected post-switch (after age-advance with S=1, then switching applied)
  # Age-advance with S=1: pam[2:19] = sd1[1:18], pam[20] = sd1[19]+sd1[20], etc.
  pam <- matrix(0, nrow(sd1), ncol(sd1), dimnames = dimnames(sd1))
  pam[2:19, ] <- sd1[1:18, ]
  pam[20, ] <- sd1[19, ] + sd1[20, ]
  pam[22:39, ] <- sd1[21:38, ]
  pam[40, ] <- sd1[39, ] + sd1[40, ]

  # With switching_type = 1 (split), switching is applied to each half separately
  # but is a linear operation; with identity survival and zero fertility the
  # combined result equals switch(pam).
  test_rows <- c(2:20, 22:40) # exclude age-0 rows (births = 0)
  exp_rel1 <- 0.9 * pam[test_rows, 1L] + 0.2 * pam[test_rows, 2L]
  exp_rel2 <- 0.1 * pam[test_rows, 1L] + 0.8 * pam[test_rows, 2L]

  expect_equal(sd2[test_rows, 1L], exp_rel1,
    tolerance = 1e-9, ignore_attr = TRUE,
    label = "religion 1 post-switch: 0.9*N1 + 0.2*N2"
  )
  expect_equal(sd2[test_rows, 2L], exp_rel2,
    tolerance = 1e-9, ignore_attr = TRUE,
    label = "religion 2 post-switch: 0.1*N1 + 0.8*N2"
  )

  # Total population is conserved through switching
  expect_equal(sum(sd2), sum(sd1),
    tolerance = 1e-6, ignore_attr = TRUE,
    label = "total population conserved through switching"
  )
})

# ---------------------------------------------------------------------------
# F: migration only between two countries
# ---------------------------------------------------------------------------

test_that("F: migration Poland -> UK — emigration from A equals immigration to B", {
  skip_on_cran()

  obj <- .make_obj("step_F",
    codes = c(616L, 826L),
    migration = TRUE
  )

  # Survival = 1, no fertility — migration is the only active process
  for (co in obj$country_object_list) {
    co$mortality_rates <- matrix(1,
      nrow = nrow(co$mortality_rates),
      ncol = ncol(co$mortality_rates),
      dimnames = dimnames(co$mortality_rates)
    )
    co$age_specific_fertility_rates[] <- 0
  }

  project(obj, progress_bar = FALSE, save_totals = FALSE)

  # Locate country objects by code
  codes_all <- vapply(obj$country_object_list, function(x) x$code, 0.0)
  co_pl <- obj$country_object_list[[which(codes_all == 616)]]
  co_uk <- obj$country_object_list[[which(codes_all == 826)]]

  rel <- .rel_cols(co_pl)

  # Poland destination_processed emigration directed at UK (code "826")
  em_pl <- co_pl$previous_emigration[
    Structure == "destination_processed" & Destination == "826"
  ]
  # UK destination_processed immigration arriving from Poland (code "616")
  im_uk <- co_uk$previous_immigration[
    Structure == "destination_processed" & Origin == "616"
  ]

  skip_if(
    nrow(em_pl) == 0L || nrow(im_uk) == 0L,
    "No Poland -> UK migration flow in this data subset"
  )

  # Both sides record the same emigrant population — column sums must match
  expect_equal(colSums(em_pl[, rel, with = FALSE]),
    colSums(im_uk[, rel, with = FALSE]),
    tolerance = 1e-6, ignore_attr = TRUE,
    label = "emigration from Poland equals immigration to UK by religion"
  )
  expect_equal(sum(em_pl[, rel, with = FALSE]),
    sum(im_uk[, rel, with = FALSE]),
    tolerance = 1e-6, ignore_attr = TRUE,
    label = "total emigration from Poland equals total immigration to UK"
  )
})

# ---------------------------------------------------------------------------
# G: full accounting identity
# ---------------------------------------------------------------------------

test_that("G: accounting identity — survived + births = S * initial + births for every sex", {
  skip_on_cran()

  S <- 0.85
  r <- 0.04

  obj <- .make_obj("step_G")
  co <- obj$country_object_list[[1L]]

  co$mortality_rates <- matrix(S,
    nrow = nrow(co$mortality_rates),
    ncol = ncol(co$mortality_rates),
    dimnames = dimnames(co$mortality_rates)
  )
  co$age_specific_fertility_rates[] <- r
  for (i in seq_along(co$fertility_differentials)) {
    fd <- co$fertility_differentials[[i]]
    if (is.matrix(fd) && nrow(fd) > 0L) co$fertility_differentials[[i]][] <- 1
  }

  sd1 <- co$structure_data[[1L]]
  .run(co)
  sd2 <- co$structure_data[[2L]]

  births_sd2 <- sum(sd2[c(1L, 21L), ]) # survived newborns in age 0-4 rows
  survived <- sum(sd2) - births_sd2 # everyone else = aged + survived cohorts

  # Full accounting: total = survived aged cohorts + births
  # With uniform S, all cohorts survive at rate S, so survived = S * initial
  expect_equal(survived, S * sum(sd1),
    tolerance = 1e-5, ignore_attr = TRUE,
    label = "survived population = S * initial (uniform survival)"
  )
  expect_equal(sum(sd2), S * sum(sd1) + births_sd2,
    tolerance = 1e-5, ignore_attr = TRUE,
    label = "sd2 = S * sd1 + births (full accounting balance)"
  )

  # Sex-level accounting
  survived_m <- sum(sd2[2:20, ])
  survived_f <- sum(sd2[22:40, ])
  expect_equal(survived_m, S * sum(sd1[1:20, ]),
    tolerance = 1e-5, ignore_attr = TRUE,
    label = "male survivors = S * initial male population"
  )
  expect_equal(survived_f, S * sum(sd1[21:40, ]),
    tolerance = 1e-5, ignore_attr = TRUE,
    label = "female survivors = S * initial female population"
  )

  # Births must be positive (rate > 0)
  expect_gt(births_sd2, 0, label = "births are positive with r > 0")

  # For every country, the religion-level row sums in sd2 are non-negative
  expect_true(all(sd2 >= 0), label = "no negative population values")
})
