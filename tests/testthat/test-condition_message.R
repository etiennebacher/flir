test_that("condition_message_linter skips allowed usages", {
  linter <- condition_message_linter()

  expect_no_lint("stop('a string', 'another')", linter)
  expect_no_lint("warning('a string', 'another')", linter)
  expect_no_lint("message('a string', 'another')", linter)
  # extracted calls likely don't obey base::stop() semantics
  expect_no_lint("ctx$stop(paste0('a', 'b'))", linter)
  expect_no_lint("ctx@stop(paste0('a', 'b'))", linter)

  expect_no_lint("format_warning(paste0('a', 'b'))", linter)

  # sprintf is OK -- gettextf() enforcement is left to other linters
  expect_no_lint("stop(sprintf('A %s!', 'string'))", linter)

  # get multiple sep= in one expression
  expect_no_lint(
    trim_some(
      "
      tryCatch(
        foo(x),
        error = function(e) stop(paste0(a, b, recycle0 = TRUE)),
        warning = function(w) warning(paste0(a, b, recycle0 = TRUE)),
      )
    "
    ),
    linter
  )
})

skip_if_not_installed("tibble")
patrick::with_parameters_test_that(
  "paste/paste allowed by condition_message_linter when using other seps and/or collapse",
  expect_no_lint(
    sprintf("%s(%s(x, %s = '%s'))", condition, fun, parameter, arg),
    condition_message_linter()
  ),
  .cases = tibble::tribble(
    ~.test_name,
    ~condition,
    ~fun,
    ~parameter,
    ~arg,
    "stop, paste0 and collapse = ''",
    "stop",
    "paste0",
    "collapse",
    "",
    "warning, paste0 and collapse = '\n'",
    "warning",
    "paste0",
    "collapse",
    "\n",
    "message, paste0 and collapse = '|'",
    "message",
    "paste0",
    "collapse",
    "|",
    # "stop, paste and collapse = ''",      "stop",     "paste", "collapse",  "",
    # "warning, paste and collapse = '\n'", "warning",  "paste", "collapse",  "\n",
    # "message, paste and collapse = '|'",  "message",  "paste", "collapse",  "|",
    "stop, paste0 and recycle0 = '-'",
    "stop",
    "paste0",
    "recycle0",
    "TRUE",
    "warning, paste0 and recycle0 = '\n'",
    "warning",
    "paste0",
    "recycle0",
    "TRUE",
    "message, paste0 and recycle0 = '|'",
    "message",
    "paste0",
    "recycle0",
    "TRUE"
  )
)

test_that("do not block usage of paste()", {
  expect_no_lint(
    "stop(paste('a string', 'another'))",
    condition_message_linter()
  )
})

test_that("condition_message_linter blocks simple disallowed usages", {
  expect_lint(
    "stop(paste0('a string', 'another'))",
    "stop(paste0(...)) can be rewritten as stop(...).",
    condition_message_linter()
  )

  # TODO: `sep` argument should be linted if it has the default value
  # expect_lint(
  #   "stop(paste0(x, sep = ' '))",
  #   "can be rewritten as",
  #   condition_message_linter()
  # )

  # not thrown off by named arguments
  expect_lint(
    "stop(paste0('a', 'b'), call. = FALSE)",
    "can be rewritten as",
    condition_message_linter()
  )

  expect_lint(
    trim_some(
      "
      tryCatch(
        foo(x),
        error = function(e) stop(paste0(a, b)),
        warning = function(w) warning(paste0(a, b, sep = '--')),
      )
    "
    ),
    "can be rewritten as",
    condition_message_linter()
  )

  # one with no sep, one with linted sep
  expect_equal(
    nrow(
      lint_text(
        trim_some(
          "
      tryCatch(
        foo(x),
        error = function(e) stop(paste0(a, b)),
        warning = function(w) warning(paste0(a, b, recycle0 = TRUE)),
      )
    "
        ),
        linters = condition_message_linter()
      )
    ),
    1
  )
})

test_that("packageStartupMessage usages are also matched", {
  expect_lint(
    "packageStartupMessage(paste0('a string', 'another'))",
    "can be rewritten as",
    condition_message_linter()
  )

  expect_no_lint(
    "packageStartupMessage(paste('a string ', 'another'))",
    condition_message_linter()
  )
})

# test_that("R>=4.0.0 raw strings are handled", {
#   skip_if_not_r_version("4.0.0")
#   expect_lint(
#     "warning(paste0(a, b, sep = R'( )'))",
#     "Don't use paste0 to build warning strings.",
#     condition_message_linter()
#   )
#   expect_lint(
#     "warning(paste0(a, b, sep = R'---[ ]---'))",
#     "Don't use paste0 to build warning strings.",
#     condition_message_linter()
#   )
# })

test_that("fix works", {
  linter <- condition_message_linter()

  expect_snapshot(fix_text("stop(paste0('a', 'b'))", linters = linter))
  expect_snapshot(
    fix_text("stop(paste0('a', 'b', collapse = 'e'))", linters = linter)
  )
  expect_snapshot(
    fix_text("stop(paste0('a', 'b', recycle0 = 'e'))", linters = linter)
  )
  expect_snapshot(
    fix_text("stop(paste0('a', 'b'), call. = FALSE)", linters = linter)
  )
  expect_snapshot(
    fix_text("stop(paste0('a', 'b'), domain = FALSE)", linters = linter)
  )
  expect_snapshot(
    fix_text("stop(domain = FALSE, paste0('a', 'b'))", linters = linter)
  )

  expect_snapshot(fix_text("warning(paste0('a', 'b'))", linters = linter))
  expect_snapshot(
    fix_text("warning(paste0('a', 'b', collapse = 'e'))", linters = linter)
  )
  expect_snapshot(
    fix_text("warning(paste0('a', 'b', sep = 'e'))", linters = linter)
  )
  expect_snapshot(
    fix_text("warning(paste0('a', 'b'), immediate. = FALSE)", linters = linter)
  )
  expect_snapshot(
    fix_text("warning(immediate. = FALSE, paste0('a', 'b'))", linters = linter)
  )
})
