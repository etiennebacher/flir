test_that("nested lints", {
  expect_snapshot(fix_text("any(duplicated(any(is.na(x))))"))
  expect_snapshot(fix_text("any(duplicated(any(is.na(x <- T))))"))

  # Examples from #60
  expect_snapshot(
    fix_text(
      "
expect_equal(
  anyDuplicated(x) > 0,
  FALSE
)"
    )
  )
  expect_snapshot(
    fix_text(
      "
test_that(
  'Formalist works',
  {
    expect_equal(
      anyDuplicated(x) > 0,
      FALSE
    )
  }
)"
    )
  )
  expect_snapshot(
    fix_text(
      "test_that('Formalist works',{expect_equal(anyDuplicated(x) > 0,FALSE)})"
    )
  )
})
