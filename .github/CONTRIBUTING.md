
# Contributing to flir

This outlines how to propose a change to **flir**.

## Fixing typos

Small typos or grammatical errors in vignettes can be fixed directly on
the Github interface since vignettes are automatically rendered by
`pkgdown`.

Fixing typos in the documentation of functions (those in the “Reference”
page) requires editing the source in the corresponding `.R` file and
then run `devtools::document()`. *Do not edit an `.Rd` file in `man/`*.

## Filing an issue

The easiest way to propose a change or new feature is to file an issue.
If you’ve found a bug, you may also create an associated issue. If
possible, try to illustrate your proposal or the bug with a minimal
[reproducible example](https://www.tidyverse.org/help/#reprex).

## Pull requests

### General information

- Please create a Git branch for each pull request (PR).
- flir uses
  [roxygen2](https://cran.r-project.org/package=roxygen2), with
  [Markdown
  syntax](https://cran.r-project.org/web/packages/roxygen2/vignettes/rd-formatting.html),
  for documentation.
- If your PR is a user-visible change, you may add a bullet point in
  `NEWS.md` describing the changes made. You may optionally add your
  GitHub username, and links to relevant issue(s)/PR(s).

### How to add a new lint rule in `flir`?

Adding a rule that exists in `lintr`:

1. Create a new `.yml` file in `inst` with `new_rule("<rule_name>")`, e.g
   `new_rule("expect_length")`.
1. Import the tests from `lintr` with `get_tests_from_lintr("<rule_name>")`, e.g
   `get_tests_from_lintr("expect_length")`.
1. Add `"<rule_name>"` in the list of linters located in `R/list-linters.R`.
1. Load the package with `devtools::load_all()`, and then run `update_linter_factory()`.
   This creates a new entry in `R/linters_factory.R`. 
1. Run `devtools::document()` to register this new entry.
1. Tweak the `.yml` file so that most tests pass (in some cases, some `lintr` 
   tests can be commented out). 
1. If the rule comes with a fix, add additional snapshot tests for `fix_text()`,
   e.g.

```r
test_that("fix works", {
  linter <- expect_length_linter()

  expect_snapshot(fix_text("expect_equal(length(x), 2L)", linters = linter))
  expect_snapshot(fix_text("expect_identical(length(x), 2L)", linters = linter))

  expect_snapshot(fix_text("expect_equal(2L, length(x))", linters = linter))
  expect_snapshot(fix_text("expect_identical(2L, length(x))", linters = linter))
})
```
