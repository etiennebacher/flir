# flir (development version)

## New features

* Most `fix_*()` functions have a new argument `interactive` (`FALSE` by 
  default). When set to `TRUE`, it opens a Shiny app in the Viewer so that the
  user can review fixes that would be applied to a file. It is therefore 
  possible to accept or skip fixes on a file-by-file basis (#76).
  
* In R packages, it is now possible to create a list of rules that will be
  available to the users of the package. This is for example useful to provide 
  automatic fixes for deprecated or superseded functions. More information is
  available in the vignette "Sharing rules across packages". Thanks to @maelle
  and @Bisaloo for the suggestion and early feedback on the implementation (#78,
  #84).

## Changes

* `unreachable_code` is deactivated by default. It can still be activated with
  the argument `linters` or in `flir/config.yml` after running `setup_flir()` 
  (#75).
* `T_and_F_symbol` do not detect anymore the use of `F` and `T` when those are
  used in the `:` operation (#81).

# flir 0.4.2

## Changes

* Linters related to `testthat` (such as `expect_named`) are ignored if the
  files that are parsed belong to a package that doesn't have a `tests/testthat`
  folder (for instance if you use `tinytest` instead). (#74)

# flir 0.4.1

## Bug fixes

* Changes were still directly applied to files that are unstaged
  in Git while there should have been a warning. This is now fixed.
  
* Properly skip changes in the user picks "No" in the menu about 
  modifying unstaged files in Git.

# flir 0.4.0

## Breaking changes

- `setup_flir()` no longer imports all built-in rules in the `flir/rules`
  folder. Those are now directly read from the folder where `flir` is
  installed. Consequently, `update_flir()` has been removed as it has no
  purpose anymore (#66).

## Other changes

- New function `add_new_rule()` to create the template for a new rule in
  `flir/rules/custom` (#67).

## Bug fixes

- Fix error in replacement in rule `sample_int-4`.

# flir 0.3.0

- **BREAKING**: `flint` is renamed `flir` to avoid namespace conflict with
  the recent [`flint` package](https://cran.r-project.org/web/packages/flint/)
  on CRAN. Thanks to Mikael Jagan for the warning (#63).

  Consequences:
    - `setup_flint()` is renamed `setup_flir()` and creates a folder
      named `flir` instead of `flint`;
    - `setup_flint_gha()` is renamed `setup_flir_gha()` and creates a
      YAML file named `flir.yml` instead of `flint.yml`;
    - `update_flint()` is renamed `update_flir()`;
    - ignoring specific lines now requires `flir-ignore` instead of
      `flint-ignore`;
    - the environment variable `FLINT_ERROR_ON_LINT` is renamed `FLIR_ERROR_ON_LINT`;
    - if `flint` was used in a package, `.Rbuildignore` must be updated to
      ignore the folder `flir` instead of `flint`.

# flir 0.2.1

## New features

* New environment variable `FLINT_ERROR_ON_LINT` to determine whether `flint`
  should error if some lints were found.

## Bug fixes

* No longer error about unavailable sourceMarkers when running `lint()` in
  Positron.

* Better detection of `flint/config.yml` when using running `flint` on a
  package or a directory.

* The cache used after `setup_flir()` is now invalidated if the rules used
  change.

* Do not print "empty data.table(...)" when no lints are detected.

# flir 0.2.0

## New features

* New linter `stopifnot_all_linter()` to detect calls to `stopifnot(all(...))`
  since the `all()` is unnecessary. This has an automatic fix available.

* New linter `list_comparison_linter()` to detect a comparison with a list,
  e.g. `lapply(x, sum) > 10`. No automatic fix available.

* Line breaks are removed from multi-line messages reported by `lint*`
  functions.

* `matrix_apply_linter` now detects when `1L` and `2L` are used in the `MARGIN`
  argument.

* `any_is_na_linter` now reports cases like `NA %in% x`, and can fix them to be
  `anyNA(x)` instead.

## Bug fixes

* `library_call_linter` no longer reports cases where `library()` calls are
  wrapped in `suppressPackageStartupMessages()`.

* Nested fixes no longer overlap. The `fix*()` functions now run several times
  on the files containing nested fixes until there are no more fixes to apply.
  This can be deactivated to run only once per file by adding `rerun = FALSE`
  (#61).

* `any_is_na_linter` wrongly reported cases like `any(is.na(x), y)`. Those are
  no longer reported.

* No longer lint and fix `expect_equal(length(x), length(y))`, which is more
  readable than `expect_length(x, length(y))`.

* No longer lint and fix `expect_equal(names(x), names(y))`, which is more
  readable than `expect_named(x, names(y))`.

# flir 0.1.2

## New features

* `sample(n, m)` is now reported and can be rewritten as `sample.int(n, m)`
  when `n` is a literal integer.

## Bug fixes

* Rule names have been harmonized to use a dash instead of underscore, e.g.
  `any_duplicated-1` instead of `any_duplicated_1`.

* Replacement of `redundant_ifelse_linter` of the form
  `ifelse(cond, FALSE, TRUE)` now works (#57).

* `absolute_path_linter` was deactivated in 0.0.5 but was still reported. It is
  now properly ignored.

* Code like `expect_equal(typeof(x), 'class')` was modified twice by
  `expect_identical_linter` and `expect_type_linter`, which lead to a wrong
  rewrite. It is now replaced by `expect_type(x, 'class')`.

# flir 0.1.1

## Bug fixes

* `fix()` and `lint()` now work correctly when several paths are passed.

* `fix_package()` and `lint_package()` used all R files present from the root
  path, even those in folders that are not typical of an R package.

* `fix_dir()` and `fix_package()` now have the arguments `force` and `verbose`,
  like `fix()`.

# flir 0.1.0

## New features

* New linters: `rep_len_linter()`, `sample_int_linter()` and
  `which_grepl_linter()`.
* Add a menu or an error if `fix()` and its variants would change some unstaged
  files.
* `update_flint()` now updates all rules and doesn't only add new rules anymore.

# flir 0.0.9

## New features

* New linters: `condition_message_linter()` and `expect_identical_linter()`.
* Rewrote vignette on adding new rules.
* `setup_flir()` now puts built-in rules in `flint/rules/builtin`.


# flir 0.0.8

## New features

* New linters: `expect_comparison_linter` and `package_hooks_linter`.
* Add argument `verbose` to `lint_package()` and `lint_dir()`.
* Better message when no lints can be fixed.
* Add one case in `seq_linter` where `seq_len(x)` is faster than `seq(1, x)`.
* Better handling of `exclude_path`.

# flir 0.0.7

## New features

* Set up the Github Actions workflow for `flint` (#22).
* New linters `function_return_linter` and `todo_comment_linter`.
* Better support for `library_call_linter`.
* Add argument `overwrite` to `setup_flir_gha()`.


# flir 0.0.6

## New features

* New linter `redundant_equals_linter`.
* Better support for `matrix_apply_linter`.

# flir 0.0.5

## New features

* Deactivated `absolute_path_linter` in default use as there are too many false
  positives.
* New linter `unnecessary_nesting_linter`.
* Add messages for `lint()` and `fix()` showing the number of files checked, lints
  found and/or fixed.

## Bug fixes

* More robust detection of allowed usage of `T` and `F` in formulas.
* Use the pipe in the replacement for `lengths_linter` if it was already present
  in code.

## Misc

* Add links to `lintr` documentation in the manual pages.

# flir 0.0.4

## New features

* New linters: `for_loop_index`,`missing_argument`.
* `fix()` has a new argument `force` (`FALSE` by default). This is useful if Git
  was not detected, `fix()` would modify several files, and it is run in a
  non-interactive context. In this situation, set `force = TRUE` to apply the
  fixes anyway.
* Add `cli` messages informing how many files are checked, and how many contain
  lints (for `lint_*` functions) or were modified (for `fix_*` functions).
* Better coverage of the `length_test` linter.

## Bug fixes

* Allow usage of `T` and `F` in formulas (#33).

# flir 0.0.3

## New features

* New linters: `absolute_path`, `duplicate_argument`, `empty_assignment`,
  `expect_length`, `expect_not`, `expect_null`, `expect_true_false`,
  `expect_type`, `literal_coercion`, `nested_ifelse`, `sort`,
  `undesirable_operator`.
* Added a contributing guide.
* Better docs for `fix()` and its variants.
* Using `fix()` on several files without using Git now opens an interactive
  menu so that the user confirms they want to run `fix()`. In case of
  non-interactive use, this errors.
* Ignore lines following `# nolint` for compatibility with `lintr`.

## Bug fixes

* Fix a few false positives (#23, #24, #27).

# flir 0.0.2

## New features

* New linters: `expect_named`, `numeric_leading_zero`, `outer_negation`,
  `redundant_ifelse`, `undesirable_function`, `unreachable_code`.

* `fix_dir()`, `fix_package()`, `lint_dir()`, `lint_package()` now have arguments
  to exclude paths, linters, and use cache.

* Removed `browser` linter (it is now part of `undesriable_function`).

* Add support for a `flint/config.yml` file that contains the list of linters
  to use so that one doesn't need to constantly specify them in `lint()` or `fix()`.


## Bug fixes

* Do not lint for `x %in% class(y)` where `x` is not a string as this is [not
  equivalent in some cases](https://github.com/vincentarelbundock/marginaleffects/pull/1171#issuecomment-2228497287). Thanks Vincent Arel-Bundock for spotting this.


# flir 0.0.1

* First Github release.
