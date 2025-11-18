# Setup flir

This creates a `flir` folder that has multiple purposes. It contains:

- the file `config.yml` where you can define rules to keep or exclude,
  as well as rules defined in other packages. More on this below;

- the file `cache_file_state.rds`, which is used when `lint_*()` or
  `fix_*()` have `cache = TRUE`;

- an optional folder `rules/custom` where you can store your own rules.

This folder must live at the root of the project and cannot be renamed.

## Usage

``` r
setup_flir(path)
```

## Arguments

- path:

  Path to package or project root. If `NULL` (default), uses `"."`.

## Value

Imports files necessary for `flir` to work but doesn't return any value
in R.

## Details

The file `flir/config.yml` can contain three fields: `keep`, `exclude`,
and `from-package`.

`keep` and `exclude` are used to define the rules to keep or to exclude
when running `lint_*()` or `fix_*()`.

It is possible for other packages to create their own list of rules, for
instance to detect or replace deprecated functions. In `from-package`,
you can list package names where `flir` should look for additional
rules. By default, if you list package `foobar`, then all rules defined
in the package `foobar` will be used. To ignore some of those rules, you
can list `from-foobar-<rulename>` in the `exclude` field.

See the vignette [Sharing rules across
packages](https://flir.etiennebacher.com/articles/sharing_rules.html)
for more information.
