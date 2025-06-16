test_that("flir-ignore works for a single line", {
  expect_lint("# flir-ignore\nany(duplicated(x))", NULL, NULL)
  expect_fix("# flir-ignore\nany(duplicated(x))", character(0))
})

test_that("flir-ignore: specific rules work", {
  expect_lint(
    "# flir-ignore: any_duplicated-1\nany(duplicated(x))",
    NULL,
    NULL
  )
  expect_fix(
    "# flir-ignore: any_duplicated-1\nany(duplicated(x))",
    character(0)
  )

  expect_lint(
    "# flir-ignore: any_na-1\nany(duplicated(x))",
    "anyDuplicated(x, ...) > 0 is better than any(duplicated(x), ...).",
    NULL
  )
})

test_that("also ignore lines that have # nolint for compatibility", {
  expect_lint("# nolint\nany(duplicated(x))", NULL, NULL)
  expect_fix("# nolint\nany(duplicated(x))", character(0))
})

test_that("flir-ignore doesn't ignore more than one line", {
  expect_lint(
    "# flir-ignore\nany(duplicated(x))\nany(duplicated(y))",
    "anyDuplicated(x, ...) > 0 is better than any(duplicated(x), ...).",
    NULL
  )
  expect_fix(
    "# flir-ignore\nany(duplicated(x))\nany(duplicated(y))",
    "# flir-ignore\nany(duplicated(x))\nanyDuplicated(y) > 0"
  )
})

test_that("flir-ignore-start and end work", {
  expect_lint(
    "# flir-ignore-start\nany(duplicated(x))\nany(duplicated(y))\n# flir-ignore-end",
    NULL,
    NULL
  )
  expect_fix(
    "# flir-ignore-start\nany(duplicated(x))\nany(duplicated(y))\n# flir-ignore-end",
    character(0)
  )
})

test_that("flir-ignore-start and end work with specific rule", {
  expect_lint(
    "# flir-ignore-start: any_duplicated-1\nany(duplicated(x))\nany(duplicated(y))\n# flir-ignore-end",
    NULL,
    NULL
  )
  expect_fix(
    "# flir-ignore-start: any_duplicated-1\nany(duplicated(x))\nany(duplicated(y))\n# flir-ignore-end",
    character(0)
  )

  expect_lint(
    "# flir-ignore-start: any_na-1\nany(duplicated(x))\nany(duplicated(y))\n# flir-ignore-end",
    "anyDuplicated(x, ...) > 0 is better than any(duplicated(x), ...).",
    NULL
  )
})

test_that("flir-ignore-start and end error if mismatch", {
  expect_snapshot(
    lint_text("# flir-ignore-start\nany(duplicated(x))\nany(duplicated(y))"),
    error = TRUE
  )

  expect_error(
    lint_text("any(duplicated(x))\nany(duplicated(y))\n# flir-ignore-end"),
    "Mismatch: the number of `start` patterns (0) and of `end` patterns (1) must be equal.",
    fixed = TRUE
  )
})
