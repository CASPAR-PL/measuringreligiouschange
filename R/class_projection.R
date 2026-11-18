#' @include class_migration.R

#' @name Country_object
Country_object$methods(
  #' @name Country_object$dem_proj_no_mig
  #' @title Calculating projection without migration
  #' @description
  #' Function for projection without migration
  #' @param switching Logical; if TRUE, religious switching is included in the projection (no default)
  #' @param switching_type Numeric; sequence of switching relative to demographic processes — 1 for split pre/post, 2 for pre-demographic only (no default)
  #' @param no_diff Logical; if TRUE, fertility differentials by religion are ignored (no default)
  #' @param post_switch Logical; if TRUE, post-switch populations are stored in separate columns (no default)
  #' @param light_switching Logical; if TRUE, switching output is stored in abbreviated form (no default)
  #' @return Called for its side effects. Advances the projection by one 5-year step, updating `structure_data`, `year`, and all `previous_*` output fields.
  #' @noRd
  dem_proj_no_mig = function(switching = TRUE, switching_type = 1, no_diff = FALSE, post_switch, light_switching = TRUE) {
    # Adding new structure to structure_data

    add_next_structure()

    # Calculating projection

    if (switching) {
      # Choosing correct switching type

      if (switching_type == 1) {
        # Dividing population in two

        temp[["switching second"]] <<- structure_data[[length(structure_data)]] / 2
        structure_data[[length(structure_data)]] <<- structure_data[[length(structure_data)]] / 2

        # Applying switching, mortality and fertility to the first half of the population

        switching_step(post_switch = post_switch, light_switching = light_switching)
        mortality_step()
        fertility_step(no_diff = no_diff, post_switch = post_switch)

        # Applying mortality, fertility and switching to the second half of the population

        mortality_step(target = "switching second")
        fertility_step(target = "switching second", no_diff = no_diff, post_switch = post_switch)
        switching_step(target = "switching second", post_switch = post_switch, light_switching)

        # Joining two halves of the population

        structure_data[[length(structure_data)]] <<- structure_data[[length(structure_data)]] + temp[["switching second"]]
      } else {
        # Calculating switching, mortality and fertility in the whole population at once

        switching_step(post_switch = post_switch, light_switching = light_switching)
        mortality_step()
        fertility_step(no_diff = no_diff, post_switch = post_switch)
      }
    } else {
      # Calculating mortality and fertility

      mortality_step()
      fertility_step(no_diff = no_diff, post_switch = post_switch)
    }
    # Calculating "previous_" data

    calculate_total_previous(switching, FALSE)

    # Adjusting current year in the projection

    year <<- year + 5
    names(structure_data)[[length(structure_data)]] <<- as.character(year)
  },

  #' @name Country_object$dem_proj_migration
  #' @title Calculating projection with migration
  #' @description
  #' Function for projection without migration
  #' @param step Numeric; which projection step (period index) to calculate (no default)
  #' @param switching Logical; if TRUE, religious switching is included in this step (no default)
  #' @param switching_type Numeric; sequence of switching relative to demographic processes — 1 for split pre/post, 2 for pre-demographic only (no default)
  #' @param no_diff Logical; if TRUE, fertility differentials by religion are ignored (no default)
  #' @param post_switch Logical; if TRUE, post-switch populations are stored in separate columns (no default)
  #' @param light_migration Logical; if TRUE, migration output is stored in abbreviated form (no default)
  #' @param light_switching Logical; if TRUE, switching output is stored in abbreviated form (no default)
  #' @return Called for its side effects. Executes one sub-step of a migration-enabled projection, updating `structure_data`, emigration/immigration buffers, `year`, and all `previous_*` output fields.
  #' @noRd

  dem_proj_migration = function(step, switching = TRUE, switching_type = 1, no_diff = FALSE, post_switch, light_migration = TRUE, light_switching = TRUE) {
    if (step == 1) {
      # Adding new structure to structure_data

      add_next_structure()

      # Separating migrants by origin and destination processed and dividing them by destination

      separate_migrants(post_switch)
      destination_processed_migrants(light_migration)
    }
    if (step == 2) {
      if (switching) {
        if (switching_type == 1) {
          # Dividing population in two

          temp[["switching second"]] <<- structure_data[[length(structure_data)]] / 2
          structure_data[[length(structure_data)]] <<- structure_data[[length(structure_data)]] / 2

          # Applying switching, mortality and fertility to the first half of the population

          switching_step(post_switch = post_switch, light_switching = light_switching)
          mortality_step()
          fertility_step(no_diff = no_diff, post_switch = post_switch)

          # Applying mortality, fertility and switching to the second half of the population

          mortality_step(target = "switching second")
          fertility_step(target = "switching second", no_diff = no_diff, post_switch)
          switching_step(target = "switching second", post_switch = post_switch, light_switching)

          # Joining two halves of the population

          structure_data[[length(structure_data)]] <<- structure_data[[length(structure_data)]] + temp[["switching second"]]
        } else {
          # Applying switching, mortality and fertility to the whole population at once

          switching_step(post_switch = post_switch, light_switching = light_switching)
          mortality_step()
          fertility_step(no_diff = no_diff, post_switch = post_switch)
        }
      } else {
        # Applying mortality and fertility

        mortality_step()
        fertility_step(no_diff = no_diff, post_switch = post_switch)
      }

      # Calculating projection in migrant population

      origin_processed_migrants(switching, switching_type, no_diff, post_switch, light_migration, light_switching)
    }
    if (step == 3) {
      # Adjusting current year in the projection

      year <<- year + 5
      names(structure_data)[[length(structure_data)]] <<- as.character(year)

      # Calculating "previous_" data

      calculate_total_previous(switching, TRUE)
    }
  }
)
