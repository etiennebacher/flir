test_that("literal_coercion_linter skips allowed usages", {
  linter <- literal_coercion_linter()

  # naive xpath includes the "_f0" here as a literal
  expect_lint('as.numeric(x$"_f0")', NULL, linter)
  expect_lint('as.numeric(x@"_f0")', NULL, linter)
  # only examine the first method for as.<type> methods
  expect_lint("as.character(as.Date(x), '%Y%m%d')", NULL, linter)

  # we are as yet agnostic on whether to prefer literals over coerced vectors
  expect_lint("as.integer(c(1, 2, 3))", NULL, linter)
  # even more ambiguous for character vectors like here, where quotes are much
  #   more awkward to type than a sequence of numbers
  expect_lint("as.character(c(1, 2, 3))", NULL, linter)
  # not possible to declare raw literals
  expect_lint("as.raw(c(1, 2, 3))", NULL, linter)
  # also not taking a stand on as.complex(0) vs. 0 + 0i
  expect_lint("as.complex(0)", NULL, linter)
  # ditto for as.integer(1e6) vs. 1000000L
  expect_lint("as.integer(1e6)", NULL, linter)
  # ditto for as.numeric(1:3) vs. c(1, 2, 3)
  expect_lint("as.numeric(1:3)", NULL, linter)
})

test_that("literal_coercion_linter skips allowed rlang usages", {
  linter <- literal_coercion_linter()

  expect_lint("int(1, 2.0, 3)", NULL, linter)
  expect_lint("chr('e', 'ab', 'xyz')", NULL, linter)
  expect_lint("lgl(0, 1)", NULL, linter)
  expect_lint("lgl(0L, 1)", NULL, linter)
  expect_lint("dbl(1.2, 1e5, 3L, 2E4)", NULL, linter)
  # make sure using namespace (`rlang::`) doesn't create problems
  expect_lint("rlang::int(1, 2, 3)", NULL, linter)
  # even if scalar, carve out exceptions for the following
  expect_lint("int(1.0e6)", NULL, linter)
})

test_that("literal_coercion_linter skips quoted keyword arguments", {
  expect_lint("as.numeric(foo('a' = 1))", NULL, literal_coercion_linter())
})

skip_if_not_installed("patrick")
skip_if_not_installed("tibble")
patrick::with_parameters_test_that(
  "literal_coercion_linter blocks simple disallowed usages",
  expect_lint(
    sprintf("as.%s(%s)", out_type, input),
    lint_msg,
    literal_coercion_linter()
  ),
  .cases = tibble::tribble(
    ~.test_name,
    ~out_type,
    ~input,
    ~lint_msg,
    "lgl, from int",
    "logical",
    "1L",
    "Use TRUE instead of as.logical(1L)",
    "lgl, from num",
    "logical",
    "1",
    "Use TRUE instead of as.logical(1)",
    "lgl, from chr",
    "logical",
    '"true"',
    'Use TRUE instead of as.logical("true")',
    "int, from num",
    "integer",
    "1",
    "Use 1L instead of as.integer(1)",
    "num, from num",
    "numeric",
    "1",
    "Use 1 instead of as.numeric(1)",
    "dbl, from num",
    "double",
    "1",
    "Use 1 instead of as.double(1)",
    # "chr, from num", "character", "1",      'Use "1" instead of as.character(1)',
    # "chr, from chr", "character", '"e"',    'Use "e" instead of as.character("e")',
    # "chr, from chr", "character", '"E"',    'Use "E" instead of as.character("E")',
    # affirmatively lint as.<type>(NA) should be NA_<type>_
    "int, from NA",
    "integer",
    "NA",
    "Use NA_integer_ instead of as.integer(NA)",
    "num, from NA",
    "numeric",
    "NA",
    "Use NA_real_ instead of as.numeric(NA)",
    "dbl, from NA",
    "double",
    "NA",
    "Use NA_real_ instead of as.double(NA)",
    "chr, from NA",
    "character",
    "NA",
    "Use NA_character_ instead of as.character(NA)"
  )
)

# TODO
# patrick::with_parameters_test_that(
#   "literal_coercion_linter blocks rlang disallowed usages",
#   expect_lint(
#     sprintf("%s(%s)", out_type, input),
#     lint_msg,
#     literal_coercion_linter()
#   ),
#   # even if `as.character(1)` works, `chr(1)` doesn't, so no corresponding test case
#   .cases = tibble::tribble(
#     ~.test_name,      ~out_type,    ~input, ~lint_msg,
#     "rlang::lgl",     "lgl",        "1L",   "Use TRUE instead of lgl(1L)",
#     "rlang::lgl[ns]", "rlang::lgl", "1L",   "Use TRUE instead of rlang::lgl(1L)",
#     "rlang::int",     "int",        "1.0",  "Use 1L instead of int(1.0)",
#     "rlang::dbl",     "dbl",        "1L",   "Use 1 instead of dbl(1L)",
#     "rlang::chr",     "chr",        '"e"',  'Use "e" instead of chr("e")',
#     "rlang::chr",     "chr",        '"E"',  'Use "E" instead of chr("E")'
#   )
# )

patrick::with_parameters_test_that(
  "literal_coercion_linter blocks simple disallowed usages",
  expect_snapshot(fix_text(sprintf("as.%s(%s)", out_type, input))),
  .cases = tibble::tribble(
    ~.test_name,
    ~out_type,
    ~input,
    ~lint_msg,
    "lgl, from int",
    "logical",
    "1L",
    "Use TRUE instead of as.logical(1L)",
    "lgl, from num",
    "logical",
    "1",
    "Use TRUE instead of as.logical(1)",
    "lgl, from chr",
    "logical",
    '"true"',
    'Use TRUE instead of as.logical("true")',
    "int, from num",
    "integer",
    "1",
    "Use 1L instead of as.integer(1)",
    "num, from num",
    "numeric",
    "1",
    "Use 1 instead of as.numeric(1)",
    "dbl, from num",
    "double",
    "1",
    "Use 1 instead of as.double(1)",
    # "chr, from num", "character", "1",      'Use "1" instead of as.character(1)',
    # "chr, from chr", "character", '"e"',    'Use "e" instead of as.character("e")',
    # "chr, from chr", "character", '"E"',    'Use "E" instead of as.character("E")',
    # affirmatively lint as.<type>(NA) should be NA_<type>_
    "int, from NA",
    "integer",
    "NA",
    "Use NA_integer_ instead of as.integer(NA)",
    "num, from NA",
    "numeric",
    "NA",
    "Use NA_real_ instead of as.numeric(NA)",
    "dbl, from NA",
    "double",
    "NA",
    "Use NA_real_ instead of as.double(NA)",
    "chr, from NA",
    "character",
    "NA",
    "Use NA_character_ instead of as.character(NA)"
  )
)
