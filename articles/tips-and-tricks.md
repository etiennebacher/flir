# Tips and tricks

The goal of this vignette is simply to record things that are nice to
know when using `flir` and that don’t really fit in other vignettes.

## Writing a fix on several lines

Suppose you have some code like this:

``` r
expect_error(
  my_super_function(with, some, parameters),
  "a very detailed error message"
)
```

Maybe you want to replace the pattern `expect_error(<code>, <message>)`
by `expect_snapshot(<code>, error = TRUE)` but you would like to keep
this code split on several lines. While `rule` will detect the pattern
whether it contains new lines or not, it is not possible to manually
include new lines with `\n` in `fix`.

Instead, we can write “paragraphs” in the YAML file, such as:

``` yaml
id: snapshot
language: r
severity: warning
rule:
  pattern: expect_error($CODE, $$$)
fix: |
  expect_snapshot(
    ~~CODE~~,
    error = TRUE
  )
message: ...
```

``` r
### Store the rule in a file
my_rule <- tempfile(fileext = ".yml")
cat("id: snapshot
language: r
severity: warning
rule:
  pattern: expect_error($CODE, $$$)
fix: |
  expect_snapshot(
    ~~CODE~~,
    error = TRUE
  )
message: ...",
file = my_rule
)

### Demo of the rule
fix_text('
expect_error(
  my_super_function(with, some, parameters),
  "a very detailed error message"
)
', linters = my_rule)
```

    ## Old code:
    ## expect_error(
    ##   my_super_function(with, some, parameters),
    ##   "a very detailed error message"
    ## )
    ## 
    ## New code:
    ## expect_snapshot(
    ##   my_super_function(with, some, parameters),
    ##   error = TRUE
    ## )
    ## 

## Detecting double and single quotes

By default, double and single quotes are considered different.
Therefore, if you have a rule like:

``` yaml
id: quotes
language: r
severity: warning
rule:
  pattern: my_function(value = "deprecated_value")
fix: my_function(value = "replacement_value")
message: ...
```

then it will replace occurrences with double quotes only:

``` r
### Store the rule in a file
my_rule <- tempfile(fileext = ".yml")
cat("id: quotes
language: r
severity: warning
rule:
  pattern: my_function(value = \"deprecated_value\")
fix: my_function(value = \"replacement_value\")
message: ...",
file = my_rule
)

### Works when code has double quotes
fix_text('my_function(value = "deprecated_value")', linters = my_rule)
```

    ## Old code: my_function(value = "deprecated_value") 
    ## New code: my_function(value = "replacement_value")

``` r
### Doesn't work when code has single quotes
fix_text("my_function(value = 'deprecated_value')", linters = my_rule)
```

To specify that this rule should be applied no matter the type of
quotes, we can use the `context` and `strictness` parameters in
`pattern`:

``` yaml
id: quotes
language: r
severity: warning
rule:
  pattern: 
    context: my_function(value = "deprecated_value")
    strictness: ast
fix: my_function(value = "replacement_value")
message: ...
```

``` r
### Store the rule in a file
my_rule <- tempfile(fileext = ".yml")
cat("id: quotes
language: r
severity: warning
rule:
  pattern: 
    context: my_function(value = \"deprecated_value\")
    strictness: ast
fix: my_function(value = \"replacement_value\")
message: ...",
file = my_rule
)

### Works when code has double quotes
fix_text('my_function(value = "deprecated_value")', linters = my_rule)
```

    ## Old code: my_function(value = "deprecated_value") 
    ## New code: my_function(value = "replacement_value")

``` r
### Works when code has single quotes
fix_text("my_function(value = 'deprecated_value')", linters = my_rule)
```

    ## Old code: my_function(value = 'deprecated_value') 
    ## New code: my_function(value = "replacement_value")

See the [ast-grep docs on
`strictness`](https://ast-grep.github.io/guide/rule-config/atomic-rule.html#strictness)
for more details.
