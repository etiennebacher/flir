# Changelog

## flir (development version)

### New features

- New linters:

  - [`expect_s3_class_linter()`](https://flir.etiennebacher.com/reference/expect_s3_class_linter.md)
    ([@trevorld](https://github.com/trevorld),
    [\#110](https://github.com/etiennebacher/flir/issues/110))
  - [`expect_s4_class_linter()`](https://flir.etiennebacher.com/reference/expect_s4_class_linter.md)
    ([@trevorld](https://github.com/trevorld),
    [\#109](https://github.com/etiennebacher/flir/issues/109))
  - [`nzchar_linter()`](https://flir.etiennebacher.com/reference/nzchar_linter.md)
    ([@trevorld](https://github.com/trevorld),
    [\#102](https://github.com/etiennebacher/flir/issues/102))
  - [`vector_logic_linter()`](https://flir.etiennebacher.com/reference/vector_logic_linter.md)
    ([@trevorld](https://github.com/trevorld),
    [\#111](https://github.com/etiennebacher/flir/issues/111))

- New vignette “Tips and tricks” that lists some solutions for problems
  one may encounter when writing new rules
  ([\#94](https://github.com/etiennebacher/flir/issues/94)).

### Bug fixes

- When using external rules with the `with-<pkg>` syntax, if the YAML
  file contains several rules separated by “—”, then `flir` would only
  use the first one. This is now fixed
  ([\#95](https://github.com/etiennebacher/flir/issues/95)).

- [`list_linters()`](https://flir.etiennebacher.com/reference/list_linters.md)
  now uses `path = "."` by default
  ([\#99](https://github.com/etiennebacher/flir/issues/99)).

### Changes

- [`expect_type_linter()`](https://flir.etiennebacher.com/reference/expect_type_linter.md)
  now has less false positives for non-type `is.*()` functions and also
  provides more fixes ([@trevorld](https://github.com/trevorld),
  [\#110](https://github.com/etiennebacher/flir/issues/110)).

## flir 0.5.0

CRAN release: 2025-06-28

This is the first CRAN release.

### Breaking changes

- [`add_new_rule()`](https://flir.etiennebacher.com/reference/add_new_rule.md)
  now errors if the file already exists
  ([\#87](https://github.com/etiennebacher/flir/issues/87)).

- In all functions that create or modify files
  ([`fix()`](https://flir.etiennebacher.com/reference/fix.md),
  [`setup_flir()`](https://flir.etiennebacher.com/reference/setup_flir.md),
  etc.), the argument `path` has to be specified. Linting functions keep
  using the default path `"."`. This is due to the CRAN policy that a
  package cannot modify the user file system
  ([\#79](https://github.com/etiennebacher/flir/issues/79)).

### New features

- Most `fix_*()` functions have a new argument `interactive` (`FALSE` by
  default). When set to `TRUE`, it opens a Shiny app in the Viewer so
  that the user can review fixes that would be applied to a file. It is
  therefore possible to accept or skip fixes on a file-by-file basis
  ([\#76](https://github.com/etiennebacher/flir/issues/76)).

- In R packages, it is now possible to create a list of rules that will
  be available to the users of the package. This can be useful to
  provide automatic fixes for deprecated or superseded functions, for
  example. More information is available in the vignette “Sharing rules
  across packages”. Thanks to [@maelle](https://github.com/maelle) and
  [@Bisaloo](https://github.com/Bisaloo) for the suggestion and early
  feedback on the implementation
  ([\#78](https://github.com/etiennebacher/flir/issues/78),
  [\#84](https://github.com/etiennebacher/flir/issues/84)).

- [`add_new_rule()`](https://flir.etiennebacher.com/reference/add_new_rule.md)
  now accepts several `name`s at once
  ([\#88](https://github.com/etiennebacher/flir/issues/88)).

### Changes

- `unreachable_code` is deactivated by default. It can still be
  activated with the argument `linters` or in `flir/config.yml` after
  running
  [`setup_flir()`](https://flir.etiennebacher.com/reference/setup_flir.md)
  ([\#75](https://github.com/etiennebacher/flir/issues/75)).

- `T_and_F_symbol` do not detect anymore the use of `F` and `T` when
  those are used in the `:` operation
  ([\#81](https://github.com/etiennebacher/flir/issues/81)).

- `semicolon_linter` is no longer used. It is a linter related to code
  formatting only and therefore isn’t in the scope of `flir` (and the
  current implementation was buggy). It is also handled by the `Air`
  formatter ([\#93](https://github.com/etiennebacher/flir/issues/93)).

### Bug fixes

- `lint_*()` and `fix_*()` now work with relative paths to YAML files,
  for example `lint(linters = "my_rule.yml")`
  ([\#92](https://github.com/etiennebacher/flir/issues/92)).

## flir 0.4.2

### Changes

- Linters related to `testthat` (such as `expect_named`) are ignored if
  the files that are parsed belong to a package that doesn’t have a
  `tests/testthat` folder (for instance if you use `tinytest` instead).
  ([\#74](https://github.com/etiennebacher/flir/issues/74))

## flir 0.4.1

### Bug fixes

- Changes were still directly applied to files that are unstaged in Git
  while there should have been a warning. This is now fixed.

- Properly skip changes in the user picks “No” in the menu about
  modifying unstaged files in Git.

## flir 0.4.0

### Breaking changes

- [`setup_flir()`](https://flir.etiennebacher.com/reference/setup_flir.md)
  no longer imports all built-in rules in the `flir/rules` folder. Those
  are now directly read from the folder where `flir` is installed.
  Consequently, `update_flir()` has been removed as it has no purpose
  anymore ([\#66](https://github.com/etiennebacher/flir/issues/66)).

### Other changes

- New function
  [`add_new_rule()`](https://flir.etiennebacher.com/reference/add_new_rule.md)
  to create the template for a new rule in `flir/rules/custom`
  ([\#67](https://github.com/etiennebacher/flir/issues/67)).

### Bug fixes

- Fix error in replacement in rule `sample_int-4`.

## flir 0.3.0

- **BREAKING**: `flint` is renamed `flir` to avoid namespace conflict
  with the recent [`flint`
  package](https://CRAN.R-project.org/package=flint) on CRAN. Thanks to
  Mikael Jagan for the warning
  ([\#63](https://github.com/etiennebacher/flir/issues/63)).

  Consequences:

  - `setup_flint()` is renamed
    [`setup_flir()`](https://flir.etiennebacher.com/reference/setup_flir.md)
    and creates a folder named `flir` instead of `flint`;
  - `setup_flint_gha()` is renamed
    [`setup_flir_gha()`](https://flir.etiennebacher.com/reference/setup_flir_gha.md)
    and creates a YAML file named `flir.yml` instead of `flint.yml`;
  - `update_flint()` is renamed `update_flir()`;
  - ignoring specific lines now requires `flir-ignore` instead of
    `flint-ignore`;
  - the environment variable `FLINT_ERROR_ON_LINT` is renamed
    `FLIR_ERROR_ON_LINT`;
  - if `flint` was used in a package, `.Rbuildignore` must be updated to
    ignore the folder `flir` instead of `flint`.

## flir 0.2.1

### New features

- New environment variable `FLINT_ERROR_ON_LINT` to determine whether
  `flint` should error if some lints were found.

### Bug fixes

- No longer error about unavailable sourceMarkers when running
  [`lint()`](https://flir.etiennebacher.com/reference/lint.md) in
  Positron.

- Better detection of `flint/config.yml` when using running `flint` on a
  package or a directory.

- The cache used after
  [`setup_flir()`](https://flir.etiennebacher.com/reference/setup_flir.md)
  is now invalidated if the rules used change.

- Do not print “empty data.table(…)” when no lints are detected.

## flir 0.2.0

### New features

- New linter
  [`stopifnot_all_linter()`](https://flir.etiennebacher.com/reference/stopifnot_all_linter.md)
  to detect calls to `stopifnot(all(...))` since the
  [`all()`](https://rdrr.io/r/base/all.html) is unnecessary. This has an
  automatic fix available.

- New linter
  [`list_comparison_linter()`](https://flir.etiennebacher.com/reference/list_comparison_linter.md)
  to detect a comparison with a list, e.g. `lapply(x, sum) > 10`. No
  automatic fix available.

- Line breaks are removed from multi-line messages reported by `lint*`
  functions.

- `matrix_apply_linter` now detects when `1L` and `2L` are used in the
  `MARGIN` argument.

- `any_is_na_linter` now reports cases like `NA %in% x`, and can fix
  them to be `anyNA(x)` instead.

### Bug fixes

- `library_call_linter` no longer reports cases where
  [`library()`](https://rdrr.io/r/base/library.html) calls are wrapped
  in
  [`suppressPackageStartupMessages()`](https://rdrr.io/r/base/message.html).

- Nested fixes no longer overlap. The `fix*()` functions now run several
  times on the files containing nested fixes until there are no more
  fixes to apply. This can be deactivated to run only once per file by
  adding `rerun = FALSE`
  ([\#61](https://github.com/etiennebacher/flir/issues/61)).

- `any_is_na_linter` wrongly reported cases like `any(is.na(x), y)`.
  Those are no longer reported.

- No longer lint and fix `expect_equal(length(x), length(y))`, which is
  more readable than `expect_length(x, length(y))`.

- No longer lint and fix `expect_equal(names(x), names(y))`, which is
  more readable than `expect_named(x, names(y))`.

## flir 0.1.2

### New features

- `sample(n, m)` is now reported and can be rewritten as
  `sample.int(n, m)` when `n` is a literal integer.

### Bug fixes

- Rule names have been harmonized to use a dash instead of underscore,
  e.g. `any_duplicated-1` instead of `any_duplicated_1`.

- Replacement of `redundant_ifelse_linter` of the form
  `ifelse(cond, FALSE, TRUE)` now works
  ([\#57](https://github.com/etiennebacher/flir/issues/57)).

- `absolute_path_linter` was deactivated in 0.0.5 but was still
  reported. It is now properly ignored.

- Code like `expect_equal(typeof(x), 'class')` was modified twice by
  `expect_identical_linter` and `expect_type_linter`, which lead to a
  wrong rewrite. It is now replaced by `expect_type(x, 'class')`.

## flir 0.1.1

### Bug fixes

- [`fix()`](https://flir.etiennebacher.com/reference/fix.md) and
  [`lint()`](https://flir.etiennebacher.com/reference/lint.md) now work
  correctly when several paths are passed.

- [`fix_package()`](https://flir.etiennebacher.com/reference/fix.md) and
  [`lint_package()`](https://flir.etiennebacher.com/reference/lint.md)
  used all R files present from the root path, even those in folders
  that are not typical of an R package.

- [`fix_dir()`](https://flir.etiennebacher.com/reference/fix.md) and
  [`fix_package()`](https://flir.etiennebacher.com/reference/fix.md) now
  have the arguments `force` and `verbose`, like
  [`fix()`](https://flir.etiennebacher.com/reference/fix.md).

## flir 0.1.0

### New features

- New linters:
  [`rep_len_linter()`](https://flir.etiennebacher.com/reference/rep_len_linter.md),
  [`sample_int_linter()`](https://flir.etiennebacher.com/reference/sample_int_linter.md)
  and
  [`which_grepl_linter()`](https://flir.etiennebacher.com/reference/which_grepl_linter.md).
- Add a menu or an error if
  [`fix()`](https://flir.etiennebacher.com/reference/fix.md) and its
  variants would change some unstaged files.
- `update_flint()` now updates all rules and doesn’t only add new rules
  anymore.

## flir 0.0.9

### New features

- New linters:
  [`condition_message_linter()`](https://flir.etiennebacher.com/reference/condition_message_linter.md)
  and
  [`expect_identical_linter()`](https://flir.etiennebacher.com/reference/expect_identical_linter.md).
- Rewrote vignette on adding new rules.
- [`setup_flir()`](https://flir.etiennebacher.com/reference/setup_flir.md)
  now puts built-in rules in `flint/rules/builtin`.

## flir 0.0.8

### New features

- New linters: `expect_comparison_linter` and `package_hooks_linter`.
- Add argument `verbose` to
  [`lint_package()`](https://flir.etiennebacher.com/reference/lint.md)
  and [`lint_dir()`](https://flir.etiennebacher.com/reference/lint.md).
- Better message when no lints can be fixed.
- Add one case in `seq_linter` where `seq_len(x)` is faster than
  `seq(1, x)`.
- Better handling of `exclude_path`.

## flir 0.0.7

### New features

- Set up the Github Actions workflow for `flint`
  ([\#22](https://github.com/etiennebacher/flir/issues/22)).
- New linters `function_return_linter` and `todo_comment_linter`.
- Better support for `library_call_linter`.
- Add argument `overwrite` to
  [`setup_flir_gha()`](https://flir.etiennebacher.com/reference/setup_flir_gha.md).

## flir 0.0.6

### New features

- New linter `redundant_equals_linter`.
- Better support for `matrix_apply_linter`.

## flir 0.0.5

### New features

- Deactivated `absolute_path_linter` in default use as there are too
  many false positives.
- New linter `unnecessary_nesting_linter`.
- Add messages for
  [`lint()`](https://flir.etiennebacher.com/reference/lint.md) and
  [`fix()`](https://flir.etiennebacher.com/reference/fix.md) showing the
  number of files checked, lints found and/or fixed.

### Bug fixes

- More robust detection of allowed usage of `T` and `F` in formulas.
- Use the pipe in the replacement for `lengths_linter` if it was already
  present in code.

### Misc

- Add links to `lintr` documentation in the manual pages.

## flir 0.0.4

### New features

- New linters: `for_loop_index`,`missing_argument`.
- [`fix()`](https://flir.etiennebacher.com/reference/fix.md) has a new
  argument `force` (`FALSE` by default). This is useful if Git was not
  detected, [`fix()`](https://flir.etiennebacher.com/reference/fix.md)
  would modify several files, and it is run in a non-interactive
  context. In this situation, set `force = TRUE` to apply the fixes
  anyway.
- Add `cli` messages informing how many files are checked, and how many
  contain lints (for `lint_*` functions) or were modified (for `fix_*`
  functions).
- Better coverage of the `length_test` linter.

### Bug fixes

- Allow usage of `T` and `F` in formulas
  ([\#33](https://github.com/etiennebacher/flir/issues/33)).

## flir 0.0.3

### New features

- New linters: `absolute_path`, `duplicate_argument`,
  `empty_assignment`, `expect_length`, `expect_not`, `expect_null`,
  `expect_true_false`, `expect_type`, `literal_coercion`,
  `nested_ifelse`, `sort`, `undesirable_operator`.
- Added a contributing guide.
- Better docs for
  [`fix()`](https://flir.etiennebacher.com/reference/fix.md) and its
  variants.
- Using [`fix()`](https://flir.etiennebacher.com/reference/fix.md) on
  several files without using Git now opens an interactive menu so that
  the user confirms they want to run
  [`fix()`](https://flir.etiennebacher.com/reference/fix.md). In case of
  non-interactive use, this errors.
- Ignore lines following `# nolint` for compatibility with `lintr`.

### Bug fixes

- Fix a few false positives
  ([\#23](https://github.com/etiennebacher/flir/issues/23),
  [\#24](https://github.com/etiennebacher/flir/issues/24),
  [\#27](https://github.com/etiennebacher/flir/issues/27)).

## flir 0.0.2

### New features

- New linters: `expect_named`, `numeric_leading_zero`, `outer_negation`,
  `redundant_ifelse`, `undesirable_function`, `unreachable_code`.

- [`fix_dir()`](https://flir.etiennebacher.com/reference/fix.md),
  [`fix_package()`](https://flir.etiennebacher.com/reference/fix.md),
  [`lint_dir()`](https://flir.etiennebacher.com/reference/lint.md),
  [`lint_package()`](https://flir.etiennebacher.com/reference/lint.md)
  now have arguments to exclude paths, linters, and use cache.

- Removed `browser` linter (it is now part of `undesriable_function`).

- Add support for a `flint/config.yml` file that contains the list of
  linters to use so that one doesn’t need to constantly specify them in
  [`lint()`](https://flir.etiennebacher.com/reference/lint.md) or
  [`fix()`](https://flir.etiennebacher.com/reference/fix.md).

### Bug fixes

- Do not lint for `x %in% class(y)` where `x` is not a string as this is
  [not equivalent in some
  cases](https://github.com/vincentarelbundock/marginaleffects/pull/1171#issuecomment-2228497287).
  Thanks Vincent Arel-Bundock for spotting this.

## flir 0.0.1

- First Github release.
