# List all lints in a file or a directory

`lint()`, `lint_text()`, `lint_package()`, and `lint_dir()` all produce
a data.frame containing the lints, their location, and potential fixes.
The only difference is in the input they take:

- `lint()` takes path to files or directories

- `lint_text()` takes some text input

- `lint_dir()` takes a path to one directory

- `lint_package()` takes a path to the root of a package and looks at
  the following list of folders: `R`, `tests`, `inst`, `vignettes`,
  `data-raw`, `demo`, `exec`.

## Usage

``` r
lint(
  path = ".",
  linters = NULL,
  exclude_path = NULL,
  exclude_linters = NULL,
  open = TRUE,
  use_cache = TRUE,
  verbose = TRUE
)

lint_dir(
  path = ".",
  linters = NULL,
  open = TRUE,
  exclude_path = NULL,
  exclude_linters = NULL,
  use_cache = TRUE,
  verbose = TRUE
)

lint_package(
  path = ".",
  linters = NULL,
  open = TRUE,
  exclude_path = NULL,
  exclude_linters = NULL,
  use_cache = TRUE,
  verbose = TRUE
)

lint_text(text, linters = NULL, exclude_linters = NULL)
```

## Arguments

- path:

  A valid path to a file or a directory. Relative paths are accepted.
  Default is `"."`.

- linters:

  A character vector with the names of the rules to apply. See the
  entire list of rules with
  [`list_linters()`](https://flir.etiennebacher.com/reference/list_linters.md).
  If you have set up the `flir` folder with
  [`setup_flir()`](https://flir.etiennebacher.com/reference/setup_flir.md),
  you can also list the linters to use in the `keep` field of
  `flir/config.yml`. See
  [`setup_flir()`](https://flir.etiennebacher.com/reference/setup_flir.md)
  for more information.

- exclude_path:

  One or several paths that will be ignored from the `path` selection.

- exclude_linters:

  One or several linters that will not be checked. Values can be the
  names of linters (such as `"any_is_na"`) or its associated function,
  such as
  [`any_is_na_linter()`](https://flir.etiennebacher.com/reference/any_is_na_linter.md)
  (this is mostly for compatibility with `lintr`). If you have set up
  the `flir` folder with
  [`setup_flir()`](https://flir.etiennebacher.com/reference/setup_flir.md),
  you can also list the linters to exclude in the `exclude` field of
  `flir/config.yml`. See
  [`setup_flir()`](https://flir.etiennebacher.com/reference/setup_flir.md)
  for more information.

- open:

  If `TRUE` (default) and if this is used in the RStudio IDE, lints will
  be shown with markers.

- use_cache:

  Do not re-parse files that haven't changed since the last time this
  function ran.

- verbose:

  Show messages.

- text:

  Text to analyze.

## Value

A dataframe where each row is a lint. The columns show the text, its
location (both the position in the text and the file in which it was
found) and the severity.

## Ignoring lines

`flir` supports ignoring single lines of code with `# flir-ignore`. For
example, this will not warn:

    # flir-ignore
    any(duplicated(x))

However, this will warn for the second `any(duplicated())`:

    # flir-ignore
    any(duplicated(x))
    any(duplicated(y))

To ignore more than one line of code, use `# flir-ignore-start` and
`# flir-ignore-end`:

    # flir-ignore-start
    any(duplicated(x))
    any(duplicated(y))
    # flir-ignore-end

## Examples

``` r
# `lint_text()` is convenient to explore with a small example
lint_text("any(duplicated(rnorm(5)))")
#> ::warning file=/tmp/RtmpNLCGso/file18bb4423a23.R,line=1,col=1::file=/tmp/RtmpNLCGso/file18bb4423a23.R,line=1,col=1,[any(duplicated(rnorm(5)))] anyDuplicated(x, ...) > 0 is better than any(duplicated(x), ...).

lint_text("any(duplicated(rnorm(5)))
any(is.na(x))
")
#> ::warning file=/tmp/RtmpNLCGso/file18bb7fc09f26.R,line=1,col=1::file=/tmp/RtmpNLCGso/file18bb7fc09f26.R,line=1,col=1,[any(duplicated(rnorm(5)))] anyDuplicated(x, ...) > 0 is better than any(duplicated(x), ...).
#> ::warning file=/tmp/RtmpNLCGso/file18bb7fc09f26.R,line=2,col=1::file=/tmp/RtmpNLCGso/file18bb7fc09f26.R,line=2,col=1,[any(is.na(x))] anyNA(x) is better than any(is.na(x)).

# Setup for the example with `lint()`
destfile <- tempfile()
cat("
x = c(1, 2, 3)
any(duplicated(x), na.rm = TRUE)

any(duplicated(x))

if (any(is.na(x))) {
  TRUE
}

any(
  duplicated(x)
)", file = destfile)

lint(destfile)
#> ℹ Going to check 1 file.
#> ✔ Found 5 lints in 1 file.
#> ℹ 5 of them can be fixed automatically.
#> ::warning file=/tmp/RtmpNLCGso/file18bb71febdf1,line=2,col=1::file=/tmp/RtmpNLCGso/file18bb71febdf1,line=2,col=1,[x = c(1, 2, 3)] Use <-, not =, for assignment.
#> ::warning file=/tmp/RtmpNLCGso/file18bb71febdf1,line=3,col=1::file=/tmp/RtmpNLCGso/file18bb71febdf1,line=3,col=1,[any(duplicated(x), na.rm = TRUE)] anyDuplicated(x, ...) > 0 is better than any(duplicated(x), ...).
#> ::warning file=/tmp/RtmpNLCGso/file18bb71febdf1,line=5,col=1::file=/tmp/RtmpNLCGso/file18bb71febdf1,line=5,col=1,[any(duplicated(x))] anyDuplicated(x, ...) > 0 is better than any(duplicated(x), ...).
#> ::warning file=/tmp/RtmpNLCGso/file18bb71febdf1,line=7,col=5::file=/tmp/RtmpNLCGso/file18bb71febdf1,line=7,col=5,[any(is.na(x))] anyNA(x) is better than any(is.na(x)).
#> ::warning file=/tmp/RtmpNLCGso/file18bb71febdf1,line=11,col=1::file=/tmp/RtmpNLCGso/file18bb71febdf1,line=11,col=1,[any(
#>   duplicated(x)
#> )] anyDuplicated(x, ...) > 0 is better than any(duplicated(x), ...).
```
