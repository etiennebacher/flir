# export_new_rule() only works in packages

    Code
      export_new_rule("foobar")
    Condition
      Error in `export_new_rule()`:
      ! `export_new_rule()` only works when the project is an R package.

# export_new_rule() errors on wrong names

    Code
      export_new_rule(1)
    Condition
      Error in `export_new_rule()`:
      ! `name` must be a character vector.

# export_new_rule() cannot overwrite files

    Code
      export_new_rule("foobar")
    Condition
      Error in `export_new_rule()`:
      ! './inst/flir/rules/foobar.yml' already exists.

# export_new_rule() cannot create file with whitespace

    Code
      export_new_rule("hi there")
    Condition
      Error in `export_new_rule()`:
      ! `name` must not contain white space.

