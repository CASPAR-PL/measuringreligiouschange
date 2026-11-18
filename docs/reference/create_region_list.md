# Creating list of Region_objects

Function for creating a list of Region_objects from a region-mapping
data frame. In most workflows this is called automatically by
[`create_projection_object`](create_projection_object.md); call it
directly only when you need to customise the region list before
assembling a projection.

## Usage

``` r
create_region_list(region_data = base_data_list[[11]])
```

## Arguments

- region_data:

  Data frame; mapping region names to region identifiers. See
  [`data_regions`](data_regions.md). Defaults to the regions table
  stored in [`base_data_list`](base_data_list.md)
  (`base_data_list[[11]]`).

## Value

List of Region_objects, one per row in `region_data`.

## See also

[`create_projection_object`](create_projection_object.md) which calls
this automatically, [`base_data_list`](base_data_list.md) for the
default region mapping data.

## Examples

``` r
create_region_list(region_data = base_data_list[[11]])
#> $EURO
#> Reference class object of class "Region_object"
#> Field "name":
#> [1] "Europe"
#> Field "region":
#> [1] "EURO"
#> Field "structure_data":
#> list()
#> Field "previous_mortality":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_mortality"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_fertility":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_fertility"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_asfr":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_asfr"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_fertility_exposure":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_fertility_exposure"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_switching":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_switching"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_immigration":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_immigration"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_emigration":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_emigration"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> 
#> $MENA
#> Reference class object of class "Region_object"
#> Field "name":
#> [1] "Middle East North Africa"
#> Field "region":
#> [1] "MENA"
#> Field "structure_data":
#> list()
#> Field "previous_mortality":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_mortality"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_fertility":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_fertility"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_asfr":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_asfr"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_fertility_exposure":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_fertility_exposure"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_switching":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_switching"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_immigration":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_immigration"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_emigration":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_emigration"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> 
#> $SSAF
#> Reference class object of class "Region_object"
#> Field "name":
#> [1] "Sub-Saharan Africa"
#> Field "region":
#> [1] "SSAF"
#> Field "structure_data":
#> list()
#> Field "previous_mortality":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_mortality"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_fertility":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_fertility"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_asfr":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_asfr"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_fertility_exposure":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_fertility_exposure"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_switching":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_switching"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_immigration":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_immigration"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_emigration":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_emigration"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> 
#> $ASPA
#> Reference class object of class "Region_object"
#> Field "name":
#> [1] "Asia Pacific"
#> Field "region":
#> [1] "ASPA"
#> Field "structure_data":
#> list()
#> Field "previous_mortality":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_mortality"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_fertility":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_fertility"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_asfr":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_asfr"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_fertility_exposure":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_fertility_exposure"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_switching":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_switching"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_immigration":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_immigration"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_emigration":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_emigration"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> 
#> $LACA
#> Reference class object of class "Region_object"
#> Field "name":
#> [1] "Latin America Caribbean"
#> Field "region":
#> [1] "LACA"
#> Field "structure_data":
#> list()
#> Field "previous_mortality":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_mortality"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_fertility":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_fertility"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_asfr":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_asfr"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_fertility_exposure":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_fertility_exposure"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_switching":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_switching"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_immigration":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_immigration"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_emigration":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_emigration"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> 
#> $NOAM
#> Reference class object of class "Region_object"
#> Field "name":
#> [1] "North America"
#> Field "region":
#> [1] "NOAM"
#> Field "structure_data":
#> list()
#> Field "previous_mortality":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_mortality"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_fertility":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_fertility"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_asfr":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_asfr"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_fertility_exposure":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_fertility_exposure"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_switching":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_switching"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_immigration":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_immigration"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> Field "previous_emigration":
#> An object of class "uninitializedField"
#> Slot "field":
#> [1] "previous_emigration"
#> 
#> Slot "className":
#> [1] "ANY"
#> 
#> 
```
