# Conducting an MRC Projection

This vignette walks through the full workflow for creating and running
an MRC projection using the package’s exported API.

- For saving plots: [Visualising MRC Projection
  Results](https://caspar-pl.github.io/measuringreligiouschange/articles/visualising-projections.md)
- For exporting to CSV: [Exporting Projection
  Results](https://caspar-pl.github.io/measuringreligiouschange/articles/exporting-results.md)
- For internal architecture: [Inner
  Workings](https://caspar-pl.github.io/measuringreligiouschange/articles/inner-workings.md)

------------------------------------------------------------------------

## 1 Create a country list — `create_country_list()`

[`create_country_list()`](https://caspar-pl.github.io/measuringreligiouschange/reference/create_country_list.md)
loads and prepares all input data for every country. It must be called
separately for each projection object you intend to run — two
projections cannot share the same country list.

``` r

library(measuringreligiouschange)

cl <- create_country_list(
  post_switch = FALSE, # controls switching mechanics and output structure.
  # FALSE = individuals who have switched religion remain
  #   in the general population and may switch again in
  #   subsequent steps. Switchers are merged into the
  #   destination religion's main output column. This is
  #   the convention used in the MRC report.
  # TRUE  = individuals who have switched are moved into
  #   separate post-switch columns (e.g. "Christians_post_switch")
  #   and are excluded from further switching, allowing
  #   you to distinguish converts from those born into a
  #   religion.
  # Must match post_switch in create_projection_object().
  progress_bar = FALSE # suppress the per-country loading bar (default TRUE)
)
```

------------------------------------------------------------------------

## 2 Assemble a projection — `create_projection_object()` + `variants_loader()`

[`create_projection_object()`](https://caspar-pl.github.io/measuringreligiouschange/reference/create_projection_object.md)
assembles all projection settings into an object.

[`variants_loader()`](https://caspar-pl.github.io/measuringreligiouschange/reference/variants_loader.md)
checks that the country list and projection settings are mutually
consistent (in particular that their `post_switch` flags match) and
prints a summary of the active settings before returning the validated
object. It must be called before
[`project()`](https://caspar-pl.github.io/measuringreligiouschange/reference/project.md).

``` r

obj <- variants_loader(create_projection_object(
  "my_projection", # unique name; also used as the default output folder name

  cl, # country list created with create_country_list()
  steps = 11L, # number of 5-year periods to project
  # (11 steps covers 2020–2075 with a 2020 base year)

  migration = TRUE, # include migration flows (emigration and immigration)

  switching = TRUE, # include religious switching
  switching_type = 1L, # switching sequence:
  #   1 = switching before mortality in each half-step
  #   2 = mortality before switching

  light_migration = TRUE, # **recommended** — store migration flows as period
  # totals rather than full age–sex breakdowns.
  # Full breakdowns increase output size by ~10× and
  # are rarely needed for a full 11-step projection.

  light_switching = TRUE, # **recommended** — store switching flows as period
  # totals for the same reason.

  no_diff = FALSE, # FALSE = use religion-specific fertility differentials
  # TRUE  = all religions share the same aggregate ASFR

  post_switch = FALSE # used in the MRC report; recommended when only the
  # current religious affiliation (not origin) is needed.
  # Must match the post_switch setting of the country list.
))
```

Each projection requires its **own** country list. To run a second
scenario (e.g. with `no_diff = TRUE`), call
[`create_country_list()`](https://caspar-pl.github.io/measuringreligiouschange/reference/create_country_list.md)
again before creating the second projection object.

``` r

cl2 <- create_country_list(post_switch = FALSE, progress_bar = FALSE)

obj2 <- variants_loader(create_projection_object(
  "nodiff", cl2,
  steps = 11L, migration = TRUE,
  switching = TRUE, switching_type = 1L,
  light_migration = TRUE, light_switching = TRUE,
  no_diff = TRUE, # uniform fertility — no religion-specific differentials
  post_switch = FALSE
))
```

------------------------------------------------------------------------

## 3 Run the projection — `project()`

``` r

project(
  obj,
  progress_bar = FALSE, # suppress the step-level ETA bar (default TRUE)
  save_totals = TRUE # compute region and global aggregates after projection
  # (required for save_plots_regions_all(); default TRUE)
)
```

Running with `save_totals = TRUE` (the default) adds a second pass that
aggregates country results to the seven world regions and the global
level. Set it to `FALSE` only when region- or global-level output is not
needed, as this substantially reduces runtime.

------------------------------------------------------------------------

## 4 Convenience helpers

### `base_object_generator()`

Creates a ready-to-project object for all 201 countries with 10 steps
(by default) and the standard demographic settings.

``` r

obj_full <- base_object_generator(
  "SC1", # projection name
  steps           = 11L,
  light_migration = TRUE, # recommended
  light_switching = TRUE, # recommended
  post_switch     = FALSE # used in the MRC report
)
project(obj_full, progress_bar = TRUE)
```

### `test_object_generator()`

Creates a one-step, three-country (Poland 616, United Kingdom 826,
United States 840) projection with `on_country_mismatch = "ignore"`,
intended for testing and development.

``` r

obj_test <- test_object_generator(
  "my_test",
  migration       = TRUE,
  switching       = TRUE,
  switching_type  = 1L,
  light_migration = TRUE,
  light_switching = TRUE,
  no_diff         = FALSE,
  post_switch     = FALSE,
  progress_bar    = FALSE
)
project(obj_test, progress_bar = FALSE, save_totals = FALSE)
```
