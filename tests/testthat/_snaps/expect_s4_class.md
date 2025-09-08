# fix works

    Code
      fix_text("expect_true(is(x, 's4class'))", linters = linter)
    Output
      Old code: expect_true(is(x, 's4class')) 
      New code: expect_s4_class(x, 's4class') 

---

    Code
      fix_text("expect_true(methods::is(x, 's4class'))", linters = linter)
    Output
      Old code: expect_true(methods::is(x, 's4class')) 
      New code: expect_s4_class(x, 's4class') 

---

    Code
      fix_text("testthat::expect_true(is(x, 's4class'))", linters = linter)
    Output
      Old code: testthat::expect_true(is(x, 's4class')) 
      New code: testthat::expect_s4_class(x, 's4class') 

---

    Code
      fix_text("testthat::expect_true(methods::is(x, 's4class'))", linters = linter)
    Output
      Old code: testthat::expect_true(methods::is(x, 's4class')) 
      New code: testthat::expect_s4_class(x, 's4class') 

