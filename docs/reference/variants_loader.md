# Calculate variant and create modified country_list_object

Applies per-country variant settings (e.g. fertility convergence,
migration adjustments) from [`info_variants`](info_variants.md) to the
country objects stored inside a projection object. Must be called after
[`create_projection_object`](create_projection_object.md) and before
[`project`](project.md). Calling it a second time on the same object is
blocked unless `force = TRUE`.

## Usage

``` r
variants_loader(
  projection_object,
  country_info = base_data_list[[10]],
  force = FALSE
)
```

## Arguments

- projection_object:

  Projection_object; an unresolved projection object whose country
  objects will be modified by variant settings

- country_info:

  Data frame; variant settings for each country, typically
  \`base_data_list\$info_variants\` (default
  \`base_data_list\[\[10\]\]\`)

- force:

  Logical, if TRUE loads a variant even if a variant has been already
  loaded. (default FALSE)

## Value

The input `projection_object` with modified `country_object_list`.

## See also

[`info_variants`](info_variants.md) for a description of the variant
settings table,
[`create_projection_object`](create_projection_object.md) to create the
object passed here, [`project`](project.md) to run the projection after
loading a variant.
[`vignette("conducting-projections")`](../articles/conducting-projections.md)
for a full walkthrough.

## Examples

``` r
p_object <- create_projection_object(name = "test")
#> [1] "Global starting parameters:"
#> [1] "Migration: TRUE"
#> [1] "Light migration: TRUE"
#> [1] "Switching: TRUE"
#> [1] "Light switching: TRUE"
#> [1] "Switching type: split"
#> [1] "Steps: 11"
#> [1] "No fertility differentials: FALSE"
#> [1] "Post switch separation: FALSE"
p_object <- variants_loader(projection_object = p_object)
#> [1] "Variant successfully loaded."
```
