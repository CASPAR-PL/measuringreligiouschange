# Smoke test — every combination of the seven binary flags resolves without error
# and can be exported via save_csv_all() and save_plots_all().
# 2^7 = 128 combinations; each runs a one-step, three-country projection.
# Skipped on CRAN due to runtime.

test_that("all 128 flag combinations complete and resolve", {
  skip_on_cran()

  combos <- expand.grid(
    no_diff = c(FALSE, TRUE),
    post_switch = c(FALSE, TRUE),
    light_migration = c(FALSE, TRUE),
    light_switching = c(FALSE, TRUE),
    switching_type = c(1L, 2L),
    switching = c(FALSE, TRUE),
    migration = c(FALSE, TRUE),
    stringsAsFactors = FALSE
  )

  for (i in seq_len(nrow(combos))) {
    cfg <- combos[i, ]
    label <- paste(
      sprintf("no_diff=%s", cfg$no_diff),
      sprintf("post_switch=%s", cfg$post_switch),
      sprintf("light_migration=%s", cfg$light_migration),
      sprintf("light_switching=%s", cfg$light_switching),
      sprintf("switching_type=%s", cfg$switching_type),
      sprintf("switching=%s", cfg$switching),
      sprintf("migration=%s", cfg$migration),
      sep = " | "
    )

    obj <- test_object_generator(
      paste0("combo_", i),
      no_diff         = cfg$no_diff,
      post_switch     = cfg$post_switch,
      migration       = cfg$migration,
      switching       = cfg$switching,
      switching_type  = as.integer(cfg$switching_type),
      light_migration = cfg$light_migration,
      light_switching = cfg$light_switching
    )

    expect_identical(obj$migration, cfg$migration, label = paste(label, "[migration flag]"))

    project(obj, progress_bar = FALSE, save_totals = FALSE)

    expect_true(obj$resolved, label = label)

    # ASFR and exposure must share religion columns; totals are weighted by name
    for (country in obj$country_object_list) {
      expect_identical(
        names(country$previous_asfr),
        names(country$previous_fertility_exposure),
        label = paste(label, "[asfr/exposure columns]", country$name)
      )
    }

    out_dir <- file.path(tempdir(), paste0("combo_", i))

    expect_equal(
      save_csv_all(obj,
        folder = out_dir, objects = list("countries"),
        progress_bar = FALSE
      ),
      "Done!",
      label = paste(label, "[save_csv_all]")
    )

    expect_no_error(
      save_plots_all(obj, folder = out_dir, progress_bar = FALSE),
      message = paste(label, "[save_plots_all]")
    )
  }
})
