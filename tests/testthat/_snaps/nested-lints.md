# nested lints

    Code
      fix_text("any(duplicated(any(is.na(x))))")
    Output
      Old code: any(duplicated(any(is.na(x)))) 
      New code: anyDuplicated(anyNA(x)) > 0 

---

    Code
      fix_text("any(duplicated(any(is.na(x <- T))))")
    Output
      Old code: any(duplicated(any(is.na(x <- T)))) 
      New code: anyDuplicated(anyNA(x <- TRUE)) > 0 

---

    Code
      fix_text("\nexpect_equal(\n  anyDuplicated(x) > 0,\n  FALSE\n)")
    Output
      Old code:
      expect_equal(
        anyDuplicated(x) > 0,
        FALSE
      )
      
      New code:
      expect_false(anyDuplicated(x) > 0)

---

    Code
      fix_text(
        "\ntest_that(\n  'Formalist works',\n  {\n    expect_equal(\n      anyDuplicated(x) > 0,\n      FALSE\n    )\n  }\n)")
    Output
      Old code:
      test_that(
        'Formalist works',
        {
          expect_equal(
            anyDuplicated(x) > 0,
            FALSE
          )
        }
      )
      
      New code:
      test_that(
        'Formalist works',
        {
          expect_false(anyDuplicated(x) > 0)
        }
      )

---

    Code
      fix_text(
        "test_that('Formalist works',{expect_equal(anyDuplicated(x) > 0,FALSE)})")
    Output
      Old code: test_that('Formalist works',{expect_equal(anyDuplicated(x) > 0,FALSE)}) 
      New code: test_that('Formalist works',{expect_false(anyDuplicated(x) > 0)}) 

