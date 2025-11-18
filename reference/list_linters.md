# Get the list of linters in `flir`

Get the list of linters in `flir`

## Usage

``` r
list_linters(path = ".")
```

## Arguments

- path:

  A valid path to a file or a directory. Relative paths are accepted.
  Default is `"."`.

## Value

A character vector

## Examples

``` r
list_linters(".")
#>  [1] "any_duplicated"       "any_is_na"            "class_equals"        
#>  [4] "condition_message"    "double_assignment"    "duplicate_argument"  
#>  [7] "empty_assignment"     "equal_assignment"     "equals_na"           
#> [10] "for_loop_index"       "function_return"      "implicit_assignment" 
#> [13] "is_numeric"           "length_levels"        "length_test"         
#> [16] "lengths"              "library_call"         "list_comparison"     
#> [19] "literal_coercion"     "matrix_apply"         "missing_argument"    
#> [22] "nested_ifelse"        "numeric_leading_zero" "nzchar"              
#> [25] "outer_negation"       "package_hooks"        "paste"               
#> [28] "redundant_equals"     "redundant_ifelse"     "rep_len"             
#> [31] "right_assignment"     "sample_int"           "seq"                 
#> [34] "sort"                 "stopifnot_all"        "T_and_F_symbol"      
#> [37] "todo_comment"         "undesirable_function" "undesirable_operator"
#> [40] "unnecessary_nesting"  "vector_logic"         "which_grepl"         
```
