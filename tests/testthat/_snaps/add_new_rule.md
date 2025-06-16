# add_new_rule() errors

    Code
      add_new_rule("foo bar")
    Condition
      Error in `add_new_rule()`:
      ! `name` must not contain white space.

---

    Code
      add_new_rule(1)
    Condition
      Error in `add_new_rule()`:
      ! `name` must be a character vector.

# export_new_rule() cannot overwrite files

    Code
      add_new_rule("foobar")
    Condition
      Error in `add_new_rule()`:
      ! './flir/rules/custom/foobar.yml' already exists.

# create template for new custom rule

    Code
      add_new_rule("foobar")
    Condition
      Error in `add_new_rule()`:
      ! Folder `flir` doesn't exist.
      i Create it with `setup_flir()` first.

---

    Code
      fs::dir_tree("flir")
    Output
      flir
      +-- cache_file_state.rds
      +-- config.yml
      \-- rules
          \-- custom
              \-- foobar.yml

