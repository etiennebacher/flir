# Create a custom rule for external use

This function creates a YAML file with the placeholder text to define a
new rule. The file is stored in `inst/flir/rules` and will be available
to users of your package if they use `flir`.

To create a new rule that you can use in the current project only, use
[`add_new_rule()`](https://flir.etiennebacher.com/reference/add_new_rule.md)
instead.

## Usage

``` r
export_new_rule(name, path)
```

## Arguments

- name:

  Name(s) of the rule. Cannot contain white space.

- path:

  Path to package or project root. If `NULL` (default), uses `"."`.

## Value

Create new file(s) but doesn't return anything
