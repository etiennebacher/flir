test_that("duplicate_argument_linter doesn't block allowed usages", {
  linter <- duplicate_argument_linter()

  expect_lint("fun(arg = 1)", NULL, linter)
  expect_lint("fun('arg' = 1)", NULL, linter)
  expect_lint("fun(`arg` = 1)", NULL, linter)
  expect_lint("'fun'(arg = 1)", NULL, linter)
  expect_lint("(function(x, y) x + y)(x = 1)", NULL, linter)
  expect_lint("dt[i = 1]", NULL, linter)
})

test_that("duplicate_argument_linter blocks disallowed usages", {
  linter <- duplicate_argument_linter()
  lint_msg <- "Avoid duplicate arguments in function calls."

  expect_lint("fun(arg = 1, arg = 2)", lint_msg, linter)
  expect_lint("fun(arg = 1, 'arg' = 2)", lint_msg, linter)
  # TODO
  # expect_lint("fun(arg = 1, `arg` = 2)", lint_msg, linter)
  expect_lint("'fun'(arg = 1, arg = 2)", lint_msg, linter)
  # TODO but looks quite rare
  # expect_lint("(function(x, y) x + y)(x = 1, x = 2)", lint_msg, linter)
  expect_lint("dt[i = 1, i = 2]", lint_msg, linter)

  expect_lint(
    trim_some(
      "
      list(
        var = 1,
        var = 2
      )
    "
    ),
    lint_msg,
    linter
  )
})

# test_that("duplicate_argument_linter respects except argument", {
#   linter_list <- duplicate_argument_linter(except = "list")
#   linter_all <- duplicate_argument_linter(except = character())
#
#   expect_lint(
#     "list(
#       var = 1,
#       var = 2
#     )",
#     NULL,
#     linter_list
#   )
#
#   expect_lint(
#     "(function(x, y) x + y)(x = 1)
#     list(var = 1, var = 2)",
#     NULL,
#     linter_list
#   )
#
#   expect_lint(
#     "fun(`
# ` = 1, `
# ` = 2)",
#     rex::rex("Avoid duplicate arguments in function calls."),
#     linter_all
#   )
#
#   expect_lint(
#     "function(arg = 1, arg = 1) {}",
#     rex::rex("Repeated formal argument 'arg'."),
#     linter_all
#   )
# })

test_that("doesn't lint duplicated arguments in allowed functions", {
  linter <- duplicate_argument_linter()

  expect_lint(
    "x %>%
     dplyr::mutate(
       col = a + b,
       col = col + d
     )",
    NULL,
    linter
  )

  expect_lint(
    "x %>%
     dplyr::transmute(
       col = a + b,
       col = col / 2.5
     )",
    NULL,
    linter
  )

  skip_if_not_r_version("4.1.0")
  expect_lint(
    "x |>
    dplyr::mutate(
      col = col |> str_replace('t', '') |> str_replace('\\\\s+$', 'xxx')
    )",
    NULL,
    linter
  )
})

test_that("interceding comments don't trip up logic", {
  linter <- duplicate_argument_linter()
  lint_msg <- "Avoid duplicate arguments"

  # comment before the EQ_SUB
  # actually this case "just works" even before #2402 since
  #   get_r_string() returns NA for both argument names
  expect_lint(
    trim_some(
      "
      fun(
        arg # xxx
        = 1,
        arg # yyy
        = 2
      )
    "
    ),
    lint_msg,
    linter
  )

  expect_lint(
    trim_some(
      "
      fun(
        arg # xxx
        = 1,
        arg = 2
      )
    "
    ),
    lint_msg,
    linter
  )

  expect_lint(
    trim_some(
      "
      fun(
        arg = 1,
        arg # yyy
        = 2
      )
    "
    ),
    lint_msg,
    linter
  )

  # comment after the EQ_SUB
  expect_lint(
    trim_some(
      "
      fun(
        arg = # xxx
        1,
        arg = # yyy
        2
      )
    "
    ),
    lint_msg,
    linter
  )

  expect_lint(
    trim_some(
      "
      fun(
        arg = # xxx
        1,
        arg = 2
      )
    "
    ),
    lint_msg,
    linter
  )

  expect_lint(
    trim_some(
      "
      fun(
        arg = 1,
        arg = # yyy
        2
      )
    "
    ),
    lint_msg,
    linter
  )

  # comment after the arg value
  expect_lint(
    trim_some(
      "
      fun(
        arg = 1 # xxx
        ,
        arg = 2 # yyy
      )
    "
    ),
    lint_msg,
    linter
  )

  expect_lint(
    trim_some(
      "
      fun(
        arg = 1 # xxx
        ,
        arg = 2
      )
    "
    ),
    lint_msg,
    linter
  )

  expect_lint(
    trim_some(
      "
      fun(
        arg = 1,
        arg = 2 # yyy
      )
    "
    ),
    lint_msg,
    linter
  )

  # comment after the OP-COMMA
  expect_lint(
    trim_some(
      "
      fun(
        arg = 1, # xxx
        arg = 2 # yyy
      )
    "
    ),
    lint_msg,
    linter
  )

  expect_lint(
    trim_some(
      "
      fun(
        arg = 1, # xxx
        arg = 2
      )
    "
    ),
    lint_msg,
    linter
  )
})

test_that("lints vectorize", {
  lint_msg <- "Avoid duplicate arguments"

  expect_equal(
    nrow(
      lint_text(
        "{
      c(a = 1, a = 2, a = 3)
      list(b = 1, b = 2, b = 3)
    }",
        linters = duplicate_argument_linter()
      )
    ),
    4
  )
})

test_that("do not block when argument values and argument names are duplicated", {
  linter <- duplicate_argument_linter()

  expect_lint("fun(arg = x, x = 1)", NULL, linter)
  expect_lint("intersect(names(a), names(b))", NULL, linter)
})
