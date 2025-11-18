# Package index

## Find and fix lints

- [`fix()`](https://flir.etiennebacher.com/reference/fix.md)
  [`fix_dir()`](https://flir.etiennebacher.com/reference/fix.md)
  [`fix_package()`](https://flir.etiennebacher.com/reference/fix.md)
  [`fix_text()`](https://flir.etiennebacher.com/reference/fix.md) :
  Automatically replace lints

- [`lint()`](https://flir.etiennebacher.com/reference/lint.md)
  [`lint_dir()`](https://flir.etiennebacher.com/reference/lint.md)
  [`lint_package()`](https://flir.etiennebacher.com/reference/lint.md)
  [`lint_text()`](https://flir.etiennebacher.com/reference/lint.md) :
  List all lints in a file or a directory

- [`list_linters()`](https://flir.etiennebacher.com/reference/list_linters.md)
  :

  Get the list of linters in `flir`

## Setup `flir`

- [`add_new_rule()`](https://flir.etiennebacher.com/reference/add_new_rule.md)
  : Create a custom rule for internal use

- [`export_new_rule()`](https://flir.etiennebacher.com/reference/export_new_rule.md)
  : Create a custom rule for external use

- [`setup_flir()`](https://flir.etiennebacher.com/reference/setup_flir.md)
  : Setup flir

- [`setup_flir_gha()`](https://flir.etiennebacher.com/reference/setup_flir_gha.md)
  :

  Create a Github Actions workflow for `flir`

## Linters

- [`T_and_F_symbol_linter`](https://flir.etiennebacher.com/reference/T_and_F_symbol_linter.md)
  :

  `T` and `F` symbol linter

- [`any_duplicated_linter`](https://flir.etiennebacher.com/reference/any_duplicated_linter.md)
  :

  Require usage of `anyDuplicated(x) > 0` over `any(duplicated(x))`

- [`any_is_na_linter`](https://flir.etiennebacher.com/reference/any_is_na_linter.md)
  :

  Require usage of `anyNA(x)` over `any(is.na(x))`

- [`class_equals_linter`](https://flir.etiennebacher.com/reference/class_equals_linter.md)
  :

  Block comparison of class with `==`

- [`condition_message_linter`](https://flir.etiennebacher.com/reference/condition_message_linter.md)
  :

  Block usage of [`paste()`](https://rdrr.io/r/base/paste.html) and
  [`paste0()`](https://rdrr.io/r/base/paste.html) with messaging
  functions using `...`

- [`double_assignment_linter`](https://flir.etiennebacher.com/reference/double_assignment_linter.md)
  : double_assignment

- [`duplicate_argument_linter`](https://flir.etiennebacher.com/reference/duplicate_argument_linter.md)
  : Duplicate argument linter

- [`empty_assignment_linter`](https://flir.etiennebacher.com/reference/empty_assignment_linter.md)
  : empty_assignment

- [`equal_assignment_linter`](https://flir.etiennebacher.com/reference/equal_assignment_linter.md)
  : equal_assignment

- [`equals_na_linter`](https://flir.etiennebacher.com/reference/equals_na_linter.md)
  : Equality check with NA linter

- [`expect_comparison_linter`](https://flir.etiennebacher.com/reference/expect_comparison_linter.md)
  :

  Require usage of `expect_gt(x, y)` over `expect_true(x > y)` (and
  similar)

- [`expect_identical_linter`](https://flir.etiennebacher.com/reference/expect_identical_linter.md)
  :

  Require usage of `expect_identical(x, y)` where appropriate

- [`expect_length_linter`](https://flir.etiennebacher.com/reference/expect_length_linter.md)
  :

  Require usage of `expect_length(x, n)` over
  `expect_equal(length(x), n)`

- [`expect_named_linter`](https://flir.etiennebacher.com/reference/expect_named_linter.md)
  :

  Require usage of `expect_named(x, n)` over `expect_equal(names(x), n)`

- [`expect_not_linter`](https://flir.etiennebacher.com/reference/expect_not_linter.md)
  :

  Require usage of `expect_false(x)` over `expect_true(!x)`

- [`expect_null_linter`](https://flir.etiennebacher.com/reference/expect_null_linter.md)
  :

  Require usage of `expect_null` for checking `NULL`

- [`expect_s3_class_linter`](https://flir.etiennebacher.com/reference/expect_s3_class_linter.md)
  :

  Require usage of `expect_s3_class()`

- [`expect_s4_class_linter`](https://flir.etiennebacher.com/reference/expect_s4_class_linter.md)
  :

  Require usage of `expect_s4_class(x, k)` over `expect_true(is(x, k))`

- [`expect_true_false_linter`](https://flir.etiennebacher.com/reference/expect_true_false_linter.md)
  :

  Require usage of `expect_true(x)` over `expect_equal(x, TRUE)`

- [`expect_type_linter`](https://flir.etiennebacher.com/reference/expect_type_linter.md)
  :

  Require usage of `expect_type(x, type)` over
  `expect_equal(typeof(x), type)`

- [`for_loop_index_linter`](https://flir.etiennebacher.com/reference/for_loop_index_linter.md)
  : Block usage of for loops directly overwriting the indexing variable

- [`function_return_linter`](https://flir.etiennebacher.com/reference/function_return_linter.md)
  : Lint common mistakes/style issues cropping up from return statements

- [`implicit_assignment_linter`](https://flir.etiennebacher.com/reference/implicit_assignment_linter.md)
  : implicit_assignment

- [`is_numeric_linter`](https://flir.etiennebacher.com/reference/is_numeric_linter.md)
  :

  Redirect `is.numeric(x) || is.integer(x)` to just use `is.numeric(x)`

- [`length_levels_linter`](https://flir.etiennebacher.com/reference/length_levels_linter.md)
  : Require usage of nlevels over length(levels(.))

- [`length_test_linter`](https://flir.etiennebacher.com/reference/length_test_linter.md)
  : Check for a common mistake where length is applied in the wrong
  place

- [`lengths_linter`](https://flir.etiennebacher.com/reference/lengths_linter.md)
  :

  Require usage of [`lengths()`](https://rdrr.io/r/base/lengths.html)
  where possible

- [`library_call_linter`](https://flir.etiennebacher.com/reference/library_call_linter.md)
  : Library call linter

- [`list_comparison_linter`](https://flir.etiennebacher.com/reference/list_comparison_linter.md)
  : Block usage of comparison operators with known-list() functions like
  lapply

- [`literal_coercion_linter`](https://flir.etiennebacher.com/reference/literal_coercion_linter.md)
  : Require usage of correctly-typed literals over literal coercions

- [`matrix_apply_linter`](https://flir.etiennebacher.com/reference/matrix_apply_linter.md)
  :

  Require usage of `colSums(x)` or `rowSums(x)` over `apply(x, ., sum)`

- [`missing_argument_linter`](https://flir.etiennebacher.com/reference/missing_argument_linter.md)
  : Missing argument linter

- [`nested_ifelse_linter`](https://flir.etiennebacher.com/reference/nested_ifelse_linter.md)
  :

  Block usage of nested [`ifelse()`](https://rdrr.io/r/base/ifelse.html)
  calls

- [`numeric_leading_zero_linter`](https://flir.etiennebacher.com/reference/numeric_leading_zero_linter.md)
  : Require usage of a leading zero in all fractional numerics

- [`nzchar_linter`](https://flir.etiennebacher.com/reference/nzchar_linter.md)
  : Require usage of nzchar where appropriate

- [`outer_negation_linter`](https://flir.etiennebacher.com/reference/outer_negation_linter.md)
  :

  Require usage of `!any(x)` over `all(!x)`, `!all(x)` over `any(!x)`

- [`package_hooks_linter`](https://flir.etiennebacher.com/reference/package_hooks_linter.md)
  : Package hooks linter

- [`paste_linter`](https://flir.etiennebacher.com/reference/paste_linter.md)
  :

  Raise lints for several common poor usages of
  [`paste()`](https://rdrr.io/r/base/paste.html)

- [`redundant_equals_linter`](https://flir.etiennebacher.com/reference/redundant_equals_linter.md)
  :

  Block usage of `==`, `!=` on logical vectors

- [`redundant_ifelse_linter`](https://flir.etiennebacher.com/reference/redundant_ifelse_linter.md)
  :

  Prevent [`ifelse()`](https://rdrr.io/r/base/ifelse.html) from being
  used to produce `TRUE`/`FALSE` or `1`/`0`

- [`rep_len_linter`](https://flir.etiennebacher.com/reference/rep_len_linter.md)
  : Require usage of rep_len(x, n) over rep(x, length.out = n)

- [`right_assignment_linter`](https://flir.etiennebacher.com/reference/right_assignment_linter.md)
  : right_assignment

- [`sample_int_linter`](https://flir.etiennebacher.com/reference/sample_int_linter.md)
  : Require usage of sample.int(n, m, ...) over sample(1:n, m, ...)

- [`seq_linter`](https://flir.etiennebacher.com/reference/seq_linter.md)
  : Sequence linter

- [`sort_linter`](https://flir.etiennebacher.com/reference/sort_linter.md)
  : Check for common mistakes around sorting vectors

- [`stopifnot_all_linter`](https://flir.etiennebacher.com/reference/stopifnot_all_linter.md)
  : Block usage of all() within stopifnot()

- [`todo_comment_linter`](https://flir.etiennebacher.com/reference/todo_comment_linter.md)
  : TODO comment linter

- [`undesirable_function_linter`](https://flir.etiennebacher.com/reference/undesirable_function_linter.md)
  : Undesirable function linter

- [`undesirable_operator_linter`](https://flir.etiennebacher.com/reference/undesirable_operator_linter.md)
  : Undesirable operator linter

- [`unnecessary_nesting_linter`](https://flir.etiennebacher.com/reference/unnecessary_nesting_linter.md)
  : Block instances of unnecessary nesting

- [`vector_logic_linter`](https://flir.etiennebacher.com/reference/vector_logic_linter.md)
  : Enforce usage of scalar logical operators in conditional statements

- [`which_grepl_linter`](https://flir.etiennebacher.com/reference/which_grepl_linter.md)
  : Require usage of grep over which(grepl(.))
