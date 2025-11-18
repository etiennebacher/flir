# Create a custom rule for internal use

This function creates a YAML file with the placeholder text to define a
new rule. The file is stored in `flir/rules/custom`. You need to create
the `flir` folder with
[`setup_flir()`](https://flir.etiennebacher.com/reference/setup_flir.md)
if it doesn't exist.

If you want to create a rule that users of your package will be able to
access, use
[`export_new_rule()`](https://flir.etiennebacher.com/reference/export_new_rule.md)
instead.

## Usage

``` r
add_new_rule(name, path)
```

## Arguments

- name:

  Name(s) of the rule. Cannot contain white space.

- path:

  Path to package or project root. If `NULL` (default), uses `"."`.

## Value

Create new file(s) but doesn't return anything
