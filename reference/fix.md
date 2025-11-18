# Automatically replace lints

`fix()`, `fix_package()`, and `fix_dir()` all replace lints in files.
The only difference is in the input they take:

- `fix()` takes path to files or directories

- `fix_dir()` takes a path to one directory

- `fix_package()` takes a path to the root of a package and looks at the
  following list of folders: `R`, `tests`, `inst`, `vignettes`,
  `data-raw`, `demo`, `exec`.

`fix_text()` takes some text input. Its main interest is to be able to
quickly experiment with some lints and fixes.

## Usage

``` r
fix(
  path,
  linters = NULL,
  exclude_path = NULL,
  exclude_linters = NULL,
  force = FALSE,
  verbose = TRUE,
  rerun = TRUE,
  interactive = FALSE
)

fix_dir(
  path,
  linters = NULL,
  exclude_path = NULL,
  exclude_linters = NULL,
  force = FALSE,
  verbose = TRUE,
  rerun = TRUE,
  interactive = FALSE
)

fix_package(
  path,
  linters = NULL,
  exclude_path = NULL,
  exclude_linters = NULL,
  force = FALSE,
  verbose = TRUE,
  rerun = TRUE,
  interactive = FALSE
)

fix_text(text, linters = NULL, exclude_linters = NULL, rerun = TRUE)
```

## Arguments

- path:

  A valid path to a file or a directory. Relative paths are accepted.
  Contrarily to
  [`lint()`](https://flir.etiennebacher.com/reference/lint.md) and its
  variants, this must be specified.

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

- force:

  Force the application of fixes on the files. This is used only in the
  case where Git is not detected, several files will be modified, and
  the code is run in a non-interactive setting.

- verbose:

  Show messages.

- rerun:

  Run the function several times until there are no more fixes to apply.
  This is useful in the case of nested lints. If `FALSE`, the function
  runs only once, potentially ignoring nested fixes.

- interactive:

  Opens a Shiny app that shows a visual diff of each modified file. This
  is particularly useful when you want to review the potential fixes
  before accepting them. Setting this to `TRUE` will disable the check
  on whether Git is used.

- text:

  Text to analyze (and to fix if necessary).

## Value

A list with as many elements as there are files to fix (in `fix_text()`,
the text is written to a temporary file).

Each element of the list contains the fixed text, where all fixes
available have been applied.

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
# `fix_text()` is convenient to explore with a small example
fix_text("any(duplicated(rnorm(5)))")
#> Old code: any(duplicated(rnorm(5))) 
#> New code: anyDuplicated(rnorm(5)) > 0 

fix_text("any(duplicated(rnorm(5)))
any(is.na(x))
")
#> Old code:
#> any(duplicated(rnorm(5)))
#> any(is.na(x))
#> 
#> New code:
#> anyDuplicated(rnorm(5)) > 0
#> anyNA(x)

# Setup for the example with `fix()`
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

fix(destfile)
#> ℹ Going to check 1 file.
#> ✔ Fixed 3 lints in 1 file.
cat(paste(readLines(destfile), collapse = "\n"))
#> 
#> x <- c(1, 2, 3)
#> anyDuplicated(x) > 0
#> 
#> anyDuplicated(x) > 0
#> 
#> if (anyNA(x)) {
#>   TRUE
#> }
#> 
#> anyDuplicated(x) > 0
```
