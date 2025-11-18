# Adding new rules

``` r
library(flir, warn.conflicts = FALSE)
```

`flir` comes with an extensive set of rules taken from `lintr`, but if
necessary one can also extend it relatively easily. This will require
some knowledge of the Rust crate `ast-grep` to write. This crate has
great documentation on [creating new
rules](https://ast-grep.github.io/guide/pattern-syntax.html) so you
should start there.

In this vignette, our objective is to replace calls to
[`stop()`](https://rdrr.io/r/base/stop.html) by
[`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html), for
instance because we prefer the formatting of the output with the latter.

``` r
stop("this is an error")
#> Error: this is an error

rlang::abort("this is an error")
#> Error:
#> ! this is an error
```

## Step 1: setup

First, we need to set up `flir` using
[`setup_flir()`](https://flir.etiennebacher.com/reference/setup_flir.md).
This will create a `flir` folder that contains (among other things) a
`rules` folder where all rules are stored. This is divided between
`builtin` rules (that shouldn’t modified manually) and `custom` rules
(where we will store our custom rule).

Then, we can create the structure of a new rule by copying an existing
rule, say `flir/rules/builtin/any_is_na.yml` for instance. After
removing the stuff that is specific to this rule, we end up with this
structure:

``` yaml
id:
language: r
severity: warning
rule:
  pattern:
fix:
message:
```

## Step 2: start exploring

When we use [`stop()`](https://rdrr.io/r/base/stop.html), we can pass
multiple elements, like in
[`paste0()`](https://rdrr.io/r/base/paste.html):

``` r
n <- 10
stop("Got ", n, " values instead of 1.")
#> Error: Got 10 values instead of 1.
```

This is not possible with
[`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html), which
needs everything to be in the argument `message`, meaning that we need
to manually put all those elements in
[`paste0()`](https://rdrr.io/r/base/paste.html):

``` r
n <- 10
rlang::abort(paste0("Got ", n, " values instead of 1."))
#> Error:
#> ! Got 10 values instead of 1.
```

Therefore, we can look for the pattern `stop(...)` and replace it by
`rlang::abort(paste0(...))`. Capturing all elements in a pattern is done
with `$$$` and those elements can be used in the `fix` or `message`
arguments using by wrapping them in `~~`:

``` yaml
id: stop_abort-1
language: r
severity: warning
rule:
  pattern: stop($$$ELEMS)
fix: rlang::abort(paste0(~~ELEMS~~))
message: Use `rlang::abort()` instead of `stop()`.
```

After storing this rule in `flir/rules/custom/stop_abort.yml`, we can
call:

``` r
flir::lint_text(
  'stop("Got ", n, " values instead of 1.")',
  linters = "stop_abort"
)
```

Running our example with
[`lint_text()`](https://flir.etiennebacher.com/reference/lint.md) now
shows the message:

``` r
flir::lint_text(
  'stop("Got ", n, " values instead of 1.")',
  linters = "stop_abort"
)
#> Original code: stop("Got ", n, " values instead of 1.")
#> Suggestion: Use `rlang::abort()` instead of `stop()`.
#> Rule ID: stop_abort-1
```

And [`fix_text()`](https://flir.etiennebacher.com/reference/fix.md)
correctly applies the fix:

``` r
flir::fix_text(
  'stop("Got ", n, " values instead of 1.")',
  linters = "stop_abort"
)
#> Old code: stop("Got ", n, " values instead of 1.")
#> New code: rlang::abort(paste0("Got ", n, " values instead of 1."))
```

Note that there are still some corner cases to address, such as ignoring
the arguments `call.` and `domain` of
[`stop()`](https://rdrr.io/r/base/stop.html) if they are specified, but
this is not in the scope of this vignette.

## Step 3 (optional): add to config

To automatically use this new linter without having to specify it
manually, we can add it to `flir/config.yaml`:

``` yaml
keep:
  - any_duplicated
  [...]
  - unreachable_code
  - stop_abort
```

Running
[`lint_text()`](https://flir.etiennebacher.com/reference/lint.md) or
[`fix_text()`](https://flir.etiennebacher.com/reference/fix.md) without
`linters` now works:

``` r
flir::fix_text('stop("Got ", n, " values instead of 1.")')
#> Old code: stop("Got ", n, " values instead of 1.")
#> New code: rlang::abort(paste0("Got ", n, " values instead of 1."))
```

## Step 4: enjoy

The new linter is now set up, you can use `flir` as before to lint or
fix specific files or entire folders, e.g. `flir::fix_dir("R")`.
