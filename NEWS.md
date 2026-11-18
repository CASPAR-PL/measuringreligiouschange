# measuringreligiouschange 1.0.2 (2026-11-13)

## BREAKING CHANGES

* `create_projection_object()` and `Projection_object` now take a single
  `migration` flag instead of separate `emigration` and `immigration` flags.
  Only `emigration` was ever read internally, so the two always acted as one switch.
* `light_migration` and `light_switching` now default to `TRUE` everywhere,
  including `test_object_generator()`. This matches the existing defaults of
  `create_projection_object()` and `base_object_generator()`. Migration and
  switching output is therefore stored in abbreviated form unless
  `light_migration = FALSE` / `light_switching = FALSE` is set explicitly.
* `base_object_generator()` and `create_projection_object()` now default to
  `steps = 10` instead of `steps = 11`, so default projections end in 2070
  instead of 2075. Set `steps = 11` explicitly to reproduce earlier results.

## BUG FIXES

* Fixed `project()` failing with `no_diff = TRUE` because ASFR output lacked
  religion column names.
* The `Total` column of the ASFR output now reports the realised rate (births /
  exposure) instead of the input ASFR. Under combined fertility factorization
  the two differ, so `Total` previously did not match the saved births.
* Realised ASFRs (`Total` and all religion columns of the `"total"` structure)
  are now 0 where exposure is 0, instead of the unweighted mean of the
  structure rates. `*_post_switch` columns keep the mean of the applied rates,
  and religion columns of individual structures still report the applied rate.
  ASFR output again matches the May 2026 projection exactly.
* Fixed R CMD check "no visible binding for global variable" notes: `.data` is
  now imported from ggplot2, plotting code uses `.data$` for column names in
  `aes()`, and `fold_asfr` uses `data.table::set()` instead of `:=` for
  `Mother_age_group`.

## DOCUMENTATION

* Documented the ASFR output convention for `previous_asfr`: `Total` is the
  realised rate (births / exposure), religion columns of individual structures
  hold the applied rates, and realised rates are 0 where exposure is 0.
* Documented that `combined_fertility_factorization` defaults to `TRUE`
  (field docs and the inner-workings vignette).
* Updated docs, examples and vignettes for the single `migration` flag, the new
  `light_migration` / `light_switching` defaults and the new default number of
  projection steps.
* Examples now use named arguments (e.g.
  `project(projection_object = obj)`, `test_object_generator(object_name = ...)`).
* Dataset docs: `Sex` is described as numeric (1 = males, 2 = females) and
  `data_population` as 201 rows.
* Corrected the `flat_fertility` description, the `outmigration_rates` column
  description, the `Projection_object` class description and the region field
  descriptions (with examples).
* Updated the package description (CASPAR, Pew-Templeton Global Religious
  Futures project) and spelled "Pew" consistently.
* Visualising-projections vignette: swapped emigration/immigration figures fixed,
  retention-by-sex figure added, and figures regenerated.
* README: the introduction now matches the package description, and the
  examples were rewritten to show a full projection (step by step and with
  `base_object_generator()`), exporting results, and a quick run with
  `test_object_generator()`.

# measuringreligiouschange 1.0.1 (2026-11-09)

## BUG FIXES

* Enabled combined fertility factorization by default
* Changed data used in testing to match Pew report
* Fixed issue causing age group 0 to have incorrect mortality saved
* Fixed save_csv_all argument ordering


# measuringreligiouschange 1.0.0

* Initial CRAN submission.
